---
title: 'Forecasting NFL Player Motion: Kalman Filters, Residuals, and Inductive Bias'
date: 2025-10-06
permalink: /posts/2025/10/kalman-filter-nfl/
tags: 
  - bayesian modeling
  - monte carlo
  - sports data
---

We have a dataset of NFL player tracking coordinates: $$x_t, y_t$$ over time.  The goal is to **forecast** where each player will be a few frames ahead.  That’s the whole game: predict motion.

At first glance this sounds like a classic machine learning task — just feed it to a model, right? But there’s a strong prior already hiding in the data: players don’t teleport.  They move continuously, with bounded acceleration. They obey something close to physics. We can use a **Kalman filter** to formalize this model. 

## 1. The core idea

The Kalman filter dates back to 1960, originally used in aerospace navigation and control.  But at heart it’s a simple recursive algorithm for estimating a hidden state when both motion and measurements are noisy.

It does two things, over and over:

1. **Predict** what happens next using a motion model.  
2. **Correct** that prediction when a noisy measurement arrives.

That’s it. The math hides inside the update equations, but the idea is intuitive:  you carry forward what you think is happening, then nudge that belief toward the data.

## 2. The model

We’ll track each player with a state vector containing position and velocity:

$$
\mathbf{x}_t = 
\begin{pmatrix}
x_t \\
y_t \\
v_{x,t} \\
v_{y,t}
\end{pmatrix}.
$$

### Dynamics

We assume constant velocity plus Gaussian noise:

$$
\mathbf{x}_{t+1} = F \mathbf{x}_t + \mathbf{w}_t, \quad \mathbf{w}_t \sim \mathcal{N}(0, Q),
$$

where

$$
F =
\begin{pmatrix}
1 & 0 & \Delta t & 0 \\
0 & 1 & 0 & \Delta t \\
0 & 0 & 1 & 0 \\
0 & 0 & 0 & 1
\end{pmatrix}.
$$

The matrix $$Q$$ encodes uncertainty about acceleration: how much we expect velocity to change between frames.

### Measurements

We only observe positions, not velocities:

$$
\mathbf{z}_t = H \mathbf{x}_t + \mathbf{v}_t, \quad \mathbf{v}_t \sim \mathcal{N}(0, R),
$$

with

$$
H =
\begin{pmatrix}
1 & 0 & 0 & 0 \\
0 & 1 & 0 & 0
\end{pmatrix}.
$$

So $$R$$ is the measurement noise covariance — basically, how much we trust the observed tracking points.

## Deriving the Kalman Filter Update

We start in the linear–Gaussian world.  
At time \(t\), we have a latent state and a noisy observation:

$$
x_t \in \mathbb{R}^n, \qquad z_t \in \mathbb{R}^m.
$$

The model:

$$
x_t = F x_{t-1} + w_{t-1}, \qquad w_{t-1} \sim \mathcal{N}(0, Q),
$$

$$
z_t = H x_t + v_t, \qquad v_t \sim \mathcal{N}(0, R),
$$

and at the previous step, the posterior is Gaussian:

$$
p(x_{t-1} \mid z_{1:t-1}) = \mathcal{N}(\hat{x}_{t-1|t-1},\, P_{t-1|t-1}).
$$

---

### 1. Prediction (Time Update)

Propagate mean and covariance through the linear dynamics:

$$
\hat{x}_{t|t-1} = F \hat{x}_{t-1|t-1}, \qquad
P_{t|t-1} = F P_{t-1|t-1} F^\top + Q.
$$

That’s just pushing a Gaussian through an affine transformation.

---

### 2. Update (Measurement Correction)

By Bayes’ rule:

$$
p(x_t \mid z_{1:t}) \propto p(z_t \mid x_t)\,p(x_t \mid z_{1:t-1}).
$$

Take the negative log (up to constants):

$$
-\log p(x_t \mid z_{1:t}) =
\frac{1}{2}(z_t - Hx_t)^\top R^{-1}(z_t - Hx_t)
+ \frac{1}{2}(x_t - \hat{x}_{t|t-1})^\top P_{t|t-1}^{-1}(x_t - \hat{x}_{t|t-1}) + c.
$$

Expand and collect quadratic and linear terms in \(x_t\):

$$
-\log p(x_t \mid z_{1:t})
= \tfrac{1}{2}x_t^\top (H^\top R^{-1} H + P_{t|t-1}^{-1})x_t
- x_t^\top (H^\top R^{-1}z_t + P_{t|t-1}^{-1}\hat{x}_{t|t-1}) + c.
$$

So we can read off:

$$
P_{t|t}^{-1} = P_{t|t-1}^{-1} + H^\top R^{-1} H,
$$

$$
P_{t|t}^{-1}\hat{x}_{t|t} = P_{t|t-1}^{-1}\hat{x}_{t|t-1} + H^\top R^{-1} z_t.
$$

Multiply through by \(P_{t|t}\) and apply the **Woodbury identity**:

$$
(P_{t|t-1}^{-1} + H^\top R^{-1} H)^{-1}
= P_{t|t-1} - P_{t|t-1}H^\top(H P_{t|t-1} H^\top + R)^{-1}H P_{t|t-1}.
$$

---

### 3. Introducing the Innovation

Define:

$$
y_t = z_t - H \hat{x}_{t|t-1}, \qquad
S_t = H P_{t|t-1} H^\top + R, \qquad
K_t = P_{t|t-1} H^\top S_t^{-1}.
$$

Then the **posterior mean** is:

$$
\hat{x}_{t|t} = \hat{x}_{t|t-1} + K_t y_t,
$$

and the **posterior covariance** is:

$$
P_{t|t} = (I - K_t H) P_{t|t-1}.
$$

To preserve symmetry and positive semidefiniteness numerically, many implementations use the **Joseph form**:

$$
P_{t|t} = (I - K_t H) P_{t|t-1} (I - K_t H)^\top + K_t R K_t^\top.
$$

---

### 4. Conditioning View (Compact Proof)

An alternative is to view \((x_t, z_t)\) jointly as Gaussian:

$$
\begin{pmatrix} x_t \\ z_t \end{pmatrix}
\sim
\mathcal{N}\!\left(
\begin{pmatrix}
\hat{x}_{t|t-1} \\[4pt]
H \hat{x}_{t|t-1}
\end{pmatrix},
\begin{pmatrix}
P_{t|t-1} & P_{t|t-1}H^\top \\[4pt]
H P_{t|t-1} & H P_{t|t-1}H^\top + R
\end{pmatrix}
\right).
$$

Conditioning a joint Gaussian on \(z_t\) gives directly:

$$
\hat{x}_{t|t} = \hat{x}_{t|t-1} + P_{t|t-1}H^\top(H P_{t|t-1}H^\top + R)^{-1}(z_t - H \hat{x}_{t|t-1}),
$$

$$
P_{t|t} = P_{t|t-1} - P_{t|t-1}H^\top(H P_{t|t-1}H^\top + R)^{-1}H P_{t|t-1}.
$$

---

### 5. Summary

- **Predict**
  $$
  \hat{x}_{t|t-1} = F\hat{x}_{t-1|t-1}, \qquad
  P_{t|t-1} = F P_{t-1|t-1} F^\top + Q.
  $$

- **Update**
  $$
  y_t = z_t - H \hat{x}_{t|t-1}, \quad
  S_t = H P_{t|t-1} H^\top + R, \quad
  K_t = P_{t|t-1} H^\top S_t^{-1},
  $$
  $$
  \hat{x}_{t|t} = \hat{x}_{t|t-1} + K_t y_t, \qquad
  P_{t|t} = (I - K_t H) P_{t|t-1}.
  $$

### 6. Notes

- This derivation applies to any linear Gaussian system—constant velocity, constant acceleration, or higher-order motion.  
- Only \(F, Q, H, R\) change depending on how you model dynamics.
- The algebra is the same: Gaussian prior × Gaussian likelihood → Gaussian posterior.  
That’s the essence of the Kalman filter.

### 7. Conditioning View and the Schur Complement

The Kalman update can be seen as nothing more mysterious than the **conditional mean and covariance** of a joint Gaussian.  

Write the joint distribution of the predicted state and measurement as:

$$
\begin{pmatrix}
x_t \\[3pt] z_t
\end{pmatrix}
\sim
\mathcal{N}\!\left(
\begin{pmatrix}
\hat{x}_{t|t-1} \\[3pt] H \hat{x}_{t|t-1}
\end{pmatrix},
\begin{pmatrix}
P_{t|t-1} & P_{t|t-1} H^\top \\[3pt]
H P_{t|t-1} & H P_{t|t-1} H^\top + R
\end{pmatrix}
\right).
$$

Then conditioning on an observed \(z_t\) is a simple linear algebra fact:

$$
x_t \mid z_t \;\sim\;
\mathcal{N}\!\left(
\hat{x}_{t|t-1} + P_{t|t-1} H^\top (H P_{t|t-1} H^\top + R)^{-1}(z_t - H \hat{x}_{t|t-1}),
\;
P_{t|t-1} - P_{t|t-1} H^\top (H P_{t|t-1} H^\top + R)^{-1} H P_{t|t-1}
\right).
$$

The second term — the covariance update — is just the **Schur complement** of the measurement block in the joint covariance matrix:

$$
P_{t|t} = P_{t|t-1} - P_{t|t-1} H^\top (H P_{t|t-1} H^\top + R)^{-1} H P_{t|t-1}.
$$

In matrix algebra terms, this is:

$$
\Sigma_{xx|z} = \Sigma_{xx} - \Sigma_{xz}\Sigma_{zz}^{-1}\Sigma_{zx},
$$

the standard formula for the conditional covariance of a partitioned Gaussian.  
So the Kalman update isn’t “derived” as much as it’s *read off* from the blockwise inversion of a joint covariance matrix.

### 8. Geometric Interpretation

There’s a deeper way to see it.  

The Kalman filter performs an **orthogonal projection** in the geometry defined by the covariance (or precision) matrix.  
Each update step says:

> take the prior mean \( \hat{x}_{t|t-1} \),  
> move it as little as possible (in the Mahalanobis norm defined by \(P_{t|t-1}^{-1}\))  
> so that the measurement constraint \( Hx_t \approx z_t \) is satisfied up to noise \(R\).

Formally, it’s the minimizer of the quadratic cost

$$
J(x_t) =
(x_t - \hat{x}_{t|t-1})^\top P_{t|t-1}^{-1}(x_t - \hat{x}_{t|t-1})
+ (z_t - Hx_t)^\top R^{-1}(z_t - Hx_t).
$$

That’s exactly the **least-squares projection** of the prior estimate onto the affine subspace consistent with the new measurement.  
The Mahalanobis metric weights that projection according to your uncertainty.

So the update rule

$$
\hat{x}_{t|t} = \hat{x}_{t|t-1} + K_t (z_t - H \hat{x}_{t|t-1})
$$

is the closed-form solution to a **weighted orthogonal projection problem**.  
In that sense, the Kalman filter is the probabilistic version of a projection algorithm: it finds the closest state (in uncertainty-weighted distance) that aligns with the new observation.

---

## 4. Why it works so well

The filter is deceptively powerful. It encodes a handful of good assumptions:

- Motion is approximately linear over short windows.
- Errors are approximately Gaussian.
- Uncertainty accumulates over time.

That’s often *enough*.  You get smoother trajectories, less jitter, and short-horizon forecasts that behave physically — no teleporting receivers, no zigzagging defenders.

---

## 5. Where it fails (and what that tells us)

Of course, the constant-velocity model breaks down constantly.

Players cut, accelerate, stop, react. The model interprets that as noise, but it’s not random.  
If you look at the **residuals** — the difference between what the Kalman filter predicted and what actually happened —

$$
\Delta x_t = x_{t,\text{true}} - x_{t,\text{kalman}}, \qquad
\Delta y_t = y_{t,\text{true}} - y_{t,\text{kalman}},
$$

you’ll see clear patterns: receivers overshoot in the direction of the route, defenders lag slightly behind, then catch up, acceleration correlates with play direction and role.

The residuals are the signal of what the physics model misses — and that’s exactly what makes them learnable.

---

## 6. Learning the residuals

The next step is to learn those systematic errors.

You can collect many plays, compute residuals, and train a regression model (say, XGBoost) to predict them as a function of contextual features:

- Player role, side (offense/defense)
- Predicted velocity components
- Frame index or forecast horizon
- Absolute yardline, play direction
- Maybe even interactions between players later on

Formally:

$$
\widehat{\Delta x} = f(\text{features}), \quad \widehat{\Delta y} = g(\text{features}).
$$

Then you build a **hybrid model**:

$$
\hat{x}_{\text{hybrid}} = x_{\text{kalman}} + \widehat{\Delta x}, \qquad
\hat{y}_{\text{hybrid}} = y_{\text{kalman}} + \widehat{\Delta y}.
$$

The hybrid keeps the Kalman’s structure — smoothness, uncertainty, physical plausibility — but corrects its systematic bias using data.

---

## 7. Results and intuition

You can plot RMSE versus forecast horizon.  The picture is almost always the same:

- For horizons of 1–2 frames (≈0.1–0.2s), the Kalman filter alone is nearly optimal.  
- As you move to 5–10 frames (≈0.5–1s), errors from unmodeled acceleration dominate — and the hybrid wins.  
- Past a second, everything blows up; even the hybrid struggles.

This pattern mirrors how far your inductive bias carries you.  The Kalman filter is great for the linear regime; machine learning takes over when the manifold bends.


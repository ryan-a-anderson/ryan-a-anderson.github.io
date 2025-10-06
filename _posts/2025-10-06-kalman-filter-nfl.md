---
title: 'Forecasting NFL Player Motion: Kalman Filters, Residuals, and Inductive Bias'
date: 2025-10-06
permalink: /posts/2025/10/kalman-filter-nfl/
tags: 
  - bayesian modeling
  - monte carlo
  - sports data
---

We have a dataset of NFL player tracking coordinates: $$x_t, y_t$$ over time.  
The goal is to **forecast** where each player will be a few frames ahead.  
That’s the whole game: predict motion.

At first glance this sounds like a classic machine learning task — just feed it to a model, right? But there’s a strong prior already hiding in the data: players don’t teleport.  
They move continuously, with bounded acceleration. They obey something close to physics.

That’s what a **Kalman filter** formalizes. It’s an algorithm that says: *assume the world moves smoothly, then update your belief as you observe it.*

---

## 1. The core idea

The Kalman filter dates back to 1960, originally used in aerospace navigation and control.  
But at heart it’s a simple recursive algorithm for estimating a hidden state when both motion and measurements are noisy.

It does two things, over and over:

1. **Predict** what happens next using a motion model.  
2. **Correct** that prediction when a noisy measurement arrives.

That’s it. The math hides inside the update equations, but the idea is intuitive:  
you carry forward what you think is happening, then nudge that belief toward the data.

---

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

---

## 3. The recursion

The Kalman filter alternates between prediction and correction.

**Prediction:**

$$
\hat{\mathbf{x}}_{t|t-1} = F \hat{\mathbf{x}}_{t-1|t-1}, \qquad
P_{t|t-1} = F P_{t-1|t-1} F^\top + Q.
$$

**Update:**

$$
y_t = \mathbf{z}_t - H \hat{\mathbf{x}}_{t|t-1}, \qquad
S_t = H P_{t|t-1} H^\top + R,
$$

$$
K_t = P_{t|t-1} H^\top S_t^{-1}, \qquad
\hat{\mathbf{x}}_{t|t} = \hat{\mathbf{x}}_{t|t-1} + K_t y_t,
$$

$$
P_{t|t} = (I - K_t H) P_{t|t-1}.
$$

You repeat this for each frame.  
When you run out of data, you keep applying the predict step — that’s forecasting.

---

## 4. Why it works so well

The filter is deceptively powerful. It encodes a handful of good assumptions:

- Motion is approximately linear over short windows.
- Errors are approximately Gaussian.
- Uncertainty accumulates over time.

That’s often *enough*.  
You get smoother trajectories, less jitter, and short-horizon forecasts that behave physically — no teleporting receivers, no zigzagging defenders.

---

## 5. Where it fails (and what that tells us)

Of course, the constant-velocity model breaks down constantly.

Players cut, accelerate, stop, react. The model interprets that as noise, but it’s not random.  
If you look at the **residuals** — the difference between what the Kalman filter predicted and what actually happened —

$$
\Delta x_t = x_{t,\text{true}} - x_{t,\text{kalman}}, \qquad
\Delta y_t = y_{t,\text{true}} - y_{t,\text{kalman}},
$$

you’ll see clear patterns.

Receivers overshoot in the direction of the route.  
Defenders lag slightly behind, then catch up.  
Acceleration correlates with play direction and role.

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

You can plot RMSE versus forecast horizon.  
The picture is almost always the same:

- For horizons of 1–2 frames (≈0.1–0.2s), the Kalman filter alone is nearly optimal.  
- As you move to 5–10 frames (≈0.5–1s), errors from unmodeled acceleration dominate — and the hybrid wins.  
- Past a second, everything blows up; even the hybrid struggles.

This pattern mirrors how far your inductive bias carries you.  
The Kalman filter is great for the linear regime; machine learning takes over when the manifold bends.

---

## 8. Why this matters

What I like about this approach is that it doesn’t throw away structure.  
You start with a model that *believes* in continuity and inertia.  
Then you let data tell you how reality deviates.

It’s the same principle that underlies a lot of good modeling:  
geometry first, correction later.

In my rigidity work, I often think about how constraints define what’s possible.  
A Kalman filter is the same story: it defines a manifold of plausible motion, then projects noisy observations onto it.  
The residual model learns the flex — the ways the system bends while staying consistent with those constraints.

That’s where the interesting behavior lives.

---

**Code:** [link to your GitHub repo, if public]  
**Further reading:** Kalman (1960), Brown & Hwang (1997), Welch & Bishop (2006), and [Modeling a Prediction Game](https://ryan-a-anderson.github.io/posts/2024/12/modeling-a-prediction-game/).


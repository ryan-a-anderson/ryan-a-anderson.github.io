---
title: 'Forecasting NFL Player Motion: Kalman Filters, Residuals, and Inductive Bias'
date: 2025-10-06
permalink: /posts/2025/10/kalman-filter-nfl/
tags: 
  - bayesian modeling
  - monte carlo
  - sports data
---

When we track NFL players over time, we observe noisy positions \( (x_t, y_t) \).  
We’d like to **forecast** their future positions: not just smooth what we saw, but predict what’s coming next.  
In this post I’ll show how a **Kalman filter** can serve as a principled baseline — and how we can overlay a learned residual correction to capture “what the physics model misses.”

This is a story of **inductive structure + data correction** — something I often come back to in thinking about prediction and geometry.

---

## 1. Why Kalman? A bit of historical and conceptual grounding

The Kalman filter has a storied history (Joseph Kalman 1960), but its core is simple: given a *model of motion* and *noisy observations*, maintain a Gaussian belief over state and update it over time.  

- It embodies **Bayesian filtering** (predict-update) in linear–Gaussian settings.  
- It’s minimum-variance among linear estimators (i.e. it’s the optimal linear filter).  
- It naturally handles **uncertainty propagation**: you don’t just predict a point, you carry covariance.  
- It can **forecast ahead** — once you exhaust measurements, you keep applying the motion model to predict future states.

In many tracking pipelines — radar, navigation, robotics — it’s a default first-line tool. In sports analytics, it’s less common than deep nets, but it makes a compelling baseline: simple, interpretable, and rooted in kinematics.

---

## 2. Model setup: state, dynamics, and measurement models

### 2.1 The state vector and motion assumptions

I model each player’s instantaneous **state** as:

\[
\mathbf{x}_t = 
\begin{pmatrix}
x_t \\ y_t \\ v_{x,t} \\ v_{y,t}
\end{pmatrix},
\]

so that position + velocity is tracked. We assume **constant velocity + Gaussian noise**:

\[
\mathbf{x}_{t+1} = F \, \mathbf{x}_t + \mathbf{w}_t, \quad \mathbf{w}_t \sim \mathcal{N}(0, Q).
\]

Here

\[
F = \begin{pmatrix}
1 & 0 & \Delta t & 0 \\
0 & 1 & 0 & \Delta t \\
0 & 0 & 1 & 0 \\
0 & 0 & 0 & 1
\end{pmatrix},
\]

and \( Q \) is the *process noise covariance*, often taken as a block that models (uncorrelated) acceleration variance. The intuition: we don’t expect perfectly constant velocity — players accelerate, decelerate, but within limits.

### 2.2 Observations and measurement noise

We **observe only positions**:

\[
\mathbf{z}_t = H \, \mathbf{x}_t + \mathbf{v}_t, \quad \mathbf{v}_t \sim \mathcal{N}(0, R),
\]

with

\[
H = \begin{pmatrix}
1 & 0 & 0 & 0 \\
0 & 1 & 0 & 0
\end{pmatrix}.
\]

Thus the measurement noise covariance \( R \) encodes how confident we are in the raw tracking positions. If vision tracking is jittery, \( R \) is large; if it’s smooth, \( R \) is small.

### 2.3 Initialization

We need an initial prior \((\hat{\mathbf{x}}_0, P_0)\).  
A typical strategy:

- Use the first two observed frames to approximate initial velocity:
  \[
  v_{x,0} \approx \frac{x_1 - x_0}{\Delta t}, \quad v_{y,0} \approx \frac{y_1 - y_0}{\Delta t}.
  \]
- Set \(P_0 = \operatorname{diag}(\sigma_x^2, \sigma_y^2, \sigma_{v_x}^2, \sigma_{v_y}^2)\) with suitably large variances to reflect uncertainty.

---

## 3. The Kalman filter algorithm

At each time step:

1. **Prediction**  
   \[
   \hat{\mathbf{x}}_{t|t-1} = F \, \hat{\mathbf{x}}_{t-1|t-1}, \qquad
   P_{t|t-1} = F P_{t-1|t-1} F^\top + Q.
   \]

2. **Update** (if we have measurement \( \mathbf{z}_t \))  
   \[
   y_t = \mathbf{z}_t - H\,\hat{\mathbf{x}}_{t|t-1}, \quad
   S = H\,P_{t|t-1}\,H^\top + R, \quad
   K = P_{t|t-1} H^\top S^{-1}
   \]
   \[
   \hat{\mathbf{x}}_{t|t} = \hat{\mathbf{x}}_{t|t-1} + K\,y_t, \qquad
   P_{t|t} = (I - K H)\,P_{t|t-1}.
   \]

If there’s no measurement (e.g. during forecasting), you skip the update and just carry the prediction forward.

Over time, the filter smooths out measurement jitter, fills in short gaps, and maintains a belief over velocity.

---

## 4. Forecasting: extending into the future

Once the measurement window ends (you run out of observed frames), you can keep applying the **predict** step:

\[
\hat{\mathbf{x}}_{t+1|T} = F\,\hat{\mathbf{x}}_{t|T}, \quad
P_{t+1|T} = F\,P_{t|T}\,F^\top + Q.
\]

These are your forecasts for \( x,y \) (and velocity) into unseen frames.  
Naturally, uncertainty grows as you go further out.  
The covariance \( P \) tells you how “sure” the model is at each forecast step.

---

## 5. But Kalman isn’t magic (and you’ll see where it errs)

The constant-velocity assumption is just an approximation. In real NFL motion:

- Players accelerate or decelerate (not constant velocity).
- They change direction sharply (cuts, pivots).  
- They react to other players, plays, blocking schemes, defensive pressure.

Those deviations show up in **residuals**:

\[
\Delta x_t = x_{\text{true}, t} - x_{\text{kalman}, t}, \qquad
\Delta y_t = y_{\text{true}, t} - y_{\text{kalman}, t}.
\]

The residuals are **not noise** — not wholly random — but structured, informed by role, play progression, direction changes, and anticipation.

It’s precisely those *predictable deviations* that the Kalman model misses that we can attempt to learn.

---

## 6. Residual learning: marrying physics + ML

Here’s the recipe:

1. Run the Kalman filter + forecasting on many plays, producing per-frame predictions and residuals \((\Delta x, \Delta y)\).
2. Engineer features that might explain the residuals:
   - Forecast horizon (how far ahead you are)
   - Player side / position / role
   - Predicted velocities \( v_x, v_y \)
   - Frame index, play direction
   - Field-level features (yardline, ball landing position, etc.)
3. Train two regression models (e.g. XGBoost) to predict \(\Delta x\) and \(\Delta y\) from those features.
4. During inference, for each forecasted point:
   \[
   \hat{x}_{\text{hybrid}} = x_{\text{kalman}} + \widehat{\Delta x}, \qquad
   \hat{y}_{\text{hybrid}} = y_{\text{kalman}} + \widehat{\Delta y}.
   \]

This hybrid approach *retains the smooth structure and uncertainty reasoning of Kalman*, but allows **data-driven correction** for non-linear motion.

One virtue: because you start from a structured prior (Kalman), the residual model only needs to learn the *departure* — not the whole motion.

---

## 7. Code sketch (conceptual)

```python
# After running Kalman and obtaining predictions & actuals:
df["residual_x"] = df.actual_x - df.predicted_x
df["residual_y"] = df.actual_y - df.predicted_y

# Feature engineering:
df = add_prediction_features(df, dt)  # yields predicted_vx, predicted_vy
# plus features like frame_id, horizon, side, role, etc.

X = encode_features(df, spec=FeatureSpec)
model_x = XGBRegressor(...).fit(X, df["residual_x"])
model_y = XGBRegressor(...).fit(X, df["residual_y"])

# In inference loop:
resid_pred = model_x.predict(X_inf)
df_inf["predicted_x_hybrid"] = df_inf["predicted_x"] + resid_pred

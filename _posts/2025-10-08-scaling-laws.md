---
title: "What Is a Scaling Law? From OLS to Transformers"
date: 2025-10-08
author: "Ryan A. Anderson"
tags:
  - scaling laws
  - linear models
  - deep learning
  - sample complexity
  - compute
---

People say a model “**scales**” when the loss keeps dropping predictably as you feed it more data, parameters, or compute. Below we describe a story of how scaling laws were developed in the past 8 years or so:

1) start with a **linear model** we can analyze to the end;  
2) translate that lens to **power-law** behavior in modern models;  
3) show how to **trade off** parameters vs. data for a target loss;  
4) derive the **compute-optimal** balance (the “Chinchilla-ish” result).

---

## Part I — A clean derivation in the linear world

Consider OLS with $D$ data points and $N$ features:
$$
y_i = x_i^\top \theta^* + \varepsilon_i,\qquad
\varepsilon_i \stackrel{iid}{\sim}\mathcal N(0,\sigma^2),\qquad
X\in\mathbb R^{D\times N},\quad
\hat\theta = (X^\top X)^{-1}X^\top y.
$$

We care about **generalization** on a fresh point $x_{\text{test}}\sim \mathcal N(0,\Sigma)$,
with $y_{\text{test}} = x_{\text{test}}^\top \theta^\* + \varepsilon_{\text{test}}, \varepsilon_{\text{test}}\sim\mathcal N(0,\sigma^2)$.
Define $\hat y = x_{\text{test}}^\top\hat\theta$.
We want $\mathbb E[(y_{\text{test}}-\hat y)^2]$, averaging over both $X$ and $x_{\text{test}}$.

**Step 1 (condition on $X,x_{\text{test}}$).**
OLS is unbiased given $X$ and
$\operatorname{Var}(\hat\theta\mid X)=\sigma^2 (X^\top X)^{-1}$, so
$$
\mathbb E\!\left[(\hat y-y_{\text{test}})^2\mid X,x_{\text{test}}\right]
= \sigma^2\!\left(1 + x_{\text{test}}^\top (X^\top X)^{-1} x_{\text{test}}\right).
$$

**Step 2 (average over $x_{\text{test}}$).**
Using $\mathbb E[x^\top A x] = \operatorname{tr}(A\Sigma)$ for $x\sim\mathcal N(0,\Sigma)$,
$$
\mathbb E\!\left[(\hat y-y_{\text{test}})^2\mid X\right]
= \sigma^2\!\left(1 + \operatorname{tr}\big((X^\top X)^{-1}\Sigma\big)\right).
$$

**Step 3 (average over $X$).**
Let $X=Z\Sigma^{1/2}$ with $Z_{ij}\sim\mathcal N(0,1)$. Then
$(X^\top X)^{-1}=\Sigma^{-1/2}(Z^\top Z)^{-1}\Sigma^{-1/2}$ and
$\operatorname{tr}((X^\top X)^{-1}\Sigma)=\operatorname{tr}((Z^\top Z)^{-1})$.
With $Z^\top Z\sim \text{Wishart}_N(I,D)$ and $D>N+1$,
$$
\mathbb E\!\left[\operatorname{tr}((Z^\top Z)^{-1})\right]=\frac{N}{D-N-1}.
$$

**Put together:**
$$
\boxed{
\mathbb E\!\left[(y_{\text{test}}-\hat y)^2\right]
= \sigma^2\!\left(1+\frac{N}{D-N-1}\right),\quad D>N+1.
}
$$

Two things drop out immediately:

- **Scaling in $D$.** For fixed $N$, the *excess* error above noise is
  $$\mathbb E[(y_{\text{test}}-\hat y)^2]-\sigma^2 \;=\; \sigma^2\,\frac{N}{D-N-1} \;\sim\; \sigma^2\,\frac{N}{D}.$$
  That “$\sim 1/D$” decay is the first, simplest **scaling law**.
- **Samples needed for a target error.** If $E_\star$ is your target test MSE, let
  $\rho \equiv E_\star/\sigma^2 - 1>0$. Then
  $$\rho=\frac{N}{D-N-1}\;\Longrightarrow\; D = N+1+\frac{N}{\rho}\;\approx\; N\!\left(1+\frac{1}{\rho}\right).$$

> **Regime change warning.** As $D\downarrow N{+}1$ the denominator shrinks and the error spikes (ill-conditioning). Regularization tames this. In highly over-parameterized regimes one often sees **double descent**: behavior improves again beyond the interpolation threshold when using the minimum-norm interpolant.

---

## Part II — What “scaling laws” mean for modern models

In deep learning we often fit **empirical power laws** for the test loss:
$$
L(N,D) \approx L^\* + c_N\,N^{-\alpha} + c_D\,D^{-\beta}.
$$

- $L^\*$ is a **Bayes/irreducible floor** (you can’t beat it without changing the task/data).
- The **approximation** term $c_N N^{-\alpha}$ reflects model capacity & architecture.
- The **estimation** term $c_D D^{-\beta}$ reflects data coverage, optimization noise, etc.

This mirrors OLS conceptually—noise floor + (something that shrinks with data) + (something that shrinks with capacity)—but the exponents $\alpha,\beta$ and constants $c_N,c_D$ are **empirical** and **setup-dependent**.

A few immediate consequences (and these are useful in practice):

- **Iso-loss tradeoff (fixed target loss).** For a target $L_{\text{target}}>L^\*$,
  $$c_N N^{-\alpha} + c_D D^{-\beta} = L_{\text{target}}-L^\* \;\equiv\; \Delta.$$
  Given $N$, the required data is
  $$D(N) = \left(\frac{\Delta - c_N N^{-\alpha}}{c_D}\right)^{-1/\beta},\quad \Delta>c_N N^{-\alpha}.$$
  These curves are your **“how much more data do I need if I double parameters?”** plots.

- **Marginal returns.** The slopes $ \partial L/\partial \log N = -\alpha c_N N^{-\alpha}$ and
  $ \partial L/\partial \log D = -\beta c_D D^{-\beta}$ tell you where more bang-for-buck lives right now (bigger magnitude = better).

---

## Part III — Compute-optimal allocation (the Chinchilla-type result)

Training a transformer-like model costs roughly proportional to **parameters × tokens**,
so let a budget constraint be $ \text{Compute} \propto N D = B $.
Then we’d like to **minimize** the power-law loss subject to that budget:
$$
\min_{N,D>0}\; c_N N^{-\alpha} + c_D D^{-\beta}
\quad \text{s.t.}\quad N D = B.
$$

Use a Lagrange multiplier $ \lambda $ for the constraint:
\[
\mathcal L = c_N N^{-\alpha} + c_D D^{-\beta} + \lambda(ND - B).
\]
First-order conditions:
\[
-\alpha c_N N^{-\alpha-1} + \lambda D = 0,
\qquad
-\beta c_D D^{-\beta-1} + \lambda N = 0.
\]

Eliminate $ \lambda $:
\[
\alpha c_N N^{-\alpha-1}/D \;=\; \beta c_D D^{-\beta-1}/N
\;\Longrightarrow\;
\boxed{\;\alpha c_N\,N^{-\alpha} \;=\; \beta c_D\,D^{-\beta}\;}
\]
(“balance the two error terms at optimum”).

Write $ D = k\,N^{\alpha/\beta} $ with $ k = \big(\tfrac{\beta c_D}{\alpha c_N}\big)^{1/\beta} $.
Combine with $ N D = B $ to solve:
\[
N^\* \;=\; \Big(\frac{B}{k}\Big)^{\frac{\beta}{\alpha+\beta}},
\qquad
D^\* \;=\; k^{\frac{\beta}{\alpha+\beta}}\, B^{\frac{\alpha}{\alpha+\beta}}.
\]

**Interpretation.**
- If $\alpha \approx \beta$, both $N^\*$ and $D^\*$ scale like $B^{1/2}$: **“scale data and parameters together.”**
- If $\alpha > \beta$ (capacity helps faster), spend relatively **more** on $N$.
- If $\beta > \alpha$ (data helps faster), spend relatively **more** on $D$.
- The **ratio at optimum** is fixed by the constants:
  \[
  \frac{c_N N^{-\alpha}}{c_D D^{-\beta}} = \frac{\beta}{\alpha}
  \quad\Longrightarrow\quad
  \text{at the optimum, the two error terms contribute in proportion } \beta:\alpha.
  \]

This is the algebraic core behind the “Chinchilla”-style guidance. Once you have empirical $(\alpha,\beta,c_N,c_D)$ for your setup, these formulas tell you how to **rebalance** model size and dataset size under a fixed training budget.

---

## Part IV — A few regime changes & limits you should expect

- **Ill-conditioning & double descent (linear intuition).** When $D$ approaches $N$, OLS variance blows up; with over-parameterization and minimum-norm solutions, loss can improve again (double descent). In deep nets, you see **bends** and **breaks** in scaling curves when you cross analogous regime boundaries (optimization, regularization, context length).

- **Data quality changes the “constants.”** Even if $\alpha,\beta$ look stable, swapping data mixtures, tokenizers, dedup strategies, or cleaning pipelines often moves $c_N,c_D$ substantially—shifting the whole scaling surface.

- **Synthetic data & feedback loops.** As the fraction of model-generated data grows, observed exponents may **flatten** (plateaus) and the additive form itself can **degrade**. Watch your scaling plots over training; regime changes are the signal.

---

## Part V — Training vs. inference “scaling”

The budgeted tradeoff above is about **training**. For **inference**, the constraint is different (latency, memory, tokens at query time). In many workloads, you get more utility from **smaller models used more/longer** (e.g., longer contexts, reranking, or multi-step inference) than from a single pass through a huge model. The math is the same—just swap the constraint to your inference budget and re-solve.

---

## Cheat sheet (copy/paste)

- **OLS test MSE (random design):**
  $$
  \mathbb E[(y_{\text{test}}-\hat y)^2]
  = \sigma^2\!\left(1+\frac{N}{D-N-1}\right),\quad D>N+1.
  $$
- **Samples needed for target test MSE $E_\star$:**
  $ \rho \equiv E_\star/\sigma^2 - 1 \Rightarrow D = N+1+N/\rho $.
- **Power-law fit (empirical):** $ L(N,D) \approx L^\* + c_N N^{-\alpha} + c_D D^{-\beta} $.
- **Iso-loss curve:** for target $ \Delta=L_{\text{target}}-L^\*>0 $,
  $ D(N) = \big( \tfrac{\Delta - c_N N^{-\alpha}}{c_D} \big)^{-1/\beta} $.
- **Compute-optimal (budget $ND=B$):**
  \[
  N^\* = \Big(\frac{B}{k}\Big)^{\frac{\beta}{\alpha+\beta}},\quad
  D^\* = k^{\frac{\beta}{\alpha+\beta}} B^{\frac{\alpha}{\alpha+\beta}},\quad
  k = \Big(\frac{\beta c_D}{\alpha c_N}\Big)^{1/\beta},\quad
  \alpha c_N N^{-\alpha} = \beta c_D D^{-\beta}.
  \]

---

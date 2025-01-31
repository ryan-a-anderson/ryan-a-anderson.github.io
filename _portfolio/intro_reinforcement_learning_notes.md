---
title: "Introduction to Reinforcement Learning Notes"
author: "Ryan Anderson"
date: '2025-01-06'
layout: single
output: html_document
---

Reinforcement learning is a paradigm of statistical learning which is distinguished from supervised and unsupervised learning. 
In RL, an agent interacts with an unknown environment and aims to maximize the total rewards it obtains from interacting with the environment.

Note that in this note I will use $X \sim N(\mu, \sigma)$ for math mode.

## Policy Evaluation via the Temporal Difference Algorithm

Recall that we start with the Bellman equation for the value function: $V^{\pi} = r^{\pi} + \gamma P^{\pi}V^{\pi}$.

We want to solve this by casting the Bellman equation as the derivative of a representation of the value function, so that we have $\frac{d}{dt}V(t) = r^{\pi} + (\gamma P^{\pi} - I)V(t)$.

Then we do a quick Taylor expansion:\
$$V(t+\delta t) \simeq V(t) = \delta t \left( r^{\pi} + \gamma \mathbb{E}[V(t+\delta t) \| V(t)] - V(t) \right)$$

The key here is that $V(S_{t+1})$ is an unbiased estimate for $\mathbb{E}[V(t+\delta t) \| V(t)]$, since we arrive at $V(S_{t+1})$ by transitioning under $P^{\pi}$ and then taking the action specified by the policy, moving us to the next step of the rollout.

Then the _temporal difference (TD) algorithm_ obtains the successive approximations to $V(S_t)$ via:\
$$V_{n+1}(S_t) = V_n(S_t) + \alpha_t\left( r_t + \gamma V_n(S_{t+1}) - V_n(S_t) \right)$$

The TD algorithm is an example of a _stochastic approximation algorithm_. Stochastic gradient descent works similarly. It's based on the idea that we can approximate a continuous ODE by taking advantage of an unbiased estimate for the term within the Taylor expansion:\
$$\dot{X}(t) = h(X(t)) \rightarrow X_{n+1} = X_n + \alpha_n (h(X_n) + M_{n+1}), \mathbb{E}[M_{n+1} | X_n] = 0$$.

Stochastic approximation has some requirements on each of the components to guarantee convergence. The most basic result is due to Robbins-Monro (1951):
1. $h$ must be $L$-Lipschitz
2. $x_{final}$ is a stable equilibrium
3. $\sum \alpha_n = \infty$ but $\sum \alpha_n^2 < \infty$
4. We want the $M$ term to be independent of the data at stage n and also to always have bounded variance, i.e. $\exists k \rightarrow \mathbb{E}[\|M_{n+1}\|^2 \| X_n] \leq k(1+\|X_n\|^2)$
5. $\sup \|X_n\| < \infty$

For the TD algorithm, the first four of these are trivial -- as an example, our Lipschitz bound ends up being the $L_{\infty}$ norm of the matrix term $(\gamma P^{\pi} - I)$.

## Policy Iteration via the Every Visit Monte Carlo Method
Consider the formula for the value of a policy in a state:\
$$V(s) = \mathbb{E}[r(s_t)+\gamma V(s_{t+1}\|s_t = s]$$

Note that we can expand this via successive steps of the rollout:\
$$V(s) = \mathbb{E}[r(s_t)+\gamma V(s_{t+1})\|s_t = s] = \mathbb{E}[r(s_t)+\gamma r(s_{t+1})+\gamma^2 V(s_{t+2})\|s_t = s]$$.

Let $G^k_t = r(s_t)+\gamma r(s_{t+1})+ \dots + \gamma^k V(s_{t+k})$. Then we can contrast different temporal difference algorithms via considering the number of rollout steps performed at each iteration. TD(1) will be the algorithm given by $V_{n+1}(S_t) = V_n(S_t) + \alpha_n G_t^1$.





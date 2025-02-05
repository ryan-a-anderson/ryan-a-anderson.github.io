---
title: "Introduction to Reinforcement Learning Notes"
author: "Ryan Anderson"
date: '2025-01-06'
layout: single
output: html_document
---

# Table of Contents
- [Lecture 1/30: Algorithms for Policy Evalation](#lecture-130-algorithms-for-policy-evalation)
  - [Policy Evaluation via the Temporal Difference Algorithm](#policy-evaluation-via-the-temporal-difference-algorithm)
  - [Policy Iteration via the Every Visit Monte Carlo Method](#policy-iteration-via-the-every-visit-monte-carlo-method)
- [Lecture 2/5: More on Policy Evaluation](#lecture-25-more-on-policy-evaluation)
  - [Convergence of Policy Evaluation](#convergence-of-policy-evaluation)

Reinforcement learning is a paradigm of statistical learning which is distinguished from supervised and unsupervised learning. 
In RL, an agent interacts with an unknown environment and aims to maximize the total rewards it obtains from interacting with the environment.

Note that in this note I will use $X \sim N(\mu, \sigma)$ for math mode.

## Lecture 1/30: Algorithms for Policy Evalation
### Policy Evaluation via the Temporal Difference Algorithm

Recall that we start with the Bellman equation for the value function: $V^{\pi} = r^{\pi} + \gamma P^{\pi}V^{\pi}$.

We want to solve this by casting the Bellman equation as the derivative of a representation of the value function, so that we have $\frac{d}{dt}V(t) = r^{\pi} + (\gamma P^{\pi} - I)V(t)$.

Then we do a quick Taylor expansion:\
$$V(t+\delta t) \simeq V(t) = \delta t \left( r^{\pi} + \gamma \mathbb{E}[V(t+\delta t) \| V(t)] - V(t) \right)$$

The key here is that $V(S_{t+1})$ is an unbiased estimate for $\mathbb{E}[V(t+\delta t) \| V(t)]$, since we arrive at $V(S_{t+1})$ by transitioning under $P^{\pi}$ and then taking the action specified by the policy, moving us to the next step of the rollout.

Then the _temporal difference (TD) algorithm_ obtains the successive approximations to $V(S_t)$ via:\
$$V_{n+1}(S_t) = V_n(S_t) + \alpha_t\left( r_t + \gamma V_n(S_{t+1}) - V_n(S_t) \right)$$

The TD algorithm is an example of a _stochastic approximation algorithm_. Stochastic gradient descent works similarly. It's based on the idea that we can approximate a continuous ODE by taking advantage of an unbiased estimate for the term within the Taylor expansion:\
$$\dot{X}(t) = h(X(t)) \rightarrow X_{n+1} = X_n + \alpha_n (h(X_n) + M_{n+1}), \mathbb{E}[M_{n+1} | X_n] = 0$$.

Stochastic approximation has some requirements on each of the components to guarantee convergence. The most basic result is due to [Robbins-Monro (1951)](https://projecteuclid.org/journals/annals-of-mathematical-statistics/volume-22/issue-3/A-Stochastic-Approximation-Method/10.1214/aoms/1177729586.full):
1. $h$ must be $L$-Lipschitz
2. $x_{final}$ is a stable equilibrium
3. $\sum \alpha_n = \infty$ but $\sum \alpha_n^2 < \infty$
4. We want the $M$ term to be independent of the data at stage n and also to always have bounded variance, i.e. $\exists k \rightarrow \mathbb{E}[\|M_{n+1}\|^2 \| X_n] \leq k(1+\|X_n\|^2)$
5. $\sup \|X_n\| < \infty$

For the TD algorithm, the first four of these are trivial -- as an example, our Lipschitz bound ends up being the $L_{\infty}$ norm of the matrix term $(\gamma P^{\pi} - I)$.

### Policy Iteration via the Every Visit Monte Carlo Method
Consider the formula for the value of a policy in a state:\
$$V(s) = \mathbb{E}[r(s_t)+\gamma V(s_{t+1}\|s_t = s]$$

Note that we can expand this via successive steps of the rollout:\
$$V(s) = \mathbb{E}[r(s_t)+\gamma V(s_{t+1})\|s_t = s] = \mathbb{E}[r(s_t)+\gamma r(s_{t+1})+\gamma^2 V(s_{t+2})\|s_t = s]$$.

Let $G^k_t = r(s_t)+\gamma r(s_{t+1})+ \dots + \gamma^k V(s_{t+k})$. Then we can contrast different temporal difference algorithms via considering the number of rollout steps performed at each iteration. TD(1) will be the algorithm given by $V_{n+1}(S_t) = V_n(S_t) + \alpha_n G_t^1$. The _every visit Monte Carlo algorithm_ is given by $V_{n+1}(S_t) = V_n(S_t) + \alpha_n G_t^{\infty}$, where to obtain $G_t^{\infty}$ we let $k$ grow sufficiently large.

Example: consider a simple MDP with 4 states. The reward structure is just that you obtain Ber(0.5) at state 3. At states 1 and 2 you can only transition to state 3, from there only to state 4 and at state 4 you can only self loop, at which point we consider the MDP to terminate. We impose an initial state distribution via $P(s_0 = 1) = 0.9, P(s_0 = 2) = 0.1$.

There is only one policy since there is only one action per state. We have $V(3) = V(2) = V(1) = 0.5$, since we impose $\gamma = 1$, given this is a finite MDP.

Let's solve this with TD(1). Start with $V_0 = (0, 0, 0, 0)^T$. Then we have:\
$$V_1(3) = V_0(3) + \alpha_1 \left( r_3 + V_0(4) - V_0(3) \right) =  0 + 1(r_3 + 0 - 0) = r_3$$\
$$V_2(3) = V_1(3) + \alpha_2 \left( r_3 + V_1(4) - V_1(3) \right) = r_3 + \alpha_2(r_3^2 - r_3) = \frac{1}{2}(r_3 + r_3^2)$$.

Then we have that the n-th time the agent visits state 3 as $V_n(3) = \frac{1}{n} \sum^n_i r_3^i$.

Now let's consider what happens for state 2. Because of the initial state distribution, the agent won't visit state 2 until the $k$-th iteration. Then we have:\
$$V_{k+1}(2) = V_k(2) + \alpha_k (r_2 + V_{k}(3) - V_k(2) )$$\
$$V_{k+1}(2) = 0 + (0 + \frac{1}{k}\sum_i^k r_3^i - 0) = \frac{1}{k}\sum_i^k r_3^i$$.

This is because before arriving at state 2, the agent would have had to visit state 3 $k$ times. Then imagine the agent next arrives at state 2 on iteration $k_2$ after first arriving at iteration $k_1$. Then we have:\
$$V_{k_2+1}(2) = V_{k_2}(2) + \alpha_{k_2} (r_2 + V_{k_2}(3) - V_{k_2}(2) )$$\
$$V_{k_2+1}(2) = \frac{1}{k_1}\sum_i^{k_1} r_3^i + \frac{1}{2} (0 + \frac{1}{k_2}\sum_i^{k_2} r_3^i - \frac{1}{k_1}\sum_i^{k_1} r_3^i )$$\
$$= \frac{1}{2}(\frac{1}{k_2}\sum_i^{k_2} r_3^i - \frac{1}{k_1}\sum_i^{k_1} r_3^i)$$.

By contrast, we can try to solve with every state MC. We have:\
$$V_{k_1+1}(2) = V_{k_1}(2) + \alpha_{k_1}(r_2 + r_3 + r_4) = r_3^{k_1}$$\
$$V_{k_2+1}(2) = V_{k_2}(2) + \alpha_{k_2}(r_2 + r_3 + r_4) = \frac{1}{2}(r_3^{k_2}-r_3^{k_1})$$.


## Lecture 2/5: More on Policy Evaluation
### Convergence of Policy Evaluation
Given an ODE $\dot{x} = h(x)$ we want to solve via _stochastic approximation_, that is find a sequence of estimates $x_{n+1} = x_n + \alpha_n (h(x_n) + M_{n+1})$ such that $x_n \rightarrow x_F$ where $h(x_F) = 0$ almost surely.

The Robbins-Monro conditions require that (1) the learning rate decays rapidly, (2) the noise term is independent of the current estimate with bounded variance, (3) the ODE function is Lipschitz, (4) the final solution is a stable equilibrium, and (5) the sequence of estimates is bounded.

An alternate set of conditions due to [Borkar and Meyn (2000)](https://epubs.siam.org/doi/abs/10.1137/S0363012997331639) require the restrictions on the learning rate, the noise term, and the Lipschitz-ness of the ODE function, but can supplant the stable equilibrium and boundedness requirements. Instead, we now need there to exist another function $h_r(x) = \frac{h(rx)}{r}$ such that $\lim_{r \to \infty} h_r(x) = h_{\infty}(x) \forall x \in \mathbb{R}^d$. Then we get for free that there is an asymptotically stable solution $x_F$.

To show the convergence of policy evaluation then we proceed with the Borkar-Meyn conditions and prove the following:
1. The conditions on the learning rate, noise function, and Lipschitz-ness of the $h$ function imply the boundedness of the estimated solutions.
2. With the above we can show that $x_n \to x_F$ almost surely.

Note that in the policy evaluation problem we have the following: $h(x) = \hat{r} + \gamma P x - x$. Then let $h_r(x)$ be given by
$$h_r(x) = \frac{h(rx)}{r} = \frac{\hat{r} - \gamma P rx - rx}{r} = (\frac{1}{r})\hat{r} + (\gamma P - I)x$$.

This implies $\lim_{r \to \infty} h_r(x) = h_{\infty}(x) = (\gamma P - I)x$.

The proof is as follows. We will construct two functions: $\phi(t)$ will be a smooth interpolation of all the visited estimates $x_n$. Meanwhile $\hat{\phi(t)}$ will be a left-continuous piecewise decaying function (sort of like an intensity function in a point process) such that 

$$\|\hat{\phi}(kT) - x_F\| \leq \delta/2 \forall k \in \mathbb{N}^+$$.

Then we just need to show that $\|\phi(t) - \hat{\phi}(t)\| \to 0, t \to \infty$.

To start, let $\epsilon > 0$ and consider $B(\epsilon)$ the $\epsilon$-neighbors of $x_F$.


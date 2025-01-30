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

The key here is that $V(S\_{t+1})$ is an unbiased estimate for $\mathbb{E}[V(t+\delta t) \| V(t)]$, since we arrive at $V(S\_{t+1})$ by transitioning under $P^{\pi}$ and then taking the action specified by the policy, moving us to the next step of the rollout.

Then the _temporal difference (TD) algorithm_ obtains the successive approximations to $V(S\_t)$ via:\
$$V\_{n+1}(S\_t) = V\_n(S\_t) + \alpha\_t\left( r\_t + \gamma V\_n(S\_{t+1}) - V\_n(S\_t) \right)$$

The TD algorithm is an example of a _stochastic approximation algorithm_. Stochastic gradient descent works similarly. It's based on the idea that we can approximate a continuous ODE by taking advantage of an unbiased estimate for the term within the Taylor expansion:\
$$\dot{X}(t) = h(X(t)) \rightarrow X\_{n+1} = X\_n + \alpha\_n (h(X\_n) + M\_{n+1}), \quad \mathbb{E}[M\_{n+1} | X\_n] = 0$$




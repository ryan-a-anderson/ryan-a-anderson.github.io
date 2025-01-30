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

Then we do a quick Taylor expansion:
```math
V(t+\delta t) \simeq V(t) = \delta t \left( r^{\pi} + \gamma \mathcal{E}[V(t+\delta t) | V(t)] - V(t) \right)
```



Then the _temporal difference (TD) algorithm_ obtains the successive approximations to $`V(S_t)`$ via:
```math
V(S_t) = V(S_{t-1}) + \partial_t
```

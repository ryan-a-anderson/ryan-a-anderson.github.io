---
title: 'Notes on Modeling POMDPs: Crites' Elevator'
date: 2025-02-03
permalink: /posts/2025/02/crites-elevator/
tags:
  - MDPs
  - POMDPs
  - value function
  - reinforcement learning
---

In his PhD thesis, [Crites & Barto (1998)](https://link.springer.com/article/10.1023/A:1007518724497) analyzed the problem of controlling multiple different elevators and modeled the system as a multi-agent POMDP, noting both the extreme size of the state space --- with 4 elevators in a 10-story building, on the order of $10^{22}$ states --- as well as the effectiveness of deep-$Q$-learning techniques in attacking the problem. 

In a simplified version of Crites' elevator, consider a three story building where people may arrive at each floor, but only up to a maximum of 2 people per floor. 
This gives a much smaller state space of 27 states. 
We will consider a single elevator with 3 actions --- visiting the 1st, 2nd, or 3rd floor. 
Upon taking action $a_i$, the number of people on that floor is fixed at zero for the next round, but arrivals may still occur at the other floors. 
The elevator experiences rewards in the form of a penalty for the total number of people waiting after each round.

We impose partial observability following [Crites & Barto (1998)](https://link.springer.com/article/10.1023/A:1007518724497) by giving the elevator incomplete information as to the number of people at each floor. 
In particular, here the elevator is only informed as to which floor contains the most people in each state --- if the states have equal numbers of people, they have equal probability of being observed.

In Figure 1 we visualize a 3D slice of the set of value functions for this example. 
We start with the policy which takes uniform actions in all observations --- $p(a_i | o_j) = 1/3$. 
We then construct policies which agree on all but $o_1$: in blue are 1000 value functions from policies $\pi_i$ whose behavior on $o_1$ is taken from samples from the unit simplex in $\mathbb{R}^3$. 
At the corners, in red, purple, and brown, are three deterministic policies which always take $\pi(a_1|o_1) = 1, \pi(a_2|o_2) = 1, \pi(a_3|o_3) = 1$, respectively. 
Between the original flat policy and each of the deterministic we take interpolations of policies and map their value functions. 

Here, we recover lines between the value functions.

<img width="354" alt="crites_elev_slice_interpol" src="https://github.com/user-attachments/assets/35b7a8cd-69f3-4458-b1c1-bf13a9aaabe5" />


---
title: "Notes on the Rigidity Problem in Graphs"
author: "Ryan Anderson"
date: '2025-04-15'
layout: single
output: html_document
---

## Testing for Rigidity in Graphs

Let $(G,p)$ be a $d$-framework: we have $G$ a graph with $V(G) = [n]$ and an embedding map $p: [n] \to \mathbb{R}^d$.

We say a $d$-framework $(G,q)$ is _equivalent_ to another $d$-framework $(G,p)$ if $\|q(u)-q(v)\| = \|p(u)-p(v)\| \forall uv \in E(G)$. 
We say two $d$-frameworks are congruent if the distances are equal for all vertices, not just all edges. Put another way, congruence implies that the edge lengths determine the non-edge lengths.

We call a $d$-framework _globally rigid_ if all equivalent frameworks are congruent.

Trivially, the complete graph on $n$ nodes $K_n$ is globally rigid for all choices of embedding map $p$.

Let $R(G,p)$ be the _rigidity matrix_ of $(G,p)$, i.e. half the Jacobian of the distance map at $p$.
A _stress_ is a vector $w \in \mathbb{R}^{E(G)}$ such that $wR(G,p) = 0$.

The corresponding _stress matrix_ $\Omega$ is the matrix such that $\Omega_{i, j} = w_{ij} \forall ij \in E(G)$, with $\Omega_{i,j} = 0$ if $i \neq j$ and $ij \not \in E(G)$, and $\Omega_{i,j} = \sum_{ij \in E} -w_{ij}$.

Note: the rank of a stress matrix is at most $n-d-1$. In fact, the existence of a stress matrix of maximal rank is equivalent to the framework being globally rigid! However, this relation only works for each choice of embedding map $p$. To get the relation generically, we need another condition, as shown below.

**Theorem**: G is _generically globally $d$-rigid_ iff every generic $d$-framework $(G,p)$ has a max-rank stress matrix.

<img width="529" alt="image" src="https://github.com/user-attachments/assets/8bba61fc-29b6-4784-8152-1b69acac56c8" caption="Figure from Connelly (2004) https://link.springer.com/article/10.1007/s00454-004-1124-4"/>


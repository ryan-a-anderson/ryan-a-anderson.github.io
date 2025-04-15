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

The corresponding _stress matrix_ $\Omega$ is the matrix such that $\Omega_{i, j} = w_{ij} \forall ij \in E(G)$, with $\Omega{i,j} = 0$ if $i \neq j$ and $ij \not \in E(G)$, and $\Omega{i,j} = \sum_{ij \in E} -w_{ij}$.



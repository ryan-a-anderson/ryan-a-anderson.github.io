---
title: "Notes on Interval Matrix Theory"
date: 2025-03-16
permalink: /posts/2025/03/interval-matrix-theory/
tags:
  - MDPs
  - POMDPs
  - linear algebra
  - interval matrix theory
---

Interval matrix theory is a subfield of linear algebra concerned with obtaining solutions to systems of equations $Ax = b$, where the components $A, b$ take values in an interval.

That is, in an interval matrix equation we have an interval matrix $A^I = [\underline{A}, \overline{A}] = \{A; \underline{A} \leq A \leq \overline{A}\}$. 
We denote the center matrix $A^c = \frac{1}{2}(\underline{A} + \overline{A})$ and the radius $\Delta = \frac{1}{2}(\overline{A} - \underline{A})$.


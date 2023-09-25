---
title: 'IMSI Algebraic Statistics Note #1'
date: 2023-09-20
permalink: /posts/2023/09/imsi-algebraic-statistics-note-1/
tags:
  - neural networks
  - algebraic statistics
---

Spent the week at a workshop at the University of Chicago, "Invitation to Algebraic Statistics," part of the IMSI long program "Algebraic Statistics and our Changing World". This week's workshop featured excellent talks on the application of algebraic statistics to estimation & optimization problems, graphical models, neural networks, algebraic economics, and ecological problems.

Overall, algebraic statistics is a cool and curious field which lives at the intersection of algebraic geometry and statistics. The guiding mantra was stated by Elizabeth Gross in her talk – in brief, statistical problems give rise to statistical models, which in general are given by sets of polynomial constraints on the relations between event probabilities. These polynomial constraints then give rise to varieties, and algebraic geometers are always on the look out for more varieties.

We can make this explicit – although the most fun example comes from June Huh and Bernd Sturmfels' paper ["Likelihood Geometry"](http://arxiv.org/abs/1305.7462), where they analyzed the variety arising from data on the three-level events "hair loss" and "football watching", it's simpler to consider just two-level events. 

Consider a 2x2 contingency table, which just counts the number of times each event $X_1, X_2$ occur. The entries of this table are $p_{i,j} = P(X_1 = i, X_2 = j)$. Under (unconditional) independence, the joint probability factorizes as $p_{ij} = p_i p_j$. But also, since $p_i = 1- p_{ii}$, this matrix must have rank 1, meaning its determinant $p_{00}p_{11} - p{01}p{10}$ vanishes. This determinant vanishing defines a variety, which the algebraic geometers go on to study further, asking questions about its irreducibility, dimension, etc.

Carlos Amendola and Julia Lindberg gave the talks on estimation and optimization. Both talks were centered around the ML degree and the method of moments. Recall that given a likelihood function $l(u) = \prod $

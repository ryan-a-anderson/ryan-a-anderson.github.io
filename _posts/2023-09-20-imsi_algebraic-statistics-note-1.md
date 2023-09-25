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

Consider a 2x2 contingency table, which just counts the number of times each event $X_1, X_2$ occur. The entries of this table are $p_{i,j} = P(X_1 = i, X_2 = j)$. Under (unconditional) independence, the joint probability factorizes as $p_{ij} = p_i p_j$. But also, since $p_i = 1- p_{ii}$, this matrix must have rank 1, meaning its determinant $p_{00}p_{11} - p_{01}p_{10}$ vanishes. This determinant vanishing defines a variety, which the algebraic geometers go on to study further, asking questions about its irreducibility, dimension, etc.

\heading{Estimation & Optimization}

Carlos Amendola and Julia Lindberg gave the talks on estimation and optimization. Both talks were centered around the ML degree and the method of moments. Say we have data which we summarize in a vector of counts $u$, with $u_i = #$ of times that the $i$th state occurs. Statisticians are taught to maximize the likelihood function $L_u(p) = \prod p_i^{u_i}$ to get the MLE, which is consistent and has minimal variance, etc. The algebraists instead note that we have a set of likelihood equations, given by the likelihood function, the determinantal constraints which arise from the independence relations, and the always-present $\sum p_i = 1$. The number of (generic!) solutions to these likelihood equations is an invariant of the statistical model called the ML degree.

Under unconditional independence the ML degree is 1 – this is also something statisticians are taught, that our optimization methods for finding an MLE won't get stuck in local minima. But this is not always the case! In the soccer vs hair loss example mentioned above, Huh and Sturmfels construct the data so that the contingency table is of rank 2 – this then leads to different determinantal constraints than if it were rank 1, and thus we get more than 1 local optima for the likelihood function.

The method of moments is an old technique, emerging from Karl Pearson's early attempts to deal with latent variables. Consider data arising from a mixture of two Gaussians $X \sim f, f = \lambda N_1(\mu_1, \sigma_1) + (1 - \lambda)N_2(\mu_2,\sigma_2)$. For any random variable $X$ with density $f$, its $j$th moment is given by $E[X^j] = \int x^j f(x) dx$ – one foundational result is that the moments of a mixture distribution are given by the mixture of the moments of each component. Pearson's method of moments involves matching the empirical moments we observe from the data to the mixture of the moments, thereby enabling us to estimate the parameters $(\lambda,\mu_1, \sigma_1,\mu_2,\sigma_2)$. Since the moments of a Gaussian are homogeneous polynomials in $(\mu,\sigma)$, we have a very algebraic feeling problem of determining how many solutions there are to a system of polynomial equations.

Uniqueness of solutions to this system in this case even has an easy statistical interpretation – a distribution is identifiable if the solution to its moments system is unique. Amendola's recent work has described exactly under which conditions mixtures of Gaussians are identifiable – under equal variance and known covariance matrix $\Sigma$, and with number of moments equal to the number of parameters, any mixture model is identifiable, except in a handful of cases.

Lindberg's talk described some really fun new results as regards both these objects – notably, that mixtures of $k$ univariate Gaussians are identifiable given $3k+2$ moments. She also described the use of homotopy continuation in finding solutions to the moments system, which was totally novel and very exciting to me.

Our problem solving session involved a lot of problems that the statisticians were good at – prove an estimator is consistent, unbiased, etc. Some of my theoretical stats had gotten a bit rusty but was a lot of fun to discuss and rehash the proofs with the mathematicians. One sub-question that troubled us asked you to prove that if we have a mixture of two Gaussians, then the likelihood function is unbounded unless the variances are equal and known. If anyone knows how to solve that, please let me know!

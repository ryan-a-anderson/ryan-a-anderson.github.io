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

## Estimation & Optimization

Carlos Amendola and Julia Lindberg gave the talks on estimation and optimization. Both talks were centered around the ML degree and the method of moments. Say we have data which we summarize in a vector of counts $u$, with $u_i$ the number of times that the $i$th state occurs. Statisticians are taught to maximize the likelihood function $L_u(p) = \prod p_i^{u_i}$ to get the MLE, which is consistent and has minimal variance, etc. The algebraists instead note that we have a set of likelihood equations, given by the likelihood function, the determinantal constraints which arise from the independence relations, and the always-present $\sum p_i = 1$. The number of (generic!) solutions to these likelihood equations is an invariant of the statistical model called the ML degree.

Under unconditional independence the ML degree is 1 – this is also something statisticians are taught, that our optimization methods for finding an MLE won't get stuck in local minima. But this is not always the case! In the soccer vs hair loss example mentioned above, Huh and Sturmfels construct the data so that the contingency table is of rank 2 – this then leads to different determinantal constraints than if it were rank 1, and thus we get more than 1 local optima for the likelihood function.

The method of moments is an old technique, emerging from Karl Pearson's early attempts to deal with latent variables. Consider data arising from a mixture of two Gaussians $X \sim f, f = \lambda N_1(\mu_1, \sigma_1) + (1 - \lambda)N_2(\mu_2,\sigma_2)$. For any random variable $X$ with density $f$, its $j$th moment is given by $E[X^j] = \int x^j f(x) dx$ – one foundational result is that the moments of a mixture distribution are given by the mixture of the moments of each component. Pearson's method of moments involves matching the empirical moments we observe from the data to the mixture of the moments, thereby enabling us to estimate the parameters $(\lambda,\mu_1, \sigma_1,\mu_2,\sigma_2)$. Since the moments of a Gaussian are homogeneous polynomials in $(\mu,\sigma)$, we have a very algebraic feeling problem of determining how many solutions there are to a system of polynomial equations.

Uniqueness of solutions to this system in this case even has an easy statistical interpretation – a distribution is identifiable if the solution to its moments system is unique. Amendola's recent work has described exactly under which conditions mixtures of Gaussians are identifiable – under equal variance and known covariance matrix $\Sigma$, and with number of moments equal to the number of parameters, any mixture model is identifiable, except in a handful of cases.

Lindberg's talk described some really fun new results as regards both these objects – notably, that mixtures of $k$ univariate Gaussians are identifiable given $3k+2$ moments. She also described the use of homotopy continuation in finding solutions to the moments system, which was totally novel and very exciting to me.

Our problem solving session involved a lot of problems that the statisticians were good at – prove an estimator is consistent, unbiased, etc. Some of my theoretical stats had gotten a bit rusty but was a lot of fun to discuss and rehash the proofs with the mathematicians. One sub-question that troubled us asked you to prove that if we have a mixture of two Gaussians, then the likelihood function is unbounded unless the variances are equal and known. If anyone knows how to solve that, please let me know!

## Graphical Models
Seth Sullivant and Pratik Misra presented on graphical models and the connection to causal inference. Lots of this stuff was familiar from stats world – $d$-separation and Gaussian graphical models and whatnot. Sullivant presented a lot of results which depended on $t$-separation, in which we consider not just separation via an edge, but rather by treks, which are paths in the graph with no colliders. 

Some of Misra's discussion included combinations of graphs via gluing, which I thought was really fascinating. He also described work on colored Gaussian graphical models, where the key property is being RCOP, where permutations on the labels preserve colorings and edge relationships. If a colored graph is RCOP then its vanishing ideal is toric, which makes all the algebraists very happy (vanishing ideals are hard to explain but easy to compute).

<img width="430" alt="image" src="https://github.com/ryan-a-anderson/ryan-a-anderson.github.io/assets/114775680/361527d1-1e5a-4c15-a143-f7711612929b">

We had a lot of fun with the problem solving session here, working on independence and intersection numbers of graphs. A result Misra presented gave that graphs with equal intersection and independence numbers live in the equivalence class of graphs of some DAG. As a result, you can take a representative of such a class and turn it into a valid DAG via correct assignation of colliders.

<img width="600" alt="image" src="https://github.com/ryan-a-anderson/ryan-a-anderson.github.io/assets/114775680/4e03232b-b056-4519-bae4-8e0ee6dfe49c">


## Neural Networks
Joe Kileel and Kathlén Kohn presented on neural networks. Much of this work was connected to topics we often discuss in the Montufar group, and indeed Guido and Kathlén collaborated on papers related to the geometry of linear convolutional networks.

Kohn provided an excellent characterization of the geometry of linear convolutional networks as you vary the stride of the convolution. Here the activation function is the identity. As such, fully connected networks are unsurprisingly given by algebraic varieties – the final function we get is just the product of the weight matrices. By contrast, with some non-zero stride added to the convolution, the variety becomes a semialgebraic set, given by inequalities, not just equalities, in the defining polynomials.

<img width="425" alt="image" src="https://github.com/ryan-a-anderson/ryan-a-anderson.github.io/assets/114775680/a771bab7-e4f9-4b81-ab2d-7ab9233349d8">

Another good result describes the function computed by convolutional networks. Since products of Toeplitz matrices, which describe convolutions, are again Toeplitz (a result I want to prove for myself), we can associate the final function with a polynomial in the strides. 

We spent the problem solving session struggling with an interesting question on group equivariance. Basically, we were asked to consider the space of linear maps which preserve the symmetries in the transformation that rotates a 3x3 image by 90 degrees.

<img width="425" alt="image" src="https://github.com/ryan-a-anderson/ryan-a-anderson.github.io/assets/114775680/eace22e4-9c68-40b8-958d-51cf42514933">

It was sort of easy to see that rotations would preserve it, but really hard to parametrize the linear maps themselves. Ultimately, we ended up working with a block-diagonal matrix and finding the relations which described each of the blocks. In the end, we didn't talk too much about neural networks!

## Algebraic Economics
Tianren Chen and Irem Portakal discussed algebraic economics, which studies algebraic properties of the models induced by games. Lots about games is prima facie algebraic – payoff matrices are really payoff tensors, in that each player in a game has payoffs for each combination of decisions they and the other player make. The Nash equilibrium of a game is given by a zero set of a system of equations which are polynomial in the payoffs. The totally mixed Nash equilibria generalize the payoffs into probabilities, from which jumping off point you can go further in the same fashion as likelihood geometry style problems.

Lots of complicated stuff about real algebraic geometry gets you to the really cool result from McKelvey & McLennan, which considers the solutions of the equilibrium polynomials geometrically. Then the number of solutions is given by (bounded by) the mixed volume of the Newton polytopes defined by the equilibrium polynomials! This kind of thing is called a BKK bound, after the result of Bernshtei Kushnirenko and Khovanskii on solutions to systems of Laurent polynomials.

<img width="943" alt="image" src="https://github.com/ryan-a-anderson/ryan-a-anderson.github.io/assets/114775680/e0bf2ef2-7fc3-460d-a30d-750e2f2d885c">

Portakal shared her really exciting result with Sturmfels on the nature of dependency equilibria. Traditionally we think about games where the players act independently. If you instead allow subsets of players to act depending on how the others will act, you induce a set of (in)dependence relations – the resulting solutions are called dependency equilibria. These dependency equilibria were first investigated by the philosopher Wolfgang Spohn, who defined them as solutions where players maximize their conditional expectation payoffs. This leads to the notion of a Spohn variety, which is given by the probability of each action for each player and their net payoffs. Irem & Portakal's result uses the Spohn variety to characterize all Nash equilibria in $n$-player, 2-strategy games as arising from some real algebraic variety.

The problem solving session was excellent because we actually calculated a BKK bound and a Spohn variety. I was able to use packages produced by the authors in Julia to count the number of Nash equilibria to [the Bach or Stravinsky game](https://moblab.com/edu/games/bach-or-stravinsky#:~:text=The%20classic%20pure%2Dstrategy%20game,coordinating%20on%20a%20different%20action), which happily turned out to be 1.

## Ecological Problems
Elizabeth Gross and Neriman Tokcan discussed the application of algebraic statistics to ecological and biomedical problems, focusing on two structures: phylogenetic trees and tensors.

Phylogenetic trees are models that encode evolutionary relationships among species. Given a set of species, we can use DNA data to identify the highest probability tree which describes their evolutionary history. In this way, statisticians would be more used to understanding them as graphical models. Phylogenetic trees and their extension via mixture phylogenetic networks have incredibly rich algebraic structure, and many of the participants there had recently worked on them. To be honest, this depth of structure made them very hard to get a sense for. One critical step in the evaluation of phylogenetic trees involves a discrete Fourier transformation, out of probability space and into $q$-space, which leads to toric ideals.

Still in our problem solving session, we investigated the "4-sunlet" network, in which the model contains one unknown network connection. This structure gives rise to essentially a mixture model, the zero sets of whose $q$-polynomials cut out an ideal we calculated.

<img width="125" alt="image" src="https://github.com/ryan-a-anderson/ryan-a-anderson.github.io/assets/114775680/65fc9030-2201-433b-a3bc-965c90e54f1f">

The easy interpretability and familiarity that these phylogenetic trees induce did make them fun to work with, but they still feel pretty complicated to my mind!

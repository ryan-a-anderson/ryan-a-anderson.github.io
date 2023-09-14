---
title: 'Summer Note #1'
date: 2023-09-14
permalink: /posts/2023/09/summer-note-1/
tags:
  - neural networks
  - geometric deep learning
  - benign overfitting
---

Back into the swing of things: attended two talks this week, and prepping for the IMSI Workshop to begin next Monday.

The first talk was given at our weekly seminar by <a href="https://media.mis.mpg.de/mml/2023-07-13/">Behrooz Tahmasebi from MIT</a>. He discussed the role of invariances emerging from group structures in reducing the sample complexity required to obtain a desired generalization error. The setting was kernel ridge regression, wherein our data live in a compact boundaryless manifold M. Then the generalization error is bounded by volume of M divided by number of samples n.

If there's a group whose action on the data manifold the regression function is invariant to, then the generalization error shrinks by the size of the group!

<img width="743" alt="image" src="https://github.com/ryan-a-anderson/ryan-a-anderson.github.io/assets/114775680/3c54f282-af31-412b-841c-4a0a61c35f64">

Tahmasebi cited the excellent <a href="https://arxiv.org/pdf/2104.13478.pdf">Geometric Deep Learning</a> notes by Bronstein et al (I also found <a href="https://www.reddit.com/r/MachineLearning/comments/n0zxey/r_geometric_deep_learning_grids_groups_graphs/">an awesome Reddit thread</a> where Velickovic posted the notes and responded to a lot of questions).

One thing I liked early in the notes is the description of the function class enumerable by multi-layer perceptrons as being not invariant to translations of the data! In particular, say an MLP is asked to classify animal images, and give the probability that the image is a cat. If given an image with a cat at its center it might return the correct result y% of the time, but if the cat is translated over by a few pixels, it will instead be accurate (y +/- epsilon)% of the time!






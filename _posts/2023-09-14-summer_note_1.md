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

![F58lUlEbwAAGi5_](https://github.com/ryan-a-anderson/ryan-a-anderson.github.io/assets/114775680/faf069de-0616-49c4-b3b6-1042a2a96dfa)

Reading the Geometric Deep Learning book also led me to the work by [Joshi on transformers](https://graphdeeplearning.github.io/post/transformers-are-gnns/), wherein he gives a really nice, simple relationship between how transformers work and how graph neural networks work. It appears that in some deep way, LLMs built with transformer architecture are so good at language processing because meaning making through language resembles a highly connected graph.

<img width="743" alt="image" src="https://github.com/ryan-a-anderson/ryan-a-anderson.github.io/assets/114775680/4cd29485-5474-47d1-9549-d28ea1927f1e">

It feels like you could extend the results Tahmasebi described in at least one simple way – just pick a few structures where we know we can define invariant groups on them and then compute the covering numbers and via metric entropy style arguments spit out a new generalization error lower bound for popular algorithms. (Of course I say simple but have no idea how you would actually do this.)

Second talk was given by [Vidya Muthukumar of Georgia Tech](https://www.mis.mpg.de/calendar/lectures/2023/abstract-36210.html). She discussed the nature of overfitting in classification problems. This line of thinking is very connected to the infamous double descent problem – double descent is exactly the phenomenon wherein an algorithm may have excellent generalization error, even if you overtrain it so much that it just interpolates the training data. This was surprising to statisticians familiar with previous learning theory, which held that generalization error was minimized not for zero training error, but some non-zero amount of training error which would allow the algorithm to maneuver in other parts of the output space.

[Bartlett et al 2019](https://arxiv.org/pdf/1906.11300.pdf) looked at how this works for linear regression and came up with lots of good results on how the exact setup of the data, especially the condition number (ratio of biggest to smallest eigenvalues) impacts the benignness of the overfitting. As they write: "The properties of Σ turn out to be crucial, since the magnitude of the variance in different directions determines both how the label noise gets distributed across the parameter space and how errors in parameter estimation in different directions in parameter space affect prediction accuracy."

Muthukumar's recent work extends the Bartlett analysis by considering behavior of classification problems, not regression problems, and compares the loss function used in training. Loss functions matter in all sorts of ways when it comes to neural networks, so this is an interesting avenue. Her approach finds that choice of loss function does not seem to impact the characterization of benign overfitting. Moreover, she characterizes the change points in the setup of the problems where overfitting switches from benign to malignant, or when it disappears entirely.

I'm really interested in classification – it feels to me like a natural way of thinking about data science, much more so than regression – so I hoped this talk would be really strong. But I felt underprepared, and couldn't follow along too well with the arguments. Oh well. [Michael Murray and others in the group at UCLA](https://arxiv.org/abs/2306.09955) have a result close in origin to the Muthukumar work, taking a look at classification with hinge loss and characterizing the benignness of overfitting. Working through this now.

The IMSI workshop ["Invitation to Algebraic Statistics"](https://www.imsi.institute/activities/invitation-to-algebraic-statistics-and-applications/) will begin Monday in Chicago, and very excited to be a part of it. In particular, Monday morning's sessions on estimation and optimization seem really strong.



High-dimensional statistics is the branch of statistics concerned with obtaining bounds on how random variables differ from their expectations, especially as the number of dimensions in the data increases. These notes will tackle three topics: (1) basic concentration inequalities and properties of sub-Gaussian random variables, (2) sparse linear regression, and (3) Dudley's theorem and its applications.

Most of our results will look something like 

$$
P(d(\hat{\theta},\theta^*) \leq r_n) \rightarrow^{n}_{\infty} 1,
$$

where the distance function $d(\hat{\theta},\theta^*)$ depends on our parameter space and $r_n$ is our rate of convergence.

## Basic Concentration Inequalities. Sub-Gaussianity & Concentration
### Motivation for Concentration Inequalities
In the classical setting, our approach to obtaining results like the above is given by one of two tools - the law of large numbers or the central limit theorem. These, however, are asymptotic results and require in particular that the number of samples is much larger than the number of dimensions.

When that asymptotic assumption fails we have to lean back on weaker results known as concentration inequalities. These are statements of the form

$$
P(|X - E[X]| \geq \alpha) \leq \beta,
$$

where $\alpha$ is usually large and $\beta$ is usually small and will depend on the number of samples.

The basic ones are well-known: we have Markov's inequality

$$
X \geq 0, E[X] \leq \infty \rightarrow P(X \geq t) \leq \frac{E[X]}{t}
$$

and Chebyshev's inequality

$$
X \geq 0, E[X^2] \leq \infty \rightarrow P(|X - E[X]| \geq t) \leq \frac{var(X)}{t^2}.
$$

One more basic and useful statement is known as the Chernoff trick - take a standard normal RV $Z_n$. Then $\forall \lambda > 0$,

$$
P(Z_n \geq t) = P(exp(\lambda Z_n) \geq exp(\lambda t)) \leq \frac{E[exp(\lambda Z_n)]}{exp(\lambda t)}
$$


### Characterizing Sub-Gaussianity
Most of our results will require that our random variables are sufficiently well-behaved. Well-behaved random variables will have well-behaved norms. Much of our machinery will hinge on our ability to use norm equivalences to chain inequalities together to get our desired results. One of those well-behaved properties is sub-Gaussianity.

A zero-mean random variable $X$ is sub-Gaussian if $\exists \sigma > 0$ such that

$$
E[exp(\lambda X)] \leq exp(\sigma^2 \frac{\lambda^2}{2}), \forall \lambda \in \mathbb{R}
$$

Gaussian RVs are sub-Gaussian, as are Rademacher RVs, which are RVs $W$ such that $P(W = 1) = P(W = -1) = \frac{1}{2}$. Rademacher RVs are said to be sub-Gaussian with parameter 1, as we have 

$$
E[exp(\lambda W)] = \frac{exp(\lambda) + exp(-\lambda)}{2} = cosh(\lambda) \leq exp(\lambda^2/2)
$$

All bounded RVs are sub-Gaussian - if $X$ takes its values in the interval $[a,b]$, then $X$ is sub-G with parameter $\frac{b-a}{2}$.

We can further characterize sub-Gaussian RVs via the following result: for an RV $X$, the following are equivalent for $K_1, \dots, K_4 > 0$:

$$
\text{Tails of X satisfy } P(\|X\| \geq t) \leq 2 exp(-\frac{t^2}{K_1^2}), \forall t \geq 0
$$

$$
\text{Moments of X satisfy } \|X\|_p = (E[\|X\|^p])^{\frac{1}{p}} \leq K_2\sqrt{p}, \forall p \geq 1
$$

$$
\text{MGF of X satisfies } E[exp(\lambda^2 X^2)] \leq exp(K_3^2 \lambda^2), \forall |\lambda| \leq \frac{1}{K_3}
$$

$$
\text{MGF of } X^2 \text{ satisfies } E[exp(\frac{X^2}{K_4})] \leq 2
$$

By way of illustration we can prove one of these equivalences. Let us show that the restriction on tails leads to the restriction on the moments of $X$.

Let $P(\|X\| \geq t) \leq 2e^{-t^2}$. Then take $E(\|X\|^p) = \int_0^{\infty} P(\|X\|^p \geq u) du$. 

Let $u = t^p$ - then $du = pt^{p-1} dt$ and $\|X\|^p \geq u \rightarrow \|X\| \geq t$.

Now

$$
E(\|X\|^p) = \int_0^{\infty} P(\|X\|^p \geq u) pt^{p-1} dt \leq \int_0^{\infty} 2e^{-t^2} pt^{p-1} dt \text{ by assumption.}
$$

But now note that our last integral on right is just the gamma function evaluated at $\frac{p}{2}$! It turns out that $p \Gamma(\frac{p}{2}) \leq 3(\frac{p}{2})^{\frac{p}{2}}$, so we have

$$
E[\|X\|^p] \leq 3(\frac{p}{2})^{\frac{p}{2}} \rightarrow (E[\|X\|^p])^{\frac{1}{p}} \leq K_1\sqrt{p}.
$$

We will also need for basically every result the notion of a sub-Gaussian norm. The sub-Gaussian norm $\|X\|_{\psi_2}$ is given by 

$$
\|X\|_{\psi_2} = \inf(t > 0 | E(exp(\frac{X^2}{t^2}) \leq 2)).
$$

Proving this is a real norm is really hard! Need to use Fatou's lemma to obtain boundedness of the norm. But using the sub-G norm we can get good results on behavior of sub-G random variables, including the following:
$$
P(\|X\| > t) \leq 2 exp(-c\frac{t^2}{\|X\|_{\psi_2}})
$$

$$
\|X\|_p \leq C\|X\|_{\psi_2}\sqrt{p}
$$

$$
E(exp(X^2 / \|X\|_{\psi_2})) \leq 2
$$

### Sub-Gaussianity and Concentration Inequalities

We can get a really easy result on sub-Gaussian RVs using the Chernoff trick. Let $X$ be sub-G. Then $P(X \geq t) \leq exp({\frac{-t^2}{2\sigma^2}})$. The proof is as follows:

$$
P(X \geq t) \leq \inf_{\lambda > 0} (exp(-\lambda t) E[exp(\lambda X)]) = inf_{\lambda > 0}(exp(-\lambda t) exp(\sigma^2\frac{\lambda^2}{2})) \leq inf_{\lambda > 0} (exp(-\lambda t + \sigma^2\frac{\lambda^2}{2})).
$$

Now if we just minimize the exponent with respect to $\lambda$, we can get our result.

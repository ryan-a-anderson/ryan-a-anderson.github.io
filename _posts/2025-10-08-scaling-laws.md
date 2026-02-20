---
title: "What Is a Scaling Law? From OLS to Transformers"
date: 2025-10-08
author: "Ryan A. Anderson"
tags:
  - scaling laws
  - linear models
  - deep learning
  - sample complexity
  - compute
---

People say a model “**scales**” when the loss keeps dropping predictably as you feed it more data, parameters, or compute. 

---

## Scaling Laws in the Classical Sense

In classical statistics, scaling laws characterize how a model’s generalization error depends on the number of data points and parameters.  

Consider a linear model with $D$ datapoints and $N$ covariates:

$$
y_i = x_i^\top\theta + \epsilon_i, \quad X \in \mathbb{R}^{D \times N}, \quad \epsilon_i \sim_{iid} N(0, \sigma^2)
$$

The estimator is given by the ordinary least squares solution:

$$
\hat{\theta} = (X^\top X)^{-1} X^\top y
$$

For a new test point $x_{\text{test}} \sim N(0, \Sigma)$, with $y_{\text{test}} = x_{\text{test}}^\top \theta + \epsilon_{\text{test}}$, we can compute the expected generalization error $E[(y_{\text{test}} - \hat{y})^2]$.  

After marginalizing over $x_{\text{test}}$ and $X$, the expression becomes:

$$
E[(y_{\text{test}} - \hat{y})^2] = \sigma^2 \left( 1 + \frac{N}{D - N - 1} \right), \quad D > N - 1
$$

Defining $\rho = \frac{E[(y_{\text{test}} - \hat{y})^2]}{\sigma^2} - 1$, we find that for a fixed generalization error, the optimal relationship between datapoints and features is roughly linear:

$$
D \simeq N \left(1 + \frac{1}{\rho}\right)
$$

This gives a simple baseline: to maintain a certain level of generalization, data and parameters should scale linearly with each other.

---

## Empirical Scaling Laws for Modern Architectures

The simplicity of this linear scaling doesn’t hold for modern deep networks. Researchers have sought to empirically measure how generalization error depends on data and parameters in more complex models.

[Arora *et al.* (2023)](https://arxiv.org/pdf/2307.15936) observed that large language models exhibit *emergent behaviors*—new capabilities that appear only once both the dataset size and parameter count cross certain thresholds. This observation led to the now-famous mantra: *“scaling is all you need.”*

Earlier, [Hestness *et al.* (2017)](https://arxiv.org/pdf/1712.00409) found that error in deep learning models follows a **power law** in dataset size:

$$
\text{error} \propto D^\beta, \quad \beta \in [-2, 0]
$$

Moreover, the number of parameters required to achieve a given level of error grows *sublinearly* with dataset size. Their empirical curves, such as those from language transformer experiments, supported this pattern.

![Language Transformer Scaling (Hestness et al. 2017)](./images/hestness_language_transformer.png)

---

## Kaplan-Type Scaling Laws

[Kaplan *et al.* (2020)](https://arxiv.org/pdf/2001.08361) rigorously verified that both dataset size and parameter count exhibit power-law relationships with generalization error. Their influential work quantified this relationship and even offered a heuristic for model scaling:

> “Every time we increase the model size by 8×, we only need to increase the data by roughly 5× to avoid a performance penalty.”

This insight reframed scaling laws as a *recipe* for training large transformer models efficiently—balancing parameters, data, and compute.  

They estimated that, for fixed datasets with $N$ parameters, the error scales as:

$$
\text{error} \propto N^{-0.076}
$$

and for fixed parameters with dataset size $D$:

$$
\text{error} \propto D^{-0.095}
$$

They also linked performance more closely to **FLOPs**—the number of floating-point operations required—since a transformer with $N$ parameters needs roughly $6N$ computations per token. Crucially, their work highlighted transformers’ superiority over other architectures.

![Kaplan Scaling Laws](images/kaplan_scaling.png)
![Transformer Performance (Kaplan et al. 2020)](images/kaplan_transformers.png)

---

## The Chinchilla Scaling Laws

[Hoffmann *et al.* (2022)](https://arxiv.org/pdf/2203.15556) later revisited Kaplan’s findings and proposed what became known as the **Chinchilla scaling laws**. Their central result was elegantly simple:

> “As compute budget increases, model size and the amount of training data should be increased in approximately equal proportions.”

In other words, optimal scaling is *balanced*: if you double your compute, you should roughly double both model parameters and dataset size.

![Chinchilla Optimal Scaling (Hoffmann et al. 2022)](images/hoffmann_optimal.png)

---

## A Theoretical Framework for Power-Law Scaling

Building on Hoffmann *et al.* (2022), we can formalize the intuition behind power-law scaling.

Suppose we have a sequence of past tokens $X_0^{s_{\max}} = [x_0, \dots, x_{s_{\max}}]$, where each token $x_i$ comes from an alphabet $\mathbb{A}$. A predictor model $f: X_0^{s_{\max}} \to P(\mathbb{A})$ outputs probabilities over the next token.  

Let $L(f)$ denote the expected generalization error (cross-entropy loss), and $f^*$ the Bayes-optimal predictor minimizing $L(f)$.

Now, suppose our predictor model is limited to $N$ parameters, forming a hypothesis class $\mathbb{H}_N$. The best possible model within this class is:

$$
f_N = \arg\min_{f \in \mathbb{H}_N} L(f)
$$
so that $L(f_N) > L(f^*)$.

If we train using only $D$ datapoints, the learned model $f_{N,D}$ further minimizes the empirical loss $L_D(f)$, giving:

$$
L(f_{N,D}) > L(f_N) > L(f^*)
$$

We can decompose the total loss as:

$$
L(N, D) = L(f_{N,D}) = L(f^*) + [L(f_N) - L(f^*)] + [L(f_{N,D}) - L(f_N)]
$$

These three components correspond to:
1. **Bayes-optimal risk** (irreducible error),
2. **Function approximation error** (finite model capacity),
3. **Dataset approximation error** (finite data).

Hoffmann *et al.* showed that these terms collectively drive the observed scaling laws.

---

### Empirical Form of the Scaling Relationship

In practice, the second term scales roughly as $N^{-0.5}$ and depends on the model architecture, while the third term scales as $D^{-0.5}$ and depends on data smoothness.  

Empirically, Hoffmann *et al.* estimated:

$$
L(N, D) = 1.69 + \frac{406.4}{N^{0.34}} + \frac{410.7}{D^{0.28}}
$$

They concluded that future models should aim to *increase these coefficients*—in other words, to make models and datasets more efficient at reducing loss through scaling.

---

## The Limits of Scaling Laws

Recent research has also explored where scaling laws break down. [Dohmatob *et al.* (2024)](https://arxiv.org/pdf/2402.07712) demonstrated that **model collapse** can occur when scaling laws shift during training.  

In experiments training linear models on synthetic data, test error eventually plateaued rather than continuing to shrink with $N/d$. As the proportion of synthetic data increased, performance degraded instead of improving.  

“Model collapse” broadly refers to situations where models deteriorate during training—either by overfitting synthetic data or losing diversity in learned representations ([Shumailov *et al.*, 2024](https://www.nature.com/articles/s41586-024-07566-y#citeas)).

![Model Collapse (Dohmatob et al. 2024)](images/dohmatob_scaling_laws.png)

---

## Scaling Laws for Inference

So far, the discussion has focused on training. But what about **inference**?

Recent studies by [Wu *et al.* (2025)](https://arxiv.org/pdf/2408.00724) and [Sardana *et al.* (2025)](https://arxiv.org/pdf/2401.00448) suggest a different rule of thumb. For inference, it’s better to go *smaller for longer*—in contrast to Hoffmann *et al.*’s principle of scaling model and data equally. This implies that the optimal trade-off for deployment and serving efficiency might deviate from that of training optimization.

![Inference Scaling (Wu et al. 2025)](images/wu_inference_scaling.png)

---

## Conclusion

From simple linear regressions to multi-billion-parameter transformers, scaling laws have revealed consistent mathematical structures in how models learn. They provide both a theoretical framework and practical heuristics for balancing model size, dataset scale, and compute resources.  

Yet, as recent work shows, these relationships are not immutable. Understanding when and why scaling laws bend—or break—may be the key to the next leap in AI efficiency and capability.

---

### References
- Arora et al. (2023). *Theory of Emergence and Complexity in LLMs.*  
- Hestness et al. (2017). *Deep Learning Scaling Laws.*  
- Kaplan et al. (2020). *Scaling Laws for Neural Language Models.*  
- [Hoffmann et al. (2022). *Training Compute-Optimal Large Language Models.*](https://arxiv.org/pdf/2203.15556)
- [Dohmatob et al. (2024). *Model Collapse Demystified.*  ](https://arxiv.org/pdf/2402.07712)
- Shumailov et al. (2024). *AI Models Collapse: A Survey.*  
- [Wu et al. (2025). *Inference Scaling Laws.*  ](https://arxiv.org/pdf/2408.00724)
- [Sardana et al. (2025). *Chinchilla Optimal Accounting for Inference.*](https://arxiv.org/pdf/2401.00448)

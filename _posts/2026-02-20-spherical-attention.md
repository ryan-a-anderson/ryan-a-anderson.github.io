---
title: "Attention on the Sphere"
date: 2026-02-20
author: "Ryan A. Anderson"
tags:
  - transformers
  - geometric deep learning
  - spherical harmonics
  - attention
  - equivariance
---

Transformers have proven to be remarkably capable architectures. For image data, the trick is simple: chop an image into patches, treat each patch as a token, and let attention do the rest. This is the core idea behind Vision Transformers ([Dosovitskiy et al., 2020](https://arxiv.org/pdf/2010.11929)), and the reason it works is that attention can learn both *local* and *global* relationships between patches simultaneously.

This stands in contrast to convolutional neural networks (CNNs) and other geometric deep learning models, which are designed to capture local topology and equivariance but struggle in the global setting. Attention gives you the best of both worlds—but only if you're working in Euclidean space. What happens when your data lives on the sphere?

---

## From Kernel Regression to Continuous Attention

To understand spherical attention, it helps to first see standard attention as a special case of kernel regression.

Consider two signals $q(x)$ and $k(x)$ (the query and key). Their *correlation* is

$$
C[q,k](x,x') = \text{corr}(q(x), k(x')).
$$

We can generalize this by replacing the correlation with an arbitrary kernel function $\alpha$, recovering the framework of kernel regression. For query and key signals $q, k: \mathbb{R}^+ \to \mathbb{R}^d$ and a value signal $v: \mathbb{R}^+ \to \mathbb{R}^e$, the **kernel regressor** is

$$
r(q(x)) = \int_{\mathbb{R}^+} \frac{\alpha(q(x),k(x'))}{\int_{\mathbb{R}^+} \alpha(q(x),k(x''))dx''} v(x') dx'.
$$

As a concrete example, setting $q(x) = x$, $k(x') = x'$, and $\alpha(x,x') = \exp(-(x-x')^2/h^2)$ recovers the **radial-basis function (RBF) regressor**.

Standard transformer attention is obtained by choosing $\alpha$ to be the exponential dot-product kernel:

$$
\text{Attn}[q,k,v](x) = \int_{\mathbb{R}^+} A[q,k](x,x')v(x')dx',
$$

where

$$
A[q,k](x,x') = \frac{\exp(q^\top(x) \cdot k(x')/\sqrt{d})}{\int_{\mathbb{R}^+} \exp(q^\top(x) \cdot k(x'')/\sqrt{d})dx''}.
$$

The kernel $\alpha(q,k) = \exp(q^\top k / \sqrt{d})$ measures similarity between query-key pairs, and the normalization makes the weights integrate to one—precisely the continuous-domain analogue of softmax attention.

---

## Moving to the Sphere

To extend attention to spherical data, two modifications are necessary:

1. Replace the Lebesgue measure on $\mathbb{R}^+$ with the **invariant Haar measure** $\mu$ on $S^2$.
2. Use a kernel $\alpha$ that is **invariant under the action of the rotation group** $SO(3)$.

The Haar measure ensures that integrals over the sphere are rotation-invariant—integrating over $S^2$ gives the same result regardless of how the sphere is oriented. The dot-product kernel $\exp(q^\top k / \sqrt{d})$ is already $SO(3)$-invariant when applied to rotated signals, so it carries over naturally.

Let $q, k: S^2 \to \mathbb{R}^d$ and $v: S^2 \to \mathbb{R}^e$. The **spherical attention** mechanism is

$$
\text{Attn}_{S^2}[q,k,v](x) = \int_{S^2} A_{S^2}[q,k](x,x')v(x')d\mu(x'),
$$

where

$$
A_{S^2}[q,k](x,x') = \frac{\exp(q^\top(x) \cdot k(x')/\sqrt{d})}{\int_{S^2} \exp(q^\top(x) \cdot k(x'')/\sqrt{d})d\mu(x'')}.
$$

The key property of this mechanism is **equivariance to rotations**: for any rotation $R \in SO(3)$,

$$
\text{Attn}_{S^2}[q \circ R, k \circ R, v \circ R](Rx) = \text{Attn}_{S^2}[q,k,v](Rx).
$$

Rotating the input signals and then applying attention is the same as applying attention and then rotating the output. This is the spherical analogue of the translation equivariance that convolutions enjoy—and it's the property that makes this architecture principled for data that lives on $S^2$.

---

## Local Neighborhood Attention

Global spherical attention requires integrating over the entire sphere, which is computationally expensive. A more efficient variant restricts attention to a **local spherical disk neighborhood** of each query point.

Define the geodesic disk of radius $r$ centered at $x \in S^2$ as

$$
D(x) = \{x' \in S^2 : d_{S^2}(x,x') < r\},
$$

where $d_{S^2}$ is the geodesic distance on the sphere. Including an indicator function $\mathbb{1}_{D(x)}(x')$ in the attention kernel restricts each query to only attend over its local neighborhood:

$$
A_{S^2}^{\text{local}}[q,k](x,x') \propto \mathbb{1}_{D(x)}(x') \cdot \exp(q^\top(x) \cdot k(x')/\sqrt{d}).
$$

This recovers a spherical analogue of local window attention, trading some expressiveness for significantly lower computational cost.

---

## Positional Embedding via Spherical Harmonics

On a flat domain, sinusoidal positional embeddings encode position by frequency. On the sphere, the natural analogue is **spherical harmonics**—the eigenfunctions of the Laplace-Beltrami operator on $S^2$ ([Brandstetter et al., 2023](https://arxiv.org/pdf/2310.06743)).

Spherical harmonics form a complete orthonormal basis for $L^2(S^2)$, and they transform predictably under rotations (via Wigner D-matrices). Using them as positional embeddings preserves the rotational structure of the architecture end-to-end.

---

## Why This Matters

Many real-world datasets are naturally spherical: global climate and weather data, omnidirectional images, 3D molecular structure, cosmological surveys. For these domains, standard Euclidean transformers impose incorrect geometric assumptions. Spherical attention ([Kaba et al., 2023](https://openreview.net/pdf?id=UCloKhbOvP)) offers a principled solution: full transformer expressiveness—learning both local and global relationships—with the correct inductive bias for spherical geometry.

---

### References

- [Dosovitskiy et al. (2020). *An Image is Worth 16x16 Words: Transformers for Image Recognition at Scale.*](https://arxiv.org/pdf/2010.11929)
- [Kaba et al. (2023). *Spherical Transformer for LiDAR Point Clouds.*](https://openreview.net/pdf?id=UCloKhbOvP)
- [Brandstetter et al. (2023). *Geometric Clifford Algebra Networks.*](https://arxiv.org/pdf/2310.06743)

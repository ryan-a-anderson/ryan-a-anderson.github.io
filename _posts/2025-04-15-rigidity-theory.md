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

The corresponding _stress matrix_ $\Omega$ is the matrix such that $\Omega_{i, j} = w_{ij} \forall ij \in E(G)$, with $\Omega_{i,j} = 0$ if $i \neq j$ and $ij \not \in E(G)$, and $\Omega_{i,j} = \sum_{ij \in E} -w_{ij}$.

Note: the rank of a stress matrix is at most $n-d-1$. In fact, the existence of a stress matrix of maximal rank is equivalent to the framework being globally rigid! However, this relation only works for each choice of embedding map $p$. To get the relation generically, we need another condition, as shown below.

**Theorem**: G is _generically globally $d$-rigid_ iff every generic $d$-framework $(G,p)$ has a max-rank stress matrix.

<img width="529" alt="image" src="https://github.com/user-attachments/assets/8bba61fc-29b6-4784-8152-1b69acac56c8" caption="Figure from Connelly (2004) https://link.springer.com/article/10.1007/s00454-004-1124-4"/>

## Finitely Completable Matrices of Rank R
The rigidity theory of graphs is a lovely interpretation of an essentially physical concept in algebraic terms. It turns out by use of a clever analogy we can extend this rigidity theory to other mathematical settings – in particular, rigidity theory is useful in the algebraic matrix completion question.

Any $m \times n$ matrix can be associated with a bipartite graph, where we have two vertex sets, one enumerating the rows and one the columns. [Tai-Danae Bradley's blog](https://www.math3ma.com/blog/matrices-probability-graphs) has a really nice post on this with great graphics.

https://cdn.prod.website-files.com/5b1d427ae0c922e912eda447/5c7ed4bcea0c9faeafe61466_pic1.jpg![image](https://github.com/user-attachments/assets/09f8893e-128c-4dac-a8d9-4fa38fac37ef)

Incomplete matrices, i.e. matrices where there are some unspecified entries, have been of interest for a long time in statistics. The most famous example is [the Netflix problem](https://krishnaswamylab.github.io/tutorial/imputation_and_netflix/), where we have $N$ users scoring $M$ movies, but not every user has seen every movie, so our matrix is incomplete. We seek clever choices of completions for this matrix that allow us to estimate what unseen movies users might best like. A common choice of clever completion is to make the matrix low-rank, so that we can think about each score as arising from some product of low-rank matrices, which may correspond to each user's thoughts about a genre, etc.

https://krishnaswamylab.github.io/img/how_to_single_cell/user_rankings.matrix.png![image](https://github.com/user-attachments/assets/27705309-2254-4b3e-b52c-d7da20a029d5)


For incomplete matrices, we generate the associated bipartite graph by adding an edge wherever we have an entry, and leaving incomplete entries with no edge between the vertices of its entry.

If we carefully calculate the rigidity matrix of the bipartite graph resulting from an incomplete matrix, we can obtain conditions for the matrix to be finitely completable at a given rank. By finitely completable of a given rank, I mean that there are only finitely many choices of completions of the missing entries which would result in the final matrix having the desired rank. This is not a very common situation – in general, there might be 0 or infinitely many choices of completions which would result in the final matrix having some rank. 

In particular, a nonsymmetric matrix $A \in \mathbb{C}^{m \times n} is finitely completable at rank $r$ if the rank of its rigidity matrix is equal to $r(m+n - r)$.

During the Macaulay2 conference at Tulane, I contributed to a package in M2 for checking whether a nonsymmetric incomplete matrix, passed to the function as a bipartite graph, was finitely completable up to a given rank $r$.

````{verbatim}
```{macaulay2, eval = FALSE}

getFiniteCompletabilityMatrix = method(Options => {Variable => null}, TypicalValue => Matrix)

isFinitelyCompletable = method(TypicalValue => Boolean)

getBipartiteGraphfromIncompleteMatrix = method(TypicalValue => List)
getBipartiteGraphfromIncompleteMatrix(ZZ, ZZ, List, Ring) := List => (rowDim, colDim, incompleteEntries, currRing) -> (
    -- Create a bipartite graph from the incomplete matrix
    bipartiteGraph := [];
    for i in 0 .. rowDim - 1 do
        for j in 0 .. colDim - 1 do
            if (i, j) in incompleteEntries then
                bipartiteGraph := bipartiteGraph || {i, j};
            fi;
        od;
    od;
    return bipartiteGraph;
);

getFiniteCompletabilityMatrix(ZZ, ZZ, ZZ, List) := Matrix => opts -> (completionRank, rowDim, colDim, edgeList) -> (
    crds := getSymbol toString(opts.Variable);
    R := QQ(monoid[crds_(1) .. crds_((rowDim+colDim)*completionRank)]); -- Create a ring with (rowDim+colDim)*completionRank variables

    -- Return a generic n by r matrix over R, fill with x_1 to x_(n*r)
    A := genericMatrix(R, (gens R)_(0), rowDim, completionRank);
    -- Return a generic r by m matrix over R, fill with x_(n*r+1) to x_(n*m)
    B := genericMatrix(R, (gens R)_((rowDim*completionRank)), completionRank, colDim);

    -- polynomialLists obtained from A, B -> A*B
    polynomialLists := apply(edgeList / toList, pair -> (A * B)_(pair#0, pair#1));
    jacobianList := polynomialLists / jacobian;

    -- Folding horizontal concatenation of the jacobian of each polynomial (from each edge)
    transpose fold((a,b) -> a|b, jacobianList)
);

isFinitelyCompletable(ZZ, ZZ, ZZ, List) := Boolean => (completionRank, rowDim, colDim, edgeList) -> (
    rank getFiniteCompletabilityMatrix(completionRank, rowDim, colDim, edgeList) == completionRank*(rowDim + colDim - completionRank)
);

TEST ///

-- testing on the bipartite graph which consists of two copies of K(3, 3) glued together on the bottom edge

twoGlueK33 = {
        {0, 0}, {0, 1}, {0, 2},
        {1, 0}, {1, 1}, {1, 2},
        {2, 0}, {2, 1}, {2, 3}, {2, 4},
        {3, 2}, {3, 3}, {3, 4},
        {4, 2}, {4, 3}, {4, 4}
    }
graph(twoGlueK33)
n = 5
m = 5
r = 1

A = getFiniteCompletabilityMatrix(Variable => x, r, n, m, twoGlueK33)
rank A
condition = r*(n + m - r)


twoGlueK33Edited = {
        {0, 0}, {0, 1}, {0, 2},
        {1, 0}, {1, 1}, {1, 2},
        {2, 0}, {2, 1}, {2, 3}, {2, 4},
        {3, 2}, {3, 3}, {3, 4},
        {4, 2}, {4, 3}
    }
graph(twoGlueK33Edited)
n = 5
m = 5
r = 1

A = getFiniteCompletabilityMatrix(Variable => x, r, n, m, twoGlueK33Edited)
rank A
condition = r*(n + m - r)
///
```
````

## Other Interesting Notes
In addition to the above work on rigidity theory done during the workshop at Tulane, I learned some other fun stuff.

There was some discussion of [Strassen's algorithm for matrix multiplication](https://en.wikipedia.org/wiki/Strassen_algorithm). Normally, $2 \times 2$ matrix multiplication requires 8 multiplications and 4 additions. Strassen was interested in proving that this was minimal in the number of multiplications – instead, he found a way to do it in 7 multiplications, but many more additions. This was mostly interesting from a representation theory point of view, but Strassen figured computation people would like it too, and so wrote out the derivation in elementary terms. It turns out to be way better – the basic matrix multiplication algorithm requires $O(n^3)$ steps, but because we only need to do 7 multiplications for each $2 \times 2$ minor multiplication, Strassen's algorithm does it in $O(n^{log_2 7}) = O(n^{2.81})$. Pretty sweet!

John Cobb, who's a postdoc at Auburn, also told me about another example of the algebraic perspective of physical phenomena – these are multiple oscillators on graphs. Multiple (or coupled) oscillators set up near each other exhibit [really strange resonant behaviors](https://arxiv.org/pdf/2203.03152), and will often fall in-phase with each other. An interesting question for any setup of coupled oscillators is which kinds of exotic modes you can generate.

You can solve this problem with PDEs and physics, or you can reinterpret the problem in algebro-geometric terms as describing the interesting variety defined by the intersection of each phase equation for each oscillator as well as a circular constraint. A paper by [Harrington, Schenck and Stillman (2023)](https://arxiv.org/pdf/2312.16069v1) did just that and is really wonderful. Using algebro-geometric tools on a graph structure defined by the coupled oscillators, they are able to find novel exotic solutions.

<img width="375" alt="image" src="https://github.com/user-attachments/assets/abceca83-60e7-4f41-8996-dd533ee81238" />

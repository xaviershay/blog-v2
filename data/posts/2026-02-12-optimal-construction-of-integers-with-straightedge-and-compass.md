---
title: "Optimal Construction of Integers with Straightedge and Compass"
tags: ["math"]
description: Any integer can be optimally constructed with a straightedge and compass in logarithmic time.
---

Any integer can be optimally constructed with a [straightedge and compass](https://en.wikipedia.org/wiki/Straightedge_and_compass_construction) in $O(\log \|x\|)$ time. This is a basic result, but I could not find it documented elsewhere.

### Preliminaries

Define a *step* as the following: given two already-constructed points $m$ and $n$ on a line, construct the point $2n - m$ by intersecting the line through $m$ and $n$ with the circle centred at $n$ passing through $m$. This results in two points: $m$ (by definition), and $n + (n - m) = 2n - m$.

<x-tikz>
  \begin{tikzpicture}[scale=3.0]
    % Draw x-axis
    \draw[<->, black, dashed] (-1.5,0) -- (3.5,0);
    \draw[black, dashed] (1,0) circle (1);
  
    \node[below right=2pt,font=\Large] at (0,0) {$m$};
    \fill (0,0) circle (1pt);
    \node[below right=2pt,font=\Large] at (1,0) {$n$};
    \fill (1,0) circle (1pt);
    \node[below right=2pt,font=\Large] at (2,0) {$2n - m$};
    \fill (2,0) circle (1pt);
  \end{tikzpicture}

  <figcaption>Using a circle and line intersection to construct a new point.</figcaption>
</x-tikz>

Assume the initial point set is $P_0 = \\{0, 1\\}$.

### Theorem 1 (Upper bound)

**Every integer $x$ can be constructed in at most $\lfloor \log_2 \|x\| \rfloor + 2$ steps.**

*Proof.* The cases $x \in \\{0, 1\\}$ are trivial. For $\|x\| \geq 1$ the proof proceeds in two parts.

#### Positive case ($x \geq 1$)

Define a sequence $(S_k)$ by $S_0 = x$ and, for $k \geq 0$:

$$
S_{k+1} = \begin{cases} S_k / 2 & \text{if } S_k \text{ is even,} \\ (S_k + 1) / 2 & \text{if } S_k \text{ is odd.} \end{cases}
$$

The sequence terminates when $S_k = 1$. Since $S_{k+1} \leq \lceil S_k / 2 \rceil < S_k$ for all $S_k > 1$, the sequence is strictly decreasing in the positive integers and terminates at some index $K$ with $K \leq \lfloor \log_2 x \rfloor + 1$.

Reversing the sequence yields valid steps. Reading from $S_K = 1$ back to $S_0 = x$:

- **Even case:** $S_k = 2\,S_{k+1} - 0$. Apply the operation with $n = S_{k+1}$, $m = 0$.
- **Odd case:** $S_k = 2\,S_{k+1} - 1$. Apply the operation with $n = S_{k+1}$, $m = 1$.

In both cases $n = S_{k+1}$ has already been constructed (by induction from $S_K = 1$) and $m \in \{0, 1\} \subseteq P_0$.

#### Negative case ($x \leq -1$)

Observe that for any constructed point $p$, the point $-p = 2 \cdot 0 - p$ can be obtained in one step by reflecting $p$ through the origin. Therefore, first construct $\|x\|$ using the positive case in at most $\lfloor \log_2 \|x\| \rfloor + 1$ steps, then apply a single reflection to obtain $x = -\|x\|$. The total is at most $\lfloor \log_2 \|x\| \rfloor + 2$ steps. $\quad\square$

### Theorem 2 (Lower bound)

**No construction from $\{0, 1\}$ can reach an integer $x$ in fewer than $\log_3 \|x\|$ steps. In particular, the number of steps is $\Omega(\log \|x\|)$.**

*Proof.* After $k$ construction steps, let $R_k = \max\{\|p\| : p \in P_k\}$ be the largest absolute value in the constructed set. Initially $R_0 = 1$. For any $m, n \in P_k$:

$$
|2n - m| \leq 2|n| + |m| \leq 3\,R_k,
$$

so $R_{k+1} \leq 3\,R_k$ and by induction $R_k \leq 3^k$. To reach $x$ we require $3^k \geq \|x\|$, hence $k \geq \log_3 \|x\|$.

Since $\log_3 \|x\| = \log_2 \|x\| / \log_2 3$ and $\log_2 3$ is a constant, this is $\Omega(\log \|x\|)$. $\quad\square$

### Corollary

**The construction complexity of an integer $x$ from $\{0, 1\}$ is $O(\log \|x\|)$.**

Theorem 1 gives an upper bound of $\lfloor \log_2 \|x\| \rfloor + 2$ and Theorem 2 gives a lower bound of $\Omega(\log \|x\|)$. The additive constants are absorbed by asymptotic notation, so the complexity is $O(\log \|x\|)$.
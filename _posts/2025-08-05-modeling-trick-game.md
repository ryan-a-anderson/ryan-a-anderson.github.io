---
title: 'Modeling a Trick-Taking Game'
date: 2025-08-05
permalink: /posts/2025/8/modeling-a-trick-taking-game/
tags:
  - card games
  - probability
  - Monte Carlo
---

## Overview

My friend Mario came over to my house last night and asked if I wanted to look at an interesting problem in a card game. 

The game is called [1000](https://en.wikipedia.org/wiki/1000_(card_game)), or, especially in Slavic countries, something like [_Tysiac_](https://www.qcsalon.net/en/tysiac). He learned the game from his fianceé, whose family is Polish.

Tysiac is a trick-taking game played with a 24 card deck –-- you toss out everything below 9. Each player is dealt 7 cards and the remainder is put into a kitty of 3 cards. Players bid for the chance to take the kitty and form tricks.

The most important trick is the marriage, or _meldunek_ as he called it. A meldunek is formed whenever a player has a king and queen of the same suit. 

![1000 card](https://github.com/user-attachments/assets/1b8574e1-7b78-4dcd-81f2-32e0ee614196)


He asked if we could think about the probability of making a meldunek conditional on how many of each king or queen you have in your hand. 

The easy calculation is to start with having one king or queen of any suit in your hand. Then the probability of making a meldunek by taking the kitty is simply $1 - (\frac{16}{17} * \frac{15}{16} * \frac{14}{15})$. That is, the first card in the kitty has a $\frac{16}{17}$ chance of not having the card you need, the second card has a $\frac{15}{16}$ chance, the third card has a $\frac{14}{15}$ chance, etc. That implies the chance of making a meldunek is 17.6%.

## LLM Evaluation

I asked this question to a few different SOTA models and thought it'd be interesting to reproduce their answers here.

### OpenAI's New Open Source Model – GPT OSS

OpenAI just released a new open source model today – it's called GPT OSS and comes in 120B parameter and 20B parameter versions.

> **Answer (≈ 33 %)**  
> If you have at least one king *or* one queen in your 7‑card hand, **but none of them is already paired with its mate**, the probability that the three‑card kitty contains a card that will complete a king‑queen pair (i.e. the queen of a king you own, or the king of a queen you own) is
\[ \boxed{\displaystyle \frac{11\,877}{35\,836}\;\approx\;0.331\;\;(33.1\%)} .\]
> 
> ---
> ## How the number is obtained  
> ### 1.  The deck and the situation  
> * 24 cards in total: 4 K, 4 Q, and 16 other cards (9, 10, J, A of each suit).  
> * You are dealt 7 cards, then a 3‑card “kitty’’ is dealt from the remaining 17 cards.  
> We condition on the event  
> **H** : *your hand contains at least one king or one queen, but never a king and the queen of the same suit.*
> In other words, the suits of the kings you hold are all different from the suits of the queens you hold.
> ### 2.  Counting admissible hands  
> Let  
> * \(k\) = number of kings in the hand,  
> * \(q\) = number of queens in the hand,  
> with \(k+q=t\) (the total number of royal cards you hold).  
> Because the suit of each king must be different from the suit of each queen, the \(t\) cards must all be of **different suits**.
> * Choose the \(t\) suits that will appear: \(\displaystyle\binom{4}{t}\).
> * Choose which of those \(t\) suits belong to kings: \(\displaystyle\binom{t}{k}\) (the remaining \(q=t-k\) suits become queens).
> * Fill the remaining \(7-t\) spots with any of the 16 non‑royal cards: \(\displaystyle\binom{16}{7-t}\).
> Hence the number of admissible hands with a given \((k,q)\) is  
> \[ N_{k,q}= \binom{4}{t}\binom{t}{k}\binom{16}{7-t},\qquad t=k+q\le 4 . \]
> Only the total \(t\) matters for the probability we will need later, so we can collect the terms for each possible \(t\):
> \[ H_t=\binom{4}{t}\,2^{t}\,\binom{16}{7-t}\qquad(t=1,2,3,4). \]
> (The factor \(2^{t}=\sum_{k=0}^{t}\binom{t}{k}\) accounts for all ways to split the \(t\) suits between kings and queens.)
> Evaluating:
> | \(t\) | \(\displaystyle H_t\) |
> |------|------------------------|
> | 1 | \(4\cdot2\cdot\binom{16}{6}=64\,064\) |
> | 2 | \(6\cdot4\cdot\binom{16}{5}=104\,832\) |
> | 3 | \(4\cdot8\cdot\binom{16}{4}=58\,240\) |
> | 4 | \(1\cdot16\cdot\binom{16}{3}=8\,960\) |
> Total admissible hands
> \[ H_{\text{tot}}=\sum_{t=1}^{4}H_t = 236\,096 . \]
> ### 3.  “Missing‑mate’’ cards that could finish a pair  
> If you hold \(t\) royal cards (any mixture of kings and queens, all of different suits), the **matching mates** that are still missing are exactly the \(t\) cards of opposite rank with the same suits.  
> All \(t\) of those mates are still among the 17 undealt cards (because none of them is in your hand).
> Therefore, after your hand is fixed, the kitty (3 cards drawn from the remaining 17) contains at least one matching mate with probability
> \[ p_t = 1-\frac{\binom{17-t}{3}}{\binom{17}{3}}, \qquad\text{where }\binom{17}{3}=680 .\]
> Evaluating for each possible \(t\):
> | \(t\) | \(\displaystyle \binom{17-t}{3}\) | \(p_t = 1-\frac{\binom{17-t}{3}}{680}\) |
> |------|-------------------|------------------------------------------|
> | 1 | 560 | \(\displaystyle\frac{120}{680}= \frac{3}{17}\approx0.1765\) |
> | 2 | 455 | \(\displaystyle\frac{225}{680}= \frac{45}{136}\approx0.3309\) |
> | 3 | 364 | \(\displaystyle\frac{316}{680}= \frac{79}{170}\approx0.4647\) |
> | 4 | 286 | \(\displaystyle\frac{394}{680}= \frac{197}{340}\approx0.5794\) |
> ### 4.  Combine hand‑count and conditional probability  
> The overall probability is the weighted average of the \(p_t\)’s, weights being the numbers of admissible hands \(H_t\):
> \[
\begin{aligned}
P
&= \frac{ \displaystyle\sum_{t=1}^{4} H_t\,p_t}{H_{\text{tot}}}
   =\frac{ \displaystyle\sum_{t=1}^{4} H_t\Bigl(1-\frac{\binom{17-t}{3}}{680}\Bigr)}{H_{\text{tot}}}\\[4pt]
&= \frac{H_{\text{tot}} - \displaystyle\frac{1}{680}
        \sum_{t=1}^{4} H_t\binom{17-t}{3}}
        {H_{\text{tot}}}.
\end{aligned}
\]
> Carrying out the arithmetic (details in the analysis) gives  
> \[
\sum_{t=1}^{4} H_t\binom{17-t}{3}=107\,336\,320,
\qquad
H_{\text{tot}}=236\,096.
\]
> Hence  
> \[
P = \frac{236\,096\;-\; \dfrac{107\,336\,320}{680}}{236\,096}
   = \frac{11\,877}{35\,836}
   \approx 0.3314 .
\]
> 
> ---
> ## 5.  Interpretation  
> * **≈ 33 %** of the time the kitty will hand you at least one card that lets you complete a king‑queen pair of the same suit, provided your starting hand already contains a king **or** a queen (or several of them) but none of them is already paired.  
> * If you have **only one** king (or only one queen) the chance is lower (≈ 18 %).  
> * The chance rises as you hold more royal cards (≈ 58 % if you already have three or four of them), because there are more “missing‑mate’’ cards that could appear in the kitty.
> That is the probability you were looking for.


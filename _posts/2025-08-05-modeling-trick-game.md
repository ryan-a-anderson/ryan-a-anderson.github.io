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

Now what if you have more than one potential meldunek-forming card in your hand? Say you have the king of hearts, queen of diamonds, and king of spades. How does that change the probability of getting a meldunek in the kitty? We wanted to take a look at how your probabilities evolved with extra "outs".

## Evaluation via Simulation

Note to start that you can only have 4 "outs" in the setup above – if you have 5 kings and queens in your hand then you must have a matching pair somehow. 

We simulated the probability of getting a meldunek in the kitty conditional on not having one in the player's hand. Our 90% credible intervals were $(0.096, 0.171)$ for the 1-out case, $(0.209, 0.267)$ for the 2-out case, $(0.287, 0.382)$ for the 3-out case, and $(0.276, 0.581)$ for the 4-out case.

<img width="1258" height="894" alt="image" src="https://github.com/user-attachments/assets/191fb87f-74f6-48c5-a6f9-5b1bc5caf3f2" />

The coding was kind of fun, just because it was important to code the 24-card deck in a faithful way, and checking for meldunek possibilities was a bit funky. My R code is below. It is not very tidyverse, which I should feel bad about because I was just TAing for UCLA's STATS 102A this summer session, but it was rather late at night when this came together!

```
cards <- 1:24
n_iter <- 100
results_by_out <- matrix(0,nrow=n_iter,ncol=4)
for(j in 1:n_iter){
  kitty_has_meldunek_results <- c()
  for(i in 1:1000){
    kitty_has_meldunek <- 0
    curr_hand_has_K_Q <- FALSE
    hand_has_meldunek <- TRUE
    
    curr_deck <- sample(cards, 24, replace = FALSE)
    hand_1 <- curr_deck[1:7]
    hand_2 <- curr_deck[8:14]
    hand_3 <- curr_deck[15:21]
    kitty <- curr_deck[22:24]
    K_Q_vector <- c(4, 5, 10, 11, 16, 17, 22, 23)
    
    if(!(1 %in% dist(K_Q_vector[K_Q_vector %in% hand_1]))) {
      hand_has_meldunek <- FALSE
      valid_checks <- K_Q_vector[K_Q_vector %in% hand_1]
      for(card in valid_checks) {
        if((card - 1) %in% K_Q_vector){
          if((card - 1) %in% kitty) {
            kitty_has_meldunek <- kitty_has_meldunek + 1
          }
        }
        else if((card + 1) %in% K_Q_vector) {
          if((card + 1) %in% kitty) {
            kitty_has_meldunek <- kitty_has_meldunek + 1
          }
        }
      }
    }
    hand_has_meldunek_results <- c(hand_has_meldunek_results, hand_has_meldunek)
    kitty_has_meldunek_results <- rbind(kitty_has_meldunek_results, c(length(valid_checks),kitty_has_meldunek))
  }
  out_1 <- mean(kitty_has_meldunek_results[kitty_has_meldunek_results[,1] == 1,2] > 0)
  out_2 <- mean(kitty_has_meldunek_results[kitty_has_meldunek_results[,1] == 2,2] > 0)
  out_3 <- mean(kitty_has_meldunek_results[kitty_has_meldunek_results[,1] == 3,2] > 0)
  out_4 <- mean(kitty_has_meldunek_results[kitty_has_meldunek_results[,1] == 4,2] > 0)
  results_by_out[j,] <- c(out_1, out_2, out_3, out_4)
}

```

Anyway, it was a fun little simulation to try out!

## LLM Evaluation

I asked this question to a few different SOTA models and thought it'd be interesting to reproduce their answers here.

### Claude 4 Sonnet

Claude got the idea basically done quickly. It took a sec for me to confirm we needed the _matching_ K/Q, not only any K/Q, but then its reasoning was very good.

> Ah, you're absolutely right! I misunderstood the pairing rule. You need the queen of the **same suit** as your king, not just any queen.
> 
> Let me recalculate:
> **Setup:**
> - You have one king of a specific suit (say King of Hearts)
> - You need the Queen of Hearts specifically to make a pair
> - After your 7-card hand, there are 17 cards remaining
> - Only **1 card** (Queen of Hearts) out of those 17 can help you
> - The kitty contains 3 of those 17 cards**Answer:** The probability that the kitty contains the matching queen (same suit as your king) is **17.6%** or about **3/17**.
>
> Your original calculation was exactly right: **P(at least one matching queen) = 1 - (16/17 × 15/16 × 14/15) = 17.6%**
> This makes much more sense - you're looking for 1 specific card out of the 17 remaining cards, and the kitty gives you 3 chances to find it. The probability simplifies to 3/17 since you're essentially asking "what's the probability that 1 specific card is among these 3 randomly chosen cards?"
> Much lower odds than my initial incorrect calculation, but that's the nature of needing a specific suited match rather than any card of the same rank!

### OpenAI's New Open Source Model – GPT OSS

OpenAI just released a new open source model today – it's called [GPT OSS](https://openai.com/open-models/) and comes in 120B parameter and 20B parameter versions. The response was not as focused, but because the model is tiny, the inference was essentially instantaneous. Pretty fun to play around with and definitely something I could see using in an OLLama type workflow.

> **Answer (≈ 33 %)**  
> If you have at least one king *or* one queen in your 7‑card hand, **but none of them is already paired with its mate**, the probability that the three‑card kitty contains a card that will complete a king‑queen pair (i.e. the queen of a king you own, or the king of a queen you own) is $\frac{11\,877}{35\,836}\;\approx\;0.331$.
> 
> ---
> ## How the number is obtained  
> ### 1.  The deck and the situation  
> * 24 cards in total: 4 K, 4 Q, and 16 other cards (9, 10, J, A of each suit).  
> * You are dealt 7 cards, then a 3‑card “kitty’’ is dealt from the remaining 17 cards.
> 
> We condition on the event **H** : *your hand contains at least one king or one queen, but never a king and the queen of the same suit.*
> 
> In other words, the suits of the kings you hold are all different from the suits of the queens you hold.
> 
> ### 2.  Counting admissible hands  
> Let  
> * $k$ = number of kings in the hand,  
> * $q$ = number of queens in the hand,
> * with $k+q=t$ (the total number of royal cards you hold).
> 
> Because the suit of each king must be different from the suit of each queen, the $t$ cards must all be of **different suits**.
> * Choose the $t$ suits that will appear: $\displaystyle\binom{4}{t}$.
> * Choose which of those $t$ suits belong to kings: $\displaystyle\binom{t}{k}$ (the remaining $q=t-k$ suits become queens).
> * Fill the remaining $7-t$ spots with any of the 16 non‑royal cards: $\displaystyle\binom{16}{7-t}$.
> 
> Hence the number of admissible hands with a given $(k,q)$ is  $ N_{k,q}= \binom{4}{t}\binom{t}{k}\binom{16}{7-t},\qquad t=k+q\le 4$.
> Only the total $t$ matters for the probability we will need later, so we can collect the terms for each possible $t$: $H_t=\binom{4}{t}\,2^{t}\,\binom{16}{7-t}\qquad(t=1,2,3,4)$.
> 
> (The factor $2^{t}=\sum_{k=0}^{t}\binom{t}{k}$ accounts for all ways to split the $t$ suits between kings and queens.)
> 
> Evaluating:
> 
> | $t$ | $\displaystyle H_t$ |
> |------|------------------------|
> | 1 | $4\cdot2\cdot\binom{16}{6}=64\,064$ |
> | 2 | $6\cdot4\cdot\binom{16}{5}=104\,832$ |
> | 3 | $4\cdot8\cdot\binom{16}{4}=58\,240$ |
> | 4 | $1\cdot16\cdot\binom{16}{3}=8\,960$ |
> 
> Total admissible hands: $ H_{\text{tot}}=\sum_{t=1}^{4}H_t = 236\,096 $.
> ### 3.  “Missing‑mate’’ cards that could finish a pair  
> If you hold $t$ royal cards (any mixture of kings and queens, all of different suits), the **matching mates** that are still missing are exactly the $t$ cards of opposite rank with the same suits.
> 
> All $t$ of those mates are still among the 17 undealt cards (because none of them is in your hand).
> 
> Therefore, after your hand is fixed, the kitty (3 cards drawn from the remaining 17) contains at least one matching mate with probability $p_t = 1-\frac{\binom{17-t}{3}}{\binom{17}{3}}, \qquad\text{where }\binom{17}{3}=680$.
> 
> Evaluating for each possible $t$:
> 
> | $t$ | $\displaystyle \binom{17-t}{3}$ | $p_t = 1-\frac{\binom{17-t}{3}}{680}$ |
> |------|-------------------|------------------------------------------|
> | 1 | 560 | $\displaystyle\frac{120}{680}= \frac{3}{17}\approx0.1765$ |
> | 2 | 455 | $\displaystyle\frac{225}{680}= \frac{45}{136}\approx0.3309$ |
> | 3 | 364 | $\displaystyle\frac{316}{680}= \frac{79}{170}\approx0.4647$ |
> | 4 | 286 | $\displaystyle\frac{394}{680}= \frac{197}{340}\approx0.5794$ |
> 
> ### 4.  Combine hand‑count and conditional probability  
> The overall probability is the weighted average of the $p_t$’s, weights being the numbers of admissible hands $H_t$:
> $ \begin{aligned}
P
&= \frac{ \displaystyle\sum_{t=1}^{4} H_t\,p_t}{H_{\text{tot}}}
   =\frac{ \displaystyle\sum_{t=1}^{4} H_t\Bigl(1-\frac{\binom{17-t}{3}}{680}\Bigr)}{H_{\text{tot}}}\\
&= \frac{H_{\text{tot}} - \displaystyle\frac{1}{680}
        \sum_{t=1}^{4} H_t\binom{17-t}{3}}
        {H_{\text{tot}}}.
\end{aligned}$
> 
> Carrying out the arithmetic (details in the analysis) gives $\sum_{t=1}^{4} H_t\binom{17-t}{3}=107\,336\,320,H_{\text{tot}}=236\,096$.
> 
> Hence  $P = \frac{236\,096\;-\; \dfrac{107\,336\,320}{680}}{236\,096} = \frac{11\,877}{35\,836} \approx 0.3314$.
> 
> ---
> ## 5.  Interpretation  
> * **≈ 33 %** of the time the kitty will hand you at least one card that lets you complete a king‑queen pair of the same suit, provided your starting hand already contains a king **or** a queen (or several of them) but none of them is already paired.  
> * If you have **only one** king (or only one queen) the chance is lower (≈ 18 %).  
> * The chance rises as you hold more royal cards (≈ 58 % if you already have three or four of them), because there are more “missing‑mate’’ cards that could appear in the kitty.
> That is the probability you were looking for.


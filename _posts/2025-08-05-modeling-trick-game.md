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


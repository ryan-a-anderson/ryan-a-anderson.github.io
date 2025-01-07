---
title: 'Modeling a Prediction Game'
date: 2024-12-18
permalink: /posts/2024/12/modeling-a-prediction-game/
tags:
  - bayesian modeling
---

## Game Setup
At the start of this year, a few friends and I got together to play a predictions game. We all filled out 5x5 bingo cards with predictions that had to come due in 2024 on any topic in the world, with eternal honor going to the one who got a bingo. Here's what my card looked like to start:

<img width="573" alt="image" src="https://github.com/user-attachments/assets/4920fde6-1328-4cc9-b052-3553c16f469b" />

Now on December 18th, here's where we're at. 

<img width="573" alt="image" src="https://github.com/user-attachments/assets/d4d2eede-ef84-430c-8f45-fde28f9828b0" />

Some of my misses were particularly galling --- before the 2023/24 season, Bayern Munich had won the Bundesliga 12 years running. [Then Harry Kane arrived](https://www.bundesliga.com/en/bundesliga/news/bayern-munich-bundesliga-harry-kane-england-spain-uefa-euro-2024-final-28196) and they let Leverkusen take the crown. It was probably a bit too [Ewing Theory](https://www.espn.com/espn/page2/story?page=simmons/010509a) to guess that the Los Angeles Angels would make the postseason the year after Shohei Ohtani's departure, while Nikki Haley winning 5 state primaries was a bit far-fetched.

Still, some politics, macroeconomic, and sports takes came to pass, and if we were to summarize my performance, we could say that of the 24 attempts I had, 8 came true by what is basically the end of the year (if Kourtney Kardashian announces another pregnancy for Xmas, I'll send Kris Jenner a card).

## Comparing Player Abilities
Since we are not quite at the end of the year, each cell in the bingo card can either be green, red or white, excepting the free space in the middle which does not count. The ability for a cell to be white reveals that the predictions game is actually a two-stage affair: as forecasters, we first had to come up with events which would trigger and move from white to red or green, then actually make the call on which way the event would go (i.e. turn red or green). The empirical results so far for each player are represented in a table below.

Table: Probabilities of each outcome for each player

|    | Red  | Green | White |
|:---|:----:|:-----:|:-----:|
|RA  | 0.17 | 0.33  | 0.50  |
|MDC | 0.29 | 0.38  | 0.33  |
|TK  | 0.12 | 0.25  | 0.62  |
|ZE  | 0.08 | 0.54  | 0.38  |
|DM  | 0.08 | 0.21  | 0.71  |

As you can see, there's good spread in forecasting ability. Players MDC and ZE have roughly equal levels of trigger-occurrence at 30-40%, but vastly different correct prediction likelihoods at 38% and 54%. To be more careful, we should estimate the probabilities of correct prediction conditional on triggering as well:

Table: Conditional probabilities of green and red given non-white

|    | p(green &#124; non-white) | p(red &#124; non-white) |
|:---|:-------------------------:|:-----------------------:|
|RA  |           0.67            |          0.33           |
|MDC |           0.56            |          0.44           |
|TK  |           0.67            |          0.33           |
|ZE  |           0.87            |          0.13           |
|DM  |           0.71            |          0.29           |

These conditional probabilities seem to have a much tighter spread, implying that trigger-occurrence is a big part of the predictions game. It would be very interesting to investigate how these conditional probabilities converge to the final unconditional probabilities at year-end!

## Bingo Dependence on Cell Triggering
Let's start again from first principles. In the real world, the game of bingo is played by filling in a bingo card with numbers or alphanumerics which range in a simple interval, say the integers 1 to 50. Each number has a 1/50 chance of being called, and in the event a cell has that particular number, then the cell is filled in. [In a 5x5 bingo card with free space]([url](https://www.sciencenews.org/article/probabilities-bingo)), there are 12 winning arrangements --- each of the columns, each of the rows, and two diagonals -- 8 of which do not use the free space.

Below I show the results of some simulation of the bingo game with different probabilities of calling a cell green. This could correspond to larger intervals in the real world game (i.e., $p(green) =  0.01$ might imply we're using numbers from 1 to 100), but in our case we should interpret it more as different levels of forecaster ability. The below chart compares $p(green)$ to $p(at least one bingo)$ on the card for the unconditional case, where cells may also be white.

![image](https://github.com/user-attachments/assets/5a5b16d3-1a5c-4dbd-9549-eb65c0f36741)

Moreover, we can estimate a logistic model here, which says that a 1 unit increase in the probability of getting a cell green correspond to a 12pt increase in the log-odds of getting a bingo.

<img width="526" alt="image" src="https://github.com/user-attachments/assets/a6595102-d13d-4558-8e01-a8ebd37b61e1" />

Overall, once $p(green) > 3/8$ or so, then you have about a 1-in-2 shot of getting a bingo. 

## Assessing Player Performance
With the above model in mind, we can use the regression model to predict our players' performance in the prediction game. We get predicted probabilities of at least one bingo as shown below:

Table: Predicted probability of at least one bingo for each player

|    |  x   |
|:---|:----:|
|RA  | 0.33 |
|MDC | 0.45 |
|TK  | 0.14 |
|ZE  | 0.88 |
|DM  | 0.09 |

We can also visualize it on the logistic curve by plotting as shown below:

![image](https://github.com/user-attachments/assets/cf8eb89c-1286-4781-8fce-cb0b329c386c)

All this parametric stuff is fine and good, but we can also brute-force this thing and just run some simulations! Parametric models are only useful if you're computing survival curves in the 70s. We've got machinery, let's put it to work!

The below plot shows density curves estimated by kernel methods for each player's probability of getting at least one bingo. To obtain these, we start with the unconditional $p(green)$ and then generate 100 bingo cards, assembling their number of bingoes for each. We run this simulation 100 times to get enough data to run the KDEs, which allow us to better understand not only the expected performance but how each player's place in the green-bingo relationship impacts the spread of their performance distribution.

![image](https://github.com/user-attachments/assets/fb51db0c-5a55-42c0-bd46-63860ff13c42)

## Conclusion
What do we make of all this? It's interesting to pull out the logistic --- and therefore highly non-linear --- relationship between our toy bingo calculations here and the chance of winning a predictions game. It's been very in vogue recently to discuss the performance of human predictors, especially the superforecasters investigated in [Philip Tetlock's research](https://thedecisionlab.com/thinkers/political-science/philip-tetlock). Moreover, people like the idea that market forces can solve the predictions problem by compelling agents to have skin in the game, which has contributed to the enormous online popularity of prediction markets like [Metaculus](https://www.metaculus.com) and [Polymarket](https://polymarket.com/ma), or especially the political betting sites like [PredictIt](https://www.predictit.org/). Hidden in the enthusiasm for this sort of thing is the idea, especially current in the Rationalist circles, that Bayesian reasoning can yield really effective thinking processes, and therefore accurate, or at least testable, predictions. If you could scale up skin-in-the-game Bayesian agents into a large market, presumably you would have solved the problem of telling the future.

This quick note explores some holes in that intellectual edifice. In the first place, the non-linearity of the relationship between success in the bingo game and success in making individual predictions should give commentators who claim to be able to assess prediction performance or accuracy pause. If it's hard to distinguish between 3/8 prediction accuracy and 1/2 prediction accuracy because success lies a logistic transform away from these parameter distances, how good could we be at assessing fine differences between humans who might be making a similar number of predictions over different time scales?

Moreover, a big problem with this analysis was the two-stage nature of the predictions game. Our participants were asked first to choose a set of 24 events to predict, and then secondarily to pick which way they would fall. Which question are prediction investigators more interested in knowing? 

![image](https://github.com/user-attachments/assets/ebe2e97f-2be8-4fdf-98bd-093c45149d18)

It's easy to see that there's less spread in the conditional probabilities than the unconditional probabilities, reflecting the fact that a large part of green performance comes in just choosing events correctly. While this question is less interesting in the 3rd week of December, this sort of thing would get very very thorny if we were trying to assess, say, mid-year performance in order to build a 2nd half of year prediction per player.

This is not even to mention the problem of overlapping predictions. Myself and player TK both predicted the Federal Reserve would cut more than twice this year –-- this prediction [came true for the both of us earlier this week](https://www.google.com/url?sa=t&source=web&rct=j&opi=89978449&url=https://www.cnbc.com/2024/12/18/fed-rate-decision-december-2024-.html&ved=2ahUKEwilqpSAxbeKAxVtMEQIHQntOjYQvOMEKAB6BAgQEAE&usg=AOvVaw17ZfX0jYP24PFuw6q2AkWu). I thought the Dodgers would win the NL pennant, while player MDC predicted the boys in blue to have the most wins in the MLB --- both hit. But the opposite situation prevailed in the case of Bob Iger leaving his 2nd stint as CEO of Disney, [who is said to be sticking around until 2026](https://www.google.com/url?sa=t&source=web&rct=j&opi=89978449&url=https://www.cbsnews.com/news/bob-iger-disney-ceo-james-gorman-chairman/&ved=2ahUKEwjx2puwxbeKAxVAEEQIHVwKGoYQFnoECEoQAQ&usg=AOvVaw1o4k5V1__EyGW81YIz-JUk), despite the predictions of myself and player DM. I hope the point has been illustrated --- with high covariance in the $p(white)$ process, it's amazing we could distinguish among players at all.

Finally, it's terribly important to mention that running a predictions game like this merely once leaves us with meagre data with which to assess true player performance. I thought a lot about what a Bayesian approach to this sort of analysis might look like, then decided against getting too much into that machinery since I thought the prior weights would have to be tuned so low as to make the whole thing uninteresting! We have essentially one sample here with which to make our estimates. Who's to say next year we won't all totally fail?



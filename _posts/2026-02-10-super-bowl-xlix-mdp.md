---
title: 'Should the Seahawks Have Run? A Markov Decision Process for Super Bowl XLIX'
date: 2026-02-10
permalink: /posts/2026/02/super-bowl-xlix-mdp/
tags:
  - markov decision processes
  - sports data
  - decision theory
---

February 1st, 2015. Super Bowl XLIX. The Seahawks trail 28-24 with 26 seconds left, 2nd and goal from the New England 1-yard line, one timeout in hand. Marshawn Lynch, the best power back in football, has just carried the ball to the 1 on the previous play. Everyone in the stadium knows what's coming next.

Everyone except offensive coordinator Darrell Bevell, who calls a slant pass. Russell Wilson throws. Malcolm Butler jumps the route. Interception. Game over. Patriots win.

The call was immediately branded the worst in Super Bowl history. But was it? The backlash was enormous and instant, but it was also almost entirely outcome-driven. Butler made an extraordinary play on a low-probability event. The question isn't whether the interception was bad --- of course it was. The question is whether the *decision* was bad, evaluated in expectation before the snap.

This is a question we can answer with math. The end of a football game, with a fixed number of downs, a ticking clock, limited timeouts, and a small set of actions, is a sequential decision problem. It's a textbook Markov decision process.

## The Setup

A **Markov decision process** (MDP) is a framework for modeling sequential decision-making under uncertainty. It consists of:

- A set of **states** $\mathcal{S}$
- A set of **actions** $\mathcal{A}$
- **Transition probabilities** $P(s' \mid s, a)$: the probability of moving to state $s'$ given you're in state $s$ and take action $a$
- A **reward function** $R(s)$: here, 1 for a touchdown and 0 for a turnover

The Markov property says the future depends only on the current state, not the path that got you there. This is a natural fit for football: given the down, distance, clock, and timeouts, the history of how you got there is irrelevant to your optimal decision going forward.

The goal is to find a **policy** $\pi^* : \mathcal{S} \to \mathcal{A}$ that maximizes the expected reward from every state. The value of a state under optimal play satisfies the **Bellman equation**:

$$
V^*(s) = \max_{a \in \mathcal{A}} \sum_{s' \in \mathcal{S}} P(s' \mid s, a) \, V^*(s').
$$

For terminal states, $V^*(\text{touchdown}) = 1$ and $V^*(\text{turnover}) = 0$.

## Modeling the Seahawks' Drive

### State Space

We need to capture the variables that affect the decision. Since Seattle is at the 1-yard line for the duration (a failed play doesn't change field position meaningfully), the relevant state is:

$$
s = (\text{down},\; \text{timeouts},\; \text{time})
$$

where:

- **Down** $\in \{2, 3, 4\}$ (they start on 2nd down)
- **Timeouts remaining** $\in \{0, 1\}$
- **Time remaining** $\in \{1, 2, 3\}$ (discretized into units, roughly 5--10 seconds each; $t = 3$ corresponds to ~26 seconds)

This gives us $3 \times 2 \times 3 = 18$ non-terminal states, plus two terminal states: **Touchdown** (win) and **Turnover** (loss --- encompassing interceptions, fumbles, turnover on downs, and time expiring).

### Actions

Two choices on every play: **Run** or **Pass**.

### Transition Probabilities

Here's where we parameterize the model with stylized but reasonable numbers for goal-line plays from the 1-yard line:

**Run play:**

| Outcome | Probability |
|:--------|:-----------:|
| Touchdown | 60% |
| Stopped, no gain | 35% |
| Fumble (turnover) | 5% |

**Pass play:**

| Outcome | Probability |
|:--------|:-----------:|
| Touchdown | 45% |
| Incomplete | 40% |
| Interception | 5% |
| Sack / TFL | 10% |

The per-play numbers favor the run by a wide margin: 60% touchdown rate vs. 45%. If this were a single-play game, running would be the obvious choice. But it isn't a single-play game. Seattle has up to three plays left, and *clock management* creates an asymmetry between the two actions that isn't visible in the per-play numbers.

### The Clock Model

This is the crux of the whole analysis. The key asymmetry:

- **After an incomplete pass**, the clock stops automatically. You advance to the next down, keep your timeout, and lose only one time unit.
- **After a failed run** (or a sack), the clock keeps running. You must either burn your timeout to stop it, or lose extra time scrambling to the line. If you have a timeout, you spend it and lose one time unit. If you don't, you lose two time units --- and if you don't have those time units, you're simply out of time.

This means the *failure mode* of a pass is much cheaper than the failure mode of a run when time is short.

## Solving the MDP

We solve for $V^*$ by **value iteration**: initialize all state values to 0, set terminal values, and iterate the Bellman equation until convergence.

```python
def value_iteration(trans_fn, epsilon=1e-12, max_iters=1000):
    states = get_all_states()
    V = {s: 0.0 for s in states}
    V["TOUCHDOWN"] = 1.0
    V["TURNOVER"] = 0.0
    policy = {}

    for _ in range(max_iters):
        delta = 0.0
        for s in states:
            old_v = V[s]
            best_val, best_act = -1.0, None
            for a in ["run", "pass"]:
                q = sum(prob * V[ns] for ns, prob in trans_fn(s, a))
                if q > best_val:
                    best_val, best_act = q, a
            V[s] = best_val
            policy[s] = best_act
            delta = max(delta, abs(V[s] - old_v))
        if delta < epsilon:
            break

    return V, policy
```

With 18 states and 2 actions, this converges immediately. The output is a complete prescription: for every possible game state, the optimal action and the win probability under optimal play.

## Results

### The Optimal Policy

Here is the optimal action and win probability for every state:

| State | $V^*(s)$ | Optimal Action | $Q(\text{run})$ | $Q(\text{pass})$ |
|:------|:--------:|:--------------:|:----------------:|:-----------------:|
| 2nd & Goal, 1 TO, ~26s | 84.30% | **Pass** | 84.15% | 84.30% |
| 2nd & Goal, 1 TO, ~12-19s | 81.00% | Pass | 78.75% | 81.00% |
| 2nd & Goal, 0 TO, ~26s | 81.00% | Pass | 78.75% | 81.00% |
| 3rd & Goal, 1 TO, ~12-19s | 81.00% | Run | 81.00% | 81.00% |
| 3rd & Goal, 0 TO, ~12-19s | 69.00% | Run | 69.00% | 67.50% |
| 4th & Goal, any | 60.00% | Run | 60.00% | 45.00% |

The **optimal policy for the Seahawks' actual situation** --- 2nd and goal, 1 timeout, 26 seconds --- is to **pass**.

But just barely. $Q(\text{pass}) = 84.30\%$ vs. $Q(\text{run}) = 84.15\%$, a margin of 0.15 percentage points. The decision is essentially a coin flip in expectation, which is itself a powerful finding.

### Strategy Comparison

How does the optimal policy compare to the two pure strategies?

| Strategy | Win Probability |
|:---------|:---------------:|
| Always Run | 81.00% |
| Always Pass | 78.30% |
| **Optimal (mixed)** | **84.30%** |

The optimal policy beats always-run by 3.3 percentage points and always-pass by 6.0 percentage points. The gain comes from sequencing: **pass first to preserve the clock, then run on later downs when you've secured time**.

The optimal sequence is: **Pass** on 2nd → **Run** on 3rd → **Run** on 4th.

### Why the Clock Changes Everything

The single-play numbers suggest running is obviously better. But consider what happens when the play *fails*:

**Failed run on 2nd down (35% chance):** The clock keeps running. Seattle burns their only timeout. Next state: 3rd down, 0 timeouts, $t = 2$. Win probability from here: **69.00%**.

**Incomplete pass on 2nd down (40% chance):** The clock stops for free. Timeout preserved. Next state: 3rd down, 1 timeout, $t = 2$. Win probability from here: **81.00%**.

That's a 12 percentage point gap in the failure states. The pass has a lower chance of scoring on *this* play, but its most likely failure mode (an incompletion) leaves Seattle in a dramatically better position for the remaining plays. The preserved timeout is worth a lot when you're under 30 seconds.

This is the key insight: **the per-play touchdown rate is the wrong quantity to optimize**. The right quantity is the probability of scoring across all remaining plays, which depends on what the clock and timeout situation look like after each possible outcome.

## Sensitivity Analysis

How robust is this finding? The interception rate is the obvious parameter to stress-test, since it's the catastrophic outcome unique to passing.

| INT Rate | $Q(\text{run})$ | $Q(\text{pass})$ | Optimal |
|:--------:|:----------------:|:-----------------:|:-------:|
| 1% | 84.15% | 86.22% | Pass |
| 3% | 84.15% | 85.26% | Pass |
| 5% | 84.15% | 84.30% | Pass |
| 8% | 84.15% | 82.87% | Run |
| 10% | 84.15% | 81.90% | Run |
| 15% | 84.15% | 79.50% | Run |

The crossover occurs around an interception rate of **7-8%**. At the baseline 5%, passing is still optimal. You'd need the interception rate to be meaningfully higher than the historical average for running to dominate.

On the other side, the always-run strategy only matches the optimal policy if the run touchdown rate rises from 60% to roughly **65%** --- not impossible, but asking a lot even of Marshawn Lynch.

## Discussion

The model here is deliberately simplified. Real football has more nuance than 18 states and 2 actions: play-action, formation, defensive alignment, the specific personnel on the field. And the transition probabilities are stylized rather than estimated from data. But the simplification is the point. Even in a toy model, the qualitative finding is clear: **clock dynamics under time pressure can offset a large per-play advantage in touchdown probability**.

The MDP framework also clarifies *why* this is so hard to see intuitively. Humans are good at comparing single-play outcomes (60% vs. 45% --- run is obviously better). We are much worse at computing multi-step expectations with branching futures and resource constraints. The value of a timeout at $t = 2$ on 3rd down doesn't pop out at you from the broadcast booth. But it's exactly what the Bellman equation captures.

There's a broader lesson here about **outcome bias** --- the tendency to evaluate the quality of a decision by how it turned out. The interception was a $\sim$5% event. If Butler doesn't jump the route, the pass falls incomplete, Seattle runs Lynch on 3rd down, and nobody remembers the play call. The *decision* was reasonable; the *outcome* was not. Confusing the two is one of the most persistent errors in how we think about strategy under uncertainty.

Pete Carroll's decision was not optimal in the way that, say, a checkmate-in-three is optimal. The margin was razor-thin. But it was defensible, and the MDP analysis shows that the standard narrative --- that passing was obviously, egregiously wrong --- doesn't survive contact with even a simple quantitative model.

The worst play call in Super Bowl history was, in expectation, approximately as good as the alternative.

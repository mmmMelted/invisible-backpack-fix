# Changelog

## 1.4.0
- Bodies now settle onto the ground whenever you take their backpack, even long after they died (they used to stay
  propped up if the ragdoll had already come to rest). A body wearing a backpack keeps its ragdoll live until the
  backpack is taken (up to 8 bodies at a time, 3 minutes each).

## 1.3.2
- Fixed a body vanishing and reappearing as a collapsed "ghost" at its death spot when you took its backpack after
  the ragdoll had already come to rest. Bodies now stay where they lie (taken within ~10 s of death they still
  settle onto the ground).

## 1.3.1
- Taking the backpack off a body lying on its back no longer leaves the body floating: it settles onto the ground
  (superseded by 1.3.2: only while the ragdoll is still active).

## 1.3.0
- A dead AI's backpack now stays on its back and is part of the ragdoll, so a body that falls backward lies on
  top of the backpack instead of burying it. You can loot it from the body.

## 1.2.0
- 25% of AI now spawn with a backpack (vanilla 5%), chosen by faction: bandits and Nomads get low-tier ones
  (Duffel, Nomad, sometimes Patrol), Guards mostly Patrol and Jaeger, Military mostly Jaeger and Kantamus.
  Adjustable in `rtv_backpackfix.cfg` (`chance_percent`; 5 = vanilla rate).
- The mod now makes the backpack choice itself, so every AI has exactly one visible backpack or none.

## 1.1.1
- Only invisible backpacks are removed; any backpack visible on an AI stays (and is set down beside the body on death).

## 1.1.0
- Worn backpacks no longer sink into the ground when an AI falls on its back: the backpack is set down beside the body.

## 1.0.0
- First release: AI without a backpack no longer drop invisible backpacks when they die.

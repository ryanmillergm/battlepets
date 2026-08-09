# Battlepets Game Design

## Match setup

- 2–8 participants.
- 2, 3, or 4 pets per participant.
- Bot, local pass-and-play, casual online, and competitive online modes.
- The host selects a 15-, 30-, or 60-second online turn timer.
- All pets are active, visible, and targetable.

## Turn and victory rules

Player order is randomized once at match start and then rotates. On a turn, the player selects one living, available pet and performs one legal action against any legal opposing pet. Eliminated players are skipped.

A pet at zero health is knocked out for the match unless a valid revive effect restores it. A player is eliminated when no pet remains alive and no currently usable revive effect remains. The last non-eliminated player wins.

## Pets and attacks

Each pet has:

- Admin-configured maximum health and descriptive tags such as `cat` or `fur`.
- A reusable basic attack.
- A super attack usable once per match.
- At most one optional initiated or automatic special ability in the first release.

Damage is fixed. There are no misses or general speed/defense stats. An unblockable speed attack bypasses shields and attack-cancel effects.

## Specialty cards

Each player receives one random specialty card at match start, visible to everyone. Admins configure whether it is manual, automatic, persistent, action-consuming, or free, along with its targets, conditions, duration, and use limit.

Supported effect primitives are damage, shield, revive, one-round stun, attack boost, one immediate extra action, unblockable attack, and tag-based conditions. Extra-action chains are limited to one per player turn.

Effects resolve in this order:

1. Validate the actor, action, and targets.
2. Resolve pre-action statuses and automatic triggers.
3. Resolve shields and other defensive effects.
4. Apply attack modifiers.
5. Apply damage and other primary effects.
6. Resolve knockouts and revive triggers.
7. Advance durations and the turn.

## Modes and progression

- Tutorial: choose a starter and learn against an Easy bot.
- Bot: play against Easy, Normal, or Hard AI.
- Local: 2–8 pass-and-play players.
- Casual: every player receives a random lineup with no duplicate pet definition within that lineup.
- Competitive: players select unique owned pets; missing slots are filled randomly.

Guests may use Bot and Local with temporary names. Registered profiles retain mode-separated history. A qualifying online match that began with at least two registered human players awards the winner 10 Battle Coins.

## Collection and shop

- New profiles choose one admin-designated starter.
- Packs contain two random pets and publish exact rarity and per-pet odds.
- Direct pet purchases and packs use Battle Coins.
- Duplicate copies are owned as quantities but cannot appear twice in one lineup.
- A user may redeem surplus copies for an admin-configured coin fraction or exchange recipe.
- Earned and purchased currency are tracked separately.

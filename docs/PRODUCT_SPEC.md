# Battlepets Product Specification

This document records settled product decisions. `GAME_DESIGN.md` is the concise rules reference; this file also covers accounts, lobbies, collection, administration, safety, and operations. Items marked **planned** are not assertions that the feature currently works.

## Product and release strategy

- Battlepets is an original turn-based creature battler inspired by the approachable structure of creature-battling games, using original Battlepet characters, names, rules, and art.
- The first client target is a Windows desktop direct download.
- Development is staged: offline vertical slice, backend/admin, online play, collection/economy, compliance-ready release, then payments and voice.
- Initial public operation is planned for the United States. Expansion requires a new legal and operational review.

## Match contract

- A match has 2–8 participants and exactly 2, 3, or 4 pets per participant.
- All pets are simultaneously active, visible, and targetable; there is no active-pet switching system.
- Player order is randomized once, then rotates for the rest of the match.
- A player normally chooses one living, available pet to perform one action on their turn.
- Any legal opposing pet may be targeted.
- Basic attacks are reusable. Each pet's super is usable once per match.
- Damage is deterministic: no general misses, random damage rolls, or speed statistic.
- An explicitly unblockable/speed attack bypasses shields and attack-cancel effects.
- Knocked-out pets remain out unless a valid card or ability revives them.
- Eliminated players are skipped. The last player with a living pet wins.

## Content model

Each pet has a stable ID, display name, maximum health, tags, art, basic attack, super attack, optional ability, rarity, direct price, starter eligibility, version, and publication state. Gameplay behavior must be composed from reviewed triggers, targets, conditions, and effect primitives; admins cannot upload executable code.

Initial effect primitives are damage, shield, revive, one-round stun, attack boost, one immediate extra action, unblockable attack, and tag-based conditions. Extra-action chains are limited to one additional action per player turn.

Every participant receives one random specialty card in every mode. It is visible to all participants. Admin configuration controls whether it is manually initiated or automatic, persistent or temporary, action-consuming or free, its valid targets and conditions, and its maximum uses.

## Modes

- **Tutorial:** the player chooses a starter and fights an Easy bot with guided instruction.
- **Bot:** the player selects Easy, Normal, or Hard AI.
- **Local:** 2–8 people share one device using pass-and-play.
- **Casual online (planned):** all participants receive random lineups; a lineup cannot contain the same pet definition twice.
- **Competitive online (planned):** participants select distinct definitions from pets they own. Empty lineup slots are filled randomly with definitions not already in that lineup.

Guests can use Tutorial, Bot, and Local modes with temporary generic names. Persistent profiles and online modes require a registered adult-owned account.

## Accounts and profiles (planned)

- An adult or parent registers with email and password and must verify the email before online access.
- An account may manage player profiles, including child profiles.
- Usernames are unique after case-insensitive normalization and are subject to moderation.
- Username changes have a proposed 30-day cooldown.
- Profiles choose from approved preset avatars; arbitrary avatar uploads are not part of the first release.
- Match history and statistics are separated by Bot, Local, Casual, and Competitive mode.

## Online lobby behavior (planned)

- Public lobbies are listed oldest-waiting first by default and can be sorted or filtered by capacity/team size.
- The host selects capacity from 2–8, team size from 2/3/4, Casual or Competitive mode, and a 15/30/60-second turn timer.
- A host may start after at least two participants join and may fill remaining seats with bots.
- A disconnected participant has a proposed 90-second reconnection grace period before bot takeover.
- Two consecutive turn timeouts also cause bot takeover.
- Online results are server-authoritative. A winner receives 10 Battle Coins only when the match began with at least two registered human participants.

## Collection and economy (planned)

- A new profile chooses one pet from the admin-designated starter set.
- Pets may be purchased directly or received from a pack.
- A pack contains exactly two pets. Published rarity labels and exact per-pet probabilities must be shown before purchase.
- Duplicate inventory copies are allowed as quantities, but the same pet definition cannot occupy two lineup slots.
- A pack should not return the same pet definition twice unless a future pack definition explicitly and visibly permits it.
- Surplus duplicates may be redeemed for an admin-configured fraction of value or exchanged using an admin recipe for a random different pet of the configured rarity rule, such as same-or-higher rarity.
- Specialty cards are assigned per match and are not collectible inventory.
- Earned and purchased Battle Coins use separate append-only ledger balances.

## Payments and child safety (planned and gated)

- Real-money coins use a parent-only hosted checkout, currently expected to use Stripe Checkout; no child-facing screen may initiate a purchase.
- Child online access, text chat, payments, and voice are independent server-side gates and default off.
- Text chat precedes voice and requires filtering, rate limiting, mute, block, report, moderation records, and limited retention.
- Child chat defaults off and requires separate verified-parent consent.
- Parents need access, export, deletion, and consent-revocation controls.
- Production enablement requires verifiable parental consent, qualified privacy/legal review, documented retention, incident response, and tested deletion.

## Administration (planned)

- A separate secured web dashboard is used for content and operations.
- Admin access requires role authorization, MFA, and an audit record for every material change.
- Admins manage pets, specialty cards, rarity tiers, packs, direct prices, odds, exchange recipes, starter eligibility, publication, retirement, and moderation.
- Published versions are immutable. Editing published content creates a new draft version.
- Retiring content prevents new use without deleting ownership or historical match snapshots.

## Initial content

Bailly and Porcha & Mercadies have recognizable existing art. Six labeled placeholder pets—Ember, Moss, Pebble, Ripple, Whisk, and Sprout—complete the eight-pet development roster. Placeholder names, balance, and art are not final production content. The visual target is polished pixel art.

## Open decisions

These require explicit resolution before their dependent feature ships:

- Final username rules, cooldown, and reserved-name policy.
- Final reconnect duration and timeout takeover policy after playtesting.
- Exact duplicate redemption fractions and exchange recipes.
- Pack duplicate policy, pricing, rarity table, and odds.
- Production consent provider, payment provider contract, retention periods, and supported age/region policy.
- Voice-chat scope, provider, recording policy, and whether it should ship at all.

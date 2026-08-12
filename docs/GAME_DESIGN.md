# Battlepets Game Design

## Match setup

- 2–8 participants.
- 2, 3, or 4 pets per participant.
- Bot, local pass-and-play, casual online, and competitive online modes.
- The host selects a 15-, 30-, or 60-second online turn timer.
- All pets are active, visible, and targetable.
- Bot and Local setup preferences are stored separately and restored when returning to the mode or restarting the game. Bot preferences include player count, team size, difficulty, and turn speed; Local preferences include player count and team size.

## Turn and victory rules

Player order is randomized once at match start and then rotates. On a turn, the player selects one living, available pet and performs one legal action against any legal opposing pet. Eliminated players are skipped.

Before the first turn, the game presents an animated shuffle that cycles through participant names, reveals who goes first, and displays the final turn order. The animation can be skipped with `Enter` or `Space`; skipping does not reroll the already-randomized order.

A pet at zero health is knocked out for the match unless a valid revive effect restores it. A player is eliminated when no pet remains alive and no currently usable revive effect remains. The last non-eliminated player wins.

## Pets and attacks

Each pet has:

- Admin-configured maximum health and descriptive tags such as `cat` or `fur`.
- A reusable basic attack.
- A super attack usable once per match.
- At most one optional initiated or automatic special ability in the first release.

Damage is fixed. There are no misses or general speed/defense stats. An unblockable speed attack bypasses shields and attack-cancel effects.

Porcha & Mercadies have 160 maximum health and use `Aggressive` as a 50-damage basic attack. Their once-per-match `Double Hair` super deals 70 damage and, if the target survives, stuns it for its next turn.

Axle has 130 maximum health and uses `Tail Whip` as a 45-damage basic attack. His once-per-match `Multistrike` super deals 40 damage for each living pet on the targeted opponent's team. For example, it attempts 40 damage when one opposing pet remains, 80 with two, 120 with three, or 160 with four; the combined damage is applied to the selected target.

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

## Battle readability

- Every pet card shows its basic and super attack names and current damage values to all players.
- Two-pet teams use tall cards; three- and four-pet teams use a two-column compact grid so names and statistics remain readable in large matches.
- Every player's specialty card is public, visually distinct from pet cards, and includes its effect description.
- The acting pet and current target receive enlarged, color-coded selection outlines.
- The selection summary names the acting pet, chosen action, damage or card effect, and target before confirmation.
- After confirmation, input pauses briefly while the attack name, result, and damage are presented; the board remains visible.
- Players can press `F` to flip open a larger detail panel for the targeted opponent, including health, tags, attacks, ability, and that opponent's specialty card. Within the panel, `A` shows the acting pet and `T` returns to the target pet.
- During Bot and Local matches, `Escape` opens a confirmation screen. Players may resume, abandon the match and return to the main menu, or exit Battlepets. Leaving an offline match does not save it.
- The battle control bar shows `H: All Controls`. Pressing `H` opens a complete control reference without advancing the match; `H` or `Escape` closes it.

## Modes and progression

- Tutorial: choose a starter and learn against an Easy bot.
- Bot: play against Easy, Normal, or Hard AI.
- Local: 2–8 pass-and-play players.
- Casual: every player receives a random lineup with no duplicate pet definition within that lineup.
- Competitive: players select unique owned pets; missing slots are filled randomly.

Guests may use Bot and Local with temporary names. Registered profiles retain mode-separated history. A qualifying online match that began with at least two registered human players awards the winner 10 Battle Coins.

The human player earns 2 Battle Coins for winning a Bot match. The offline development balance is saved locally and displayed in the Play and Shop submenus. Online wins award 10 Battle Coins only under the qualifying registered-human rule and will use the authoritative server ledger when online play is implemented. Local matches do not award coins.

Before a Local match begins, the roster screen asks for each participant's display name. Every seat can independently be changed between Human and Bot. Pass-and-play handoff screens appear only before a human participant's turn.

Bots first target opponents who have not yet received a hostile action. If several opponents are untouched, the bot chooses the one with the greatest combined remaining health across all of its pets. After every opponent has been attacked, the selected difficulty's normal targeting behavior applies. A blocked attack and an offensive damage or stun specialty card count as an attack for this rule.

Bot matches offer Relaxed, Normal, and Quick turn-presentation speeds. This setting changes the pause before a bot acts and the time its attack/result presentation remains visible; it does not alter AI difficulty or battle rules. Relaxed is the default.

## Collection and shop

- After the title screen, the main hub presents Inventory, Play, and Shop. Play opens the Bot/Local choices. Shop opens with `S`; its PET PACKS card opens with `P` or a left click.
- The local development pack shop sells Basic (30 coins), Uncommon (50), Epic (75), and Legendary (100) packs. Each contains two different pets and displays its exact rarity and per-pet draw odds before confirmation.
- Inventory persists owned copy quantities. Any copy may be sold after two confirmations for 5/10/20/30 coins at Basic/Uncommon/Epic/Legendary rarity; selling the last copy removes that pet from available lineups.
- Bot setup opens Collection with `C`; Local opens it with `C` on each selected roster seat. The collection shows owned pets in stat cards plus empty future slots. Players select exactly the configured team size with no duplicate definitions. Bot mode applies the lineup to Player 1; Local mode stores a separate lineup for every configured seat. The same screen is intended for the registered profile in Online mode.
- New profiles choose one admin-designated starter.
- Packs contain two random pets and publish exact rarity and per-pet odds.
- Direct pet purchases and packs use Battle Coins.
- Duplicate copies are owned as quantities but cannot appear twice in one lineup.
- A user may redeem surplus copies for an admin-configured coin fraction or exchange recipe.
- Earned and purchased currency are tracked separately.

# Roadmap

## M0 — Foundation

- Establish the root GameMaker project as canonical.
- Preserve and inspect the ignored `bp/` legacy project.
- Document rules, architecture, development, safety, and status.
- Replace temporary and Pokémon-derived identifiers as systems are rebuilt.

## M1 — Offline battle vertical slice

- Data-defined eight-pet catalog with original characters and remaining labeled development placeholders.
- Deterministic battle engine for 2–8 players and 2–4 pets each.
- Main menu, tutorial, Bot, Local, battle setup, battle board, and results.
- Easy, Normal, and Hard bot behavior.

## M2 — Backend and admin

- Dockerized Node/PostgreSQL service and browser admin dashboard.
- Accounts, parent-managed child profiles, unique usernames, approved avatars, and email verification.
- Versioned pet, card, pack, rarity, price, odds, and exchange content.

## M3 — Online play

- Public lobby browser, host controls, bot filling, authoritative matches, reconnects, and results.
- Moderated text chat and mode-separated history/statistics.
- Server-awarded Battle Coins for qualifying wins.

## M4 — Collection and economy

- Starter choice, inventory quantities, team builder, direct shop, two-pet packs, published odds, and duplicate redemption.
- Auditable earned/purchased currency ledger.

## M5 — Safe public release

- Parent notice/consent integration, access/export/deletion, retention enforcement, moderation operations, deployment hardening, and Windows packaging.
- Child online features remain disabled until qualified privacy review approves production use.

## M6 — Payments and voice

- Parent-only hosted checkout and webhook fulfillment after legal/payment review.
- Separately reviewed WebRTC lobby voice with distinct parental opt-in.

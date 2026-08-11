# Battlepets Administrator Guide

## Important current limitation

The browser admin at `http://localhost:5173` is currently a navigation and API-health scaffold. Its editors are intentionally locked because authentication, role checks, MFA, audit logging, and content CRUD/publishing APIs are not implemented. It cannot currently create or publish a pet.

Until those controls exist, changing the development catalog is a developer operation in GameMaker. Do not edit production database rows manually; doing so would bypass validation, version history, and auditing.

## Running the current admin scaffold

1. Copy `.env.example` to `.env` and `server/.env.example` to `server/.env`.
2. Use the same local PostgreSQL password in both database settings and replace the development JWT secret.
3. From the repository root, run `docker compose up -d postgres mailpit`.
4. In `server/`, run `npm install`, `npm run db:generate`, `npm run db:migrate`, and `npm run dev`.
5. In `admin/`, run `npm install` and `npm run dev`.
6. Open `http://localhost:5173`. A green API status confirms only that the service is reachable, not that editing is enabled.

## Creating a development pet today

The live offline catalog is defined in `scripts/scr_bp_catalog/scr_bp_catalog.gml`.

1. Import the pet's original artwork into the root GameMaker project and give the sprite a stable, original asset name.
2. Add one `bp_pet_definition(...)` entry to the `_pets` array.
3. Supply these fields in order:
   - stable lowercase ID, using underscores and never changing after release;
   - player-facing name;
   - positive maximum health;
   - basic attack name and positive fixed damage;
   - super name and positive base damage;
   - an array of normalized lowercase tags;
   - GameMaker sprite asset, or `-1` only for an explicitly labeled placeholder;
   - whether the basic attack is unblockable;
   - optional super stun duration in rounds;
   - optional `true` when the super's listed damage is multiplied by the targeted opponent's number of living pets.
4. Increase the returned catalog `version` when making a compatibility-relevant catalog change.
5. Open `battlepets.yyp`, run the Windows target, and confirm the log says `BATTLEPETS SELF-TESTS PASSED`.
6. Play at least one Bot and one Local match using the new pet. Check its art, health, attacks, super-use limit, targeting, knockout behavior, and interaction with every relevant specialty card.
7. Update `GAME_DESIGN.md` if rules changed, this guide if fields changed, and `PROGRESS.md` with verification evidence.

Example development entry:

```gml
bp_pet_definition(
    "cloud_pup",
    "Cloud Pup",
    100,
    "Breeze Bop",
    16,
    "Storm Zoom",
    34,
    ["dog", "fur", "air"],
    spr_cloud_pup,
    true,
    0,
    false
)
```

The current helper is deliberately small and does not yet expose rarity, direct price, starter eligibility, or a configurable ability object. Those fields exist in the planned backend model and must not be implied by this GML example.

## Planned dashboard workflow: create a pet

Once M2 administration is implemented, an authorized administrator will:

1. Sign in with an Admin account and complete MFA.
2. Open **Battlepets**, select **New draft**, and enter a permanent slug and display name.
3. Select a rarity, direct coin price, starter eligibility, maximum health, and normalized tags.
4. Upload approved pixel-art assets and provide preview/animation metadata. Uploaded files must pass type, size, dimension, malware, and ownership checks.
5. Configure the basic attack and super using preset targets, conditions, damage, and effects. Configure at most one optional ability for the first release. Arbitrary scripts are never accepted.
6. Run validation. It must reject duplicate slugs, invalid values, unknown tags/effects, missing art, inaccessible text, illegal targets, effect loops, and unsafe extra-action chains.
7. Preview the pet in representative battle states and run automated balance/rules fixtures.
8. Save the draft for review. A second authorized reviewer should approve production publication.
9. Publish a new immutable content version. Publication records the actor, timestamp, before/after values, validation result, and reason.
10. Verify catalog delivery in a non-production environment before enabling the version in production.

## Editing, retiring, and restoring pets

- Never mutate a published revision in place. **Edit** creates a new draft based on the latest revision.
- Balance changes require a new version and regression tests. Active matches retain their snapshotted version.
- **Retire** removes a pet from new lineups, packs, and direct purchases. It must not delete inventory, currency history, or past matches.
- Restoration publishes a reviewed new revision; it does not rewrite the retired revision.
- Permanent deletion is limited to unused drafts. Published content is retained for referential and audit integrity.

## Specialty cards

Create cards from approved effect primitives only. Configure trigger (manual/automatic), target rules, conditions, action cost, persistence/duration, amount, and maximum uses. Preview visibility because each player's assigned card is public to all match participants. Test automatic triggers, knockout/revive timing, shields, unblockable attacks, stuns, boosts, and extra-action limits.

## Rarities, packs, prices, and exchange recipes

1. Create rarity tiers before assigning pets; supply a stable slug, display label, display order, accessible color, and active state.
2. A pack contains exactly two draws. Select eligible published pets and configure weights.
3. The system must calculate and display normalized exact per-pet odds; the administrator reviews the calculated result rather than entering contradictory marketing odds.
4. Configure coin price and whether repeated definitions within one pack are prohibited. The default product decision prohibits them.
5. Configure duplicate redemption as a disclosed value/fraction and exchange recipes as required quantities plus eligible output rarities.
6. Preview edge cases, including a pool too small to supply two distinct pets, inactive content, and rounding totals.
7. Publish a versioned configuration with an effective date. Never silently change odds for an already advertised purchase.

## Starters

Only active, published, age-appropriate pets can be starter-eligible. Keep enough eligible choices to provide a meaningful selection. Changing eligibility affects new profiles only and never removes an existing player's pet.

## Moderation and operations

Moderator and Admin roles are distinct. Moderators may review reports and apply documented sanctions but cannot publish game content or alter currency. Currency adjustments require an Admin reason, a unique idempotency key, and an append-only ledger entry; balances must never be edited directly.

Before enabling child online access, chat, payments, or voice, verify that its independent release gate has written approval and that required controls in `SECURITY_PRIVACY.md` have passed. A dashboard toggle alone is never sufficient authorization.

## Publication checklist

- Original content ownership is recorded.
- Names, descriptions, and tags pass moderation and accessibility review.
- IDs are stable and unique; all referenced content exists and is published.
- Values and effects pass schema validation and automated fixtures.
- Art renders correctly at supported resolutions.
- Pack odds total correctly and displayed disclosures match behavior.
- A reviewer approved the change and the audit record contains a reason.
- Staging smoke tests passed; rollback means retiring the new revision and restoring a known-good revision.

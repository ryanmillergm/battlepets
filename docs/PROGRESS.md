# Progress

## Status legend

- `[ ]` not started
- `[-]` in progress
- `[x]` complete and verified

## M0 — Foundation

- [x] Audit the original project and identify the canonical root project.
- [x] Document the intended game rules and staged product vision.
- [x] Ignore the preserved `bp/` legacy project without deleting it.
- [-] Inspect and salvage useful legacy animations and art.
- [-] Replace temporary resources and broken prototype logic.

## M1 — Offline battle vertical slice

- [x] Define the content catalog and eight-pet development roster.
- [x] Implement the current deterministic battle state and action validation.
- [x] Implement the current shield, revive, damage, stun, boost, knockout, elimination, and results behavior.
- [x] Implement Main Menu, setup, tutorial shortcut, Bot, and Local flows for the vertical slice.
- [x] Implement Easy, Normal, and Hard AI.
- [x] Run automated construction checks for 2–8 players and team sizes 2, 3, and 4.
- [x] Add visible attack values, specialty-card descriptions, selection summaries, card details, and staged damage presentation.
- [-] Complete hands-on gameplay and usability testing for every setup combination.

## M2 — Backend and admin foundation

- [x] Create the Node.js/TypeScript Fastify service shell and health endpoint.
- [x] Implement fail-closed child-online, chat, payment, and voice feature flags.
- [x] Implement and test the initial authoritative TypeScript attack reducer.
- [x] Define the initial PostgreSQL/Prisma account, profile, content, inventory, currency, lobby, match, and action schema.
- [x] Add local PostgreSQL and Mailpit services through Docker Compose.
- [x] Build the React/Vite admin navigation and service-health shell.
- [ ] Implement authentication, MFA, authorization, and audit logging.
- [ ] Implement admin CRUD, validation, preview, versioning, and publishing APIs/forms.

## Verification completed

- [x] GameMaker Windows build and startup smoke test completed; runtime reported `BATTLEPETS SELF-TESTS PASSED`.
- [x] Server TypeScript build completed successfully.
- [x] Server battle tests passed (4 tests).
- [x] Prisma client generation completed successfully.
- [x] Service health smoke test completed successfully.
- [x] Admin production build completed successfully.
- [x] Server and admin dependency audits reported no known vulnerabilities at the time checked.

## Later milestones

- [ ] M3 online play and chat.
- [ ] M4 collection and economy.
- [ ] M5 compliance-gated public release.
- [ ] M6 parent-only payments and separately gated voice.

## Known legacy issues

- The old pack object destroys itself before its intended spawn code and references undefined coordinates.
- The old follower experiment targets a missing `obj_player` and runs only in Create.
- The INI pool scripts use inconsistent section names and Pokémon-derived placeholders.
- `scr_open_pack` is empty and `obj_server` is not a networking implementation.

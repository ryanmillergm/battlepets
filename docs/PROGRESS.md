# Progress

## Axle roster update

- [x] Replaced the Ripple placeholder with Axle and assigned the `Axle` sprite asset.
- [x] Set Axle to 130 health, `Tail Whip` at 45 damage, and the once-per-match `Multistrike` super at 40 damage per living pet on the targeted opponent's team.
- [x] Added dynamic Multistrike damage calculation, visible multiplier explanations, and a self-test covering a three-pet target team for 120 attempted damage.
- [x] Added owner-only Exalted Ghost Axle with guaranteed local ownership, black-outlined white/light-blue rarity treatment, 150 health, 50-damage InvisiCrunch, and 70-damage Ghostability that activates 70% hostile-damage avoidance while preserving legal targeting; excluded it from rewards and bot teams.
- [x] Defined Exalted pets as skill-event/special-case rewards, made the entire rarity unsellable, and gave Ghost Axle a displayed 1,400 Battle Coin value.
- [x] Added the reserved Glitch owner identity with an owner-ID-controlled verified checkmark on the title and main hub for local account testing.
- [x] Enlarged the gold BATTLEPETS main-menu logo across most of the screen with a dark offset shadow, then replaced stretched default lettering with a slightly smaller native-resolution bold title font for sharper rendering.
- [x] Added mouse-wheel row scrolling to Inventory and choose-pets collection screens without off-screen keyboard focus overriding the wheel position.

## Local pack and inventory economy

- [x] Added four priced, tier-capped Battlepet packs with published draw odds and two different rewards.
- [x] Set fixed rare Legendary odds to 1.5% for Axle and 1.5% for Porcha & Mercadies in packs and the future expanded Trade Up pool.
- [x] Set Epic pack odds to 10% for Bailly and 10% for Jack per draw (20% Epic total, 30% Basic, and 50% Uncommon).
- [x] Added persistent pet quantities, pack purchase confirmations/results, and Battle Coin deductions.
- [x] Added Inventory with duplicate counts, two-step selling, lineup cleanup, and rarity-based coin returns.
- [x] Added the Inventory / Play / Shop hub plus keyboard and mouse pack navigation.
- [x] Replaced the redundant Shop link inside Play with a green Trading entry and added a dark-green submenu for planned Trade Up and Player Trading flows with keyboard and mouse selection.
- [x] Centered the Play submenu's game modes and added a left-side planned Settings entry with keyboard and mouse feedback.
- [x] Implemented persistent Trade Up exchanges with player-selected same-rarity copies, confirmation, lineup cleanup, and a white reward-reveal screen.
- [-] Added left-click support across the title, menus, setup, roster, collection, transitions, pause, results, Shop, Inventory, Trading, and battle selection/action flows; hands-on full mouse-only verification remains.

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
- [x] Add a locally persisted development Battle Coin balance and 2-coin Bot-win rewards; retain server-authoritative online rewards as planned work.
- [x] Add the development Collection grid and per-seat Bot/Local team selection using the owned eight-pet roster.
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
- [x] Added a main-menu-only `FULLSCREEN` / `WINDOWED` button, retained `F11` and `Alt+Enter` shortcuts, rebuilt and installed the Windows game, and manually confirmed true fullscreen switching on August 11, 2026.
- [x] Added the white-and-gold `BP` Windows application icon source, PNG preview, and ICO asset for desktop shortcuts and packaged installs on August 11, 2026.
- [x] Added a thicker square black border directly against the outside of the Windows application and Desktop icon, with brighter high-contrast gold `BP` lettering.
- [x] Softened the icon's bright gold slightly and added a thin black outline around the `BP` letters for clarity.
- [x] Strengthened the `BP` lettering to a complete black outline and generated a multi-resolution Windows ICO for sharper scaling.
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

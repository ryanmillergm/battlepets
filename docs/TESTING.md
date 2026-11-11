# Testing and Verification

## Current automated checks

The GameMaker client runs self-tests when `obj_game` is created. They construct every supported player/team-size combination and check pack definitions and rarity caps, basic attacks, shields, unblockable behavior, bot target priority, and Axle's living-opponent-pet Multistrike scaling. A successful startup writes `BATTLEPETS SELF-TESTS PASSED` to the GameMaker output log.

The pack checks also verify that Epic packs give Bailly and Jack a 10% chance each and Legendary packs give Axle and Porcha & Mercadies a fixed 1.5% chance each per draw. Once ordinary Legendary pets exist, repeated Epic-to-Legendary Trade Ups should preserve the same 1.5% chance for each rare Legendary and distribute the remaining outcomes among ordinary Legendaries.

The TypeScript service has four battle reducer tests. Run:

```powershell
Set-Location server
npm test
npm run build
npm run db:generate
```

Build the dashboard with:

```powershell
Set-Location admin
npm run build
```

## Local smoke test

1. Start PostgreSQL and Mailpit with `docker compose up -d postgres mailpit`.
2. Start the server with `npm run dev` in `server/`.
3. Request `http://localhost:3000/health` and confirm an `ok` response.
4. Start the dashboard with `npm run dev` in `admin/` and confirm its API indicator becomes green.
5. Run the GameMaker Windows target and confirm its self-test message.
6. On the main menu, click `FULLSCREEN` and confirm true fullscreen mode opens and the button changes to `WINDOWED`; confirm the button is hidden on every other screen, returning to the main menu restores access to it, and the 1600x900 GUI layout remains intact. Repeat the mode toggle with `F11` and `Alt+Enter`.
7. Confirm Windows builds and installed Desktop shortcuts display the white icon with centered gold `BP` lettering at small and large icon sizes.
8. Open Play and confirm Settings appears on the left with a coming-soon label, game modes are centered, and green Trading appears on the right without a milestone label. Verify `S` and clicking Settings show its coming-soon message. Use `T` and a left click to open Trading's dark-green submenu; verify left/right, Enter, and mouse selection for Trade Up and Player Trading, their M4 status messages, Escape returning to Play, and the separate main-hub Shop remaining available.
9. Open Trading and confirm Trade Up has no M4 label. In Trade Up, verify choosing Basic, Uncommon, or Epic opens the matching collection; left click/Space adds an available copy, right click/R removes one, exactly three chosen copies are required, and confirmation can be cancelled. Confirm a trade consumes only the selected copies, awards one random next-rarity pet on a white result screen, persists after restart, and removes depleted pets from saved lineups. Verify Legendary cannot be selected as a source tier.
10. Complete the title, hub, Play, setup, Local roster, collection, shuffle, handoff, pause, result, Shop, Inventory, Trading, and Trade Up flows using the mouse; confirm every visible action can be activated with left click while keyboard controls remain available.
11. Confirm Ghost Axle is restored to at least one owned copy and appears first in choose-pets screens as Exalted with a black-outlined white/light-blue treatment, 150 health, 50-damage InvisiCrunch, and 70-damage Ghostability against any opposing pet. Confirm it never appears in packs, Trade Up rewards, or random bot teams. Before Ghostability, verify hostile damage connects normally; after Ghostability, verify Ghost Axle remains targetable and repeated hostile damage attempts phase through at the configured 70% rate while successful attacks connect at 30%.
12. Confirm Ghost Axle displays a 1,400 Battle Coin value while showing `EXALTED - NOT SELLABLE`. No Exalted Battlepet may be sold, including duplicate copies.
13. Confirm the title and main hub display `Glitch` with a blue checkmark. Naming a local battle player Glitch must not display an account verification badge.
14. Confirm the sharp gold BATTLEPETS logo spans most of the main-menu width without blur or overlap with the profile name, Play control, or Tutorial control.
15. Confirm the installed application and Desktop shortcut show the slightly softened bright-gold BP letters with a complete black outline and a thicker square black frame directly against the outside edge. Check that the multi-resolution icon remains sharp at small, medium, and large Desktop sizes.
12. Populate enough pets to exceed the visible rows, then verify the mouse wheel scrolls Inventory and every choose-pets collection screen while clicks and keyboard focus map to the correct scrolled card.

## Required manual battle matrix

Test team sizes 2, 3, and 4 at participant counts 2 through 8. For each supported mode, verify setup, turn rotation, legal/illegal targets, every pet acting, basic attacks, one-use supers, every specialty effect, knockout, revive, elimination, final result, pass-and-play concealment, and each AI level. Automated state-construction coverage does not replace this hands-on matrix.

## Known coverage gaps

- Pack purchase, save/reload, mouse input, confirmation dialogs, and duplicate-sale flows require manual UI testing.

- No automated client UI/input tests or full 2–8 player gameplay simulations.
- Offline and TypeScript engines do not yet share generated cross-language fixtures.
- No authentication, admin CRUD, lobby, reconnect, economy, moderation, or end-to-end online tests because those features are not implemented.
- No production load, penetration, accessibility, deletion/retention, consent, payment, or voice testing.

Record the command, date, environment, result, and relevant log whenever a milestone is marked verified in `PROGRESS.md`.

# Testing and Verification

## Current automated checks

The GameMaker client runs self-tests when `obj_game` is created. They construct every supported player/team-size combination and check basic attacks, shields, and unblockable behavior. A successful startup writes `BATTLEPETS SELF-TESTS PASSED` to the GameMaker output log.

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

## Required manual battle matrix

Test team sizes 2, 3, and 4 at participant counts 2 through 8. For each supported mode, verify setup, turn rotation, legal/illegal targets, every pet acting, basic attacks, one-use supers, every specialty effect, knockout, revive, elimination, final result, pass-and-play concealment, and each AI level. Automated state-construction coverage does not replace this hands-on matrix.

## Known coverage gaps

- No automated client UI/input tests or full 2–8 player gameplay simulations.
- Offline and TypeScript engines do not yet share generated cross-language fixtures.
- No authentication, admin CRUD, lobby, reconnect, economy, moderation, or end-to-end online tests because those features are not implemented.
- No production load, penetration, accessibility, deletion/retention, consent, payment, or voice testing.

Record the command, date, environment, result, and relevant log whenever a milestone is marked verified in `PROGRESS.md`.

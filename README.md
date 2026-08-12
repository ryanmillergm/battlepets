# Battlepets

Battlepets is a turn-based, free-for-all creature battler built with GameMaker. Two to eight players bring teams of two to four Battlepets, take turns in a randomized rotating order, and may attack any opposing pet. The final player with a living pet wins.

The current implementation target is a polished Windows desktop vertical slice with a tutorial, three bot difficulties, and local pass-and-play. Accounts, public online lobbies, collection/economy systems, child-safety controls, payments, and voice are staged behind that playable foundation.

## Repository layout

- `battlepets.yyp` and the root GameMaker resource folders are the canonical client.
- `bp/` is a preserved legacy copy and is intentionally ignored. It may contain older animation frames worth recovering.
- `docs/` contains the rules, architecture, roadmap, progress log, and development instructions.

## Current status

The repository now contains a playable offline foundation, deterministic battle rules, three bot difficulties, a backend/service foundation, a PostgreSQL schema, and an admin-dashboard shell. Online play, accounts, collection management, economy endpoints, and admin editing forms are not complete. See [docs/PROGRESS.md](docs/PROGRESS.md) for verified status.

## Documentation

- [Game design](docs/GAME_DESIGN.md): player-facing rules and modes.
- [Product specification](docs/PRODUCT_SPEC.md): consolidated product decisions and acceptance rules.
- [Architecture](docs/ARCHITECTURE.md): client, service, database, and trust boundaries.
- [Administrator guide](docs/ADMIN_GUIDE.md): current and planned content-management procedures.
- [Testing](docs/TESTING.md): verification commands, coverage, and known gaps.
- [Security and privacy](docs/SECURITY_PRIVACY.md): child-safety and release gates.
- [Roadmap](docs/ROADMAP.md) and [progress](docs/PROGRESS.md): planned and completed work.

## Development

1. Open `battlepets.yyp` in GameMaker 2024.14 or a compatible newer release.
2. Run the project using the Windows target.
3. Treat generated `*.resource_order` files as local IDE state; they are ignored.

On the main menu, click `FULLSCREEN` to enter true fullscreen mode or `WINDOWED` to return. `F11` and `Alt+Enter` are also available as keyboard shortcuts.

### Local service and admin dashboard

1. Copy the root `.env.example` to `.env` and set a local PostgreSQL password.
2. Copy `server/.env.example` to `server/.env`, use the same database password in `DATABASE_URL`, and replace the development JWT secret.
3. Run `docker compose up -d postgres mailpit` from the repository root.
4. Run `npm install`, `npm run db:generate`, and `npm run db:migrate` in `server/`.
5. Run `npm run dev` in `server/` and `admin/` in separate terminals.
6. Open the admin dashboard at `http://localhost:5173`; local email is visible at `http://localhost:8025`.

Development adapters fail closed: child online access, chat, payments, and voice default to disabled.

## Repository policy

Agents may read and edit this repository, but must not commit or push without explicit user permission. See `AGENTS.md`.

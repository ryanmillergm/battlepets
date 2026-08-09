# Architecture

## Components

- GameMaker Windows client: menus, offline rules engine, local saves, bot AI, rendering, input, and HTTP/WebSocket client.
- Node.js 22/TypeScript service: REST API, secure WebSockets, server-authoritative online rules, authentication, economy, moderation, and content delivery.
- PostgreSQL: accounts, profiles, content, inventories, currency ledger, lobbies, matches, results, consent, and moderation records.
- React/TypeScript admin dashboard: validated content authoring, publication, account moderation, and operations.
- Local object storage: versioned pet/card art, replaceable with managed object storage later.

Local development will use Docker Compose. Production deployment remains portable to managed cloud infrastructure.

## Contracts

REST and WebSocket payloads use versioned JSON Schema/OpenAPI definitions. Core resource families are authentication, profiles, parental controls, catalog, inventory, shop, history, lobby discovery, moderation, and admin content.

Online clients submit requested actions, never results. The server validates the current turn, actor, target, content version, effect use limits, and resulting state. Every accepted action receives a monotonically increasing sequence number; duplicate or stale commands are rejected idempotently.

Offline GML and online TypeScript rules engines consume the same content shape and deterministic test fixtures. Published content is snapshotted into a match so later edits cannot change an active or historical battle.

### Implemented service surface

- `GET /health` returns service health and protocol version.
- `GET /v1/features` returns the four independent release gates.
- `GET /v1/ws` accepts a WebSocket connection but currently rejects commands as unauthenticated.

Authentication, catalog CRUD, publishing, lobbies, moderation, economy, and account APIs are designs, not implemented endpoints. Their OpenAPI and WebSocket schemas must be written before client integration.

## Content lifecycle

Content moves through Draft, Validated, Published, and Retired states. The current database only represents this partially through `active` and `contentVersion`; the complete lifecycle and immutable revision records remain to be implemented. Publishing creates a new immutable revision. Existing match snapshots continue using their original revision. Retiring content removes it from new purchases and matches without deleting inventories or match history.

## Security boundaries

- Database, admin, email, consent-provider, payment, and signing secrets exist only on the server.
- Game clients use short-lived access tokens held in memory; persistent login is deferred until secure Windows credential storage is implemented.
- Admin access requires role checks and MFA.
- Child online access, chat, payments, and voice each have independent server-side feature gates.
- Currency changes use an append-only ledger and transactional, idempotent operations.

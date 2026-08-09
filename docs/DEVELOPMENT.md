# Development Instructions

## Client

Use `battlepets.yyp` as the only active GameMaker project. Do not edit the preserved `bp/` copy unless intentionally recovering an asset into the root project.

New gameplay code should:

- Use structs and arrays rather than INI files for runtime battle state.
- Keep content definitions separate from battle state.
- Use stable string IDs in serialized data; never serialize GameMaker asset indices over the network.
- Keep rendering/input separate from deterministic rules mutation.
- Route every action through one validator/reducer so bots, local players, tutorials, replays, and online fixtures share behavior.

## Definition of done

A task is complete only when its behavior is documented, test fixtures cover its edge cases, the canonical project opens without missing resources, and `docs/PROGRESS.md` reflects the verified state.

Do not commit or push without explicit user permission.

## Documentation rules

- Update `GAME_DESIGN.md` when a player-visible rule changes.
- Update `PRODUCT_SPEC.md` when a settled product or operational decision changes.
- Update `ADMIN_GUIDE.md` when an admin workflow or content field changes.
- Update `TESTING.md` and `PROGRESS.md` with evidence whenever work becomes verified.
- Label proposed behavior as planned; do not describe an unavailable screen or endpoint as operational.

import { describe, expect, it } from "vitest";
import { applyAttack, createPetState, type BattleState, type PetDefinition } from "../src/domain/battle.js";

const pet: PetDefinition = {
  id: "test",
  name: "Test Pet",
  maxHealth: 50,
  tags: ["fur"],
  basic: { name: "Tap", damage: 10, unblockable: false },
  super: { name: "Burst", damage: 25, unblockable: false },
};

function battle(): BattleState {
  return {
    players: [
      { id: 0, name: "A", pets: [createPetState(pet)], eliminated: false },
      { id: 1, name: "B", pets: [createPetState(pet)], eliminated: false },
    ],
    order: [0, 1],
    orderIndex: 0,
    round: 1,
    sequence: 0,
    phase: "active",
    winner: null,
  };
}

describe("battle reducer", () => {
  it("applies fixed damage and advances the turn", () => {
    const state = battle();
    const result = applyAttack(state, { idempotencyKey: "1", playerId: 0, actorSlot: 0, targetPlayerId: 1, targetSlot: 0, kind: "basic" });
    expect(result.damage).toBe(10);
    expect(state.players[1]?.pets[0]?.health).toBe(40);
    expect(state.orderIndex).toBe(1);
  });

  it("consumes a shield without dealing damage", () => {
    const state = battle();
    state.players[1]!.pets[0]!.shield = 1;
    const result = applyAttack(state, { idempotencyKey: "2", playerId: 0, actorSlot: 0, targetPlayerId: 1, targetSlot: 0, kind: "basic" });
    expect(result.blocked).toBe(true);
    expect(result.damage).toBe(0);
    expect(state.players[1]?.pets[0]?.health).toBe(50);
  });

  it("allows a super once", () => {
    const state = battle();
    applyAttack(state, { idempotencyKey: "3", playerId: 0, actorSlot: 0, targetPlayerId: 1, targetSlot: 0, kind: "super" });
    state.orderIndex = 0;
    expect(() => applyAttack(state, { idempotencyKey: "4", playerId: 0, actorSlot: 0, targetPlayerId: 1, targetSlot: 0, kind: "super" })).toThrow("Super already used");
  });

  it("rejects out-of-turn commands", () => {
    const state = battle();
    expect(() => applyAttack(state, { idempotencyKey: "5", playerId: 1, actorSlot: 0, targetPlayerId: 0, targetSlot: 0, kind: "basic" })).toThrow("Out-of-turn action");
  });
});

export type ActionKind = "basic" | "super";

export interface AttackDefinition {
  name: string;
  damage: number;
  unblockable: boolean;
}

export interface PetDefinition {
  id: string;
  name: string;
  maxHealth: number;
  tags: string[];
  basic: AttackDefinition;
  super: AttackDefinition;
}

export interface PetState {
  definition: PetDefinition;
  health: number;
  superUsed: boolean;
  shield: number;
  stunTurns: number;
  attackBonus: number;
}

export interface PlayerState {
  id: number;
  name: string;
  pets: PetState[];
  eliminated: boolean;
}

export interface BattleState {
  players: PlayerState[];
  order: number[];
  orderIndex: number;
  round: number;
  sequence: number;
  phase: "active" | "complete";
  winner: number | null;
}

export interface AttackCommand {
  idempotencyKey: string;
  playerId: number;
  actorSlot: number;
  targetPlayerId: number;
  targetSlot: number;
  kind: ActionKind;
}

export interface ActionResult {
  state: BattleState;
  damage: number;
  blocked: boolean;
  knockedOut: boolean;
}

export function createPetState(definition: PetDefinition): PetState {
  return { definition, health: definition.maxHealth, superUsed: false, shield: 0, stunTurns: 0, attackBonus: 0 };
}

export function currentPlayerId(state: BattleState): number {
  const playerId = state.order[state.orderIndex];
  if (playerId === undefined) throw new Error("Battle has no current player");
  return playerId;
}

export function applyAttack(state: BattleState, command: AttackCommand): ActionResult {
  if (state.phase !== "active") throw new Error("Battle is complete");
  if (command.playerId !== currentPlayerId(state)) throw new Error("Out-of-turn action");
  if (command.playerId === command.targetPlayerId) throw new Error("Cannot attack your own pet");

  const player = state.players[command.playerId];
  const targetPlayer = state.players[command.targetPlayerId];
  const actor = player?.pets[command.actorSlot];
  const target = targetPlayer?.pets[command.targetSlot];
  if (!player || !targetPlayer || !actor || !target) throw new Error("Invalid actor or target");
  if (player.eliminated || actor.health <= 0 || actor.stunTurns > 0) throw new Error("Actor cannot act");
  if (targetPlayer.eliminated || target.health <= 0) throw new Error("Target cannot be attacked");
  if (command.kind === "super" && actor.superUsed) throw new Error("Super already used");

  const attack = command.kind === "super" ? actor.definition.super : actor.definition.basic;
  if (command.kind === "super") actor.superUsed = true;

  let blocked = false;
  let damage = Math.max(0, attack.damage + actor.attackBonus);
  if (target.shield > 0 && !attack.unblockable) {
    target.shield -= 1;
    damage = 0;
    blocked = true;
  }
  damage = Math.min(target.health, damage);
  target.health -= damage;
  const knockedOut = target.health === 0;

  state.sequence += 1;
  updateEliminations(state);
  if (state.phase === "active") advanceTurn(state);
  return { state, damage, blocked, knockedOut };
}

export function updateEliminations(state: BattleState): void {
  const remaining: number[] = [];
  for (const player of state.players) {
    player.eliminated = !player.pets.some((pet) => pet.health > 0);
    if (!player.eliminated) remaining.push(player.id);
  }
  if (remaining.length <= 1) {
    state.phase = "complete";
    state.winner = remaining[0] ?? null;
  }
}

export function advanceTurn(state: BattleState): void {
  const oldPlayer = state.players[currentPlayerId(state)];
  if (!oldPlayer) throw new Error("Current player is missing");
  for (const pet of oldPlayer.pets) pet.stunTurns = Math.max(0, pet.stunTurns - 1);

  for (let attempts = 0; attempts < state.order.length; attempts += 1) {
    state.orderIndex = (state.orderIndex + 1) % state.order.length;
    if (state.orderIndex === 0) state.round += 1;
    const next = state.players[currentPlayerId(state)];
    if (next && !next.eliminated) return;
  }
  throw new Error("No active player remains");
}

function bp_pet_state_create(_definition) {
    return {
        definition: _definition,
        health: _definition.max_health,
        super_used: false,
        shield: 0,
        stun_turns: 0,
        attack_bonus: 0
    };
}

function bp_shuffle(_values) {
    var _result = [];
    for (var _copy = 0; _copy < array_length(_values); _copy++) array_push(_result, _values[_copy]);
    for (var _i = array_length(_result) - 1; _i > 0; _i--) {
        var _j = irandom(_i);
        var _swap = _result[_i];
        _result[_i] = _result[_j];
        _result[_j] = _swap;
    }
    return _result;
}

function bp_match_create(_catalog, _names, _bots, _team_size, _difficulty) {
    var _players = [];
    var _pet_count = array_length(_catalog.pets);

    for (var _p = 0; _p < array_length(_names); _p++) {
        var _team = [];
        for (var _slot = 0; _slot < _team_size; _slot++) {
            var _pet_index = (_p * _team_size + _slot) mod _pet_count;
            array_push(_team, bp_pet_state_create(_catalog.pets[_pet_index]));
        }

        array_push(_players, {
            id: _p,
            name: _names[_p],
            is_bot: _bots[_p],
            difficulty: _difficulty,
            pets: _team,
            card: _catalog.cards[irandom(array_length(_catalog.cards) - 1)],
            card_used: false,
            has_been_attacked: false,
            eliminated: false
        });
    }

    var _order = [];
    for (var _i = 0; _i < array_length(_players); _i++) array_push(_order, _i);
    _order = bp_shuffle(_order);

    var _match = {
        players: _players,
        order: _order,
        order_index: 0,
        round: 1,
        action_number: 0,
        coins_awarded: false,
        phase: "active",
        winner: -1,
        log: [],
        last_message: "Battle started! Turn order:"
    };

    var _order_text = "";
    for (var _o = 0; _o < array_length(_order); _o++) {
        if (_o > 0) _order_text += ", ";
        _order_text += _players[_order[_o]].name;
    }
    _match.last_message = "Turn order: " + _order_text;
    array_push(_match.log, _match.last_message);
    return _match;
}

function bp_current_player_index(_match) {
    return _match.order[_match.order_index];
}

function bp_pet_alive(_pet) {
    return _pet.health > 0;
}

function bp_player_has_living_pet(_player) {
    for (var _i = 0; _i < array_length(_player.pets); _i++) {
        if (bp_pet_alive(_player.pets[_i])) return true;
    }
    return false;
}

function bp_player_has_revive(_player) {
    return !_player.card_used && _player.card.effect == "revive";
}

function bp_action_is_legal(_match, _player_index, _actor_slot, _action, _target_player, _target_slot) {
    if (_match.phase != "active") return false;
    if (_player_index != bp_current_player_index(_match)) return false;
    if (_target_player < 0 || _target_player >= array_length(_match.players)) return false;
    if (_target_slot < 0 || _target_slot >= array_length(_match.players[_target_player].pets)) return false;

    var _player = _match.players[_player_index];
    var _target = _match.players[_target_player].pets[_target_slot];

    if (_action == "card") {
        if (_player.card_used) return false;
        switch (_player.card.effect) {
            case "revive": return _target_player == _player_index && !bp_pet_alive(_target);
            case "shield": return _target_player == _player_index && bp_pet_alive(_target);
            case "boost": return _target_player == _player_index && bp_pet_alive(_target);
            case "damage": return _target_player != _player_index && bp_pet_alive(_target);
            case "stun": return _target_player != _player_index && bp_pet_alive(_target);
        }
        return false;
    }

    if (_actor_slot < 0 || _actor_slot >= array_length(_player.pets)) return false;
    var _actor = _player.pets[_actor_slot];
    if (!bp_pet_alive(_actor) || _actor.stun_turns > 0) return false;
    if (_target_player == _player_index || !bp_pet_alive(_target)) return false;
    if (_action == "super" && _actor.super_used) return false;
    return _action == "basic" || _action == "super";
}

function bp_damage_pet(_target, _amount, _unblockable) {
    if (_target.shield > 0 && !_unblockable) {
        _target.shield -= 1;
        return 0;
    }
    var _actual = min(_target.health, max(0, _amount));
    _target.health -= _actual;
    return _actual;
}

function bp_apply_action(_match, _player_index, _actor_slot, _action, _target_player, _target_slot) {
    if (!bp_action_is_legal(_match, _player_index, _actor_slot, _action, _target_player, _target_slot)) {
        _match.last_message = "That action is not legal.";
        return false;
    }

    var _player = _match.players[_player_index];
    var _target_owner = _match.players[_target_player];
    var _target = _target_owner.pets[_target_slot];
    var _message = "";

    // A hostile attack attempt counts even when a shield prevents damage.
    if (_target_player != _player_index && (_action != "card" || _player.card.effect == "damage" || _player.card.effect == "stun")) {
        _target_owner.has_been_attacked = true;
    }

    if (_action == "card") {
        var _card = _player.card;
        _player.card_used = true;
        switch (_card.effect) {
            case "shield":
                _target.shield += _card.amount;
                _message = _player.name + " gave " + _target.definition.name + " a shield.";
                break;
            case "revive":
                _target.health = max(1, floor(_target.definition.max_health * _card.amount / 100));
                _message = _player.name + " revived " + _target.definition.name + ".";
                break;
            case "damage":
                var _card_damage = bp_damage_pet(_target, _card.amount, false);
                _message = _player.name + " used " + _card.name + " for " + string(_card_damage) + " damage.";
                break;
            case "stun":
                _target.stun_turns = max(_target.stun_turns, _card.amount);
                _message = _target.definition.name + " is out for its owner's next turn.";
                break;
            case "boost":
                _target.attack_bonus += _card.amount;
                _message = _target.definition.name + " gained " + string(_card.amount) + " attack.";
                break;
        }
    } else {
        var _actor = _player.pets[_actor_slot];
        var _attack = _action == "super" ? _actor.definition.super : _actor.definition.basic;
        if (_action == "super") _actor.super_used = true;
        var _damage = bp_damage_pet(_target, _attack.damage + _actor.attack_bonus, _attack.unblockable);
        _message = _player.name + "'s " + _actor.definition.name + " used " + _attack.name + " on " + _target.definition.name;
        _message += _damage == 0 ? ", but a shield blocked it." : " for " + string(_damage) + " damage.";
    }

    if (_target.health <= 0) _message += " " + _target.definition.name + " was knocked out!";
    _match.action_number += 1;
    _match.last_message = _message;
    array_push(_match.log, _message);
    bp_update_eliminations(_match);
    if (_match.phase == "active") bp_advance_turn(_match);
    return true;
}

function bp_update_eliminations(_match) {
    var _remaining = 0;
    var _winner = -1;
    for (var _p = 0; _p < array_length(_match.players); _p++) {
        var _player = _match.players[_p];
        _player.eliminated = !bp_player_has_living_pet(_player) && !bp_player_has_revive(_player);
        if (!_player.eliminated) {
            _remaining += 1;
            _winner = _p;
        }
    }
    if (_remaining <= 1) {
        _match.phase = "complete";
        _match.winner = _winner;
        _match.last_message = _winner >= 0 ? _match.players[_winner].name + " wins the battle!" : "The battle ended in a draw.";
        array_push(_match.log, _match.last_message);
    }
}

function bp_advance_turn(_match) {
    var _old_player = _match.players[bp_current_player_index(_match)];
    for (var _i = 0; _i < array_length(_old_player.pets); _i++) {
        if (_old_player.pets[_i].stun_turns > 0) _old_player.pets[_i].stun_turns -= 1;
    }

    repeat (array_length(_match.order)) {
        _match.order_index = (_match.order_index + 1) mod array_length(_match.order);
        if (_match.order_index == 0) _match.round += 1;
        if (!_match.players[bp_current_player_index(_match)].eliminated) break;
    }
}

function bp_first_legal_actor(_match, _player_index) {
    var _pets = _match.players[_player_index].pets;
    for (var _i = 0; _i < array_length(_pets); _i++) {
        if (bp_pet_alive(_pets[_i]) && _pets[_i].stun_turns <= 0) return _i;
    }
    return -1;
}

function bp_player_has_legal_card_target(_match, _player_index) {
    var _player = _match.players[_player_index];
    if (_player.card_used) return false;
    for (var _p = 0; _p < array_length(_match.players); _p++) {
        for (var _s = 0; _s < array_length(_match.players[_p].pets); _s++) {
            if (bp_action_is_legal(_match, _player_index, -1, "card", _p, _s)) return true;
        }
    }
    return false;
}

function bp_skip_turn(_match, _player_index) {
    if (_match.phase != "active" || _player_index != bp_current_player_index(_match)) return false;
    _match.last_message = _match.players[_player_index].name + " has no available action and passes.";
    array_push(_match.log, _match.last_message);
    _match.action_number += 1;
    bp_advance_turn(_match);
    return true;
}

function bp_find_legal_target(_match, _player_index, _actor_slot, _action, _start, _direction) {
    var _team_size = array_length(_match.players[0].pets);
    var _total = array_length(_match.players) * _team_size;
    for (var _offset = 1; _offset <= _total; _offset++) {
        var _flat = (_start + _direction * _offset + _total * 2) mod _total;
        var _target_player = _flat div _team_size;
        var _target_slot = _flat mod _team_size;
        if (bp_action_is_legal(_match, _player_index, _actor_slot, _action, _target_player, _target_slot)) return _flat;
    }
    return -1;
}

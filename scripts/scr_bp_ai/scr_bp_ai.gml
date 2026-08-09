function bp_ai_choose_action(_match, _player_index) {
    var _player = _match.players[_player_index];
    var _actor = bp_first_legal_actor(_match, _player_index);

    if (_actor < 0 && bp_player_has_revive(_player)) {
        for (var _r = 0; _r < array_length(_player.pets); _r++) {
            if (!bp_pet_alive(_player.pets[_r])) return { actor: -1, action: "card", target_player: _player_index, target_slot: _r };
        }
    }

    if (!_player.card_used && _player.difficulty >= 1) {
        var _effect = _player.card.effect;
        if (_effect == "revive") {
            for (var _dead = 0; _dead < array_length(_player.pets); _dead++) {
                if (!bp_pet_alive(_player.pets[_dead])) return { actor: _actor, action: "card", target_player: _player_index, target_slot: _dead };
            }
        }
        if (_effect == "shield" || _effect == "boost") {
            var _weakest_own = -1;
            var _weakest_hp = 1000000;
            for (var _own = 0; _own < array_length(_player.pets); _own++) {
                if (bp_pet_alive(_player.pets[_own]) && _player.pets[_own].health < _weakest_hp) {
                    _weakest_hp = _player.pets[_own].health;
                    _weakest_own = _own;
                }
            }
            if (_weakest_own >= 0 && (_effect == "boost" || _weakest_hp < _player.pets[_weakest_own].definition.max_health * 0.6)) {
                return { actor: _actor, action: "card", target_player: _player_index, target_slot: _weakest_own };
            }
        }
    }

    // Give untouched opponents attention before returning to difficulty-specific
    // targeting. Among untouched opponents, prefer the team with the most total HP.
    var _priority_player = -1;
    var _priority_health = -1;
    for (var _priority_index = 0; _priority_index < array_length(_match.players); _priority_index++) {
        if (_priority_index == _player_index) continue;
        var _priority_opponent = _match.players[_priority_index];
        if (_priority_opponent.eliminated || _priority_opponent.has_been_attacked) continue;
        var _team_health = 0;
        for (var _priority_slot = 0; _priority_slot < array_length(_priority_opponent.pets); _priority_slot++) {
            _team_health += max(0, _priority_opponent.pets[_priority_slot].health);
        }
        if (_team_health > _priority_health) {
            _priority_health = _team_health;
            _priority_player = _priority_index;
        }
    }

    var _target_player = -1;
    var _target_slot = -1;
    var _best_health = 1000000;
    var _candidates = [];
    for (var _p = 0; _p < array_length(_match.players); _p++) {
        if (_p == _player_index) continue;
        if (_priority_player >= 0 && _p != _priority_player) continue;
        for (var _s = 0; _s < array_length(_match.players[_p].pets); _s++) {
            var _target = _match.players[_p].pets[_s];
            if (!bp_pet_alive(_target)) continue;
            array_push(_candidates, { player: _p, slot: _s });
            if (_target.health < _best_health) {
                _best_health = _target.health;
                _target_player = _p;
                _target_slot = _s;
            }
        }
    }

    if (_player.difficulty == 0 && array_length(_candidates) > 0) {
        var _random_target = _candidates[irandom(array_length(_candidates) - 1)];
        _target_player = _random_target.player;
        _target_slot = _random_target.slot;
    }

    var _action = "basic";
    if (_actor >= 0 && !_player.pets[_actor].super_used) {
        if (_player.difficulty >= 2 || irandom(3) == 0) _action = "super";
    }

    if (!_player.card_used && (_player.card.effect == "damage" || _player.card.effect == "stun") && _player.difficulty >= 1) {
        _action = "card";
    }
    return { actor: _actor, action: _action, target_player: _target_player, target_slot: _target_slot };
}

function bp_test_check(_condition, _message) {
    if (_condition) return true;
    show_debug_message("BATTLEPETS TEST FAILED: " + _message);
    return false;
}

function bp_run_self_tests(_catalog) {
    var _passed = true;

    _passed = bp_test_check(array_length(_catalog.packs) == 4, "four pack tiers") && _passed;
    for (var _pack_test = 0; _pack_test < array_length(_catalog.packs); _pack_test++) {
        var _weight_total = 0;
        for (var _weight_test = 0; _weight_test < array_length(_catalog.packs[_pack_test].weights); _weight_test++) {
            _weight_total += _catalog.packs[_pack_test].weights[_weight_test];
            if (_weight_test > _catalog.packs[_pack_test].maximum_rarity) {
                _passed = bp_test_check(_catalog.packs[_pack_test].weights[_weight_test] == 0, "pack excludes rarities above its tier") && _passed;
            }
        }
        _passed = bp_test_check(_weight_total == 100, "pack rarity odds total 100") && _passed;
        _passed = bp_test_check(bp_pack_roll_rarity(_catalog.packs[_pack_test], 0) <= _catalog.packs[_pack_test].maximum_rarity, "pack minimum roll respects tier") && _passed;
        _passed = bp_test_check(bp_pack_roll_rarity(_catalog.packs[_pack_test], 99) <= _catalog.packs[_pack_test].maximum_rarity, "pack maximum roll respects tier") && _passed;
    }

    for (var _players = 2; _players <= 8; _players++) {
        for (var _team_size = 2; _team_size <= 4; _team_size++) {
            var _names = [];
            var _bots = [];
            repeat (_players) {
                array_push(_names, "Test " + string(array_length(_names) + 1));
                array_push(_bots, false);
            }
            var _size_match = bp_match_create(_catalog, _names, _bots, _team_size, 0);
            _passed = bp_test_check(array_length(_size_match.players) == _players, "player count") && _passed;
            _passed = bp_test_check(array_length(_size_match.players[0].pets) == _team_size, "team size") && _passed;
            _passed = bp_test_check(array_length(_size_match.order) == _players, "turn order size") && _passed;
        }
    }

    var _shield_pet = bp_pet_state_create(_catalog.pets[0]);
    _shield_pet.shield = 1;
    var _blocked = bp_damage_pet(_shield_pet, 20, false);
    _passed = bp_test_check(_blocked == 0 && _shield_pet.health == _shield_pet.definition.max_health && _shield_pet.shield == 0, "shield blocks one attack") && _passed;
    var _unblocked = bp_damage_pet(_shield_pet, 20, true);
    _passed = bp_test_check(_unblocked == 20 && _shield_pet.health == _shield_pet.definition.max_health - 20, "unblockable bypasses shield") && _passed;

    var _match = bp_match_create(_catalog, ["Alpha", "Beta"], [false, false], 2, 0);
    var _current = bp_current_player_index(_match);
    var _actor = bp_first_legal_actor(_match, _current);
    var _target_flat = bp_find_legal_target(_match, _current, _actor, "basic", -1, 1);
    var _target_player = _target_flat div 2;
    var _target_slot = _target_flat mod 2;
    var _before = _match.players[_target_player].pets[_target_slot].health;
    var _acted = bp_apply_action(_match, _current, _actor, "basic", _target_player, _target_slot);
    _passed = bp_test_check(_acted && _match.action_number == 1, "legal basic attack") && _passed;
    _passed = bp_test_check(_match.players[_target_player].pets[_target_slot].health < _before, "basic attack damage") && _passed;
    _passed = bp_test_check(_match.players[_target_player].has_been_attacked, "hostile action marks target player attacked") && _passed;

    var _multi_match = bp_match_create(_catalog, ["Axle Test", "Target Team"], [false, false], 4, 0);
    _multi_match.order = [0, 1];
    _multi_match.order_index = 0;
    _multi_match.players[0].pets[0] = bp_pet_state_create(_catalog.pets[5]);
    _multi_match.players[1].pets[0].health = 500;
    _multi_match.players[1].pets[3].health = 0;
    var _multi_acted = bp_apply_action(_multi_match, 0, 0, "super", 1, 0);
    _passed = bp_test_check(_multi_acted && _multi_match.players[1].pets[0].health == 380, "Axle Multistrike deals 40 per living opposing pet") && _passed;

    var _ai_match = bp_match_create(_catalog, ["Bot", "Low", "High", "Already"], [true, false, false, false], 2, 0);
    var _ai_player = bp_current_player_index(_ai_match);
    _ai_match.players[_ai_player].is_bot = true;
    for (var _ap = 0; _ap < array_length(_ai_match.players); _ap++) {
        if (_ap == _ai_player) continue;
        _ai_match.players[_ap].has_been_attacked = true;
    }
    var _low_player = (_ai_player + 1) mod 4;
    var _high_player = (_ai_player + 2) mod 4;
    _ai_match.players[_low_player].has_been_attacked = false;
    _ai_match.players[_high_player].has_been_attacked = false;
    for (var _ls = 0; _ls < 2; _ls++) _ai_match.players[_low_player].pets[_ls].health = 10;
    for (var _hs = 0; _hs < 2; _hs++) _ai_match.players[_high_player].pets[_hs].health = 70;
    var _ai_choice = bp_ai_choose_action(_ai_match, _ai_player);
    _passed = bp_test_check(_ai_choice.target_player == _high_player, "bot prioritizes highest-health untouched player") && _passed;

    show_debug_message(_passed ? "BATTLEPETS SELF-TESTS PASSED" : "BATTLEPETS SELF-TESTS FAILED");
    return _passed;
}

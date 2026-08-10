if (screen == "local_roster" && roster_editing) {
    local_player_names[roster_selected] = string_copy(keyboard_string, 1, 18);
    if (keyboard_check_pressed(vk_enter)) {
        if (string_length(local_player_names[roster_selected]) == 0) local_player_names[roster_selected] = "Player " + string(roster_selected + 1);
        roster_editing = false;
        keyboard_string = "";
    } else if (keyboard_check_pressed(vk_escape)) {
        local_player_names[roster_selected] = roster_original_name;
        roster_editing = false;
        keyboard_string = "";
    }
    exit;
}

if (screen == "battle" && controls_open) {
    if (keyboard_check_pressed(vk_escape) || keyboard_check_pressed(ord("H"))) controls_open = false;
    exit;
}

if (screen == "pause") {
    if (keyboard_check_pressed(vk_escape) || keyboard_check_pressed(ord("R"))) screen = screen_before_pause;
    if (keyboard_check_pressed(ord("M"))) screen = "main";
    if (keyboard_check_pressed(ord("X"))) game_end();
    exit;
}

if (keyboard_check_pressed(vk_escape)) {
    if (screen == "battle" || screen == "handoff") {
        screen_before_pause = screen;
        screen = "pause";
        exit;
    }
    if (screen == "main") {
        game_end();
    } else if (screen == "shop") {
        screen = "mode";
    } else {
        screen = "main";
    }
}

switch (screen) {
    case "main":
        if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(ord("P"))) screen = "mode";
        if (keyboard_check_pressed(ord("T"))) {
            tutorial = true;
            play_mode = "bot";
            setup_players = 2;
            setup_team_size = 1;
            setup_difficulty = 0;
            setup_bot_speed = 0;
            start_match();
        }
        break;

    case "shop":
        // Shop browsing and purchases activate with the M4 collection/economy APIs.
        break;

    case "mode":
        if (keyboard_check_pressed(ord("S"))) screen = "shop";
        if (keyboard_check_pressed(ord("B"))) {
            tutorial = false;
            play_mode = "bot";
            setup_players = max(2, setup_players);
            screen = "setup";
        }
        if (keyboard_check_pressed(ord("L"))) {
            tutorial = false;
            play_mode = "local";
            screen = "setup";
        }
        break;

    case "shuffle":
        shuffle_timer -= 1;
        if (shuffle_timer > 90) {
            var _shuffle_interval = shuffle_timer > 170 ? 5 : (shuffle_timer > 125 ? 8 : 12);
            if (shuffle_timer mod _shuffle_interval == 0) {
                shuffle_candidate = match.order[irandom(array_length(match.order) - 1)];
            }
        } else {
            shuffle_candidate = match.order[0];
        }
        if (shuffle_timer <= 0 || keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
            shuffle_candidate = match.order[0];
            screen = "battle";
        }
        break;

    case "local_roster":
        if (keyboard_check_pressed(vk_up)) roster_selected = max(0, roster_selected - 1);
        if (keyboard_check_pressed(vk_down)) roster_selected = min(setup_players - 1, roster_selected + 1);
        if (keyboard_check_pressed(ord("B"))) local_player_bots[roster_selected] = !local_player_bots[roster_selected];
        if (keyboard_check_pressed(vk_enter)) {
            roster_editing = true;
            roster_original_name = local_player_names[roster_selected];
            keyboard_string = local_player_names[roster_selected];
        }
        if (keyboard_check_pressed(ord("S"))) start_match();
        break;

    case "setup":
        if (keyboard_check_pressed(vk_up)) setup_players = min(8, setup_players + 1);
        if (keyboard_check_pressed(vk_down)) setup_players = max(2, setup_players - 1);
        if (keyboard_check_pressed(vk_right)) setup_team_size = min(4, setup_team_size + 1);
        if (keyboard_check_pressed(vk_left)) setup_team_size = max(2, setup_team_size - 1);
        if (keyboard_check_pressed(ord("D"))) setup_difficulty = (setup_difficulty + 1) mod 3;
        if (play_mode == "bot" && keyboard_check_pressed(ord("S"))) setup_bot_speed = (setup_bot_speed + 1) mod 3;
        if (keyboard_check_pressed(vk_enter)) {
            if (play_mode == "local") {
                prepare_local_roster();
                screen = "local_roster";
            } else {
                start_match();
            }
        }
        break;

    case "handoff":
        if (keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_enter)) {
            reset_turn_selection();
            screen = "battle";
        }
        break;

    case "battle":
        if (combat_fx_timer > 0) {
            combat_fx_timer -= 1;
            if (combat_fx_timer <= 0) {
                if (match.phase == "complete") {
                    screen = "result";
                } else if (play_mode == "local" && !match.players[bp_current_player_index(match)].is_bot) {
                    screen = "handoff";
                } else {
                    reset_turn_selection();
                }
            }
            break;
        }

        if (match.phase == "complete") {
            screen = "result";
            break;
        }

        var _current = bp_current_player_index(match);
        var _player = match.players[_current];

        if (bp_first_legal_actor(match, _current) < 0 && !bp_player_has_legal_card_target(match, _current)) {
            bp_skip_turn(match, _current);
            if (play_mode == "local") screen = "handoff"; else reset_turn_selection();
            break;
        }

        if (_player.is_bot) {
            bot_delay -= 1;
            if (bot_delay <= 0) {
                var _choice = bp_ai_choose_action(match, _current);
                present_action(_current, _choice.actor, _choice.action, _choice.target_player, _choice.target_slot);
            }
            break;
        }

        if (keyboard_check_pressed(ord("H"))) {
            controls_open = true;
            details_open = false;
            break;
        }

        if (keyboard_check_pressed(ord("F"))) {
            details_open = !details_open;
            if (details_open) {
                if (selected_target >= 0) {
                    detail_player = selected_target div array_length(_player.pets);
                    detail_slot = selected_target mod array_length(_player.pets);
                } else {
                    detail_player = _current;
                    detail_slot = selected_actor;
                }
            }
        }
        if (details_open) {
            if (keyboard_check_pressed(ord("A")) && selected_actor >= 0) {
                detail_player = _current;
                detail_slot = selected_actor;
            }
            if (keyboard_check_pressed(ord("T")) && selected_target >= 0) {
                detail_player = selected_target div array_length(_player.pets);
                detail_slot = selected_target mod array_length(_player.pets);
            }
            break;
        }

        if (keyboard_check_pressed(ord("1"))) selected_action = "basic";
        if (keyboard_check_pressed(ord("2"))) selected_action = "super";
        if (keyboard_check_pressed(ord("3"))) selected_action = "card";

        if (keyboard_check_pressed(ord("Q")) || keyboard_check_pressed(ord("E"))) {
            var _direction = keyboard_check_pressed(ord("Q")) ? -1 : 1;
            var _pet_count = array_length(_player.pets);
            for (var _try = 1; _try <= _pet_count; _try++) {
                var _candidate = (selected_actor + _direction * _try + _pet_count * 2) mod _pet_count;
                if (bp_pet_alive(_player.pets[_candidate]) && _player.pets[_candidate].stun_turns <= 0) {
                    selected_actor = _candidate;
                    break;
                }
            }
        }

        var _target_direction = 0;
        if (keyboard_check_pressed(vk_left)) _target_direction = -1;
        if (keyboard_check_pressed(vk_right)) _target_direction = 1;
        if (_target_direction != 0 || selected_target < 0 || !bp_action_is_legal(match, _current, selected_actor, selected_action, selected_target div array_length(_player.pets), selected_target mod array_length(_player.pets))) {
            var _from = selected_target < 0 ? -1 : selected_target;
            selected_target = bp_find_legal_target(match, _current, selected_actor, selected_action, _from, _target_direction == 0 ? 1 : _target_direction);
        }

        if (keyboard_check_pressed(vk_enter) && selected_target >= 0) {
            var _target_player = selected_target div array_length(_player.pets);
            var _target_slot = selected_target mod array_length(_player.pets);
            present_action(_current, selected_actor, selected_action, _target_player, _target_slot);
        }
        break;

    case "result":
        if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) screen = "main";
        break;
}

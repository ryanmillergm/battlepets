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
    } else if (screen == "shop" || screen == "inventory") {
        pack_confirm_open = false;
        sale_confirm_stage = 0;
        screen = "hub";
    } else if (screen == "pack_shop") {
        pack_confirm_open = false;
        screen = "shop";
    } else if (screen == "pack_result") {
        screen = "pack_shop";
    } else if (screen == "mode") {
        screen = "hub";
    } else if (screen == "hub") {
        screen = "main";
    } else if (screen == "collection") {
        screen = collection_return_screen;
    } else {
        screen = "main";
    }
}

switch (screen) {
    case "main":
        if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) screen = "hub";
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

    case "hub":
        if (keyboard_check_pressed(vk_left)) hub_cursor = max(0, hub_cursor - 1);
        if (keyboard_check_pressed(vk_right)) hub_cursor = min(2, hub_cursor + 1);
        if (keyboard_check_pressed(ord("I"))) { hub_cursor = 0; screen = "inventory"; economy_message = ""; }
        if (keyboard_check_pressed(ord("P"))) { hub_cursor = 1; screen = "mode"; }
        if (keyboard_check_pressed(ord("S"))) { hub_cursor = 2; screen = "shop"; }
        var _hub_click = mouse_check_button_pressed(mb_left);
        if (_hub_click) {
            var _hub_mx = device_mouse_x_to_gui(0);
            var _hub_my = device_mouse_y_to_gui(0);
            if (_hub_my >= 285 && _hub_my <= 555) {
                if (_hub_mx >= 238 && _hub_mx <= 578) { hub_cursor = 0; screen = "inventory"; economy_message = ""; }
                if (_hub_mx >= 613 && _hub_mx <= 953) { hub_cursor = 1; screen = "mode"; }
                if (_hub_mx >= 988 && _hub_mx <= 1328) { hub_cursor = 2; screen = "shop"; }
            }
        }
        if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
            if (hub_cursor == 0) { screen = "inventory"; economy_message = ""; }
            if (hub_cursor == 1) screen = "mode";
            if (hub_cursor == 2) screen = "shop";
        }
        break;

    case "shop":
        var _shop_open_packs = keyboard_check_pressed(ord("P"));
        if (mouse_check_button_pressed(mb_left)) {
            var _shop_mx = device_mouse_x_to_gui(0);
            var _shop_my = device_mouse_y_to_gui(0);
            if (_shop_mx >= 630 && _shop_mx <= 970 && _shop_my >= 285 && _shop_my <= 555) _shop_open_packs = true;
        }
        if (_shop_open_packs) {
            pack_cursor = 0;
            pack_confirm_open = false;
            economy_message = "";
            screen = "pack_shop";
        }
        break;

    case "pack_shop":
        if (pack_confirm_open) {
            if (keyboard_check_pressed(ord("C"))) pack_confirm_open = false;
            if (keyboard_check_pressed(vk_enter)) purchase_selected_pack();
            if (mouse_check_button_pressed(mb_left)) {
                var _confirm_mx = device_mouse_x_to_gui(0);
                var _confirm_my = device_mouse_y_to_gui(0);
                if (_confirm_my >= 660 && _confirm_my <= 725) {
                    if (_confirm_mx >= 510 && _confirm_mx <= 750) pack_confirm_open = false;
                    if (_confirm_mx >= 850 && _confirm_mx <= 1090) purchase_selected_pack();
                }
            }
            break;
        }
        if (keyboard_check_pressed(vk_left)) pack_cursor = max(0, pack_cursor - 1);
        if (keyboard_check_pressed(vk_right)) pack_cursor = min(3, pack_cursor + 1);
        var _pack_choose = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space);
        if (mouse_check_button_pressed(mb_left)) {
            var _pack_mx = device_mouse_x_to_gui(0);
            var _pack_my = device_mouse_y_to_gui(0);
            if (_pack_my >= 280 && _pack_my <= 585) {
                for (var _pack_click_index = 0; _pack_click_index < 4; _pack_click_index++) {
                    var _pack_click_x = 85 + _pack_click_index * 380;
                    if (_pack_mx >= _pack_click_x && _pack_mx <= _pack_click_x + 330) { pack_cursor = _pack_click_index; _pack_choose = true; }
                }
            }
        }
        if (_pack_choose) { pack_confirm_open = true; economy_message = ""; }
        break;

    case "pack_result":
        if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) screen = "pack_shop";
        if (mouse_check_button_pressed(mb_left)) screen = "pack_shop";
        break;

    case "inventory":
        if (sale_confirm_stage > 0) {
            if (keyboard_check_pressed(ord("C"))) sale_confirm_stage = 0;
            if (keyboard_check_pressed(vk_enter)) {
                if (sale_confirm_stage == 1) sale_confirm_stage = 2; else sell_selected_pet();
            }
            if (mouse_check_button_pressed(mb_left)) {
                var _sale_mx = device_mouse_x_to_gui(0);
                var _sale_my = device_mouse_y_to_gui(0);
                if (_sale_my >= 665 && _sale_my <= 730) {
                    if (_sale_mx >= 510 && _sale_mx <= 750) sale_confirm_stage = 0;
                    if (_sale_mx >= 850 && _sale_mx <= 1090) { if (sale_confirm_stage == 1) sale_confirm_stage = 2; else sell_selected_pet(); }
                }
            }
            break;
        }
        var _inventory_col = inventory_cursor mod 4;
        var _inventory_row = inventory_cursor div 4;
        if (keyboard_check_pressed(vk_left)) _inventory_col = max(0, _inventory_col - 1);
        if (keyboard_check_pressed(vk_right)) _inventory_col = min(3, _inventory_col + 1);
        if (keyboard_check_pressed(vk_up)) _inventory_row = max(0, _inventory_row - 1);
        if (keyboard_check_pressed(vk_down)) _inventory_row = min(1, _inventory_row + 1);
        inventory_cursor = clamp(_inventory_row * 4 + _inventory_col, 0, array_length(catalog.pets) - 1);
        if (mouse_check_button_pressed(mb_left)) {
            var _inventory_mx = device_mouse_x_to_gui(0);
            var _inventory_my = device_mouse_y_to_gui(0);
            for (var _inventory_click = 0; _inventory_click < array_length(catalog.pets); _inventory_click++) {
                var _inventory_x = 70 + (_inventory_click mod 4) * 380;
                var _inventory_y = 225 + (_inventory_click div 4) * 270;
                if (_inventory_mx >= _inventory_x && _inventory_mx <= _inventory_x + 330 && _inventory_my >= _inventory_y && _inventory_my <= _inventory_y + 225) inventory_cursor = _inventory_click;
            }
            if (_inventory_mx >= 620 && _inventory_mx <= 980 && _inventory_my >= 790 && _inventory_my <= 855 && pet_quantities[inventory_cursor] > 0) { sale_confirm_stage = 1; economy_message = ""; }
        }
        if ((keyboard_check_pressed(ord("S")) || keyboard_check_pressed(vk_enter)) && pet_quantities[inventory_cursor] > 0) { sale_confirm_stage = 1; economy_message = ""; }
        break;

    case "mode":
        if (keyboard_check_pressed(ord("S"))) screen = "shop";
        if (keyboard_check_pressed(ord("B"))) {
            if (array_length(owned_pet_ids) < 2) {
                economy_message = "Own at least 2 different Battlepets before playing.";
            } else {
                tutorial = false;
                play_mode = "bot";
                load_setup_for_mode("bot");
                economy_message = "";
                screen = "setup";
            }
        }
        if (keyboard_check_pressed(ord("L"))) {
            if (array_length(owned_pet_ids) < 2) {
                economy_message = "Own at least 2 different Battlepets before playing.";
            } else {
                tutorial = false;
                play_mode = "local";
                load_setup_for_mode("local");
                economy_message = "";
                screen = "setup";
            }
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
        if (keyboard_check_pressed(ord("C"))) open_collection("local_roster", roster_selected);
        if (keyboard_check_pressed(vk_enter)) {
            roster_editing = true;
            roster_original_name = local_player_names[roster_selected];
            keyboard_string = local_player_names[roster_selected];
        }
        if (keyboard_check_pressed(ord("S"))) start_match();
        break;

    case "collection":
        var _collection_col = collection_cursor mod 4;
        var _collection_row = collection_cursor div 4;
        if (keyboard_check_pressed(vk_left)) _collection_col = max(0, _collection_col - 1);
        if (keyboard_check_pressed(vk_right)) _collection_col = min(3, _collection_col + 1);
        if (keyboard_check_pressed(vk_up)) _collection_row = max(0, _collection_row - 1);
        if (keyboard_check_pressed(vk_down)) _collection_row = min(2, _collection_row + 1);
        collection_cursor = _collection_row * 4 + _collection_col;

        if (keyboard_check_pressed(vk_space) && collection_cursor < array_length(owned_pet_ids)) {
            var _collection_id = owned_pet_ids[collection_cursor];
            var _selected_position = -1;
            for (var _selected_search = 0; _selected_search < array_length(collection_selected_ids); _selected_search++) {
                if (collection_selected_ids[_selected_search] == _collection_id) _selected_position = _selected_search;
            }
            if (_selected_position >= 0) {
                array_delete(collection_selected_ids, _selected_position, 1);
            } else if (array_length(collection_selected_ids) < setup_team_size) {
                array_push(collection_selected_ids, _collection_id);
            }
        }

        if (keyboard_check_pressed(vk_enter) && array_length(collection_selected_ids) == setup_team_size) {
            if (collection_context_seat >= 0) local_player_lineups[collection_context_seat] = copy_lineup(collection_selected_ids); else bot_lineup_ids = copy_lineup(collection_selected_ids);
            screen = collection_return_screen;
        }
        break;

    case "setup":
        var _setup_changed = false;
        if (keyboard_check_pressed(vk_up)) { setup_players = min(8, setup_players + 1); _setup_changed = true; }
        if (keyboard_check_pressed(vk_down)) { setup_players = max(2, setup_players - 1); _setup_changed = true; }
        if (keyboard_check_pressed(vk_right)) { setup_team_size = min(4, setup_team_size + 1); _setup_changed = true; }
        if (keyboard_check_pressed(vk_left)) { setup_team_size = max(2, setup_team_size - 1); _setup_changed = true; }
        if (play_mode == "bot" && keyboard_check_pressed(ord("D"))) { setup_difficulty = (setup_difficulty + 1) mod 3; _setup_changed = true; }
        if (play_mode == "bot" && keyboard_check_pressed(ord("S"))) { setup_bot_speed = (setup_bot_speed + 1) mod 3; _setup_changed = true; }
        if (_setup_changed) save_setup_for_mode(play_mode);
        if (play_mode == "bot" && keyboard_check_pressed(ord("C"))) open_collection("setup", -1);
        if (keyboard_check_pressed(vk_enter)) {
            if (array_length(owned_pet_ids) < setup_team_size) {
                economy_message = "You need " + string(setup_team_size) + " different Battlepets for this team size.";
            } else if (play_mode == "local") {
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
                    award_match_coins();
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
            award_match_coins();
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

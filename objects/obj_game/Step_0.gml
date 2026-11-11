var _fullscreen_click = false;
if (screen == "main" && mouse_check_button_pressed(mb_left)) {
    var _fullscreen_mx = device_mouse_x_to_gui(0);
    var _fullscreen_my = device_mouse_y_to_gui(0);
    _fullscreen_click = _fullscreen_mx >= 1360 && _fullscreen_mx <= 1580 && _fullscreen_my >= 18 && _fullscreen_my <= 62;
}
if (_fullscreen_click || keyboard_check_pressed(vk_f11)) {
    window_set_fullscreen(!window_get_fullscreen());
}

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
    if (mouse_check_button_pressed(mb_left)) {
        var _pause_my = device_mouse_y_to_gui(0);
        if (_pause_my >= 380 && _pause_my < 445) screen = screen_before_pause;
        if (_pause_my >= 445 && _pause_my < 515) screen = "main";
        if (_pause_my >= 515 && _pause_my <= 575) game_end();
    }
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
    } else if (screen == "trading") {
        economy_message = "";
        screen = "mode";
    } else if (screen == "trade_up") {
        trade_up_confirm = false;
        economy_message = "";
        screen = "trading";
    } else if (screen == "trade_up_select") {
        trade_up_confirm = false;
        economy_message = "";
        screen = "trade_up";
    } else if (screen == "trade_up_reward") {
        reset_trade_up_selection(trade_up_cursor);
        screen = "trade_up";
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
        var _tutorial_selected = keyboard_check_pressed(ord("T"));
        if (mouse_check_button_pressed(mb_left)) {
            var _main_mx = device_mouse_x_to_gui(0);
            var _main_my = device_mouse_y_to_gui(0);
            if (_main_mx >= 500 && _main_mx <= 1100 && _main_my >= 350 && _main_my < 425) screen = "hub";
            if (_main_mx >= 500 && _main_mx <= 1100 && _main_my >= 425 && _main_my <= 500) _tutorial_selected = true;
        }
        if (_tutorial_selected) {
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
        var _inventory_max_scroll = max(0, ceil(array_length(catalog.pets) / 4) - 2);
        var _inventory_keyboard_moved = false;
        if (mouse_wheel_up()) inventory_scroll_row = max(0, inventory_scroll_row - 1);
        if (mouse_wheel_down()) inventory_scroll_row = min(_inventory_max_scroll, inventory_scroll_row + 1);
        if (mouse_check_button_pressed(mb_left)) {
            var _inventory_scroll_mx = device_mouse_x_to_gui(0);
            var _inventory_scroll_my = device_mouse_y_to_gui(0);
            if (_inventory_scroll_mx >= 1500 && _inventory_scroll_my >= 250 && _inventory_scroll_my <= 350) inventory_scroll_row = max(0, inventory_scroll_row - 1);
            if (_inventory_scroll_mx >= 1500 && _inventory_scroll_my >= 500 && _inventory_scroll_my <= 600) inventory_scroll_row = min(_inventory_max_scroll, inventory_scroll_row + 1);
        }
        if (keyboard_check_pressed(vk_left)) { _inventory_col = max(0, _inventory_col - 1); _inventory_keyboard_moved = true; }
        if (keyboard_check_pressed(vk_right)) { _inventory_col = min(3, _inventory_col + 1); _inventory_keyboard_moved = true; }
        if (keyboard_check_pressed(vk_up)) { _inventory_row = max(0, _inventory_row - 1); _inventory_keyboard_moved = true; }
        if (keyboard_check_pressed(vk_down)) { _inventory_row = min(ceil(array_length(catalog.pets) / 4) - 1, _inventory_row + 1); _inventory_keyboard_moved = true; }
        inventory_cursor = clamp(_inventory_row * 4 + _inventory_col, 0, array_length(catalog.pets) - 1);
        if (_inventory_keyboard_moved) {
            if (_inventory_row < inventory_scroll_row) inventory_scroll_row = _inventory_row;
            if (_inventory_row > inventory_scroll_row + 1) inventory_scroll_row = _inventory_row - 1;
        }
        if (mouse_check_button_pressed(mb_left)) {
            var _inventory_mx = device_mouse_x_to_gui(0);
            var _inventory_my = device_mouse_y_to_gui(0);
            for (var _inventory_click = 0; _inventory_click < array_length(catalog.pets); _inventory_click++) {
                var _inventory_x = 70 + (_inventory_click mod 4) * 380;
                var _inventory_y = 225 + ((_inventory_click div 4) - inventory_scroll_row) * 270;
                if (_inventory_mx >= _inventory_x && _inventory_mx <= _inventory_x + 330 && _inventory_my >= _inventory_y && _inventory_my <= _inventory_y + 225) inventory_cursor = _inventory_click;
            }
            if (_inventory_mx >= 620 && _inventory_mx <= 980 && _inventory_my >= 790 && _inventory_my <= 855) {
                if (can_sell_pet(inventory_cursor)) { sale_confirm_stage = 1; economy_message = ""; }
                else if (catalog.pets[inventory_cursor].rarity == 4 && pet_quantities[inventory_cursor] > 0) economy_message = "Exalted Battlepets cannot be sold.";
                else if (catalog.pets[inventory_cursor].owner_only && pet_quantities[inventory_cursor] == 1) economy_message = "Your special owner copy cannot be sold.";
            }
        }
        if (keyboard_check_pressed(ord("S")) || keyboard_check_pressed(vk_enter)) {
            if (can_sell_pet(inventory_cursor)) { sale_confirm_stage = 1; economy_message = ""; }
            else if (catalog.pets[inventory_cursor].rarity == 4 && pet_quantities[inventory_cursor] > 0) economy_message = "Exalted Battlepets cannot be sold.";
            else if (catalog.pets[inventory_cursor].owner_only && pet_quantities[inventory_cursor] == 1) economy_message = "Your special owner copy cannot be sold.";
        }
        break;

    case "mode":
        var _trading_selected = keyboard_check_pressed(ord("T"));
        var _settings_selected = keyboard_check_pressed(ord("S"));
        if (mouse_check_button_pressed(mb_left)) {
            var _mode_mx = device_mouse_x_to_gui(0);
            var _mode_my = device_mouse_y_to_gui(0);
            if (_mode_mx >= 40 && _mode_mx <= 440 && _mode_my >= 120 && _mode_my <= 300) _settings_selected = true;
            if (_mode_mx >= 1160 && _mode_mx <= 1560 && _mode_my >= 120 && _mode_my <= 335) _trading_selected = true;
            if (_mode_mx >= 520 && _mode_mx <= 1080 && _mode_my >= 285 && _mode_my < 375) keyboard_key_press(ord("B"));
            if (_mode_mx >= 520 && _mode_mx <= 1080 && _mode_my >= 375 && _mode_my <= 465) keyboard_key_press(ord("L"));
        }
        if (_settings_selected) economy_message = "Settings are coming soon.";
        if (_trading_selected) {
            trading_cursor = 0;
            economy_message = "";
            screen = "trading";
            break;
        }
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

    case "trading":
        if (keyboard_check_pressed(vk_left)) trading_cursor = 0;
        if (keyboard_check_pressed(vk_right)) trading_cursor = 1;
        var _choose_trade = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space);
        if (mouse_check_button_pressed(mb_left)) {
            var _trading_mx = device_mouse_x_to_gui(0);
            var _trading_my = device_mouse_y_to_gui(0);
            if (_trading_my >= 285 && _trading_my <= 585) {
                if (_trading_mx >= 220 && _trading_mx <= 750) { trading_cursor = 0; _choose_trade = true; }
                if (_trading_mx >= 850 && _trading_mx <= 1380) { trading_cursor = 1; _choose_trade = true; }
            }
        }
        if (_choose_trade) {
            if (trading_cursor == 0) {
                trade_up_cursor = 0;
                trade_up_confirm = false;
                economy_message = "";
                screen = "trade_up";
            } else {
                economy_message = "Player Trading is coming in M4.";
            }
        }
        break;

    case "trade_up":
        if (keyboard_check_pressed(vk_left)) trade_up_cursor = max(0, trade_up_cursor - 1);
        if (keyboard_check_pressed(vk_right)) trade_up_cursor = min(2, trade_up_cursor + 1);
        var _start_trade_up = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space);
        if (mouse_check_button_pressed(mb_left)) {
            var _trade_up_mx = device_mouse_x_to_gui(0);
            var _trade_up_my = device_mouse_y_to_gui(0);
            if (_trade_up_my >= 285 && _trade_up_my <= 585) {
                for (var _trade_up_click = 0; _trade_up_click < 3; _trade_up_click++) {
                    var _trade_up_x = 95 + _trade_up_click * 505;
                    if (_trade_up_mx >= _trade_up_x && _trade_up_mx <= _trade_up_x + 400) { trade_up_cursor = _trade_up_click; _start_trade_up = true; }
                }
            }
        }
        if (_start_trade_up) {
            if (trade_up_owned_count(trade_up_cursor) >= 3) {
                reset_trade_up_selection(trade_up_cursor);
                screen = "trade_up_select";
            } else {
                economy_message = "You need 3 " + rarity_names[trade_up_cursor] + " Battlepets to trade up.";
            }
        }
        break;

    case "trade_up_select":
        var _trade_candidates = [];
        for (var _trade_candidate_index = 0; _trade_candidate_index < array_length(catalog.pets); _trade_candidate_index++) {
            if (catalog.pets[_trade_candidate_index].rarity == trade_up_cursor) array_push(_trade_candidates, _trade_candidate_index);
        }
        var _trade_candidate_position = 0;
        for (var _trade_find_position = 0; _trade_find_position < array_length(_trade_candidates); _trade_find_position++) {
            if (_trade_candidates[_trade_find_position] == trade_up_pet_cursor) _trade_candidate_position = _trade_find_position;
        }
        if (!trade_up_confirm) {
            if (keyboard_check_pressed(vk_left)) _trade_candidate_position = max(0, _trade_candidate_position - 1);
            if (keyboard_check_pressed(vk_right)) _trade_candidate_position = min(array_length(_trade_candidates) - 1, _trade_candidate_position + 1);
            trade_up_pet_cursor = _trade_candidates[_trade_candidate_position];
            if (keyboard_check_pressed(vk_space) && trade_up_selected_total() < 3 && trade_up_selected_counts[trade_up_pet_cursor] < pet_quantities[trade_up_pet_cursor]) trade_up_selected_counts[trade_up_pet_cursor] += 1;
            if (keyboard_check_pressed(ord("R")) && trade_up_selected_counts[trade_up_pet_cursor] > 0) trade_up_selected_counts[trade_up_pet_cursor] -= 1;
            if (mouse_check_button_pressed(mb_left) || mouse_check_button_pressed(mb_right)) {
                var _trade_select_mx = device_mouse_x_to_gui(0);
                var _trade_select_my = device_mouse_y_to_gui(0);
                if (_trade_select_my >= 245 && _trade_select_my <= 610) {
                    for (var _trade_select_card = 0; _trade_select_card < array_length(_trade_candidates); _trade_select_card++) {
                        var _trade_select_x = 300 + _trade_select_card * 600;
                        if (_trade_select_mx >= _trade_select_x && _trade_select_mx <= _trade_select_x + 400) {
                            trade_up_pet_cursor = _trade_candidates[_trade_select_card];
                            if (mouse_check_button_pressed(mb_left) && trade_up_selected_total() < 3 && trade_up_selected_counts[trade_up_pet_cursor] < pet_quantities[trade_up_pet_cursor]) trade_up_selected_counts[trade_up_pet_cursor] += 1;
                            if (mouse_check_button_pressed(mb_right) && trade_up_selected_counts[trade_up_pet_cursor] > 0) trade_up_selected_counts[trade_up_pet_cursor] -= 1;
                        }
                    }
                }
            }
            if (keyboard_check_pressed(vk_enter)) {
                if (trade_up_selected_total() == 3) trade_up_confirm = true; else economy_message = "Choose exactly 3 Battlepets to continue.";
            }
        } else {
            if (keyboard_check_pressed(ord("C"))) trade_up_confirm = false;
            if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
                if (perform_trade_up(trade_up_cursor)) { trade_up_confirm = false; screen = "trade_up_reward"; }
            }
        }
        break;

    case "trade_up_reward":
        if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) || mouse_check_button_pressed(mb_left)) {
            reset_trade_up_selection(trade_up_cursor);
            screen = "trade_up";
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
        if (shuffle_timer <= 0 || keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) || mouse_check_button_pressed(mb_left)) {
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
        if (mouse_check_button_pressed(mb_left)) {
            var _roster_mx = device_mouse_x_to_gui(0);
            var _roster_my = device_mouse_y_to_gui(0);
            var _roster_columns_click = setup_players > 4 ? 2 : 1;
            var _roster_rows_click = ceil(setup_players / _roster_columns_click);
            var _roster_start_click = 800 - ((_roster_columns_click * 570 + (_roster_columns_click - 1) * 30) * 0.5);
            for (var _roster_click = 0; _roster_click < setup_players; _roster_click++) {
                var _roster_click_col = _roster_click div _roster_rows_click;
                var _roster_click_row = _roster_click mod _roster_rows_click;
                var _roster_click_x = _roster_start_click + _roster_click_col * 600;
                var _roster_click_y = 205 + _roster_click_row * 92;
                if (_roster_mx >= _roster_click_x && _roster_mx <= _roster_click_x + 570 && _roster_my >= _roster_click_y && _roster_my <= _roster_click_y + 72) roster_selected = _roster_click;
            }
            if (_roster_my >= 700 && _roster_my < 760) open_collection("local_roster", roster_selected);
            if (_roster_my >= 760 && _roster_my <= 815) start_match();
        }
        break;

    case "collection":
        var _collection_col = collection_cursor mod 4;
        var _collection_row = collection_cursor div 4;
        var _collection_max_scroll = max(0, ceil(collection_slot_count / 4) - 2);
        var _collection_keyboard_moved = false;
        if (mouse_wheel_up()) collection_scroll_row = max(0, collection_scroll_row - 1);
        if (mouse_wheel_down()) collection_scroll_row = min(_collection_max_scroll, collection_scroll_row + 1);
        if (mouse_check_button_pressed(mb_left)) {
            var _collection_scroll_mx = device_mouse_x_to_gui(0);
            var _collection_scroll_my = device_mouse_y_to_gui(0);
            if (_collection_scroll_mx >= 1500 && _collection_scroll_my >= 210 && _collection_scroll_my <= 310) collection_scroll_row = max(0, collection_scroll_row - 1);
            if (_collection_scroll_mx >= 1500 && _collection_scroll_my >= 470 && _collection_scroll_my <= 570) collection_scroll_row = min(_collection_max_scroll, collection_scroll_row + 1);
        }
        if (keyboard_check_pressed(vk_left)) { _collection_col = max(0, _collection_col - 1); _collection_keyboard_moved = true; }
        if (keyboard_check_pressed(vk_right)) { _collection_col = min(3, _collection_col + 1); _collection_keyboard_moved = true; }
        if (keyboard_check_pressed(vk_up)) { _collection_row = max(0, _collection_row - 1); _collection_keyboard_moved = true; }
        if (keyboard_check_pressed(vk_down)) { _collection_row = min(2, _collection_row + 1); _collection_keyboard_moved = true; }
        collection_cursor = _collection_row * 4 + _collection_col;
        if (_collection_keyboard_moved) {
            if (_collection_row < collection_scroll_row) collection_scroll_row = _collection_row;
            if (_collection_row > collection_scroll_row + 1) collection_scroll_row = _collection_row - 1;
        }

        var _collection_toggle = keyboard_check_pressed(vk_space);
        if (mouse_check_button_pressed(mb_left)) {
            var _collection_mx = device_mouse_x_to_gui(0);
            var _collection_my = device_mouse_y_to_gui(0);
            var _collection_start_click = (1600 - (4 * 350 + 3 * 25)) * 0.5;
            for (var _collection_click = 0; _collection_click < collection_slot_count; _collection_click++) {
                var _collection_click_x = _collection_start_click + (_collection_click mod 4) * 375;
                var _collection_click_y = 145 + ((_collection_click div 4) - collection_scroll_row) * 208;
                if (_collection_mx >= _collection_click_x && _collection_mx <= _collection_click_x + 350 && _collection_my >= _collection_click_y && _collection_my <= _collection_click_y + 190) { collection_cursor = _collection_click; _collection_toggle = true; }
            }
        }
        if (_collection_toggle && collection_cursor < array_length(owned_pet_ids)) {
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

        if ((keyboard_check_pressed(vk_enter) || (mouse_check_button_pressed(mb_left) && device_mouse_y_to_gui(0) >= 805)) && array_length(collection_selected_ids) == setup_team_size) {
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
        if (mouse_check_button_pressed(mb_left)) {
            var _setup_mx = device_mouse_x_to_gui(0);
            var _setup_my = device_mouse_y_to_gui(0);
            if (_setup_my >= 280 && _setup_my <= 350) { setup_players += _setup_mx < 800 ? -1 : 1; setup_players = clamp(setup_players, 2, 8); save_setup_for_mode(play_mode); }
            if (_setup_my >= 410 && _setup_my <= 480) { setup_team_size += _setup_mx < 800 ? -1 : 1; setup_team_size = clamp(setup_team_size, 2, 4); save_setup_for_mode(play_mode); }
            if (play_mode == "bot" && _setup_my >= 495 && _setup_my < 555) { setup_difficulty = (setup_difficulty + 1) mod 3; save_setup_for_mode(play_mode); }
            if (play_mode == "bot" && _setup_my >= 555 && _setup_my < 615) { setup_bot_speed = (setup_bot_speed + 1) mod 3; save_setup_for_mode(play_mode); }
            if (play_mode == "bot" && _setup_my >= 615 && _setup_my < 675) open_collection("setup", -1);
            if (_setup_my >= (play_mode == "bot" ? 685 : 620) && _setup_my <= 760) keyboard_key_press(vk_enter);
        }
        break;

    case "handoff":
        if (keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_enter) || mouse_check_button_pressed(mb_left)) {
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

        if (!_player.is_bot && mouse_check_button_pressed(mb_left)) {
            var _battle_mx = device_mouse_x_to_gui(0);
            var _battle_my = device_mouse_y_to_gui(0);
            var _battle_team_size = array_length(_player.pets);
            if (_battle_my < 88 && _battle_mx >= 1420) { screen_before_pause = "battle"; screen = "pause"; break; }
            for (var _battle_player_click = 0; _battle_player_click < array_length(match.players); _battle_player_click++) {
                var _battle_panel_x = 25 + (_battle_player_click mod 4) * 392;
                var _battle_panel_y = 100 + (_battle_player_click div 4) * 335;
                var _battle_pet_rows = ceil(_battle_team_size / 2);
                var _battle_card_width = 172;
                var _battle_card_height = (199 - (_battle_pet_rows - 1) * 6) / _battle_pet_rows;
                for (var _battle_pet_click = 0; _battle_pet_click < _battle_team_size; _battle_pet_click++) {
                    var _battle_card_x = _battle_panel_x + 10 + (_battle_pet_click mod 2) * 178;
                    var _battle_card_y = _battle_panel_y + 96 + (_battle_pet_click div 2) * (_battle_card_height + 6);
                    if (_battle_mx >= _battle_card_x && _battle_mx <= _battle_card_x + _battle_card_width && _battle_my >= _battle_card_y && _battle_my <= _battle_card_y + _battle_card_height) {
                        if (_battle_player_click == _current && bp_pet_alive(_player.pets[_battle_pet_click]) && _player.pets[_battle_pet_click].stun_turns <= 0) selected_actor = _battle_pet_click;
                        if (_battle_player_click != _current && bp_action_is_legal(match, _current, selected_actor, selected_action, _battle_player_click, _battle_pet_click)) selected_target = _battle_player_click * _battle_team_size + _battle_pet_click;
                    }
                }
            }
            if (_battle_my >= 790) {
                if (_battle_mx < 255) selected_action = "basic";
                else if (_battle_mx < 475) selected_action = "super";
                else if (_battle_mx < 695) selected_action = "card";
                else if (_battle_mx < 895) { controls_open = true; details_open = false; break; }
                else if (_battle_mx < 1095) {
                    details_open = !details_open;
                    if (details_open) { detail_player = selected_target >= 0 ? selected_target div _battle_team_size : _current; detail_slot = selected_target >= 0 ? selected_target mod _battle_team_size : selected_actor; }
                    break;
                } else if (selected_target >= 0) {
                    var _click_target_player = selected_target div _battle_team_size;
                    var _click_target_slot = selected_target mod _battle_team_size;
                    present_action(_current, selected_actor, selected_action, _click_target_player, _click_target_slot);
                    break;
                }
            }
        }

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
        if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) || mouse_check_button_pressed(mb_left)) screen = "main";
        break;
}

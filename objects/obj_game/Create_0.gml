randomize();
display_set_gui_size(1600, 900);
title_font = font_add("Arial", 190, true, false, 32, 127);

catalog = bp_catalog_create();
global.bp_self_tests_passed = bp_run_self_tests(catalog);

account_id = "owner_glitch";
account_username = "Glitch";
account_verified = account_id == "owner_glitch";

ini_open("battlepets_save.ini");
battle_coins = max(0, floor(ini_read_real("currency", "battle_coins", 0)));
saved_bot_players = clamp(floor(ini_read_real("bot_setup", "players", 2)), 2, 8);
saved_bot_team_size = clamp(floor(ini_read_real("bot_setup", "team_size", 2)), 2, 4);
saved_bot_difficulty = clamp(floor(ini_read_real("bot_setup", "difficulty", 0)), 0, 2);
saved_bot_speed = clamp(floor(ini_read_real("bot_setup", "speed", 0)), 0, 2);
saved_local_players = clamp(floor(ini_read_real("local_setup", "players", 2)), 2, 8);
saved_local_team_size = clamp(floor(ini_read_real("local_setup", "team_size", 2)), 2, 4);
pet_quantities = [];
for (var _inventory_load = 0; _inventory_load < array_length(catalog.pets); _inventory_load++) {
    var _loaded_quantity = max(0, floor(ini_read_real("inventory", catalog.pets[_inventory_load].id, 1)));
    if (catalog.pets[_inventory_load].owner_only) _loaded_quantity = max(1, _loaded_quantity);
    array_push(pet_quantities, _loaded_quantity);
}
ini_close();

screen = "main";
screen_before_pause = "battle";
play_mode = "bot";
setup_players = saved_bot_players;
setup_team_size = saved_bot_team_size;
setup_difficulty = saved_bot_difficulty;
setup_bot_speed = saved_bot_speed;
match = undefined;
selected_actor = 0;
selected_action = "basic";
selected_target = -1;
bot_delay = 30;
tutorial = false;
details_open = false;
controls_open = false;
detail_player = -1;
detail_slot = -1;
combat_fx_timer = 0;
combat_fx_duration = 75;
combat_fx = undefined;
shuffle_timer = 0;
shuffle_duration = 240;
shuffle_candidate = 0;
local_player_names = [];
local_player_bots = [];
roster_selected = 0;
roster_editing = false;
roster_original_name = "";
last_coin_reward = 0;
owned_pet_ids = [];
for (var _owned_index = 0; _owned_index < array_length(catalog.pets); _owned_index++) array_push(owned_pet_ids, catalog.pets[_owned_index].id);
bot_lineup_ids = [];
local_player_lineups = [];
collection_selected_ids = [];
collection_cursor = 0;
collection_scroll_row = 0;
collection_return_screen = "setup";
collection_context_seat = -1;
collection_slot_count = 12;
hub_cursor = 1;
trading_cursor = 0;
trade_up_cursor = 0;
trade_up_confirm = false;
trade_up_pet_cursor = 0;
trade_up_selected_counts = array_create(array_length(catalog.pets), 0);
trade_up_reward_index = -1;
pack_cursor = 0;
pack_confirm_open = false;
pack_results = [];
inventory_cursor = array_length(catalog.pets) - 1;
inventory_scroll_row = max(0, ceil(array_length(catalog.pets) / 4) - 2);
sale_confirm_stage = 0;
economy_message = "";

rarity_names = ["Basic", "Uncommon", "Epic", "Legendary", "Exalted"];
rarity_sale_values = [5, 10, 20, 30, 50];
rarity_colors = [make_color_rgb(95, 170, 105), make_color_rgb(70, 145, 220), make_color_rgb(155, 85, 205), make_color_rgb(220, 155, 35), make_color_rgb(205, 240, 255)];

pet_sale_value = function(_pet) {
    return _pet.id == "ghost_axle" ? 1400 : rarity_sale_values[_pet.rarity];
};

can_sell_pet = function(_pet_index) {
    if (_pet_index < 0 || _pet_index >= array_length(catalog.pets)) return false;
    var _pet = catalog.pets[_pet_index];
    if (pet_quantities[_pet_index] <= 0) return false;
    if (_pet.rarity == 4) return false;
    return !_pet.owner_only || pet_quantities[_pet_index] > 1;
};

bot_think_delays = [90, 50, 18];
bot_action_delays = [110, 75, 45];

get_bot_think_delay = function() {
    return bot_think_delays[setup_bot_speed];
};

save_battle_coins = function() {
    ini_open("battlepets_save.ini");
    ini_write_real("currency", "battle_coins", battle_coins);
    ini_close();
};

save_economy = function() {
    ini_open("battlepets_save.ini");
    ini_write_real("currency", "battle_coins", battle_coins);
    for (var _save_pet = 0; _save_pet < array_length(catalog.pets); _save_pet++) {
        ini_write_real("inventory", catalog.pets[_save_pet].id, pet_quantities[_save_pet]);
    }
    ini_close();
};

rebuild_owned_pet_ids = function() {
    owned_pet_ids = [];
    for (var _owner_pet = 0; _owner_pet < array_length(catalog.pets); _owner_pet++) {
        if (catalog.pets[_owner_pet].owner_only && pet_quantities[_owner_pet] > 0) array_push(owned_pet_ids, catalog.pets[_owner_pet].id);
    }
    for (var _owned_pet = 0; _owned_pet < array_length(catalog.pets); _owned_pet++) {
        if (!catalog.pets[_owned_pet].owner_only && pet_quantities[_owned_pet] > 0) array_push(owned_pet_ids, catalog.pets[_owned_pet].id);
    }
};

catalog_pet_index_by_id = function(_pet_id) {
    for (var _pet_index = 0; _pet_index < array_length(catalog.pets); _pet_index++) {
        if (catalog.pets[_pet_index].id == _pet_id) return _pet_index;
    }
    return -1;
};

cleanup_lineups = function() {
    for (var _bot_slot = array_length(bot_lineup_ids) - 1; _bot_slot >= 0; _bot_slot--) {
        var _bot_index = catalog_pet_index_by_id(bot_lineup_ids[_bot_slot]);
        if (_bot_index < 0 || pet_quantities[_bot_index] <= 0) array_delete(bot_lineup_ids, _bot_slot, 1);
    }
    for (var _lineup_player = 0; _lineup_player < array_length(local_player_lineups); _lineup_player++) {
        for (var _lineup_slot = array_length(local_player_lineups[_lineup_player]) - 1; _lineup_slot >= 0; _lineup_slot--) {
            var _lineup_index = catalog_pet_index_by_id(local_player_lineups[_lineup_player][_lineup_slot]);
            if (_lineup_index < 0 || pet_quantities[_lineup_index] <= 0) array_delete(local_player_lineups[_lineup_player], _lineup_slot, 1);
        }
    }
};

trade_up_owned_count = function(_rarity) {
    var _total = 0;
    for (var _trade_count_index = 0; _trade_count_index < array_length(catalog.pets); _trade_count_index++) {
        if (catalog.pets[_trade_count_index].rarity == _rarity) _total += pet_quantities[_trade_count_index];
    }
    return _total;
};

reset_trade_up_selection = function(_rarity) {
    trade_up_selected_counts = array_create(array_length(catalog.pets), 0);
    trade_up_pet_cursor = 0;
    for (var _trade_first_index = 0; _trade_first_index < array_length(catalog.pets); _trade_first_index++) {
        if (catalog.pets[_trade_first_index].rarity == _rarity) { trade_up_pet_cursor = _trade_first_index; break; }
    }
    trade_up_confirm = false;
    economy_message = "";
};

trade_up_selected_total = function() {
    var _selected_total = 0;
    for (var _selected_count_index = 0; _selected_count_index < array_length(trade_up_selected_counts); _selected_count_index++) _selected_total += trade_up_selected_counts[_selected_count_index];
    return _selected_total;
};

choose_weighted_reward = function(_candidates, _chance_space) {
    if (array_length(_candidates) <= 0) return undefined;
    var _fixed_total = 0;
    var _ordinary = [];
    for (var _candidate_scan = 0; _candidate_scan < array_length(_candidates); _candidate_scan++) {
        var _candidate_index = _candidates[_candidate_scan];
        var _fixed_chance = catalog.pets[_candidate_index].fixed_legendary_chance;
        if (_fixed_chance > 0) _fixed_total += _fixed_chance; else array_push(_ordinary, _candidate_index);
    }
    if (array_length(_ordinary) <= 0 || _fixed_total >= _chance_space) return _candidates[irandom(array_length(_candidates) - 1)];
    var _reward_roll = random(_chance_space);
    var _fixed_cursor = 0;
    for (var _fixed_scan = 0; _fixed_scan < array_length(_candidates); _fixed_scan++) {
        var _fixed_index = _candidates[_fixed_scan];
        var _candidate_chance = catalog.pets[_fixed_index].fixed_legendary_chance;
        if (_candidate_chance <= 0) continue;
        _fixed_cursor += _candidate_chance;
        if (_reward_roll < _fixed_cursor) return _fixed_index;
    }
    return _ordinary[irandom(array_length(_ordinary) - 1)];
};

perform_trade_up = function(_rarity) {
    if (_rarity < 0 || _rarity >= 3 || trade_up_selected_total() != 3) return false;
    for (var _trade_validate_index = 0; _trade_validate_index < array_length(catalog.pets); _trade_validate_index++) {
        if (trade_up_selected_counts[_trade_validate_index] < 0 || trade_up_selected_counts[_trade_validate_index] > pet_quantities[_trade_validate_index]) return false;
        if (trade_up_selected_counts[_trade_validate_index] > 0 && catalog.pets[_trade_validate_index].rarity != _rarity) return false;
    }
    var _rewards = [];
    for (var _trade_reward_index = 0; _trade_reward_index < array_length(catalog.pets); _trade_reward_index++) {
        if (catalog.pets[_trade_reward_index].rarity == _rarity + 1 && !catalog.pets[_trade_reward_index].owner_only) array_push(_rewards, _trade_reward_index);
    }
    if (array_length(_rewards) <= 0) return false;
    for (var _trade_remove_index = 0; _trade_remove_index < array_length(catalog.pets); _trade_remove_index++) pet_quantities[_trade_remove_index] -= trade_up_selected_counts[_trade_remove_index];
    var _reward_index = _rarity + 1 == 3 ? choose_weighted_reward(_rewards, 100) : _rewards[irandom(array_length(_rewards) - 1)];
    pet_quantities[_reward_index] += 1;
    trade_up_reward_index = _reward_index;
    rebuild_owned_pet_ids();
    cleanup_lineups();
    save_economy();
    economy_message = "";
    return true;
};

draw_pack_pet = function(_pack, _excluded_id) {
    var _rarity = bp_pack_roll_rarity(_pack, irandom(99));
    var _candidates = [];
    for (var _draw_index = 0; _draw_index < array_length(catalog.pets); _draw_index++) {
        var _draw_pet = catalog.pets[_draw_index];
        if (_draw_pet.rarity == _rarity && _draw_pet.id != _excluded_id && !_draw_pet.owner_only) array_push(_candidates, _draw_index);
    }
    if (array_length(_candidates) <= 0) return undefined;
    var _chosen_index = _rarity == 3 ? choose_weighted_reward(_candidates, _pack.weights[_rarity]) : _candidates[irandom(array_length(_candidates) - 1)];
    return catalog.pets[_chosen_index].id;
};

purchase_selected_pack = function() {
    var _pack = catalog.packs[pack_cursor];
    if (battle_coins < _pack.price) {
        economy_message = "Not enough Battle Coins.";
        return false;
    }
    var _first_reward = draw_pack_pet(_pack, "");
    var _second_reward = draw_pack_pet(_pack, _first_reward);
    if (is_undefined(_first_reward) || is_undefined(_second_reward)) {
        economy_message = "This pack cannot be opened right now.";
        return false;
    }
    battle_coins -= _pack.price;
    pet_quantities[catalog_pet_index_by_id(_first_reward)] += 1;
    pet_quantities[catalog_pet_index_by_id(_second_reward)] += 1;
    pack_results = [_first_reward, _second_reward];
    rebuild_owned_pet_ids();
    save_economy();
    economy_message = "Pack opened!";
    pack_confirm_open = false;
    screen = "pack_result";
    return true;
};

sell_selected_pet = function() {
    if (inventory_cursor < 0 || inventory_cursor >= array_length(catalog.pets)) return false;
    if (!can_sell_pet(inventory_cursor)) {
        economy_message = catalog.pets[inventory_cursor].rarity == 4 ? "Exalted Battlepets cannot be sold." : "Your special owner copy cannot be sold.";
        sale_confirm_stage = 0;
        return false;
    }
    var _pet = catalog.pets[inventory_cursor];
    var _sale_value = pet_sale_value(_pet);
    pet_quantities[inventory_cursor] -= 1;
    battle_coins += _sale_value;
    rebuild_owned_pet_ids();
    cleanup_lineups();
    save_economy();
    economy_message = "Sold " + _pet.name + " for " + string(_sale_value) + " Battle Coins.";
    sale_confirm_stage = 0;
    return true;
};

load_setup_for_mode = function(_mode) {
    if (_mode == "bot") {
        setup_players = saved_bot_players;
        setup_team_size = saved_bot_team_size;
        setup_difficulty = saved_bot_difficulty;
        setup_bot_speed = saved_bot_speed;
    } else if (_mode == "local") {
        setup_players = saved_local_players;
        setup_team_size = saved_local_team_size;
    }
};

save_setup_for_mode = function(_mode) {
    ini_open("battlepets_save.ini");
    if (_mode == "bot") {
        saved_bot_players = setup_players;
        saved_bot_team_size = setup_team_size;
        saved_bot_difficulty = setup_difficulty;
        saved_bot_speed = setup_bot_speed;
        ini_write_real("bot_setup", "players", saved_bot_players);
        ini_write_real("bot_setup", "team_size", saved_bot_team_size);
        ini_write_real("bot_setup", "difficulty", saved_bot_difficulty);
        ini_write_real("bot_setup", "speed", saved_bot_speed);
    } else if (_mode == "local") {
        saved_local_players = setup_players;
        saved_local_team_size = setup_team_size;
        ini_write_real("local_setup", "players", saved_local_players);
        ini_write_real("local_setup", "team_size", saved_local_team_size);
    }
    ini_close();
};

award_match_coins = function() {
    if (match == undefined || match.coins_awarded) return 0;
    match.coins_awarded = true;
    last_coin_reward = 0;

    if (match.winner == 0 && !match.players[0].is_bot) {
        if (play_mode == "bot") last_coin_reward = 2;
        if (play_mode == "online") last_coin_reward = 10;
    }

    if (last_coin_reward > 0) {
        battle_coins += last_coin_reward;
        save_battle_coins();
        match.last_message += "  +" + string(last_coin_reward) + " Battle Coins!";
    }
    return last_coin_reward;
};

prepare_local_roster = function() {
    local_player_names = [];
    local_player_bots = [];
    local_player_lineups = [];
    for (var _roster_index = 0; _roster_index < setup_players; _roster_index++) {
        array_push(local_player_names, "Player " + string(_roster_index + 1));
        array_push(local_player_bots, false);
        var _default_lineup = [];
        for (var _default_slot = 0; _default_slot < setup_team_size; _default_slot++) array_push(_default_lineup, owned_pet_ids[(_roster_index * setup_team_size + _default_slot) mod array_length(owned_pet_ids)]);
        array_push(local_player_lineups, _default_lineup);
    }
    roster_selected = 0;
    roster_editing = false;
    roster_original_name = "";
    keyboard_string = "";
};

default_lineup = function() {
    var _result = [];
    for (var _lineup_slot = 0; _lineup_slot < setup_team_size; _lineup_slot++) array_push(_result, owned_pet_ids[_lineup_slot mod array_length(owned_pet_ids)]);
    return _result;
};

copy_lineup = function(_source) {
    var _result = [];
    for (var _copy_index = 0; _copy_index < array_length(_source); _copy_index++) array_push(_result, _source[_copy_index]);
    return _result;
};

open_collection = function(_return_screen, _seat) {
    collection_return_screen = _return_screen;
    collection_context_seat = _seat;
    var _source = _seat >= 0 ? local_player_lineups[_seat] : bot_lineup_ids;
    if (array_length(_source) != setup_team_size) _source = default_lineup();
    collection_selected_ids = copy_lineup(_source);
    collection_cursor = 0;
    collection_scroll_row = 0;
    screen = "collection";
};

catalog_pet_by_id = function(_pet_id) {
    for (var _catalog_index = 0; _catalog_index < array_length(catalog.pets); _catalog_index++) {
        if (catalog.pets[_catalog_index].id == _pet_id) return catalog.pets[_catalog_index];
    }
    return undefined;
};

rebuild_owned_pet_ids();

start_match = function() {
    var _names = [];
    var _bots = [];
    for (var _i = 0; _i < setup_players; _i++) {
        var _is_bot = play_mode == "local" ? local_player_bots[_i] : (play_mode == "bot" && _i > 0);
        var _chosen_name = play_mode == "local" ? local_player_names[_i] : (_is_bot ? "Bot " + string(_i) : "Player " + string(_i + 1));
        array_push(_names, _chosen_name);
        array_push(_bots, _is_bot);
    }

    match = bp_match_create(catalog, _names, _bots, setup_team_size, setup_difficulty);
    if (play_mode == "local") {
        for (var _local_team = 0; _local_team < array_length(match.players); _local_team++) {
            match.players[_local_team].pets = [];
            for (var _local_pet = 0; _local_pet < array_length(local_player_lineups[_local_team]); _local_pet++) {
                array_push(match.players[_local_team].pets, bp_pet_state_create(catalog_pet_by_id(local_player_lineups[_local_team][_local_pet])));
            }
        }
    } else {
        if (array_length(bot_lineup_ids) != setup_team_size) bot_lineup_ids = default_lineup();
        match.players[0].pets = [];
        for (var _bot_pet = 0; _bot_pet < array_length(bot_lineup_ids); _bot_pet++) array_push(match.players[0].pets, bp_pet_state_create(catalog_pet_by_id(bot_lineup_ids[_bot_pet])));
    }
    last_coin_reward = 0;
    selected_action = "basic";
    selected_actor = bp_first_legal_actor(match, bp_current_player_index(match));
    selected_target = bp_find_legal_target(match, bp_current_player_index(match), selected_actor, selected_action, -1, 1);
    bot_delay = get_bot_think_delay();
    details_open = false;
    controls_open = false;
    detail_player = -1;
    detail_slot = -1;
    combat_fx_timer = 0;
    combat_fx = undefined;
    shuffle_timer = shuffle_duration;
    shuffle_candidate = match.order[irandom(array_length(match.order) - 1)];
    screen = "shuffle";
};

reset_turn_selection = function() {
    if (match.phase != "active") exit;
    var _current = bp_current_player_index(match);
    selected_action = "basic";
    selected_actor = bp_first_legal_actor(match, _current);
    selected_target = bp_find_legal_target(match, _current, selected_actor, selected_action, -1, 1);
    bot_delay = match.players[_current].is_bot ? get_bot_think_delay() : 30;
};

present_action = function(_player_index, _actor_slot, _action, _target_player, _target_slot) {
    var _player = match.players[_player_index];
    var _target = match.players[_target_player].pets[_target_slot];
    var _health_before = _target.health;
    var _title = _player.card.name;
    if (_action != "card") {
        var _actor = _player.pets[_actor_slot];
        var _attack = _action == "super" ? _actor.definition.super : _actor.definition.basic;
        _title = _actor.definition.name + " - " + _attack.name;
    }

    if (!bp_apply_action(match, _player_index, _actor_slot, _action, _target_player, _target_slot)) return false;

    var _presentation_duration = _player.is_bot ? bot_action_delays[setup_bot_speed] : combat_fx_duration;
    combat_fx = {
        actor_player: _player_index,
        actor_slot: _actor_slot,
        target_player: _target_player,
        target_slot: _target_slot,
        action: _action,
        title: _title,
        damage: max(0, _health_before - _target.health),
        message: match.last_message,
        duration: _presentation_duration
    };
    combat_fx_timer = _presentation_duration;
    details_open = false;
    return true;
};

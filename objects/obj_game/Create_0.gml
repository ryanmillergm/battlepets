randomize();
display_set_gui_size(1600, 900);

catalog = bp_catalog_create();
global.bp_self_tests_passed = bp_run_self_tests(catalog);

ini_open("battlepets_save.ini");
battle_coins = max(0, floor(ini_read_real("currency", "battle_coins", 0)));
saved_bot_players = clamp(floor(ini_read_real("bot_setup", "players", 2)), 2, 8);
saved_bot_team_size = clamp(floor(ini_read_real("bot_setup", "team_size", 2)), 2, 4);
saved_bot_difficulty = clamp(floor(ini_read_real("bot_setup", "difficulty", 0)), 0, 2);
saved_bot_speed = clamp(floor(ini_read_real("bot_setup", "speed", 0)), 0, 2);
saved_local_players = clamp(floor(ini_read_real("local_setup", "players", 2)), 2, 8);
saved_local_team_size = clamp(floor(ini_read_real("local_setup", "team_size", 2)), 2, 4);
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
collection_return_screen = "setup";
collection_context_seat = -1;
collection_slot_count = 12;

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
    screen = "collection";
};

catalog_pet_by_id = function(_pet_id) {
    for (var _catalog_index = 0; _catalog_index < array_length(catalog.pets); _catalog_index++) {
        if (catalog.pets[_catalog_index].id == _pet_id) return catalog.pets[_catalog_index];
    }
    return undefined;
};

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

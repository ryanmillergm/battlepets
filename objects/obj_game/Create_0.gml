randomize();
display_set_gui_size(1600, 900);

catalog = bp_catalog_create();
global.bp_self_tests_passed = bp_run_self_tests(catalog);
screen = "main";
screen_before_pause = "battle";
play_mode = "bot";
setup_players = 2;
setup_team_size = 2;
setup_difficulty = 0;
setup_bot_speed = 0;
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

bot_think_delays = [90, 50, 18];
bot_action_delays = [110, 75, 45];

get_bot_think_delay = function() {
    return bot_think_delays[setup_bot_speed];
};

prepare_local_roster = function() {
    local_player_names = [];
    local_player_bots = [];
    for (var _roster_index = 0; _roster_index < setup_players; _roster_index++) {
        array_push(local_player_names, "Player " + string(_roster_index + 1));
        array_push(local_player_bots, false);
    }
    roster_selected = 0;
    roster_editing = false;
    roster_original_name = "";
    keyboard_string = "";
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

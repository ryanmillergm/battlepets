randomize();
display_set_gui_size(1600, 900);

catalog = bp_catalog_create();
global.bp_self_tests_passed = bp_run_self_tests(catalog);
screen = "main";
play_mode = "bot";
setup_players = 2;
setup_team_size = 2;
setup_difficulty = 0;
match = undefined;
selected_actor = 0;
selected_action = "basic";
selected_target = -1;
bot_delay = 30;
tutorial = false;

start_match = function() {
    var _names = [];
    var _bots = [];
    for (var _i = 0; _i < setup_players; _i++) {
        var _is_bot = play_mode == "bot" && _i > 0;
        array_push(_names, _is_bot ? "Bot " + string(_i) : "Player " + string(_i + 1));
        array_push(_bots, _is_bot);
    }

    match = bp_match_create(catalog, _names, _bots, setup_team_size, setup_difficulty);
    selected_action = "basic";
    selected_actor = bp_first_legal_actor(match, bp_current_player_index(match));
    selected_target = bp_find_legal_target(match, bp_current_player_index(match), selected_actor, selected_action, -1, 1);
    bot_delay = 30;
    screen = "battle";
};

reset_turn_selection = function() {
    if (match.phase != "active") exit;
    var _current = bp_current_player_index(match);
    selected_action = "basic";
    selected_actor = bp_first_legal_actor(match, _current);
    selected_target = bp_find_legal_target(match, _current, selected_actor, selected_action, -1, 1);
    bot_delay = 30;
};

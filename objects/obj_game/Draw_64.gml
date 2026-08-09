var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
draw_clear(make_color_rgb(13, 20, 38));
draw_set_font(-1);
draw_set_alpha(1);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

if (screen == "main") {
    draw_set_color(make_color_rgb(255, 210, 70));
    draw_text_transformed(_gw * 0.5, 210, "BATTLEPETS", 3, 3, 0);
    draw_set_color(c_white);
    draw_text_transformed(_gw * 0.5, 390, "ENTER / P  -  PLAY", 1.5, 1.5, 0);
    draw_text_transformed(_gw * 0.5, 450, "T  -  TUTORIAL", 1.5, 1.5, 0);
    draw_set_color(make_color_rgb(150, 170, 205));
    draw_text(_gw * 0.5, 560, "Turn-based free-for-all battles for 2-8 players");
    exit;
}

if (screen == "mode") {
    draw_set_color(make_color_rgb(255, 210, 70));
    draw_text_transformed(_gw * 0.5, 170, "CHOOSE PLAY MODE", 2, 2, 0);
    draw_set_color(c_white);
    draw_text_transformed(_gw * 0.5, 340, "B  -  BOTS", 1.5, 1.5, 0);
    draw_text_transformed(_gw * 0.5, 420, "L  -  LOCAL (TAKE TURNS)", 1.5, 1.5, 0);
    draw_set_color(make_color_rgb(130, 145, 175));
    draw_text_transformed(_gw * 0.5, 500, "ONLINE  -  COMING IN M3", 1.25, 1.25, 0);
    draw_text(_gw * 0.5, 650, "ESC - Back");
    exit;
}

if (screen == "setup") {
    var _difficulty_names = ["Easy", "Normal", "Hard"];
    draw_set_color(make_color_rgb(255, 210, 70));
    draw_text_transformed(_gw * 0.5, 150, string_upper(play_mode) + " BATTLE SETUP", 2, 2, 0);

    draw_set_color(make_color_rgb(150, 170, 205));
    draw_text_transformed(_gw * 0.5, 265, "CHOOSE NUMBER OF PLAYERS", 1.1, 1.1, 0);
    draw_set_color(c_white);
    draw_text_transformed(_gw * 0.5, 315, "Players: " + string(setup_players) + "   (UP / DOWN)", 1.5, 1.5, 0);

    draw_set_color(make_color_rgb(150, 170, 205));
    draw_text_transformed(_gw * 0.5, 395, "CHOOSE NUMBER OF PETS", 1.1, 1.1, 0);
    draw_set_color(c_white);
    draw_text_transformed(_gw * 0.5, 445, "Pets each: " + string(setup_team_size) + "   (LEFT / RIGHT)", 1.5, 1.5, 0);

    if (play_mode == "bot") draw_text_transformed(_gw * 0.5, 535, "Bot level: " + _difficulty_names[setup_difficulty] + "   (D)", 1.5, 1.5, 0);
    draw_set_color(make_color_rgb(110, 235, 155));
    draw_text_transformed(_gw * 0.5, 650, "ENTER - START", 1.5, 1.5, 0);
    exit;
}

if (screen == "handoff") {
    var _next = match.players[bp_current_player_index(match)].name;
    draw_set_color(make_color_rgb(255, 210, 70));
    draw_text_transformed(_gw * 0.5, 320, "PASS TO " + string_upper(_next), 2, 2, 0);
    draw_set_color(c_white);
    draw_text_transformed(_gw * 0.5, 470, "Press SPACE when ready", 1.5, 1.5, 0);
    exit;
}

if (screen == "result") {
    draw_set_color(make_color_rgb(255, 210, 70));
    draw_text_transformed(_gw * 0.5, 300, match.last_message, 2, 2, 0);
    draw_set_color(c_white);
    draw_text_transformed(_gw * 0.5, 480, "ENTER - MAIN MENU", 1.5, 1.5, 0);
    exit;
}

if (screen == "battle") {
    var _current_index = bp_current_player_index(match);
    var _team_size = array_length(match.players[0].pets);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(make_color_rgb(255, 210, 70));
    draw_text_transformed(30, 18, "Round " + string(match.round) + "  |  " + match.players[_current_index].name + "'s turn", 1.35, 1.35, 0);
    draw_set_color(c_white);
    draw_text(30, 54, match.last_message);

    for (var _p = 0; _p < array_length(match.players); _p++) {
        var _col = _p mod 4;
        var _row = _p div 4;
        var _px = 25 + _col * 392;
        var _py = 100 + _row * 335;
        var _panel_color = _p == _current_index ? make_color_rgb(105, 83, 24) : make_color_rgb(28, 42, 69);
        if (match.players[_p].eliminated) _panel_color = make_color_rgb(48, 35, 44);
        draw_set_color(_panel_color);
        draw_roundrect(_px, _py, _px + 370, _py + 305, false);
        draw_set_color(c_white);
        draw_text(_px + 12, _py + 10, match.players[_p].name + (match.players[_p].is_bot ? " [BOT]" : ""));
        draw_set_color(make_color_rgb(180, 195, 225));
        draw_text(_px + 12, _py + 34, "Card: " + match.players[_p].card.name + (match.players[_p].card_used ? " (used)" : ""));

        var _card_width = (350 - (_team_size - 1) * 6) / _team_size;
        for (var _s = 0; _s < _team_size; _s++) {
            var _pet = match.players[_p].pets[_s];
            var _cx = _px + 10 + _s * (_card_width + 6);
            var _cy = _py + 66;
            var _flat = _p * _team_size + _s;
            var _is_actor = _p == _current_index && _s == selected_actor;
            var _is_target = _flat == selected_target;
            draw_set_color(_pet.health <= 0 ? make_color_rgb(55, 55, 65) : make_color_rgb(62, 78, 110));
            draw_rectangle(_cx, _cy, _cx + _card_width, _cy + 225, false);
            draw_set_color(_is_target ? c_red : (_is_actor ? c_lime : make_color_rgb(105, 125, 160)));
            draw_rectangle(_cx, _cy, _cx + _card_width, _cy + 225, true);

            if (_pet.definition.sprite != -1) draw_sprite_ext(_pet.definition.sprite, 0, _cx + _card_width * 0.5, _cy + 70, 0.42, 0.42, 0, c_white, _pet.health > 0 ? 1 : 0.35);
            draw_set_halign(fa_center);
            draw_set_color(c_white);
            draw_text_ext(_cx + _card_width * 0.5, _cy + 120, _pet.definition.name, 14, _card_width - 8);
            draw_set_color(make_color_rgb(35, 35, 45));
            draw_rectangle(_cx + 7, _cy + 170, _cx + _card_width - 7, _cy + 185, false);
            draw_set_color(_pet.health > _pet.definition.max_health * 0.35 ? make_color_rgb(80, 220, 120) : make_color_rgb(235, 80, 75));
            draw_rectangle(_cx + 7, _cy + 170, _cx + 7 + (_card_width - 14) * (_pet.health / _pet.definition.max_health), _cy + 185, false);
            draw_set_color(c_white);
            draw_text(_cx + _card_width * 0.5, _cy + 192, string(_pet.health) + "/" + string(_pet.definition.max_health));
            var _status = (_pet.shield > 0 ? "Shield " : "") + (_pet.stun_turns > 0 ? "Stunned" : "");
            draw_text(_cx + _card_width * 0.5, _cy + 210, _status);
            draw_set_halign(fa_left);
        }
    }

    draw_set_color(make_color_rgb(18, 28, 50));
    draw_rectangle(0, 790, _gw, _gh, false);
    draw_set_color(c_white);
    draw_text(25, 806, "Q/E: choose pet    LEFT/RIGHT: choose target    1: Basic    2: Super    3: Card    ENTER: act");
    draw_set_color(make_color_rgb(255, 210, 70));
    draw_text(25, 844, "Selected: " + string_upper(selected_action));
    if (tutorial) {
        draw_set_halign(fa_right);
        draw_set_color(make_color_rgb(145, 220, 255));
        draw_text(_gw - 25, 844, "Tutorial: knock out every opposing pet to win.");
    }
}

var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
draw_clear(make_color_rgb(13, 20, 38));
draw_set_font(-1);
draw_set_alpha(1);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

if (screen == "pause") {
    draw_set_color(make_color_rgb(255, 210, 70));
    draw_text_transformed(_gw * 0.5, 225, "LEAVE THIS MATCH?", 2.25, 2.25, 0);
    draw_set_color(make_color_rgb(165, 185, 220));
    draw_text(_gw * 0.5, 300, "Your current Bot or Local match will not be saved if you leave.");

    draw_set_color(make_color_rgb(38, 58, 91));
    draw_roundrect(_gw * 0.5 - 300, 365, _gw * 0.5 + 300, 565, false);
    draw_set_color(c_white);
    draw_text_transformed(_gw * 0.5, 410, "R  -  RESUME MATCH", 1.5, 1.5, 0);
    draw_text_transformed(_gw * 0.5, 475, "M  -  RETURN TO MAIN MENU", 1.5, 1.5, 0);
    draw_set_color(make_color_rgb(255, 125, 110));
    draw_text_transformed(_gw * 0.5, 540, "X  -  EXIT BATTLEPETS", 1.5, 1.5, 0);
    draw_set_color(make_color_rgb(150, 170, 205));
    draw_text(_gw * 0.5, 630, "ESC also resumes the match");
    exit;
}

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
    var _bot_speed_names = ["Relaxed", "Normal", "Quick"];
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

    if (play_mode == "bot") {
        draw_text_transformed(_gw * 0.5, 525, "Bot level: " + _difficulty_names[setup_difficulty] + "   (D)", 1.5, 1.5, 0);
        draw_text_transformed(_gw * 0.5, 585, "Bot turn speed: " + _bot_speed_names[setup_bot_speed] + "   (S)", 1.5, 1.5, 0);
    }
    draw_set_color(make_color_rgb(110, 235, 155));
    draw_text_transformed(_gw * 0.5, play_mode == "bot" ? 690 : 650, "ENTER - START", 1.5, 1.5, 0);
    exit;
}

if (screen == "local_roster") {
    draw_set_color(make_color_rgb(255, 210, 70));
    draw_text_transformed(_gw * 0.5, 105, "LOCAL PLAYER ROSTER", 2, 2, 0);
    draw_set_color(make_color_rgb(150, 170, 205));
    draw_text(_gw * 0.5, 155, "Name every participant and optionally turn any seat into a bot");

    var _roster_columns = setup_players > 4 ? 2 : 1;
    var _roster_rows = ceil(setup_players / _roster_columns);
    var _roster_width = 570;
    var _roster_start_x = _gw * 0.5 - ((_roster_columns * _roster_width + (_roster_columns - 1) * 30) * 0.5);
    for (var _roster_slot = 0; _roster_slot < setup_players; _roster_slot++) {
        var _roster_col = _roster_slot div _roster_rows;
        var _roster_row = _roster_slot mod _roster_rows;
        var _roster_x = _roster_start_x + _roster_col * (_roster_width + 30);
        var _roster_y = 205 + _roster_row * 92;
        var _roster_active = _roster_slot == roster_selected;
        draw_set_color(_roster_active ? make_color_rgb(105, 83, 24) : make_color_rgb(38, 58, 91));
        draw_roundrect(_roster_x, _roster_y, _roster_x + _roster_width, _roster_y + 72, false);
        draw_set_halign(fa_left);
        draw_set_color(c_white);
        draw_text(_roster_x + 18, _roster_y + 14, "SEAT " + string(_roster_slot + 1) + "   " + local_player_names[_roster_slot]);
        draw_set_color(local_player_bots[_roster_slot] ? make_color_rgb(255, 180, 90) : make_color_rgb(110, 235, 155));
        draw_text(_roster_x + 18, _roster_y + 42, local_player_bots[_roster_slot] ? "BOT PLAYER" : "HUMAN PLAYER");
        if (_roster_active) {
            draw_set_color(c_white);
            draw_text(_roster_x + _roster_width - 185, _roster_y + 42, roster_editing ? "TYPING NAME..." : "SELECTED");
        }
    }

    draw_set_halign(fa_center);
    draw_set_color(c_white);
    draw_text(_gw * 0.5, 705, roster_editing ? "TYPE A NAME    ENTER - SAVE    ESC - CANCEL EDIT" : "UP/DOWN - SELECT    ENTER - EDIT NAME    B - HUMAN/BOT");
    draw_set_color(make_color_rgb(110, 235, 155));
    if (!roster_editing) draw_text_transformed(_gw * 0.5, 765, "S - START MATCH", 1.5, 1.5, 0);
    draw_set_color(make_color_rgb(150, 170, 205));
    draw_text(_gw * 0.5, 825, "ESC - Back to Main Menu");
    exit;
}

if (screen == "shuffle") {
    var _shuffle_revealed = shuffle_timer <= 90;
    var _candidate_name = match.players[shuffle_candidate].name;
    var _shuffle_pulse = 1 + 0.08 * sin(current_time * 0.025);

    draw_set_color(make_color_rgb(255, 210, 70));
    draw_text_transformed(_gw * 0.5, 125, "SHUFFLING TURN ORDER", 2, 2, 0);
    draw_set_color(make_color_rgb(150, 170, 205));
    draw_text(_gw * 0.5, 185, "Every participant has an equal chance to go first");

    draw_set_color(_shuffle_revealed ? make_color_rgb(105, 83, 24) : make_color_rgb(38, 58, 91));
    draw_roundrect(_gw * 0.5 - 300, 245, _gw * 0.5 + 300, 440, false);
    draw_set_color(_shuffle_revealed ? make_color_rgb(110, 235, 155) : c_white);
    draw_text_transformed(_gw * 0.5, 320, _candidate_name, 2.4 * _shuffle_pulse, 2.4 * _shuffle_pulse, 0);
    draw_set_color(make_color_rgb(190, 205, 230));
    draw_text(_gw * 0.5, 395, _shuffle_revealed ? "GOES FIRST!" : "Shuffling...");

    if (_shuffle_revealed) {
        var _order_line = "";
        for (var _shuffle_index = 0; _shuffle_index < array_length(match.order); _shuffle_index++) {
            if (_shuffle_index > 0) _order_line += "  >  ";
            _order_line += match.players[match.order[_shuffle_index]].name;
        }
        draw_set_color(make_color_rgb(255, 210, 70));
        draw_text(_gw * 0.5, 520, "FINAL TURN ORDER");
        draw_set_color(c_white);
        draw_text_ext(_gw * 0.5, 575, _order_line, 24, 1250);
        draw_set_color(make_color_rgb(150, 170, 205));
        draw_text(_gw * 0.5, 700, "Battle starting...");
    } else {
        draw_set_color(make_color_rgb(130, 145, 175));
        draw_text(_gw * 0.5, 700, "ENTER / SPACE - Skip animation");
    }
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
    var _showing_fx = combat_fx_timer > 0;
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
        var _panel_color = _p == _current_index && !_showing_fx ? make_color_rgb(105, 83, 24) : make_color_rgb(28, 42, 69);
        if (match.players[_p].eliminated) _panel_color = make_color_rgb(48, 35, 44);
        draw_set_color(_panel_color);
        draw_roundrect(_px, _py, _px + 370, _py + 305, false);
        draw_set_color(c_white);
        draw_text(_px + 12, _py + 10, match.players[_p].name + (match.players[_p].is_bot ? " [BOT]" : ""));
        draw_set_color(match.players[_p].card_used ? make_color_rgb(75, 62, 90) : make_color_rgb(112, 67, 150));
        draw_roundrect(_px + 9, _py + 34, _px + 361, _py + 88, false);
        draw_set_color(c_white);
        draw_text(_px + 17, _py + 38, "SPECIALTY: " + match.players[_p].card.name + (match.players[_p].card_used ? " (USED)" : ""));
        draw_set_color(make_color_rgb(225, 205, 240));
        draw_text_ext(_px + 17, _py + 56, match.players[_p].card.description, 12, 338);

        var _pet_columns = 2;
        var _pet_rows = ceil(_team_size / _pet_columns);
        var _card_width = (350 - 6) / _pet_columns;
        var _card_height = (199 - (_pet_rows - 1) * 6) / _pet_rows;
        var _compact_cards = _pet_rows > 1;
        for (var _s = 0; _s < _team_size; _s++) {
            var _pet = match.players[_p].pets[_s];
            var _pet_col = _s mod _pet_columns;
            var _pet_row = _s div _pet_columns;
            var _cx = _px + 10 + _pet_col * (_card_width + 6);
            var _cy = _py + 96 + _pet_row * (_card_height + 6);
            var _flat = _p * _team_size + _s;
            var _is_actor = _showing_fx ? (_p == combat_fx.actor_player && _s == combat_fx.actor_slot) : (_p == _current_index && _s == selected_actor);
            var _is_target = _showing_fx ? (_p == combat_fx.target_player && _s == combat_fx.target_slot) : (_flat == selected_target);
            var _pulse = 1 + 0.025 * sin(current_time * 0.018);
            var _grow = (_is_actor || _is_target) ? 5 * _pulse : 0;
            draw_set_color(_pet.health <= 0 ? make_color_rgb(55, 55, 65) : make_color_rgb(62, 78, 110));
            draw_rectangle(_cx - _grow, _cy - _grow, _cx + _card_width + _grow, _cy + _card_height + _grow, false);
            draw_set_color(_is_target ? c_red : (_is_actor ? c_lime : make_color_rgb(105, 125, 160)));
            draw_rectangle(_cx - _grow, _cy - _grow, _cx + _card_width + _grow, _cy + _card_height + _grow, true);

            var _short_pet_name = string_replace(_pet.definition.name, " (Placeholder)", "");
            var _status = (_pet.shield > 0 ? "Shield " : "") + (_pet.stun_turns > 0 ? "Stunned" : "");
            if (_compact_cards) {
                if (_pet.definition.sprite != -1) draw_sprite_ext(_pet.definition.sprite, 0, _cx + 29, _cy + 34, 0.2, 0.2, 0, c_white, _pet.health > 0 ? 1 : 0.35);
                draw_set_halign(fa_left);
                draw_set_color(c_white);
                draw_text_transformed(_cx + 57, _cy + 7, _short_pet_name, 0.76, 0.76, 0);
                draw_set_color(make_color_rgb(220, 230, 250));
                draw_text_transformed(_cx + 57, _cy + 27, "1 " + _pet.definition.basic.name + "  " + string(_pet.definition.basic.damage + _pet.attack_bonus), 0.76, 0.76, 0);
                draw_set_color(_pet.super_used ? make_color_rgb(125, 130, 145) : make_color_rgb(255, 220, 105));
                draw_text_transformed(_cx + 57, _cy + 46, "2 " + _pet.definition.super.name + "  " + string(_pet.definition.super.damage + _pet.attack_bonus), 0.76, 0.76, 0);
                draw_set_color(make_color_rgb(35, 35, 45));
                draw_rectangle(_cx + 7, _cy + 68, _cx + _card_width - 7, _cy + 80, false);
                draw_set_color(_pet.health > _pet.definition.max_health * 0.35 ? make_color_rgb(80, 220, 120) : make_color_rgb(235, 80, 75));
                draw_rectangle(_cx + 7, _cy + 68, _cx + 7 + (_card_width - 14) * (_pet.health / _pet.definition.max_health), _cy + 80, false);
                draw_set_halign(fa_center);
                draw_set_color(c_white);
                draw_text(_cx + _card_width * 0.5, _cy + 82, string(_pet.health) + "/" + string(_pet.definition.max_health) + (_status == "" ? "" : "  " + _status));
            } else {
                draw_set_halign(fa_center);
                draw_set_color(c_white);
                draw_text(_cx + _card_width * 0.5, _cy + 10, _short_pet_name);

                if (_pet.definition.sprite != -1) {
                    draw_sprite_ext(_pet.definition.sprite, 0, _cx + _card_width * 0.5, _cy + 67, 0.36, 0.36, 0, c_white, _pet.health > 0 ? 1 : 0.35);
                } else {
                    draw_set_color(make_color_rgb(82, 99, 130));
                    draw_roundrect(_cx + _card_width * 0.5 - 38, _cy + 38, _cx + _card_width * 0.5 + 38, _cy + 88, false);
                    draw_set_color(make_color_rgb(170, 185, 215));
                    draw_text_transformed(_cx + _card_width * 0.5, _cy + 63, "ART COMING SOON", 0.62, 0.62, 0);
                }

                draw_set_color(make_color_rgb(220, 230, 250));
                draw_text(_cx + _card_width * 0.5, _cy + 105, "1 " + _pet.definition.basic.name + "  " + string(_pet.definition.basic.damage + _pet.attack_bonus));
                draw_set_color(_pet.super_used ? make_color_rgb(125, 130, 145) : make_color_rgb(255, 220, 105));
                draw_text(_cx + _card_width * 0.5, _cy + 130, "2 " + _pet.definition.super.name + "  " + string(_pet.definition.super.damage + _pet.attack_bonus));
                draw_set_color(make_color_rgb(35, 35, 45));
                draw_rectangle(_cx + 7, _cy + 154, _cx + _card_width - 7, _cy + 168, false);
                draw_set_color(_pet.health > _pet.definition.max_health * 0.35 ? make_color_rgb(80, 220, 120) : make_color_rgb(235, 80, 75));
                draw_rectangle(_cx + 7, _cy + 154, _cx + 7 + (_card_width - 14) * (_pet.health / _pet.definition.max_health), _cy + 168, false);
                draw_set_color(c_white);
                draw_text(_cx + _card_width * 0.5, _cy + 174, string(_pet.health) + "/" + string(_pet.definition.max_health));
                draw_set_color(make_color_rgb(185, 205, 235));
                draw_text(_cx + _card_width * 0.5, _cy + 190, _status);
            }
            draw_set_halign(fa_left);
        }
    }

    draw_set_color(make_color_rgb(18, 28, 50));
    draw_rectangle(0, 790, _gw, _gh, false);
    draw_set_color(c_white);
    draw_text(25, 806, "Q/E: choose pet    LEFT/RIGHT: target    1: Basic    2: Super    3: Specialty    F: Details    ENTER: act    ESC: Pause / Exit    H: All Controls");
    draw_set_color(make_color_rgb(255, 210, 70));
    if (!_showing_fx) {
        var _has_selected_pet = selected_actor >= 0 && selected_actor < array_length(match.players[_current_index].pets);
        var _selected_pet = _has_selected_pet ? match.players[_current_index].pets[selected_actor] : undefined;
        var _selected_target_pet = selected_target >= 0 ? match.players[selected_target div _team_size].pets[selected_target mod _team_size] : undefined;
        var _selection_text = match.players[_current_index].card.name + " - " + match.players[_current_index].card.description;
        if (selected_action != "card" && _has_selected_pet) {
            _selection_text = selected_action == "super" ? _selected_pet.definition.super.name + " - " + string(_selected_pet.definition.super.damage + _selected_pet.attack_bonus) + " damage" : _selected_pet.definition.basic.name + " - " + string(_selected_pet.definition.basic.damage + _selected_pet.attack_bonus) + " damage";
        }
        draw_text(25, 844, "SELECTED: " + (_has_selected_pet ? _selected_pet.definition.name : "Specialty Card") + " | " + _selection_text + (_selected_target_pet == undefined ? "" : " | TARGET: " + _selected_target_pet.definition.name));
    }
    if (tutorial) {
        draw_set_halign(fa_right);
        draw_set_color(make_color_rgb(145, 220, 255));
        draw_text(_gw - 25, 844, "Tutorial: knock out every opposing pet to win.");
    }

    if (_showing_fx) {
        var _progress = 1 - combat_fx_timer / combat_fx.duration;
        draw_set_halign(fa_center);
        draw_set_color(make_color_rgb(10, 14, 27));
        draw_set_alpha(0.94);
        draw_roundrect(_gw * 0.5 - 310, 742, _gw * 0.5 + 310, 888, false);
        draw_set_alpha(1);
        draw_set_color(make_color_rgb(255, 210, 70));
        draw_text_transformed(_gw * 0.5, 775, combat_fx.title, 1.55, 1.55, 0);
        draw_set_color(combat_fx.damage > 0 ? make_color_rgb(255, 95, 85) : make_color_rgb(145, 220, 255));
        draw_text_transformed(_gw * 0.5, 825 - sin(_progress * pi) * 18, combat_fx.damage > 0 ? "-" + string(combat_fx.damage) + " DAMAGE" : "NO DAMAGE", 1.8, 1.8, 0);
        draw_set_color(c_white);
        draw_text_ext(_gw * 0.5, 866, combat_fx.message, 14, 580);
    } else if (controls_open) {
        draw_set_halign(fa_center);
        draw_set_color(make_color_rgb(13, 20, 38));
        draw_set_alpha(0.98);
        draw_roundrect(_gw * 0.5 - 460, 115, _gw * 0.5 + 460, 755, false);
        draw_set_alpha(1);
        draw_set_color(make_color_rgb(255, 210, 70));
        draw_text_transformed(_gw * 0.5, 160, "ALL BATTLE CONTROLS", 2, 2, 0);

        draw_set_halign(fa_left);
        draw_set_color(c_white);
        var _help_x = _gw * 0.5 - 380;
        draw_text(_help_x, 225, "Q / E");
        draw_text(_help_x + 180, 225, "Select which of your available pets will act.");
        draw_text(_help_x, 270, "LEFT / RIGHT");
        draw_text(_help_x + 180, 270, "Select a legal pet target. The target has a red outline.");
        draw_text(_help_x, 315, "1 - BASIC");
        draw_text(_help_x + 180, 315, "Select the acting pet's reusable basic attack.");
        draw_text(_help_x, 360, "2 - SUPER");
        draw_text(_help_x + 180, 360, "Select the acting pet's once-per-match super attack.");
        draw_text(_help_x, 405, "3 - SPECIALTY");
        draw_text(_help_x + 180, 405, "Select your public specialty card and a legal target.");
        draw_text(_help_x, 450, "ENTER");
        draw_text(_help_x + 180, 450, "Confirm and perform the currently selected action.");
        draw_text(_help_x, 495, "F - DETAILS");
        draw_text(_help_x + 180, 495, "Flip open the targeted pet's detailed card.");
        draw_text(_help_x, 540, "A / T");
        draw_text(_help_x + 180, 540, "Inside Details, switch between Acting pet and Target pet.");
        draw_text(_help_x, 585, "ESC");
        draw_text(_help_x + 180, 585, "Pause; then Resume, return to Main Menu, or Exit Battlepets.");
        draw_text(_help_x, 630, "H - HELP");
        draw_text(_help_x + 180, 630, "Open or close this complete controls panel.");

        draw_set_halign(fa_center);
        draw_set_color(make_color_rgb(150, 170, 205));
        draw_text(_gw * 0.5, 705, "Press H or ESC to return to the battle");
    } else if (details_open && detail_player >= 0 && detail_slot >= 0) {
        var _detail_owner = match.players[detail_player];
        var _detail_pet = _detail_owner.pets[detail_slot];
        var _details_are_actor = detail_player == _current_index && detail_slot == selected_actor;
        draw_set_halign(fa_center);
        draw_set_color(make_color_rgb(17, 25, 47));
        draw_set_alpha(0.98);
        draw_roundrect(_gw * 0.5 - 350, 215, _gw * 0.5 + 350, 690, false);
        draw_set_alpha(1);
        draw_set_color(make_color_rgb(255, 210, 70));
        draw_text_transformed(_gw * 0.5, 260, _detail_pet.definition.name, 2, 2, 0);
        draw_set_color(c_white);
        draw_text(_gw * 0.5, 305, (_details_are_actor ? "YOUR ACTING PET" : "TARGET PET") + " - " + _detail_owner.name);
        draw_text(_gw * 0.5, 335, "Health: " + string(_detail_pet.health) + "/" + string(_detail_pet.definition.max_health) + "    Tags: " + string(_detail_pet.definition.tags));
        draw_text_transformed(_gw * 0.5, 395, "BASIC - " + _detail_pet.definition.basic.name + " - " + string(_detail_pet.definition.basic.damage + _detail_pet.attack_bonus) + " damage", 1.35, 1.35, 0);
        draw_text_transformed(_gw * 0.5, 450, "SUPER - " + _detail_pet.definition.super.name + " - " + string(_detail_pet.definition.super.damage + _detail_pet.attack_bonus) + " damage" + (_detail_pet.super_used ? " (USED)" : " (ONCE PER MATCH)"), 1.35, 1.35, 0);
        draw_set_color(make_color_rgb(180, 235, 205));
        draw_text_ext(_gw * 0.5, 515, "ABILITY: " + _detail_pet.definition.ability, 18, 620);
        draw_set_color(make_color_rgb(225, 205, 240));
        draw_text_ext(_gw * 0.5, 575, "SPECIALTY: " + _detail_owner.card.name + " - " + _detail_owner.card.description + (_detail_owner.card_used ? " (USED)" : ""), 18, 620);
        draw_set_color(make_color_rgb(150, 170, 205));
        draw_text(_gw * 0.5, 650, "A - ACTING PET    T - TARGET PET    F - FLIP BACK");
    }
}

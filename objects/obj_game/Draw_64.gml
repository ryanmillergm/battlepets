var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
draw_clear(make_color_rgb(13, 20, 38));
draw_set_font(-1);
draw_set_alpha(1);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

var fit_text_scale = function(_text, _available_width, _maximum_scale) {
    return min(_maximum_scale, _available_width / max(1, string_width(_text)));
};

var draw_pet_sprite_fit = function(_sprite, _left, _top, _width, _height, _alpha) {
    if (_sprite == -1) return;
    var _bbox_left = sprite_get_bbox_left(_sprite);
    var _bbox_right = sprite_get_bbox_right(_sprite);
    var _bbox_top = sprite_get_bbox_top(_sprite);
    var _bbox_bottom = sprite_get_bbox_bottom(_sprite);
    var _visible_width = max(1, _bbox_right - _bbox_left + 1);
    var _visible_height = max(1, _bbox_bottom - _bbox_top + 1);
    var _sprite_scale = min(_width / _visible_width, _height / _visible_height);
    var _center_x = _left + _width * 0.5;
    var _center_y = _top + _height * 0.5;
    var _draw_x = _center_x - (_bbox_left + _bbox_right) * 0.5 * _sprite_scale;
    var _draw_y = _center_y - (_bbox_top + _bbox_bottom) * 0.5 * _sprite_scale;
    draw_sprite_ext(_sprite, 0, _draw_x, _draw_y, _sprite_scale, _sprite_scale, 0, c_white, _alpha);
};

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
    draw_clear(c_white);
    draw_set_color(make_color_rgb(212, 160, 20));
    draw_text_transformed(_gw * 0.5, 210, "BATTLEPETS", 3, 3, 0);
    draw_set_color(make_color_rgb(13, 20, 38));
    draw_text_transformed(_gw * 0.5, 390, "ENTER / SPACE  -  PLAY", 1.5, 1.5, 0);
    draw_text_transformed(_gw * 0.5, 460, "T  -  TUTORIAL", 1.5, 1.5, 0);
    draw_set_color(make_color_rgb(75, 88, 112));
    draw_text(_gw * 0.5, 600, "Turn-based free-for-all battles for 2-8 players");
    exit;
}

if (screen == "hub") {
    draw_clear(c_white);
    draw_set_color(make_color_rgb(212, 160, 20));
    draw_text_transformed(_gw * 0.5, 130, "BATTLEPETS", 2.4, 2.4, 0);
    draw_set_halign(fa_right);
    draw_text_transformed(_gw - 35, 35, "BATTLE COINS: " + string(battle_coins), 1.25, 1.25, 0);
    draw_set_halign(fa_center);
    var _hub_names = ["INVENTORY", "PLAY", "SHOP"];
    var _hub_keys = ["I", "P", "S"];
    var _hub_descriptions = ["View pets, duplicates, and sell values.", "Bot and local Battlepet battles.", "Spend Battle Coins on pets and packs."];
    var _hub_colors = [make_color_rgb(80, 175, 135), make_color_rgb(75, 175, 255), make_color_rgb(155, 85, 205)];
    for (var _hub_index = 0; _hub_index < 3; _hub_index++) {
        var _hub_x = 238 + _hub_index * 375;
        draw_set_color(_hub_index == hub_cursor ? make_color_rgb(225, 235, 250) : make_color_rgb(238, 242, 248));
        draw_roundrect(_hub_x, 285, _hub_x + 340, 555, false);
        draw_set_color(_hub_colors[_hub_index]);
        draw_rectangle(_hub_x, 285, _hub_x + 340, 302, false);
        draw_text_transformed(_hub_x + 170, 350, _hub_keys[_hub_index] + " - " + _hub_names[_hub_index], 1.45, 1.45, 0);
        draw_set_color(make_color_rgb(38, 50, 72));
        draw_text_ext(_hub_x + 170, 430, _hub_descriptions[_hub_index], 20, 290);
    }
    draw_set_color(make_color_rgb(75, 88, 112));
    draw_text(_gw * 0.5, 720, "LEFT / RIGHT + ENTER, or left-click a card    |    ESC - Title");
    exit;
}

if (screen == "shop") {
    draw_clear(c_white);
    draw_set_halign(fa_right);
    draw_set_color(make_color_rgb(212, 160, 20));
    draw_text_transformed(_gw - 35, 35, "BATTLE COINS: " + string(battle_coins), 1.25, 1.25, 0);
    draw_set_halign(fa_center);
    draw_set_color(make_color_rgb(212, 160, 20));
    draw_text_transformed(_gw * 0.5, 135, "BATTLEPETS SHOP", 2.25, 2.25, 0);
    draw_set_color(make_color_rgb(75, 88, 112));
    draw_text(_gw * 0.5, 195, "Build your collection with Battle Coins");

    var _shop_width = 340;
    var _shop_gap = 35;
    var _shop_start = _gw * 0.5 - (_shop_width * 1.5 + _shop_gap);
    var _shop_names = ["BATTLEPETS", "PET PACKS", "BATTLE COINS"];
    var _shop_descriptions = ["Purchase a specific published pet.", "Open a pack containing exactly two pets.", "Parent-only purchases after release approval."];
    var _shop_colors = [make_color_rgb(75, 175, 255), make_color_rgb(150, 90, 190), make_color_rgb(212, 160, 20)];
    for (var _shop_index = 0; _shop_index < 3; _shop_index++) {
        var _shop_x = _shop_start + _shop_index * (_shop_width + _shop_gap);
        draw_set_color(make_color_rgb(238, 242, 248));
        draw_roundrect(_shop_x, 285, _shop_x + _shop_width, 555, false);
        draw_set_color(_shop_colors[_shop_index]);
        draw_rectangle(_shop_x, 285, _shop_x + _shop_width, 300, false);
        draw_text_transformed(_shop_x + _shop_width * 0.5, 355, _shop_names[_shop_index], 1.45, 1.45, 0);
        draw_set_color(make_color_rgb(38, 50, 72));
        draw_text_ext(_shop_x + _shop_width * 0.5, 430, _shop_descriptions[_shop_index], 20, _shop_width - 45);
        draw_set_color(_shop_index == 1 ? make_color_rgb(75, 45, 105) : make_color_rgb(95, 108, 132));
        draw_text(_shop_x + _shop_width * 0.5, 510, _shop_index == 1 ? "P - OPEN PACK SHOP" : "COMING IN M4");
    }

    draw_set_color(make_color_rgb(13, 20, 38));
    draw_text(_gw * 0.5, 675, "Exact rarity and pet odds will be shown before every pack purchase.");
    draw_set_color(make_color_rgb(75, 88, 112));
    draw_text(_gw * 0.5, 760, "P or left-click PET PACKS    |    ESC - Back");
    exit;
}

if (screen == "pack_shop") {
    draw_clear(c_white);
    draw_set_color(make_color_rgb(155, 85, 205));
    draw_text_transformed(_gw * 0.5, 95, "BATTLEPET PACKS", 2.2, 2.2, 0);
    draw_set_halign(fa_right);
    draw_set_color(make_color_rgb(212, 160, 20));
    draw_text_transformed(_gw - 35, 35, "BATTLE COINS: " + string(battle_coins), 1.25, 1.25, 0);
    draw_set_halign(fa_center);
    for (var _pack_index = 0; _pack_index < array_length(catalog.packs); _pack_index++) {
        var _pack = catalog.packs[_pack_index];
        var _pack_x = 85 + _pack_index * 380;
        draw_set_color(_pack_index == pack_cursor ? make_color_rgb(225, 232, 248) : make_color_rgb(240, 243, 248));
        draw_roundrect(_pack_x, 280, _pack_x + 330, 585, false);
        draw_set_color(_pack.color);
        draw_rectangle(_pack_x, 280, _pack_x + 330, 300, false);
        draw_text_transformed(_pack_x + 165, 335, rarity_names[_pack.maximum_rarity], 1.45, 1.45, 0);
        draw_pet_sprite_fit(Battlepetpack, _pack_x + 105, 375, 120, 95, 1);
        draw_set_color(make_color_rgb(40, 52, 75));
        draw_text(_pack_x + 165, 500, "2 DIFFERENT PETS");
        draw_set_color(make_color_rgb(212, 160, 20));
        draw_text_transformed(_pack_x + 165, 545, string(_pack.price) + " COINS", 1.25, 1.25, 0);
    }
    draw_set_color(make_color_rgb(75, 88, 112));
    draw_text(_gw * 0.5, 665, "LEFT / RIGHT + ENTER, or left-click a pack");
    draw_text(_gw * 0.5, 735, "Each reward is a different Battlepet. Exact odds appear before purchase.");
    if (economy_message != "") { draw_set_color(make_color_rgb(195, 55, 55)); draw_text(_gw * 0.5, 795, economy_message); }
    draw_set_color(make_color_rgb(75, 88, 112));
    draw_text(_gw * 0.5, 850, "ESC - Shop");

    if (pack_confirm_open) {
        var _confirm_pack = catalog.packs[pack_cursor];
        draw_set_alpha(0.82); draw_set_color(make_color_rgb(10, 16, 30)); draw_rectangle(0, 0, _gw, _gh, false); draw_set_alpha(1);
        draw_set_color(c_white); draw_roundrect(355, 120, 1245, 775, false);
        draw_set_color(_confirm_pack.color);
        draw_text_transformed(_gw * 0.5, 175, "BUY " + string_upper(_confirm_pack.name) + "?", 1.65, 1.65, 0);
        draw_set_color(make_color_rgb(40, 52, 75));
        draw_text_transformed(_gw * 0.5, 230, "COST: " + string(_confirm_pack.price) + " BATTLE COINS", 1.25, 1.25, 0);
        draw_text(_gw * 0.5, 275, "Balance after purchase: " + string(battle_coins - _confirm_pack.price));
        draw_set_halign(fa_left);
        var _odds_y = 335;
        for (var _odds_rarity = 0; _odds_rarity < 4; _odds_rarity++) {
            if (_confirm_pack.weights[_odds_rarity] > 0) {
                draw_set_color(make_color_rgb(55, 68, 92));
                draw_text(455, _odds_y, rarity_names[_odds_rarity] + ": " + string(_confirm_pack.weights[_odds_rarity]) + "% per draw");
                var _pet_odds_text = "";
                for (var _odds_pet = 0; _odds_pet < array_length(catalog.pets); _odds_pet++) {
                    if (catalog.pets[_odds_pet].rarity == _odds_rarity) {
                        if (_pet_odds_text != "") _pet_odds_text += ", ";
                        _pet_odds_text += string_replace(catalog.pets[_odds_pet].name, " (Placeholder)", "") + " " + string_format(_confirm_pack.weights[_odds_rarity] * 0.5, 0, 1) + "%";
                    }
                }
                draw_set_color(make_color_rgb(105, 115, 135));
                draw_text(735, _odds_y, _pet_odds_text);
                _odds_y += 50;
            }
        }
        draw_set_halign(fa_center);
        draw_set_color(make_color_rgb(205, 215, 230)); draw_roundrect(510, 660, 750, 725, false);
        draw_set_color(make_color_rgb(75, 88, 112)); draw_text(630, 693, "CANCEL (C)");
        draw_set_color(_confirm_pack.color); draw_roundrect(850, 660, 1090, 725, false);
        draw_set_color(c_white); draw_text(970, 693, "CONFIRM (ENTER)");
    }
    exit;
}

if (screen == "pack_result") {
    draw_clear(c_white);
    draw_set_color(make_color_rgb(212, 160, 20));
    draw_text_transformed(_gw * 0.5, 125, "PACK OPENED!", 2.25, 2.25, 0);
    for (var _reward_slot = 0; _reward_slot < array_length(pack_results); _reward_slot++) {
        var _reward_pet = catalog_pet_by_id(pack_results[_reward_slot]);
        var _reward_x = 380 + _reward_slot * 460;
        draw_set_color(make_color_rgb(238, 242, 248)); draw_roundrect(_reward_x, 245, _reward_x + 380, 620, false);
        draw_set_color(c_white); draw_roundrect(_reward_x + 75, 300, _reward_x + 305, 485, false);
        draw_pet_sprite_fit(_reward_pet.sprite, _reward_x + 85, 310, 210, 165, 1);
        draw_set_color(make_color_rgb(35, 48, 70)); draw_text_transformed(_reward_x + 190, 535, string_replace(_reward_pet.name, " (Placeholder)", ""), 1.35, 1.35, 0);
        draw_set_color(catalog.packs[_reward_pet.rarity].color); draw_text(_reward_x + 190, 580, rarity_names[_reward_pet.rarity] + "  |  OWNED: " + string(pet_quantities[catalog_pet_index_by_id(_reward_pet.id)]));
    }
    draw_set_color(make_color_rgb(75, 88, 112)); draw_text(_gw * 0.5, 760, "ENTER / SPACE or left-click to continue");
    exit;
}

if (screen == "inventory") {
    draw_clear(c_white);
    draw_set_color(make_color_rgb(80, 175, 135)); draw_text_transformed(_gw * 0.5, 90, "INVENTORY", 2.2, 2.2, 0);
    draw_set_halign(fa_right); draw_set_color(make_color_rgb(212, 160, 20)); draw_text_transformed(_gw - 35, 35, "BATTLE COINS: " + string(battle_coins), 1.25, 1.25, 0); draw_set_halign(fa_center);
    for (var _inventory_index = 0; _inventory_index < array_length(catalog.pets); _inventory_index++) {
        var _inventory_pet = catalog.pets[_inventory_index];
        var _inventory_x = 70 + (_inventory_index mod 4) * 380;
        var _inventory_y = 225 + (_inventory_index div 4) * 270;
        draw_set_color(_inventory_index == inventory_cursor ? make_color_rgb(220, 235, 230) : make_color_rgb(238, 242, 248));
        draw_roundrect(_inventory_x, _inventory_y, _inventory_x + 330, _inventory_y + 225, false);
        draw_pet_sprite_fit(_inventory_pet.sprite, _inventory_x + 15, _inventory_y + 35, 115, 120, pet_quantities[_inventory_index] > 0 ? 1 : 0.25);
        draw_set_halign(fa_left); draw_set_color(make_color_rgb(35, 48, 70));
        var _inventory_name = string_replace(_inventory_pet.name, " (Placeholder)", "");
        draw_text_transformed(_inventory_x + 145, _inventory_y + 40, _inventory_name, fit_text_scale(_inventory_name, 165, 1.05), fit_text_scale(_inventory_name, 165, 1.05), 0);
        draw_set_color(catalog.packs[_inventory_pet.rarity].color); draw_text(_inventory_x + 145, _inventory_y + 85, rarity_names[_inventory_pet.rarity]);
        draw_set_color(make_color_rgb(65, 78, 100)); draw_text(_inventory_x + 145, _inventory_y + 125, "OWNED: " + string(pet_quantities[_inventory_index]));
        draw_text(_inventory_x + 145, _inventory_y + 165, "SELL: " + string(rarity_sale_values[_inventory_pet.rarity]) + " COINS");
        draw_set_halign(fa_center);
    }
    draw_set_color(pet_quantities[inventory_cursor] > 0 ? make_color_rgb(80, 175, 135) : make_color_rgb(155, 165, 180)); draw_roundrect(620, 790, 980, 855, false);
    draw_set_color(c_white); draw_text(800, 823, pet_quantities[inventory_cursor] > 0 ? "SELL SELECTED PET (S / ENTER)" : "NO COPY TO SELL");
    if (economy_message != "") { draw_set_color(make_color_rgb(55, 115, 80)); draw_text(_gw * 0.5, 755, economy_message); }
    draw_set_color(make_color_rgb(75, 88, 112)); draw_text(150, 835, "ESC - Back");
    if (sale_confirm_stage > 0) {
        var _sale_pet = catalog.pets[inventory_cursor];
        var _sale_value = rarity_sale_values[_sale_pet.rarity];
        draw_set_alpha(0.82); draw_set_color(make_color_rgb(10, 16, 30)); draw_rectangle(0, 0, _gw, _gh, false); draw_set_alpha(1);
        draw_set_color(c_white); draw_roundrect(355, 180, 1245, 775, false);
        draw_set_color(make_color_rgb(40, 52, 75));
        draw_text_transformed(_gw * 0.5, 275, sale_confirm_stage == 1 ? "SELL THIS BATTLEPET?" : "ARE YOU ABSOLUTELY SURE?", 1.75, 1.75, 0);
        draw_text_transformed(_gw * 0.5, 355, string_replace(_sale_pet.name, " (Placeholder)", ""), 1.45, 1.45, 0);
        draw_set_color(make_color_rgb(212, 160, 20)); draw_text_transformed(_gw * 0.5, 425, "YOU WILL RECEIVE " + string(_sale_value) + " BATTLE COINS", 1.25, 1.25, 0);
        draw_set_color(make_color_rgb(175, 65, 65));
        draw_text(_gw * 0.5, 500, pet_quantities[inventory_cursor] == 1 ? "This is your last copy. The pet will leave your collection." : "Copies remaining after sale: " + string(pet_quantities[inventory_cursor] - 1));
        draw_set_color(make_color_rgb(205, 215, 230)); draw_roundrect(510, 665, 750, 730, false); draw_set_color(make_color_rgb(75, 88, 112)); draw_text(630, 698, "CANCEL (C)");
        draw_set_color(make_color_rgb(80, 175, 135)); draw_roundrect(850, 665, 1090, 730, false); draw_set_color(c_white); draw_text(970, 698, sale_confirm_stage == 1 ? "CONTINUE" : "CONFIRM SALE");
    }
    exit;
}

if (screen == "mode") {
    draw_clear(c_white);
    draw_set_halign(fa_right);
    draw_set_color(make_color_rgb(212, 160, 20));
    draw_text_transformed(_gw - 35, 35, "BATTLE COINS: " + string(battle_coins), 1.25, 1.25, 0);
    draw_set_halign(fa_center);
    draw_set_color(make_color_rgb(255, 210, 70));
    draw_text_transformed(_gw * 0.32, 170, "CHOOSE PLAY MODE", 2, 2, 0);
    draw_set_color(make_color_rgb(75, 175, 255));
    draw_text_transformed(_gw * 0.32, 330, "B  -  BOTS", 1.5, 1.5, 0);
    draw_set_color(make_color_rgb(110, 235, 155));
    draw_text_transformed(_gw * 0.32, 420, "L  -  LOCAL (TAKE TURNS)", 1.5, 1.5, 0);
    draw_set_color(make_color_rgb(0, 165, 175));
    draw_text_transformed(_gw * 0.75, 170, "S  -  SHOP", 2, 2, 0);
    draw_set_color(make_color_rgb(55, 115, 120));
    draw_text_transformed(_gw * 0.75, 235, "Packs, Specialties, Pets", 1.1, 1.1, 0);
    draw_set_color(make_color_rgb(95, 108, 132));
    draw_text_transformed(_gw * 0.32, 510, "ONLINE  -  COMING IN M3", 1.25, 1.25, 0);
    draw_set_color(make_color_rgb(13, 20, 38));
    draw_text(_gw * 0.32, 650, "ESC - Back");
    if (economy_message != "") { draw_set_color(make_color_rgb(195, 55, 55)); draw_text(_gw * 0.5, 735, economy_message); }
    exit;
}

if (screen == "setup") {
    var _difficulty_names = ["Easy", "Normal", "Hard"];
    var _bot_speed_names = ["Relaxed", "Normal", "Quick"];
    if (play_mode == "local") draw_clear(c_white);
    draw_set_color(play_mode == "bot" ? make_color_rgb(75, 175, 255) : make_color_rgb(255, 210, 70));
    draw_text_transformed(_gw * 0.5, 150, string_upper(play_mode) + " BATTLE SETUP", 2, 2, 0);

    draw_set_color(play_mode == "local" ? make_color_rgb(75, 88, 112) : make_color_rgb(150, 170, 205));
    draw_text_transformed(_gw * 0.5, 265, "CHOOSE NUMBER OF PLAYERS", 1.1, 1.1, 0);
    draw_set_color(play_mode == "local" ? make_color_rgb(13, 20, 38) : c_white);
    draw_text_transformed(_gw * 0.5, 315, "Players: " + string(setup_players) + "   (UP / DOWN)", 1.5, 1.5, 0);

    draw_set_color(play_mode == "local" ? make_color_rgb(75, 88, 112) : make_color_rgb(150, 170, 205));
    draw_text_transformed(_gw * 0.5, 395, "CHOOSE NUMBER OF PETS", 1.1, 1.1, 0);
    draw_set_color(play_mode == "local" ? make_color_rgb(13, 20, 38) : c_white);
    draw_text_transformed(_gw * 0.5, 445, "Pets each: " + string(setup_team_size) + "   (LEFT / RIGHT)", 1.5, 1.5, 0);

    if (play_mode == "bot") {
        draw_text_transformed(_gw * 0.5, 525, "Bot level: " + _difficulty_names[setup_difficulty] + "   (D)", 1.5, 1.5, 0);
        draw_text_transformed(_gw * 0.5, 585, "Bot turn speed: " + _bot_speed_names[setup_bot_speed] + "   (S)", 1.5, 1.5, 0);
    }
    if (play_mode == "bot") {
        draw_set_color(make_color_rgb(25, 155, 85));
        draw_text_transformed(_gw * 0.5, 640, "C - CHOOSE BATTLEPETS", 1.25, 1.25, 0);
    }
    draw_set_color(play_mode == "local" ? make_color_rgb(25, 155, 85) : make_color_rgb(110, 235, 155));
    draw_text_transformed(_gw * 0.5, play_mode == "bot" ? 715 : 650, "ENTER - START", 1.5, 1.5, 0);
    if (economy_message != "") { draw_set_color(make_color_rgb(255, 120, 105)); draw_text(_gw * 0.5, 790, economy_message); }
    exit;
}

if (screen == "collection") {
    draw_clear(c_white);
    draw_set_color(make_color_rgb(0, 145, 155));
    draw_text_transformed(_gw * 0.5, 55, "BATTLEPET COLLECTION", 2, 2, 0);
    draw_set_color(make_color_rgb(75, 88, 112));
    var _collection_owner = collection_context_seat >= 0 ? local_player_names[collection_context_seat] : "Player 1";
    draw_text(_gw * 0.5, 105, _collection_owner + " - Choose " + string(setup_team_size) + " pets for battle   (" + string(array_length(collection_selected_ids)) + "/" + string(setup_team_size) + " selected)");

    var _collection_card_width = 350;
    var _collection_card_height = 190;
    var _collection_gap_x = 25;
    var _collection_gap_y = 18;
    var _collection_start_x = (_gw - (4 * _collection_card_width + 3 * _collection_gap_x)) * 0.5;
    for (var _collection_slot = 0; _collection_slot < collection_slot_count; _collection_slot++) {
        var _collection_x = _collection_start_x + (_collection_slot mod 4) * (_collection_card_width + _collection_gap_x);
        var _collection_y = 145 + (_collection_slot div 4) * (_collection_card_height + _collection_gap_y);
        var _collection_owned = _collection_slot < array_length(owned_pet_ids);
        var _collection_focused = _collection_slot == collection_cursor;
        var _collection_selected_number = 0;
        if (_collection_owned) {
            for (var _collection_pick = 0; _collection_pick < array_length(collection_selected_ids); _collection_pick++) {
                if (collection_selected_ids[_collection_pick] == owned_pet_ids[_collection_slot]) _collection_selected_number = _collection_pick + 1;
            }
        }

        draw_set_color(_collection_owned ? make_color_rgb(238, 242, 248) : make_color_rgb(225, 229, 235));
        draw_roundrect(_collection_x, _collection_y, _collection_x + _collection_card_width, _collection_y + _collection_card_height, false);
        var _focus_flash = 45 + floor(35 * (0.5 + 0.5 * sin(current_time * 0.012)));
        draw_set_color(_collection_focused ? make_color_rgb(255, _focus_flash, _focus_flash) : (_collection_selected_number > 0 ? make_color_rgb(25, 155, 85) : make_color_rgb(160, 170, 188)));
        draw_rectangle(_collection_x, _collection_y, _collection_x + _collection_card_width, _collection_y + _collection_card_height, true);
        if (_collection_focused) {
            draw_set_color(make_color_rgb(255, 35, 45));
            draw_rectangle(_collection_x + 3, _collection_y + 3, _collection_x + _collection_card_width - 3, _collection_y + _collection_card_height - 3, true);
        }

        if (_collection_owned) {
            var _collection_pet = catalog_pet_by_id(owned_pet_ids[_collection_slot]);
            var _collection_name = string_replace(_collection_pet.name, " (Placeholder)", "");
            var _art_left = _collection_x + 15;
            var _art_top = _collection_y + 35;
            var _art_width = 105;
            var _art_height = 115;
            draw_set_color(make_color_rgb(218, 226, 238));
            draw_roundrect(_art_left, _art_top, _art_left + _art_width, _art_top + _art_height, false);
            if (_collection_pet.sprite != -1) {
                draw_pet_sprite_fit(_collection_pet.sprite, _art_left + 5, _art_top + 5, _art_width - 10, _art_height - 10, 1);
            } else {
                draw_set_halign(fa_center);
                draw_set_color(make_color_rgb(125, 142, 170));
                draw_text_transformed(_art_left + _art_width * 0.5, _art_top + 44, "?", 2.2, 2.2, 0);
                draw_text_transformed(_art_left + _art_width * 0.5, _art_top + 88, "ART COMING SOON", 0.55, 0.55, 0);
            }
            draw_set_halign(fa_left);
            draw_set_color(make_color_rgb(13, 20, 38));
            var _collection_text_width = _collection_card_width - 145;
            var _collection_name_scale = fit_text_scale(_collection_name, _collection_text_width, 1.15);
            draw_text_transformed(_collection_x + 130, _collection_y + 22, _collection_name, _collection_name_scale, _collection_name_scale, 0);
            draw_set_halign(fa_right);
            draw_set_color(catalog.packs[_collection_pet.rarity].color);
            draw_text_transformed(_collection_x + _collection_card_width - 12, _collection_y + 22, "x" + string(pet_quantities[catalog_pet_index_by_id(_collection_pet.id)]), 0.9, 0.9, 0);
            draw_set_halign(fa_left);
            draw_set_color(make_color_rgb(75, 88, 112));
            var _collection_health_text = "HEALTH  " + string(_collection_pet.max_health);
            var _collection_basic_text = "BASIC   " + _collection_pet.basic.name + "  " + string(_collection_pet.basic.damage);
            var _collection_super_damage = _collection_pet.super.per_target_pet ? string(_collection_pet.super.damage) + " x opposing pets" : string(_collection_pet.super.damage);
            var _collection_super_text = "SUPER   " + _collection_pet.super.name + "  " + _collection_super_damage + (_collection_pet.super.stun > 0 ? " + STUN" : "");
            var _collection_tags_text = "TAGS    " + string(_collection_pet.tags);
            var _collection_health_scale = fit_text_scale(_collection_health_text, _collection_text_width, 1);
            var _collection_basic_scale = fit_text_scale(_collection_basic_text, _collection_text_width, 1);
            var _collection_super_scale = fit_text_scale(_collection_super_text, _collection_text_width, 1);
            var _collection_tags_scale = fit_text_scale(_collection_tags_text, _collection_text_width, 1);
            draw_text_transformed(_collection_x + 130, _collection_y + 60, _collection_health_text, _collection_health_scale, _collection_health_scale, 0);
            draw_text_transformed(_collection_x + 130, _collection_y + 88, _collection_basic_text, _collection_basic_scale, _collection_basic_scale, 0);
            draw_text_transformed(_collection_x + 130, _collection_y + 116, _collection_super_text, _collection_super_scale, _collection_super_scale, 0);
            draw_text_transformed(_collection_x + 130, _collection_y + 144, _collection_tags_text, _collection_tags_scale, _collection_tags_scale, 0);
            if (_collection_selected_number > 0) {
                draw_set_halign(fa_center);
                draw_set_color(make_color_rgb(25, 155, 85));
                draw_text_transformed(_collection_x + 45, _collection_y + 158, "TEAM " + string(_collection_selected_number), 0.9, 0.9, 0);
            }
        } else {
            draw_set_halign(fa_center);
            draw_set_color(make_color_rgb(145, 155, 172));
            draw_text_transformed(_collection_x + _collection_card_width * 0.5, _collection_y + 82, "EMPTY PET SLOT", 1.1, 1.1, 0);
            draw_text(_collection_x + _collection_card_width * 0.5, _collection_y + 125, "Find or purchase another Battlepet");
        }
    }

    draw_set_halign(fa_center);
    draw_set_color(make_color_rgb(13, 20, 38));
    draw_text(_gw * 0.5, 790, "ARROWS - MOVE    SPACE - ADD / REMOVE PET    ENTER - CONFIRM TEAM");
    draw_set_color(array_length(collection_selected_ids) == setup_team_size ? make_color_rgb(25, 155, 85) : make_color_rgb(190, 80, 65));
    draw_text(_gw * 0.5, 835, array_length(collection_selected_ids) == setup_team_size ? "TEAM READY" : "SELECT EXACTLY " + string(setup_team_size) + " PETS");
    draw_set_color(make_color_rgb(75, 88, 112));
    draw_text(_gw * 0.5, 870, "ESC - Cancel and return");
    exit;
}

if (screen == "local_roster") {
    draw_clear(c_white);
    draw_set_color(make_color_rgb(255, 210, 70));
    draw_text_transformed(_gw * 0.5, 105, "LOCAL PLAYER ROSTER", 2, 2, 0);
    draw_set_color(make_color_rgb(75, 88, 112));
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
    draw_set_color(make_color_rgb(13, 20, 38));
    draw_text(_gw * 0.5, 690, roster_editing ? "TYPE A NAME    ENTER - SAVE    ESC - CANCEL EDIT" : "UP/DOWN - SELECT    ENTER - EDIT NAME    B - HUMAN/BOT");
    if (!roster_editing) {
        draw_set_color(make_color_rgb(25, 155, 85));
        draw_text_transformed(_gw * 0.5, 730, "C - CHOOSE PETS", 1.15, 1.15, 0);
    }
    draw_set_color(make_color_rgb(25, 155, 85));
    if (!roster_editing) draw_text_transformed(_gw * 0.5, 785, "S - START MATCH", 1.5, 1.5, 0);
    draw_set_color(make_color_rgb(75, 88, 112));
    draw_text(_gw * 0.5, 845, "ESC - Back to Main Menu");
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
    draw_set_color(make_color_rgb(255, 210, 70));
    draw_text_transformed(_gw * 0.5, 570, "BATTLE COINS: " + string(battle_coins), 1.35, 1.35, 0);
    if (last_coin_reward > 0) {
        draw_set_color(make_color_rgb(110, 235, 155));
        draw_text_transformed(_gw * 0.5, 630, "REWARD EARNED: +" + string(last_coin_reward), 1.25, 1.25, 0);
    }
    exit;
}

if (screen == "battle") {
    var _current_index = bp_current_player_index(match);
    var _team_size = array_length(match.players[0].pets);
    var _showing_fx = combat_fx_timer > 0;
    if (play_mode == "local") draw_clear(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(make_color_rgb(255, 210, 70));
    draw_text_transformed(30, 18, "Round " + string(match.round) + "  |  " + match.players[_current_index].name + "'s turn", 1.35, 1.35, 0);
    draw_set_color(play_mode == "local" ? make_color_rgb(13, 20, 38) : c_white);
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
                if (_pet.definition.sprite != -1) draw_pet_sprite_fit(_pet.definition.sprite, _cx + 5, _cy + 5, 47, 54, _pet.health > 0 ? 1 : 0.35);
                draw_set_halign(fa_left);
                draw_set_color(c_white);
                var _compact_text_width = _card_width - 63;
                var _compact_name_scale = fit_text_scale(_short_pet_name, _compact_text_width, 0.76);
                draw_text_transformed(_cx + 57, _cy + 7, _short_pet_name, _compact_name_scale, _compact_name_scale, 0);
                draw_set_color(make_color_rgb(220, 230, 250));
                var _compact_basic_text = "1 " + _pet.definition.basic.name + "  " + string(_pet.definition.basic.damage + _pet.attack_bonus);
                var _compact_basic_scale = fit_text_scale(_compact_basic_text, _compact_text_width, 0.76);
                draw_text_transformed(_cx + 57, _cy + 27, _compact_basic_text, _compact_basic_scale, _compact_basic_scale, 0);
                draw_set_color(_pet.super_used ? make_color_rgb(125, 130, 145) : make_color_rgb(255, 220, 105));
                var _compact_super_damage = _pet.definition.super.per_target_pet ? string(_pet.definition.super.damage) + "x PETS" : string(_pet.definition.super.damage + _pet.attack_bonus);
                var _compact_super_text = "2 " + _pet.definition.super.name + "  " + _compact_super_damage + (_pet.definition.super.stun > 0 ? " +STUN" : "");
                var _compact_super_scale = fit_text_scale(_compact_super_text, _compact_text_width, 0.76);
                draw_text_transformed(_cx + 57, _cy + 46, _compact_super_text, _compact_super_scale, _compact_super_scale, 0);
                draw_set_color(make_color_rgb(35, 35, 45));
                draw_rectangle(_cx + 7, _cy + 68, _cx + _card_width - 7, _cy + 80, false);
                draw_set_color(_pet.health > _pet.definition.max_health * 0.35 ? make_color_rgb(80, 220, 120) : make_color_rgb(235, 80, 75));
                draw_rectangle(_cx + 7, _cy + 68, _cx + 7 + (_card_width - 14) * (_pet.health / _pet.definition.max_health), _cy + 80, false);
                draw_set_halign(fa_center);
                draw_set_color(c_white);
                var _compact_health_text = string(_pet.health) + "/" + string(_pet.definition.max_health) + (_status == "" ? "" : "  " + _status);
                var _compact_health_scale = fit_text_scale(_compact_health_text, _card_width - 14, 1);
                draw_text_transformed(_cx + _card_width * 0.5, _cy + 82, _compact_health_text, _compact_health_scale, _compact_health_scale, 0);
            } else {
                draw_set_halign(fa_center);
                draw_set_color(c_white);
                var _tall_name_scale = fit_text_scale(_short_pet_name, _card_width - 14, 1);
                draw_text_transformed(_cx + _card_width * 0.5, _cy + 10, _short_pet_name, _tall_name_scale, _tall_name_scale, 0);

                if (_pet.definition.sprite != -1) {
                    draw_pet_sprite_fit(_pet.definition.sprite, _cx + 12, _cy + 30, _card_width - 24, 68, _pet.health > 0 ? 1 : 0.35);
                } else {
                    draw_set_color(make_color_rgb(82, 99, 130));
                    draw_roundrect(_cx + _card_width * 0.5 - 38, _cy + 38, _cx + _card_width * 0.5 + 38, _cy + 88, false);
                    draw_set_color(make_color_rgb(170, 185, 215));
                    draw_text_transformed(_cx + _card_width * 0.5, _cy + 63, "ART COMING SOON", 0.62, 0.62, 0);
                }

                draw_set_color(make_color_rgb(220, 230, 250));
                var _tall_basic_text = "1 " + _pet.definition.basic.name + "  " + string(_pet.definition.basic.damage + _pet.attack_bonus);
                var _tall_basic_scale = fit_text_scale(_tall_basic_text, _card_width - 14, 1);
                draw_text_transformed(_cx + _card_width * 0.5, _cy + 105, _tall_basic_text, _tall_basic_scale, _tall_basic_scale, 0);
                draw_set_color(_pet.super_used ? make_color_rgb(125, 130, 145) : make_color_rgb(255, 220, 105));
                var _tall_super_damage = _pet.definition.super.per_target_pet ? string(_pet.definition.super.damage) + " x PETS" : string(_pet.definition.super.damage + _pet.attack_bonus);
                var _tall_super_text = "2 " + _pet.definition.super.name + "  " + _tall_super_damage + (_pet.definition.super.stun > 0 ? " + STUN" : "");
                var _tall_super_scale = fit_text_scale(_tall_super_text, _card_width - 14, 1);
                draw_text_transformed(_cx + _card_width * 0.5, _cy + 130, _tall_super_text, _tall_super_scale, _tall_super_scale, 0);
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

    draw_set_color(c_black);
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
            if (selected_action == "super") {
                var _selected_super_damage = _selected_pet.definition.super.damage;
                if (_selected_pet.definition.super.per_target_pet && selected_target >= 0) {
                    _selected_super_damage *= bp_player_living_pet_count(match.players[selected_target div _team_size]);
                }
                _selection_text = _selected_pet.definition.super.name + " - " + string(_selected_super_damage + _selected_pet.attack_bonus) + " damage" + (_selected_pet.definition.super.per_target_pet ? " (40 x living opposing pets)" : "") + (_selected_pet.definition.super.stun > 0 ? " + stun next turn" : "");
            } else {
                _selection_text = _selected_pet.definition.basic.name + " - " + string(_selected_pet.definition.basic.damage + _selected_pet.attack_bonus) + " damage";
            }
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
        var _detail_super_damage = _detail_pet.definition.super.per_target_pet ? string(_detail_pet.definition.super.damage) + " x TARGET'S LIVING PETS" : string(_detail_pet.definition.super.damage + _detail_pet.attack_bonus) + " damage";
        draw_text_transformed(_gw * 0.5, 450, "SUPER - " + _detail_pet.definition.super.name + " - " + _detail_super_damage + (_detail_pet.definition.super.stun > 0 ? " + STUN NEXT TURN" : "") + (_detail_pet.super_used ? " (USED)" : " (ONCE PER MATCH)"), 1.35, 1.35, 0);
        draw_set_color(make_color_rgb(180, 235, 205));
        draw_text_ext(_gw * 0.5, 515, "ABILITY: " + _detail_pet.definition.ability, 18, 620);
        draw_set_color(make_color_rgb(225, 205, 240));
        draw_text_ext(_gw * 0.5, 575, "SPECIALTY: " + _detail_owner.card.name + " - " + _detail_owner.card.description + (_detail_owner.card_used ? " (USED)" : ""), 18, 620);
        draw_set_color(make_color_rgb(150, 170, 205));
        draw_text(_gw * 0.5, 650, "A - ACTING PET    T - TARGET PET    F - FLIP BACK");
    }
}

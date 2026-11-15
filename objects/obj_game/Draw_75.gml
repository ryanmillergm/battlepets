var _show_fullscreen_button = screen == "main";
var _show_menu_back = screen == "hub" || screen == "shop" || screen == "inventory" || screen == "pack_shop" || screen == "pack_result" || screen == "mode" || screen == "trading" || screen == "trade_up" || screen == "trade_up_select" || screen == "trade_up_reward" || screen == "setup" || screen == "collection" || screen == "local_roster";
if (!_show_fullscreen_button && !_show_menu_back) exit;

var _button_left = _show_fullscreen_button ? 1360 : 20;
var _button_top = 18;
var _button_right = _show_fullscreen_button ? 1580 : 180;
var _button_bottom = 62;
var _mouse_x = device_mouse_x_to_gui(0);
var _mouse_y = device_mouse_y_to_gui(0);
var _hovered = _mouse_x >= _button_left && _mouse_x <= _button_right && _mouse_y >= _button_top && _mouse_y <= _button_bottom;

draw_set_alpha(0.96);
draw_set_color(_hovered ? make_color_rgb(75, 175, 255) : make_color_rgb(38, 58, 91));
draw_roundrect(_button_left, _button_top, _button_right, _button_bottom, false);
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_font(-1);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text((_button_left + _button_right) * 0.5, (_button_top + _button_bottom) * 0.5, _show_fullscreen_button ? (window_get_fullscreen() ? "WINDOWED" : "FULLSCREEN") : "<  BACK");

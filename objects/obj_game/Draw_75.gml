if (screen != "main") exit;

var _button_left = 1360;
var _button_top = 18;
var _button_right = 1580;
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
draw_text((_button_left + _button_right) * 0.5, (_button_top + _button_bottom) * 0.5, window_get_fullscreen() ? "WINDOWED" : "FULLSCREEN");

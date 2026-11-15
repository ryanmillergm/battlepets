if (async_load[? "id"] != account_request_id) exit;

account_busy = false;
// GameMaker reports network transport state in `status` and the API response
// code (such as 200 or 202) in `http_status`.
var _transport_status = async_load[? "status"];
var _status = ds_map_exists(async_load, "http_status") ? async_load[? "http_status"] : _transport_status;
var _body = async_load[? "result"];
var _response = undefined;
if (is_string(_body) && string_length(_body) > 0) {
    try { _response = json_parse(_body); } catch (_error) { _response = undefined; }
}

if (account_request_kind == "logout" && _status == 204) {
    account_busy = false;
    account_message = "";
    exit;
}

if (_status < 200 || _status >= 300 || is_undefined(_response)) {
    if (is_struct(_response) && variable_struct_exists(_response, "code")) account_message = string_replace_all(_response.code, "_", " ");
    else account_message = _status <= 0 ? "Server unavailable. You can continue offline." : "The server could not complete that request.";
    if (account_request_kind == "refresh") account_clear_refresh();
    exit;
}

switch (account_request_kind) {
    case "register":
        screen = "account_verify";
        account_code = "";
        account_message = "";
        keyboard_string = "";
        break;
    case "verify":
        screen = "account_login";
        account_field = 0;
        account_message = "Email verified. Log in to continue.";
        account_set_keyboard();
        break;
    case "forgot":
        screen = "account_reset";
        account_field = 0;
        account_code = "";
        account_new_password = "";
        account_message = "Enter the code from the test email.";
        account_set_keyboard();
        break;
    case "reset":
        account_clear_refresh();
        screen = "account_login";
        account_field = 0;
        account_password = "";
        account_message = "Password changed. Log in with the new password.";
        account_set_keyboard();
        break;
    case "login":
    case "refresh":
        offline_mode = false;
        account_access_token = _response.accessToken;
        account_refresh_token = _response.refreshToken;
        account_save_refresh(account_refresh_token);
        var _headers = ds_map_create();
        ds_map_add(_headers, "Authorization", "Bearer " + account_access_token);
        account_request_id = http_request(account_api_url + "/v1/account", "GET", _headers, "");
        ds_map_destroy(_headers);
        account_request_kind = "account";
        account_busy = true;
        account_message = "Loading profile...";
        break;
    case "account":
        account_id = _response.id;
        if (array_length(_response.profiles) > 0) {
            account_username = _response.profiles[0].displayName;
            account_verified = _response.verified;
        }
        keyboard_string = "";
        account_message = "";
        screen = "main";
        break;
}

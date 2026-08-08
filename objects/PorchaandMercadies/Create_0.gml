// Initialize pet behavior
following = true;
target = obj_player; // Assuming you have a player object
speed_factor = 0.05;

if (following && instance_exists(target)) {
    // Move towards player smoothly
    x = lerp(x, target.x - 20, speed_factor);
    y = lerp(y, target.y - 20, speed_factor);
}


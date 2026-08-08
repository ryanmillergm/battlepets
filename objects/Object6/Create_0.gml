opened = false;
image_speed = 0; // Don't animate by default
image_index = 0; // Show closed sprite

if (!opened) {
    opened = true;
    image_index = 1; // Switch to "open" sprite if you have one

    // --- THE LOOT SYSTEM ---
    // 1. Choose a random pet type
    var _pet_type = choose(BPPorchaandMercadies, Bailly); // Add different objects

	
    // 3. Optional: Destroy pack after a delay
    alarm[0] = 30; // 30 frames/0.5 seconds
}
instance_destroy();


if (!opened) {
    opened = true;

    // Define loot possibilities
    var _loot_table = [Bailly, BPPorchaandMercadies];

    // Pick one randomly
    var _chosen_pet = _loot_table[irandom(array_length(_loot_table) - 1)];

    // Spawn it
    instance_create_layer(x5, y5, "Instances", _chosen_pet);

    instance_destroy();
}


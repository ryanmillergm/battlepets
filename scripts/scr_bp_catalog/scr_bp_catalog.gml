function bp_pet_definition(_id, _name, _rarity, _health, _basic_name, _basic_damage, _super_name, _super_damage, _tags, _sprite, _unblockable, _super_stun, _super_per_target_pet) {
    return {
        id: _id,
        name: _name,
        rarity: _rarity,
        max_health: _health,
        tags: _tags,
        sprite: _sprite,
        basic: { name: _basic_name, damage: _basic_damage, unblockable: _unblockable, stun: 0, per_target_pet: false },
        super: {
            name: _super_name,
            damage: _super_damage,
            unblockable: false,
            stun: is_undefined(_super_stun) ? 0 : _super_stun,
            per_target_pet: is_undefined(_super_per_target_pet) ? false : _super_per_target_pet
        },
        ability: _unblockable ? "Quick: basic attacks cannot be blocked" : "None"
    };
}

function bp_pack_definition(_id, _name, _price, _maximum_rarity, _weights, _color) {
    return { id: _id, name: _name, price: _price, maximum_rarity: _maximum_rarity, weights: _weights, color: _color };
}

function bp_pack_roll_rarity(_pack, _roll) {
    var _remaining = clamp(floor(_roll), 0, 99);
    for (var _rarity = 0; _rarity < array_length(_pack.weights); _rarity++) {
        if (_remaining < _pack.weights[_rarity]) return _rarity;
        _remaining -= _pack.weights[_rarity];
    }
    return _pack.maximum_rarity;
}

function bp_card_definition(_id, _name, _description, _effect, _amount) {
    return {
        id: _id,
        name: _name,
        description: _description,
        effect: _effect,
        amount: _amount,
        consumes_action: true,
        max_uses: 1
    };
}

function bp_catalog_create() {
    var _pets = [
        bp_pet_definition("bailly", "Bailly", 2, 90, "Golden Kick", 16, "Sunburst", 34, ["fur"], Bailly, true),
        bp_pet_definition("porcha_mercadies", "Porcha & Mercadies", 3, 160, "Aggressive", 50, "Double Hair", 70, ["cat", "fur"], BPPorchaandMercadies, false, 1),
        bp_pet_definition("ember", "Ember (Placeholder)", 0, 82, "Spark", 18, "Firework", 36, ["fur"], -1, false),
        bp_pet_definition("moss", "Moss (Placeholder)", 1, 125, "Bramble", 13, "Overgrowth", 28, ["plant"], -1, false),
        bp_pet_definition("jack", "Jack", 2, 140, "Bump", 12, "Rockslide", 30, ["stone"], Sprite9, false),
        bp_pet_definition("axle", "Axle", 3, 130, "Tail Whip", 45, "Multistrike", 40, ["dog", "fur"], Axle, false, 0, true),
        bp_pet_definition("whisk", "Whisk (Placeholder)", 1, 78, "Swipe", 19, "Nine Lives", 35, ["cat", "fur"], -1, true),
        bp_pet_definition("sprout", "Sprout (Placeholder)", 0, 115, "Seed Pop", 14, "Bloom Blast", 32, ["plant"], -1, false)
    ];

    var _cards = [
        bp_card_definition("guard", "Guardian Shield", "Give one living pet a shield that blocks the next blockable attack.", "shield", 1),
        bp_card_definition("revive", "Second Chance", "Return one knocked-out pet at half health.", "revive", 50),
        bp_card_definition("sting", "Surprise Sting", "Deal 18 damage to an opposing pet.", "damage", 18),
        bp_card_definition("stun", "Time Out", "Make an opposing pet unavailable for its owner's next turn.", "stun", 1),
        bp_card_definition("boost", "Power Snack", "Add 8 damage to one pet's attacks for the rest of the match.", "boost", 8)
    ];

    var _packs = [
        bp_pack_definition("basic", "Basic Battlepet Pack", 30, 0, [100, 0, 0, 0], make_color_rgb(95, 170, 105)),
        bp_pack_definition("uncommon", "Uncommon Battlepet Pack", 50, 1, [45, 55, 0, 0], make_color_rgb(70, 145, 220)),
        bp_pack_definition("epic", "Epic Battlepet Pack", 75, 2, [25, 45, 30, 0], make_color_rgb(155, 85, 205)),
        bp_pack_definition("legendary", "Legendary Battlepet Pack", 100, 3, [25, 40, 30, 5], make_color_rgb(220, 155, 35))
    ];

    return { pets: _pets, cards: _cards, packs: _packs, version: 3 };
}

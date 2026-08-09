function bp_pet_definition(_id, _name, _health, _basic_name, _basic_damage, _super_name, _super_damage, _tags, _sprite, _unblockable) {
    return {
        id: _id,
        name: _name,
        max_health: _health,
        tags: _tags,
        sprite: _sprite,
        basic: { name: _basic_name, damage: _basic_damage, unblockable: _unblockable },
        super: { name: _super_name, damage: _super_damage, unblockable: false },
        ability: _unblockable ? "Quick: basic attacks cannot be blocked" : "None"
    };
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
        bp_pet_definition("bailly", "Bailly", 90, "Golden Kick", 16, "Sunburst", 34, ["fur"], Bailly, true),
        bp_pet_definition("porcha_mercadies", "Porcha & Mercadies", 110, "Double Pounce", 15, "Best Friends", 31, ["cat", "fur"], BPPorchaandMercadies, false),
        bp_pet_definition("ember", "Ember (Placeholder)", 82, "Spark", 18, "Firework", 36, ["fur"], -1, false),
        bp_pet_definition("moss", "Moss (Placeholder)", 125, "Bramble", 13, "Overgrowth", 28, ["plant"], -1, false),
        bp_pet_definition("pebble", "Pebble (Placeholder)", 140, "Bump", 12, "Rockslide", 30, ["stone"], -1, false),
        bp_pet_definition("ripple", "Ripple (Placeholder)", 100, "Splash", 16, "Tidal Wave", 33, ["water"], -1, false),
        bp_pet_definition("whisk", "Whisk (Placeholder)", 78, "Swipe", 19, "Nine Lives", 35, ["cat", "fur"], -1, true),
        bp_pet_definition("sprout", "Sprout (Placeholder)", 115, "Seed Pop", 14, "Bloom Blast", 32, ["plant"], -1, false)
    ];

    var _cards = [
        bp_card_definition("guard", "Guardian Shield", "Give one living pet a shield that blocks the next blockable attack.", "shield", 1),
        bp_card_definition("revive", "Second Chance", "Return one knocked-out pet at half health.", "revive", 50),
        bp_card_definition("sting", "Surprise Sting", "Deal 18 damage to an opposing pet.", "damage", 18),
        bp_card_definition("stun", "Time Out", "Make an opposing pet unavailable for its owner's next turn.", "stun", 1),
        bp_card_definition("boost", "Power Snack", "Add 8 damage to one pet's attacks for the rest of the match.", "boost", 8)
    ];

    return { pets: _pets, cards: _cards, version: 1 };
}

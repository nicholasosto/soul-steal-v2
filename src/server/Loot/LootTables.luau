-- LootTables.lua
local LootTables = {}

LootTables.Common = {
    Items = {
        LootItem.new("Common Sword", "Weapon", "Common", { Damage = 10 }, game.ServerStorage.CommonSword),
        LootItem.new("Common Shield", "Armor", "Common", { Defense = 5 }, game.ServerStorage.CommonShield),
        LootItem.new("Common Potion", "Consumable", "Common", { Health = 10 }, game.ServerStorage.CommonPotion)
    },
    Adjustments = { Common = 1.0, Uncommon = 0.8, Rare = 0.5, Epic = 0.2, Legendary = 0.1 }
}

LootTables["Weak"] = {
    Items = { ... }, -- List of LootItem instances
    Adjustments = { Common = 1.0, Uncommon = 0.8, Rare = 0.5, Epic = 0.2, Legendary = 0.1 }
}

LootTables["Boss"] = {
    Items = { ... },
    Adjustments = { Common = 1.0, Uncommon = 1.2, Rare = 1.5, Epic = 2.0, Legendary = 3.0 }
}

return LootTables
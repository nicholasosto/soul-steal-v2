-- LootItem.lua
local LootItem = {}
LootItem.__index = LootItem

function LootItem.new(name, itemType, rarity, attributes, model)
    local self = setmetatable({}, LootItem)
    self.Name = name
    self.Type = itemType
    self.Rarity = rarity
    self.Attributes = attributes or {}
    self.Model = model
    -- Add ClickDetector to model
    local clickDetector = Instance.new("ClickDetector")
    clickDetector.Parent = model
    clickDetector.MaxActivationDistance = 10
    clickDetector.MouseClick:Connect(function(player)
        print("Player clicked on loot item: ", self.Name)
        -- Add item to player inventory
    end)
    return self
end

return LootItem
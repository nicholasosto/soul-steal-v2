local LootManager = {}
LootManager.__index = LootManager

local LootTables = require(game.ServerStorage.LootTables)
local LootItem = require(game.ServerStorage.LootItem)

function LootManager.new()
    local self = setmetatable({}, LootManager)
    return self
end


function LootManager:GenerateLoot(npcRank, position)
    local lootTable = LootTables[npcRank]
    local adjustedRates = self:CalculateDrop(RarityDropRates, lootTable.Adjustments)
    
    -- Determine rarity based on adjusted rates
    local rarity = self:SelectRarity(adjustedRates)
    
    -- Select an item of that rarity
    local possibleItems = {}
    for _, item in ipairs(lootTable.Items) do
        if item.Rarity == rarity then
            table.insert(possibleItems, item)
        end
    end
    
    if #possibleItems > 0 then
        local selectedItem = possibleItems[math.random(1, #possibleItems)]
        self:SpawnLootItem(selectedItem, position)
    end
end

function LootManager:SelectRarity(adjustedRates)
    local total = 0
    for _, rate in pairs(adjustedRates) do
        total = total + rate
    end
    
    local rand = math.random() * total
    local cumulative = 0
    for rarity, rate in pairs(adjustedRates) do
        cumulative = cumulative + rate
        if rand <= cumulative then
            return rarity
        end
    end
    return "Common" -- Default fallback
end

function LootManager:CalculateDrop(baseRates, adjustments)
    local adjustedRates = {}
    for rarity, rate in pairs(baseRates) do
        adjustedRates[rarity] = rate * (adjustments[rarity] or 1)
    end
    return adjustedRates
end

function LootManager:SpawnLootItem(lootItem, position)
    local itemClone = lootItem.Model:Clone()
    itemClone:PivotTo(position)
    itemClone.Parent = workspace
    -- Add collectibility, e.g., ClickDetector or Touched event
end




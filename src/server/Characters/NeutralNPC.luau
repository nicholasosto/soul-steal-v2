-- NeutralNPC.lua
local NPCBase = require(game.ServerScriptService.NPCBase)
local NeutralNPC = setmetatable({}, NPCBase)
NeutralNPC.__index = NeutralNPC

function NeutralNPC.new(name, model)
    local self = NPCBase.new(name, model)
    setmetatable(self, NeutralNPC)
    self.Dialogue = {}
    self.Quests = {}
    self.ShopInventory = {}
    return self
end

function NeutralNPC:Talk(player)
    -- Implement dialogue interaction
end

function NeutralNPC:OfferQuest(player)
    -- Offer a quest to the player
end

function NeutralNPC:SellItem(player, itemID)
    -- Handle item selling logic
end

return NeutralNPC

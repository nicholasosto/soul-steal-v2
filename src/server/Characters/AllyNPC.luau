-- AllyNPC.lua
local NPCBase = require(game.ServerScriptService.NPCBase)
local AllyNPC = setmetatable({}, NPCBase)
AllyNPC.__index = AllyNPC

function AllyNPC.new(name, model)
    local self = NPCBase.new(name, model)
    setmetatable(self, AllyNPC)
    self.SupportAbilities = {}
    self.FollowTarget = nil
    return self
end

function AllyNPC:Follow(target)
    -- Implement follow logic
end

function AllyNPC:Assist(target)
    -- Implement assistance logic (e.g., attacking enemies)
end

function AllyNPC:Heal(target)
    -- Implement healing logic
end

return AllyNPC

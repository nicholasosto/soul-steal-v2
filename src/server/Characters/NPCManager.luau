-- NPCManager.lua
local NPCManager = {}

local EnemyNPC = require(game.ServerScriptService.EnemyNPC)
local AllyNPC = require(game.ServerScriptService.AllyNPC)
local NeutralNPC = require(game.ServerScriptService.NeutralNPC)

function NPCManager:SpawnEnemy(name, model)
    local enemy = EnemyNPC.new(name, model)
    -- Additional setup
    return enemy
end

function NPCManager:SpawnAlly(name, model)
    local ally = AllyNPC.new(name, model)
    -- Additional setup
    return ally
end

function NPCManager:SpawnNeutral(name, model)
    local neutral = NeutralNPC.new(name, model)
    -- Additional setup
    return neutral
end

return NPCManager

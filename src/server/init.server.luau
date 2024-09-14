print("Hello world, from server!")

- ServerMain.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local RemoteEvents = require(ReplicatedStorage:WaitForChild("RemoteEvents"))
local DataStoreManager = require(game.ServerScriptService.DataManager:WaitForChild("DataStoreManager"))
local AbilityBase = require(script.Parent.Abilities.AbilityBase)
local CharacterBase = require(script.Parent.Characters.CharacterBase)
local PlayerCharacter = require(game.ServerScriptService.Characters.PlayerCharacter)
local NPCManager = require(game.ServerScriptService.Characters.NPCManager)

NPCManager:SpawnNPC(game.Workspace.Rig, CFrame.new(310,10,310))
-- Import specific abilities if needed

-- Table to keep track of players' cooldowns
local playerCooldowns = {}

-- Handle RemoteFunction call to get player's abilities data
RemoteEvents.GetPlayerAbilities.OnServerInvoke = function(player)
	local abilitiesData = DataStoreManager:GetValue(player, "Abilities")
	return abilitiesData
end

-- Function to handle ability activation requests
RemoteEvents.ActivateAbility.OnServerEvent:Connect(function(player, abilityName, target)
	
	local abilitiesData = DataStoreManager:GetValue(player, "Abilities")
	
	print("Ability Data [",abilityName,"]: ", abilitiesData[abilityName])
	
	
	if not abilitiesData then
		warn("No abilities data found for player:", player.Name)
		return
	end

	local abilityInfo = abilitiesData[abilityName]
	
	if not abilityInfo or not abilityInfo.Unlocked then
		warn("Player tried to use an ability they don't have:", abilityName)
		return
	end

	-- Check cooldown
	local currentTime = tick()
	playerCooldowns[player] = playerCooldowns[player] or {}
	local lastUsed = playerCooldowns[player][abilityName] or 0
	local cooldownTime = getAbilityCooldown(abilityName, abilityInfo.Level) -- Use the same function or define it here
	if currentTime - lastUsed < cooldownTime then
		warn("Ability is on cooldown for player:", player.Name, abilityName)
		return
	end

	-- Activate the ability
	playerCooldowns[player][abilityName] = currentTime
	-- Retrieve the ability instance and activate it
	local abilityInstance = getAbilityInstance(abilityName)
	abilityInstance:Activate(player, target)

	-- Confirm activation to the client
	RemoteEvents.AbilityActivated:FireClient(player, abilityName, target)
end)

-- Function to get ability cooldown (same as client)
function getAbilityCooldown(abilityName, level)
	-- Define base cooldowns for abilities
	local cooldown = getAbilityInstance(abilityName).Cooldown or 10

	return math.max(cooldown, 1)
end

-- Function to get ability instance
function getAbilityInstance(abilityName)
	-- You should have a mapping of ability names to their instances or constructors
	local abilities = {
		LifeDrain = require(script.Parent.Abilities.LifeDrain).new(),
		MagicShield = require(script.Parent.Abilities.MagicShield).new(),
		SpeedBoost = require(script.Parent.Abilities.SpeedBoost).new(),
		Necromancy = require(script.Parent.Abilities.Necromancy).new(),
		SoulSiphon = require(script.Parent.Abilities.SoulSiphon).new(),
		-- Add other abilities here
	}
	return abilities[abilityName]
end


Players.PlayerAdded:Connect(function(player: Player) 

	player.CharacterAdded:Connect(function(character: Model) 
		
		PlayerCharacter.new(player)
		
		
	end)
	
end)
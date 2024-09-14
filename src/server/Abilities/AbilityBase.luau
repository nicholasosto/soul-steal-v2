local ServerScripts = game:GetService("ServerScriptService")

-- AbilityBase.lua
local DataStoreManager = require(ServerScripts.DataManager.DataStoreManager)

local AbilityBase = {}

AbilityBase.__index = AbilityBase


function AbilityBase.new()
	local self = setmetatable({}, AbilityBase)
	self.Name = "Generic Ability"
	self.Cooldown = 0
	self.LastUsed = 0
	return self
end

function AbilityBase:CanActivate()
	return (tick() - self.LastUsed) >= self.Cooldown
end

function AbilityBase:IsUnlocked(player)
	local unlocked = DataStoreManager:GetNestedValue(player, {"Abilities", self.Name, "Unlocked"})
	
	print("Is Unlocked Check: ", unlocked, " Player: ", player.Name)
	return unlocked == true
end

function AbilityBase:GetLevel(player)
	local level = DataStoreManager:GetNestedValue(player, {"Abilities", self.Name, "Level"})
	return level or 0
end

function AbilityBase:Activate(user, target)
	warn("ActivateBase: ", user, target )
	if not self:IsUnlocked(user) then
		warn("Ability not unlocked:", self.Name)
		return
	end
	-- Proceed with activation logic, possibly modified by ability level
	local level = self:GetLevel(user.Player)
	-- Adjust ability effects based on level
end

return AbilityBase

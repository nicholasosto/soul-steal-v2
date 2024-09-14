-- MagicShield.lua
local AbilityBase = require(script.Parent.AbilityBase)
local MagicShield = {}
MagicShield.__index = MagicShield
setmetatable(MagicShield, AbilityBase)

function MagicShield.new()
	local self = AbilityBase.new()
	setmetatable(self, MagicShield)
	self.Name = "Life Drain"
	self.Cooldown = 5
	return self
end

function MagicShield:Activate(user, target)
	AbilityBase.Activate(self, user, target)
	if target and target.Health > 0 then
		local amount = 20
		target:TakeDamage(amount)
		user:Heal(amount)
		-- Trigger visual effects
	end
end

return MagicShield

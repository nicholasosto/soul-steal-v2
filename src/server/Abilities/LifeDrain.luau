-- LifeDrain.lua

local AbilityBase = require(script.Parent.AbilityBase)
local LifeDrain = {}
LifeDrain.__index = LifeDrain
setmetatable(LifeDrain, AbilityBase)

function LifeDrain.new()
	local self = AbilityBase.new()
	setmetatable(self, LifeDrain)
	self.Name = "LifeDrain"
	self.Cooldown = 5  -- Cooldown time in seconds
	self.Duration = 5  -- Duration of the life drain effect in seconds
	self.DrainAmountPerSecond = 10  -- Amount of health to drain per second
	return self
end

function LifeDrain:Activate(user, target)
	warn("LifeDrain Activate: ", user, target )
	-- Check if the ability can be activated
	if not self:CanActivate() then return end
	self.LastUsed = tick()

	-- Validate the target
	if not target then

		warn("Invalid target for Life Drain ability.")
		return
	end

	-- Ensure target is alive
	if target.Humanoid.Health <= 0 then
		warn("Target is already dead.")
		return
	end

	-- Begin the life drain effect
	local startTime = tick()
	local endTime = startTime + self.Duration

	-- Create attachments and beam for visual effect
	local beam = Instance.new("Beam")
	local attachment0 = Instance.new("Attachment")
	local attachment1 = Instance.new("Attachment")

	-- Attach to user's character
	local userCharacter = user.Character
	if not userCharacter or not userCharacter:FindFirstChild("HumanoidRootPart") then
		warn("User character is invalid.")
		return
	end
	attachment0.Parent = userCharacter.HumanoidRootPart

	-- Attach to target's character

	attachment1.Parent = target.HumanoidRootPart

	-- Configure the beam
	beam.Attachment0 = attachment0
	beam.Attachment1 = attachment1
	beam.Color = ColorSequence.new(Color3.new(1, 0, 0))  -- Red color
	beam.Width0 = 0.2
	beam.Width1 = 0.2
	beam.Parent = workspace

	-- Drain logic
	local drainConnection
	drainConnection = game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
		local currentTime = tick()
		if currentTime >= endTime or target.Humanoid.Health <= 0 or user.Character.Humanoid.Health <= 0 then
			-- End the effect
			drainConnection:Disconnect()
			beam:Destroy()
			attachment0:Destroy()
			attachment1:Destroy()
			return
		end

		-- Drain health from the target and heal the user
		local drainAmount = self.DrainAmountPerSecond * deltaTime
		target.Humanoid:TakeDamage(drainAmount)
		user.Character.Humanoid.Health += drainAmount
	end)
end

return LifeDrain

-- EnemyNPC.lua

-- Require necessary modules and services
local NPCBase = require(game.ServerScriptService.Characters.NPCBase)
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- EnemyNPC class definition
local EnemyNPC = {}
EnemyNPC.__index = EnemyNPC
setmetatable(EnemyNPC, {__index = NPCBase}) -- Correct inheritance setup

-- Constructor
function EnemyNPC.new(name, model)
	local self = NPCBase.new(name, model)
	setmetatable(self, EnemyNPC)

	-- Combat Attributes
	self.AttackPower = 15
	self.Defense = 5
	self.AttackSpeed = 1.5
	self.AttackRange = 15
	self.AggroRange = 50
	self.CanAttack = true
	self.ExperienceYield = 100
	self.LootTable = {
		{ItemID = "HealthPotion", DropChance = 50},
		{ItemID = "IronSword", DropChance = 10}
	}
	self.Abilities = {"Fireball", "Charge"}
	self.Resistances = {Fire = 0.5, Ice = 1.0}
	self.Weaknesses = {Lightning = 1.5}
	self.AbilityCooldowns = {}

	-- AI Behavior Attributes
	self.BehaviorState = "Idle"
	self.PatrolPoints = {}
	self.Target = nil
	self.LastKnownPosition = nil
	self.VisionCone = 90
	self.HearingRadius = 30

	-- Status Effects
	self.StatusEffects = {}

	-- Additional Setup
	self.Humanoid = self.Model:FindFirstChildOfClass("Humanoid")
	if not self.Humanoid then
		error("Humanoid not found in NPC model: " .. self.Name)
	end

	self.Speed = self.Speed or 16
	self.Humanoid.WalkSpeed = self.Speed
	self.Humanoid.Died:Connect(function()
		self:OnDeath()
	end)

	self.Model.PrimaryPart = self.Model:FindFirstChild("HumanoidRootPart")
	if not self.Model.PrimaryPart then
		error("HumanoidRootPart not found in NPC model: " .. self.Name)
	end
	
	self.IsMoving = false
	self.Waypoints = {}
	self.CurrentWaypointIndex = 1

	self:LoadAnimations()
	self:StartAI()

	return self
end

-- Load Animations
function EnemyNPC:LoadAnimations()
	self.Animations = {}
	local animationsFolder = self.Model:FindFirstChild("Animations")
	if animationsFolder then
		for _, anim in pairs(animationsFolder:GetChildren()) do
			if anim:IsA("Animation") then
				local animationTrack = self.Humanoid:LoadAnimation(anim)
				self.Animations[anim.Name] = animationTrack
			end
		end
	else
		warn("Animations folder not found in model:", self.Model.Name)
	end
end

-- Play Animation
function EnemyNPC:PlayAnimation(animationName)
	for _, anim in pairs(self.Animations) do
		anim:Stop()
	end
	if self.Animations[animationName] then
		self.Animations[animationName]:Play()
	else
		warn("Animation not found:", animationName)
	end
end

-- Start AI
function EnemyNPC:StartAI()
	local lastUpdateTime = tick()
	self.AIConnection = RunService.Heartbeat:Connect(function(deltaTime)
		self:UpdateBehavior(deltaTime)
		self:UpdateStatusEffects(deltaTime)
	end)
end

-- Update Behavior
function EnemyNPC:UpdateBehavior(deltaTime)
	if self.BehaviorState == "Idle" then
		self:DetectPlayer()
		if self.Target then
			self.BehaviorState = "Chase"
			self.IsMoving = false -- Reset moving flag
		else
			self:Patrol()
		end
	elseif self.BehaviorState == "Chase" then
		if self.Target and self.Target.Character and self.Target.Character:FindFirstChild("HumanoidRootPart") then
			local distance = (self.Model.PrimaryPart.Position - self.Target.Character.HumanoidRootPart.Position).Magnitude
			if distance <= self.AttackRange then
				self.BehaviorState = "Attack"
				self.IsMoving = false -- Stop moving when attacking
			else
				self:Chase(self.Target)
			end
		else
			self.Target = nil
			self.BehaviorState = "Idle"
			self.IsMoving = false
		end
	elseif self.BehaviorState == "Attack" then
		if self.Target and self.Target.Character and self.Target.Character:FindFirstChild("Humanoid") then
			local targetHumanoid = self.Target.Character.Humanoid
			if targetHumanoid.Health <= 0 then
				self.Target = nil
				self.BehaviorState = "Idle"
			else
				local distance = (self.Model.PrimaryPart.Position - self.Target.Character.HumanoidRootPart.Position).Magnitude
				if distance > self.AttackRange then
					self.BehaviorState = "Chase"
				else
					self:AttackTarget()
				end
			end
		else
			self.Target = nil
			self.BehaviorState = "Idle"
		end
	elseif self.BehaviorState == "Flee" then
		self:Flee()
	end
end


-- Detect Player
function EnemyNPC:DetectPlayer()
	for _, player in pairs(Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local direction = (player.Character.HumanoidRootPart.Position - self.Model.PrimaryPart.Position).Unit
			local angle = math.deg(math.acos(self.Model.PrimaryPart.CFrame.LookVector:Dot(direction)))
			local distance = (self.Model.PrimaryPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
			if angle <= (self.VisionCone / 2) and distance <= self.AggroRange then
				self.Target = player
				break
			end
		end
	end
end

-- Patrol Behavior
function EnemyNPC:Patrol()
	-- Implement patrol logic if PatrolPoints are set
	if #self.PatrolPoints > 0 then
		-- Move towards the next patrol point
		-- For simplicity, you can cycle through patrol points

		self:PlayAnimation("Walk")
	else
		-- Idle behavior
		self:PlayAnimation("Idle")
	end
end

-- Chase Target
function EnemyNPC:Chase(target)
	if not self.IsMoving then
		self.IsMoving = true
		local path = PathfindingService:CreatePath()
		path:ComputeAsync(self.Model.PrimaryPart.Position, target.Character.HumanoidRootPart.Position)
		self.Waypoints = path:GetWaypoints()
		self.CurrentWaypointIndex = 1
		self:MoveToNextWaypoint()
	end
end

function EnemyNPC:MoveToNextWaypoint()
	if self.CurrentWaypointIndex <= #self.Waypoints then
		local waypoint = self.Waypoints[self.CurrentWaypointIndex]
		self.CurrentWaypointIndex = self.CurrentWaypointIndex + 1
		self.Humanoid:MoveTo(waypoint.Position)
		self.MoveConnection = self.Humanoid.MoveToFinished:Connect(function(reached)
			self.MoveConnection:Disconnect()
			if reached and self.BehaviorState == "Chase" then
				self:MoveToNextWaypoint()
			else
				self.IsMoving = false
			end
		end)
	else
		self.IsMoving = false
	end
end

-- Attack Target
function EnemyNPC:AttackTarget()
	if self.CanAttack then
		self.CanAttack = false
		self:PlayAnimation("Attack")
		self:ApplyDamage(self.Target, self:CalculateDamage())
		delay(1 / self.AttackSpeed, function()
			self.CanAttack = true
		end)
	end
end

-- Flee Behavior
function EnemyNPC:Flee()
	-- Implement fleeing behavior
end

-- Calculate Damage
function EnemyNPC:CalculateDamage()
	local damage = self.AttackPower
	-- Include any modifiers, critical hits, etc.
	return damage
end

-- Apply Damage to Target
function EnemyNPC:ApplyDamage(target, amount)
	if target and target.Character and target.Character:FindFirstChild("Humanoid") then
		local humanoid = target.Character.Humanoid
		humanoid:TakeDamage(amount)
	end
end

-- Receive Damage
function EnemyNPC:ReceiveDamage(amount, damageType)
	local effectiveDamage = amount
	if self.Resistances[damageType] then
		effectiveDamage = effectiveDamage * self.Resistances[damageType]
	end
	if self.Weaknesses[damageType] then
		effectiveDamage = effectiveDamage * self.Weaknesses[damageType]
	end
	self.Health = self.Health - effectiveDamage
	if self.Health <= 0 then
		self:Die()
	end
end

-- Update Status Effects
function EnemyNPC:UpdateStatusEffects(deltaTime)
	for effect, duration in pairs(self.StatusEffects) do
		self.StatusEffects[effect] = duration - deltaTime
		if self.StatusEffects[effect] <= 0 then
			self.StatusEffects[effect] = nil
			self:RemoveStatusEffect(effect)
		else
			self:ApplyEffectTick(effect, deltaTime)
		end
	end
end

-- Apply Effect Tick
function EnemyNPC:ApplyEffectTick(effect, deltaTime)
	if effect == "Poisoned" then
		local poisonDamage = self.PoisonDamage * deltaTime
		self.Health = self.Health - poisonDamage
		if self.Health <= 0 then
			self:Die()
		end
	end
	-- Handle other effects
end

-- Remove Status Effect
function EnemyNPC:RemoveStatusEffect(effect)
	if effect == "Stunned" then
		self.Humanoid.WalkSpeed = self.Speed
	end
	-- Handle other effects
end

-- Use Ability
function EnemyNPC:UseAbility(abilityName)
	if abilityName == "Fireball" then
		if self.AbilityCooldowns[abilityName] and tick() < self.AbilityCooldowns[abilityName] then
			return
		end
		self.AbilityCooldowns[abilityName] = tick() + 5 -- 5-second cooldown

		-- Implement Fireball logic
		local fireball = Instance.new("Part")
		fireball.Size = Vector3.new(1, 1, 1)
		fireball.Shape = Enum.PartType.Ball
		fireball.BrickColor = BrickColor.new("Bright orange")
		fireball.Position = self.Model.PrimaryPart.Position
		fireball.Parent = workspace

		local direction = (self.Target.Character.HumanoidRootPart.Position - self.Model.PrimaryPart.Position).Unit
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Velocity = direction * 50
		bodyVelocity.Parent = fireball

		fireball.Touched:Connect(function(hit)
			local character = hit.Parent
			if character and character:FindFirstChild("Humanoid") and Players:GetPlayerFromCharacter(character) == self.Target then
				self:ApplyDamage(self.Target, 25)
				fireball:Destroy()
			end
		end)

		delay(5, function()
			if fireball and fireball.Parent then
				fireball:Destroy()
			end
		end)
	end
end

-- Drop Loot
function EnemyNPC:DropLoot()
	for _, loot in pairs(self.LootTable) do
		local roll = math.random(1, 100)
		if roll <= loot.DropChance then
			local item = game.ReplicatedStorage.Items[loot.ItemID]:Clone()
			item.Position = self.Model.PrimaryPart.Position
			item.Parent = workspace
		end
	end
end

-- Grant Experience
function EnemyNPC:GrantExperience(killer)
	local leaderstats = killer:FindFirstChild("leaderstats")
	if leaderstats and leaderstats:FindFirstChild("Experience") then
		leaderstats.Experience.Value = leaderstats.Experience.Value + self.ExperienceYield
	end
end

-- Grant Soul (Specific to Soul-Steal mechanic)
function EnemyNPC:GrantSoul(player)
	local playerStats = player:FindFirstChild("Stats")
	if playerStats and playerStats:FindFirstChild("Souls") then
		playerStats.Souls.Value = playerStats.Souls.Value + 1
	end
end

-- On Death
function EnemyNPC:OnDeath()
	self:PlayAnimation("Die")
	self:DropLoot()
	if self.Target then
		self:GrantExperience(self.Target)
		self:GrantSoul(self.Target)
	end
	if self.AIConnection then
		self.AIConnection:Disconnect()
	end
	delay(5, function()
		self.Model:Destroy()
	end)
end

-- Die Method (Alias for OnDeath)
function EnemyNPC:Die()
	self:OnDeath()
end

return EnemyNPC

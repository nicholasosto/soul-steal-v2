-- NPCBase.lua
local NPCBase = {}
NPCBase.__index = NPCBase

function NPCBase.new(name, model)
    local self = setmetatable({}, NPCBase)
    self.Name = name
    self.Health = 100
    self.MaxHealth = 100
    self.Speed = 16
    self.Level = 1
    self.Position = model.PrimaryPart.Position
    self.Animations = {}
    self.States = {Idle = true, Moving = false, Attacking = false}
    self.Model = model
    self.Humanoid = model:FindFirstChildOfClass("Humanoid")
    return self
end

function NPCBase:MoveTo(position)
    -- Implement pathfinding movement to the target position

    warn("TODO: Moving to position: ", position)
end

function NPCBase:TakeDamage(amount)
    warn(self.name, "Taking damage: ", amount)
    self.Health = self.Health - amount
    self.Humanoid.Health = self.Health
    if self.Health <= 0 then
        self:Die()
    end
end

function NPCBase:Die()
    -- Handle NPC death logic
    warn(self.Name, " has died! drop loot")
end

function NPCBase:PlayAnimation(animationName)
    warn("Playing animation: ", animationName)
    -- Play the specified animation
end

function NPCBase:UpdateState(stateName)
    warn("Updating state: ", stateName)
    -- Update NPC state
end

function NPCBase:Interact(player)
    warn("Interacting with player: ", player.Name)
    -- Default interaction (can be overridden in subclasses)
end

return NPCBase

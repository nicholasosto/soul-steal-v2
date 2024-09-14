# Quick Reference Guide for EnemyNPC.lua

**Version:** 1.0 (Development Version)

---

## 1. Overview

The `EnemyNPC` class represents non-player characters (NPCs) in the game "Soul-Steal" that can engage in combat, chase players, patrol, and utilize special abilities. It inherits from the `NPCBase` class and implements additional functionality for combat behaviors, state management, AI logic, and ability usage.

---

## 2. Class Structure

### 2.1 NPCBase Inheritance
The `EnemyNPC` class inherits base attributes and methods from `NPCBase`. Key inherited attributes and methods include:

- **Attributes:**
  - `Name`
  - `Health`
  - `Speed`
  - `Level`
  - `Position`

- **Methods:**
  - `MoveTo(position: Vector3)`
  - `TakeDamage(amount: number)`
  - `Die()`
  - `PlayAnimation(animationName: string)`
  - `Interact(player: Player)`

---

## 3. Core Features

### 3.1 Attributes

| Attribute Name      | Type     | Description                                                                 | Status       |
|---------------------|----------|-----------------------------------------------------------------------------|--------------|
| `AttackPower`        | `number` | The base damage dealt by the NPC during an attack.                          | **Complete** |
| `Defense`            | `number` | The NPC's defense value, reducing damage taken.                             | **Complete** |
| `AttackSpeed`        | `number` | Determines the delay between attacks.                                       | **Complete** |
| `AttackRange`        | `number` | The range within which the NPC can attack the target.                       | **Complete** |
| `AggroRange`         | `number` | The distance at which the NPC detects and chases a player.                  | **Complete** |
| `ExperienceYield`    | `number` | The amount of experience given to the player upon defeating the NPC.        | **Complete** |
| `Abilities`          | `table`  | A list of abilities the NPC can use (e.g., "Fireball", "Charge").           | **Complete** |
| `Resistances`        | `table`  | Defines resistances to certain damage types (e.g., Fire, Ice).              | **Complete** |
| `Weaknesses`         | `table`  | Defines weaknesses to certain damage types (e.g., Lightning).               | **Complete** |
| `StatusEffects`      | `table`  | Active status effects applied to the NPC (e.g., poisoned, stunned).         | **Complete** |
| `AbilityCooldowns`   | `table`  | Cooldown timers for special abilities.                                      | **Complete** |
| `PatrolPoints`       | `table`  | Waypoints the NPC will patrol between while in the idle state.              | **Complete** |
| `IsMoving`           | `boolean`| Flag indicating whether the NPC is currently moving.                        | **Complete** |
| `Waypoints`          | `table`  | The pathfinding waypoints the NPC will follow.                              | **Complete** |

---

### 3.2 Methods

| Method Name              | Description                                                                                 | Status       |
|--------------------------|---------------------------------------------------------------------------------------------|--------------|
| `new(name: string, model: Model)` | Constructor to initialize a new `EnemyNPC` instance.                              | **Complete** |
| `LoadAnimations()`        | Loads the NPC's animations from the `Animations` folder in the model.                      | **Complete** |
| `PlayAnimation(animationName: string)` | Plays the specified animation by name.                                          | **Complete** |
| `UpdateBehavior(deltaTime: number)` | Core method that updates the NPC's state based on game conditions.               | **Complete** |
| `DetectPlayer()`          | Detects nearby players using vision and aggro range logic.                                  | **Complete** |
| `Chase(target: Player)`   | Chases the target player using pathfinding.                                                 | **Complete** |
| `MoveToNextWaypoint()`    | Moves the NPC to the next pathfinding waypoint.                                              | **Complete** |
| `AttackTarget()`          | Performs an attack on the target, considering attack cooldowns.                             | **Complete** |
| `CalculateDamage()`       | Calculates the damage to be dealt to the target, considering resistances and weaknesses.    | **Complete** |
| `ApplyDamage(target: Player, amount: number)` | Applies the calculated damage to the target.                             | **Complete** |
| `UseAbility(abilityName: string)` | Uses the specified ability (e.g., "Fireball"), with cooldown management.          | **Complete** |
| `DropLoot()`              | Drops loot upon NPC death based on the defined loot table.                                  | **Complete** |
| `GrantExperience(killer: Player)` | Grants experience to the player who killed the NPC.                                  | **Complete** |
| `GrantSoul(player: Player)` | Grants a soul to the player as part of the "Soul-Steal" mechanic.                         | **Complete** |
| `OnDeath()`               | Handles the NPC's death, including animations, loot dropping, and cleanup.                  | **Complete** |

---

### 3.3 States

The `EnemyNPC` class uses a state machine to handle behavior transitions:

- **Idle:** The NPC is patrolling or standing still, looking for players to engage.
- **Chase:** The NPC detects a player and chases them using pathfinding.
- **Attack:** The NPC is within attack range and actively attacking the player.
- **Flee:** (Optional) The NPC retreats from combat under certain conditions (e.g., low health).

**State Handler Method:**
```lua
function EnemyNPC:UpdateBehavior(deltaTime)
    -- Handles state transitions between Idle, Chase, Attack, and Flee
end
```
**Completed:** The state handler logic is complete, but minor adjustments may be made for optimization.

---

### 3.4 In-Development Features

#### 3.4.1 Flee State
- **Description:** When the NPC's health drops below a certain threshold, it will retreat from combat.
- **Status:** **In Development**
- **Planned Enhancements:**
  - Introduce logic to move the NPC away from the player when its health is critically low.
  - Implement a cooldown before the NPC can engage again after fleeing.

---

### 3.5 AI Features

The NPC AI is updated in real-time using the `RunService.Heartbeat`:

- **AI Loop:**
```lua
function EnemyNPC:StartAI()
    self.AIConnection = RunService.Heartbeat:Connect(function(deltaTime)
        self:UpdateBehavior(deltaTime)
        self:UpdateStatusEffects(deltaTime)
    end)
end
```
**Completed:** The AI loop is fully functional and updates NPC behavior and status effects.

---

## 4. Special Abilities

The `EnemyNPC` class supports special abilities that are used during combat.

### 4.1 Ability Usage
- **Method:**
```lua
function EnemyNPC:UseAbility(abilityName)
    -- Example: Launches a fireball at the target
end
```
- **Completed Abilities:**
  - **Fireball:** A projectile attack that deals damage on contact.
  - **Charge:** A movement-based attack that pushes the player back.

---

## 5. Development Notes

### 5.1 Known Issues
- **Attack Cooldown:** Occasionally, the NPC may continue attacking when the target is out of range. Being addressed in the next update.

### 5.2 Planned Features
- **Advanced Flee Logic:** Add complex AI retreat strategies when facing stronger enemies or low health.

---

## 6. Example Usage

**Spawning an `EnemyNPC`:**
```lua
local EnemyNPC = require(game.ServerScriptService.Characters.EnemyNPC)

local enemyModel = game.ReplicatedStorage.Models.EnemyGoblin:Clone()
enemyModel.Parent = workspace.Enemies

local goblinNPC = EnemyNPC.new("Goblin Warrior", enemyModel)
goblinNPC.PatrolPoints = {
    Vector3.new(0, 0, 0),
    Vector3.new(10, 0, 0),
    Vector3.new(10, 0, 10),
    Vector3.new(0, 0, 10)
}
```

---

## 7. Change Log

| Version | Date       | Changes                                                                                         |
|---------|------------|-------------------------------------------------------------------------------------------------|
| 1.0     | 09/14/2024 | Initial release of `EnemyNPC` class, including core combat, AI, and behavior management.         |
| 1.1     | 09/15/2024 | Added ability cooldown management and improved attack state handling.                            |
| 1.2     | TBD        | In development: Advanced flee mechanics and additional NPC behaviors.                            |

---

## Conclusion

This quick reference guide provides a concise overview of the `EnemyNPC` class, detailing its core functionality, methods, and attributes. It also outlines areas still under development and known issues that are being addressed.

-- DataStoreManager.lua
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService") -- For deep copy
local DataTemplate = require(script.Parent:WaitForChild("DataTemplate"))

local DataStoreManager = {}
DataStoreManager.__index = DataStoreManager

-- Configure your DataStore
local DATASTORE_NAME = "PlayerDataStore"
local DATA_VERSION = DataTemplate._version
local PlayerDataStore = DataStoreService:GetDataStore(DATASTORE_NAME)

-- Utility function for deep copying tables
local function DeepCopy(original)
	return HttpService:JSONDecode(HttpService:JSONEncode(original))
end

-- Function to synchronize data with the template
local function SynchronizeData(template, loadedData)
	local synchronizedData = DeepCopy(template)

	for key, value in pairs(loadedData) do
		if synchronizedData[key] ~= nil then
			if typeof(value) == "table" and typeof(synchronizedData[key]) == "table" then
				synchronizedData[key] = SynchronizeData(synchronizedData[key], value) -- Recursive synchronization
			else
				synchronizedData[key] = value
			end
		else
			-- Keep extra keys that are not in the template
			synchronizedData[key] = value
		end
	end

	return synchronizedData
end

-- Function to migrate data to the current version
local function MigrateData(loadedData)
	local version = loadedData._version or 0

	-- Example migration logic
	if version < 1 then
		-- Migrate from version 0 to version 1
		-- For example, rename a key or adjust data formats
		-- loadedData.NewKey = loadedData.OldKey or defaultValue
		-- loadedData.OldKey = nil
	end

	-- Update the version
	loadedData._version = DATA_VERSION

	return loadedData
end

-- Main function to load player data
function DataStoreManager:LoadData(player)
	local success, result = pcall(function()
		return PlayerDataStore:GetAsync(player.UserId)
	end)

	local playerData

	if success then
		playerData = result or {}
		-- Check version
		if playerData._version ~= DATA_VERSION then
			playerData = MigrateData(playerData)
		end
		-- Synchronize keys
		playerData = SynchronizeData(DataTemplate, playerData)
	else
		warn("Failed to load data for player:", player, result)
		-- Use a copy of the data template
		playerData = DeepCopy(DataTemplate)
	end

	self.PlayerData[player.UserId] = playerData
	return playerData
end

-- Function to save player data
function DataStoreManager:SaveData(player)
	local playerData = self.PlayerData[player.UserId]
	if playerData then
		local success, result = pcall(function()
			return PlayerDataStore:SetAsync(player.UserId, playerData)
		end)
		if not success then
			warn("Failed to save data for player:", player, result)
		end
	end
end

-- Wrapper functions for simple key-value pairs
function DataStoreManager:SetValue(player, key, value)
	local playerData = self.PlayerData[player.UserId]
	if playerData then
		playerData[key] = value
		self:SaveData(player)
	end
end

function DataStoreManager:GetValue(player, key)
	local playerData = self.PlayerData[player.UserId]
	if playerData then
		return playerData[key]
	end
	return nil
end

function DataStoreManager:IncrementValue(player, key, amount)
	local playerData = self.PlayerData[player.UserId]
	if playerData and typeof(playerData[key]) == "number" then
		playerData[key] = playerData[key] + amount
		self:SaveData(player)
		return playerData[key]
	end
	return nil
end

function DataStoreManager:DecrementValue(player, key, amount)
	return self:IncrementValue(player, key, -amount)
end

-- Wrapper functions for nested data (e.g., abilities)
function DataStoreManager:SetNestedValue(player, keys, value)
	local playerData = self.PlayerData[player.UserId]
	if playerData then
		local current = playerData
		for i = 1, #keys - 1 do
			local key = keys[i]
			if current[key] == nil or typeof(current[key]) ~= "table" then
				current[key] = {}
			end
			current = current[key]
		end
		current[keys[#keys]] = value
		self:SaveData(player)
	end
end

function DataStoreManager:GetNestedValue(player, keys)
	local playerData = self.PlayerData[player.UserId]
	if playerData then
		local current = playerData
		for _, key in ipairs(keys) do
			current = current[key]
			print("current[",key,"]: ", current)
			if current == nil then
				return nil
			end
		end
		return current
	end
	return nil
end

function DataStoreManager:IncrementNestedValue(player, keys, amount)
	local value = self:GetNestedValue(player, keys)
	if typeof(value) == "number" then
		value = value + amount
		self:SetNestedValue(player, keys, value)
		return value
	else
		warn("Cannot increment non-number value at keys:", table.concat(keys, " -> "))
	end
	return nil
end

function DataStoreManager:DecrementNestedValue(player, keys, amount)
	return self:IncrementNestedValue(player, keys, -amount)
end

-- Function to unlock an ability for a player
function UnlockAbility(player, abilityName)
	DataStoreManager:SetNestedValue(player, {"Abilities", abilityName, "Unlocked"}, true)
	DataStoreManager:SetNestedValue(player, {"Abilities", abilityName, "Level"}, 1)
end

-- Function to level up an ability for a player
function LevelUpAbility(player, abilityName)
	local currentLevel = DataStoreManager:GetNestedValue(player, {"Abilities", abilityName, "Level"})
	if currentLevel then
		DataStoreManager:SetNestedValue(player, {"Abilities", abilityName, "Level"}, currentLevel + 1)
	else
		warn("Ability not found or not unlocked:", abilityName)
	end
end


-- Initialize the DataStoreManager
function DataStoreManager.new()
	local self = setmetatable({}, DataStoreManager)
	self.PlayerData = {}

	-- Player added event
	Players.PlayerAdded:Connect(function(player)
		self:LoadData(player)
	end)

	-- Player removing event
	Players.PlayerRemoving:Connect(function(player)
		self:SaveData(player)
		self.PlayerData[player.UserId] = nil
	end)

	-- Bind to close event to save all player data
	game:BindToClose(function()
		for _, player in pairs(Players:GetPlayers()) do
			self:SaveData(player)
		end
	end)

	return self
end

return DataStoreManager.new()

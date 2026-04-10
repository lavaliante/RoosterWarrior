local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local upgradePurchaseRemote = remotesFolder:WaitForChild("UpgradePurchase")
local UPGRADE_STORE = DataStoreService:GetDataStore("PlayerUpgrades_v1")
local SAVE_RETRY_COUNT = 3
local SAVE_RETRY_DELAY = 1

local UPGRADES = {
	Health = {
		MaxLevel = 5,
		BaseCost = 25,
		CostStep = 15,
		HealthPerLevel = 20,
	},
	Damage = {
		MaxLevel = 5,
		BaseCost = 30,
		CostStep = 20,
	},
}

local upgradeValueConnections = {}
local saveDebounces = {}

local function getUpgradeDataKey(player)
	return "player_" .. tostring(player.UserId)
end

local function getLeaderstats(player)
	return player:WaitForChild("leaderstats")
end

local function getFeathersValue(player)
	return getLeaderstats(player):WaitForChild("Feathers")
end

local function getOrCreateUpgradeFolder(player)
	local upgradeFolder = player:FindFirstChild("UpgradeData")

	if not upgradeFolder then
		upgradeFolder = Instance.new("Folder")
		upgradeFolder.Name = "UpgradeData"
		upgradeFolder.Parent = player
	end

	for upgradeName in pairs(UPGRADES) do
		local levelValue = upgradeFolder:FindFirstChild(upgradeName)

		if not levelValue then
			levelValue = Instance.new("IntValue")
			levelValue.Name = upgradeName
			levelValue.Value = 0
			levelValue.Parent = upgradeFolder
		end
	end

	return upgradeFolder
end

local function getUpgradeLevel(player, upgradeName)
	local upgradeFolder = getOrCreateUpgradeFolder(player)
	local levelValue = upgradeFolder:FindFirstChild(upgradeName)

	return levelValue and levelValue.Value or 0
end

local function getUpgradeCost(upgradeName, currentLevel)
	local config = UPGRADES[upgradeName]

	if not config then
		return nil
	end

	return config.BaseCost + currentLevel * config.CostStep
end

local function applyUpgradeAttributes(player)
	player:SetAttribute("HealthUpgradeLevel", getUpgradeLevel(player, "Health"))
	player:SetAttribute("DamageUpgradeLevel", getUpgradeLevel(player, "Damage"))
end

local function applyHealthUpgradeToCharacter(player, healToFull)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	local baseHealth = 100 + (player:GetAttribute("CharacterHealthBonus") or 0)
	local healthLevel = getUpgradeLevel(player, "Health")
	local bonusHealth = healthLevel * UPGRADES.Health.HealthPerLevel
	local newMaxHealth = baseHealth + bonusHealth
	local previousMaxHealth = humanoid.MaxHealth
	local currentHealth = humanoid.Health

	humanoid.MaxHealth = newMaxHealth

	if healToFull then
		humanoid.Health = newMaxHealth
	elseif previousMaxHealth > 0 then
		local healthRatio = math.clamp(currentHealth / previousMaxHealth, 0, 1)
		humanoid.Health = math.clamp(newMaxHealth * healthRatio, 0, newMaxHealth)
	else
		humanoid.Health = math.clamp(currentHealth, 0, newMaxHealth)
	end
end

local function hookCharacterStatAttributes(player)
	player:GetAttributeChangedSignal("CharacterHealthBonus"):Connect(function()
		applyHealthUpgradeToCharacter(player, false)
	end)
end

local function loadUpgrades(player)
	local upgradeFolder = getOrCreateUpgradeFolder(player)
	local success, storedData = pcall(function()
		return UPGRADE_STORE:GetAsync(getUpgradeDataKey(player))
	end)

	if not success then
		warn(string.format("Failed to load upgrades for %s: %s", player.Name, tostring(storedData)))
	end

	for upgradeName, config in pairs(UPGRADES) do
		local levelValue = upgradeFolder:FindFirstChild(upgradeName)
		if levelValue then
			local loadedValue = 0
			if success and type(storedData) == "table" and type(storedData[upgradeName]) == "number" then
				loadedValue = math.clamp(math.floor(storedData[upgradeName]), 0, config.MaxLevel)
			end
			levelValue.Value = loadedValue
		end
	end

	applyUpgradeAttributes(player)
	applyHealthUpgradeToCharacter(player, true)

	return upgradeFolder
end

local function saveUpgrades(player)
	local upgradeFolder = getOrCreateUpgradeFolder(player)
	local payload = {}

	for upgradeName in pairs(UPGRADES) do
		local levelValue = upgradeFolder:FindFirstChild(upgradeName)
		payload[upgradeName] = levelValue and math.max(0, math.floor(levelValue.Value)) or 0
	end

	local success = false
	local lastError

	for _ = 1, SAVE_RETRY_COUNT do
		success, lastError = pcall(function()
			UPGRADE_STORE:SetAsync(getUpgradeDataKey(player), payload)
		end)

		if success then
			return true
		end

		task.wait(SAVE_RETRY_DELAY)
	end

	warn(string.format("Failed to save upgrades for %s: %s", player.Name, tostring(lastError)))
	return false
end

local function scheduleUpgradeSave(player)
	if saveDebounces[player] then
		return
	end

	saveDebounces[player] = true

	task.delay(1.5, function()
		saveDebounces[player] = nil
		if player.Parent then
			saveUpgrades(player)
		end
	end)
end

local function connectUpgradeEvents(player, upgradeFolder)
	if upgradeValueConnections[player] then
		for _, connection in ipairs(upgradeValueConnections[player]) do
			connection:Disconnect()
		end
	end

	upgradeValueConnections[player] = {}

	for upgradeName in pairs(UPGRADES) do
		local levelValue = upgradeFolder:FindFirstChild(upgradeName)

		if levelValue then
			local connection = levelValue.Changed:Connect(function()
				applyUpgradeAttributes(player)
				scheduleUpgradeSave(player)

				if upgradeName == "Health" then
					applyHealthUpgradeToCharacter(player, true)
				end
			end)
			table.insert(upgradeValueConnections[player], connection)
		end
	end
end

local function tryPurchaseUpgrade(player, upgradeName)
	local config = UPGRADES[upgradeName]

	if not config then
		return
	end

	local upgradeFolder = getOrCreateUpgradeFolder(player)
	local levelValue = upgradeFolder:FindFirstChild(upgradeName)
	local feathers = getFeathersValue(player)

	if not levelValue or not feathers then
		return
	end

	if levelValue.Value >= config.MaxLevel then
		return
	end

	local cost = getUpgradeCost(upgradeName, levelValue.Value)

	if feathers.Value < cost then
		return
	end

	feathers.Value -= cost
	levelValue.Value += 1
end

upgradePurchaseRemote.OnServerEvent:Connect(function(player, upgradeName)
	if type(upgradeName) ~= "string" then
		return
	end

	tryPurchaseUpgrade(player, upgradeName)
end)

Players.PlayerAdded:Connect(function(player)
	local upgradeFolder = loadUpgrades(player)
	connectUpgradeEvents(player, upgradeFolder)
	hookCharacterStatAttributes(player)

	player.CharacterAdded:Connect(function()
		task.defer(function()
			applyHealthUpgradeToCharacter(player, true)
		end)
	end)
end)

for _, player in ipairs(Players:GetPlayers()) do
	local upgradeFolder = loadUpgrades(player)
	connectUpgradeEvents(player, upgradeFolder)
	hookCharacterStatAttributes(player)

	player.CharacterAdded:Connect(function()
		task.defer(function()
			applyHealthUpgradeToCharacter(player, true)
		end)
	end)
end

Players.PlayerRemoving:Connect(function(player)
	local connections = upgradeValueConnections[player]
	if connections then
		for _, connection in ipairs(connections) do
			connection:Disconnect()
		end
		upgradeValueConnections[player] = nil
	end

	saveDebounces[player] = nil
	saveUpgrades(player)
end)

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		saveUpgrades(player)
	end
end)

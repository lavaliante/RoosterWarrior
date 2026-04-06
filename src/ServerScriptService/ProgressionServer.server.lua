local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local upgradePurchaseRemote = remotesFolder:WaitForChild("UpgradePurchase")

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

	for upgradeName in pairs(UPGRADES) do
		local levelValue = upgradeFolder:FindFirstChild(upgradeName)

		if levelValue then
			levelValue.Value = 0
		end
	end

	applyUpgradeAttributes(player)
	applyHealthUpgradeToCharacter(player, true)

	return upgradeFolder
end

local function connectUpgradeEvents(player, upgradeFolder)
	for upgradeName in pairs(UPGRADES) do
		local levelValue = upgradeFolder:FindFirstChild(upgradeName)

		if levelValue then
			levelValue.Changed:Connect(function()
				applyUpgradeAttributes(player)

				if upgradeName == "Health" then
					applyHealthUpgradeToCharacter(player, true)
				end
			end)
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

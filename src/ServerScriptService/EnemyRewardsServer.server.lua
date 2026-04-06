local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local Workspace = game:GetService("Workspace")

local FEATHERS_DATASTORE = DataStoreService:GetDataStore("PlayerFeathers_v1")
local SAVE_RETRY_COUNT = 3
local SAVE_RETRY_DELAY = 1

local REWARD_BY_ENEMY_TYPE = {
	RedDemon = 5,
	BlueDemon = 7,
	GreenDemon = 10,
	PurpleDemon = 14,
	WhiteDemon = 20,
}

local trackedEnemies = {}
local playerSaveConnections = {}
local pendingSaveTasks = {}

local function getPlayerDataKey(player)
	return "player_" .. tostring(player.UserId)
end

local function getOrCreateLeaderstats(player)
	local leaderstats = player:FindFirstChild("leaderstats")

	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end

	local feathers = leaderstats:FindFirstChild("Feathers")

	if not feathers then
		feathers = Instance.new("IntValue")
		feathers.Name = "Feathers"
		feathers.Value = 0
		feathers.Parent = leaderstats
	end

	return feathers
end

local function saveFeathers(player)
	local feathers = getOrCreateLeaderstats(player)
	local dataKey = getPlayerDataKey(player)
	local success = false
	local lastError

	for _ = 1, SAVE_RETRY_COUNT do
		success, lastError = pcall(function()
			FEATHERS_DATASTORE:SetAsync(dataKey, feathers.Value)
		end)

		if success then
			return true
		end

		task.wait(SAVE_RETRY_DELAY)
	end

	warn(string.format("Failed to save feathers for %s: %s", player.Name, tostring(lastError)))
	return false
end

local function scheduleSave(player)
	if pendingSaveTasks[player] then
		return
	end

	pendingSaveTasks[player] = true

	task.delay(2, function()
		pendingSaveTasks[player] = nil

		if player.Parent then
			saveFeathers(player)
		end
	end)
end

local function loadFeathers(player)
	local feathers = getOrCreateLeaderstats(player)
	local dataKey = getPlayerDataKey(player)
	local success, storedValue = pcall(function()
		return FEATHERS_DATASTORE:GetAsync(dataKey)
	end)

	if not success then
		warn(string.format("Failed to load feathers for %s: %s", player.Name, tostring(storedValue)))
		return feathers
	end

	if type(storedValue) == "number" then
		feathers.Value = math.max(0, math.floor(storedValue))
	end

	return feathers
end

local function awardKillReward(enemyModel)
	local lastHitUserId = enemyModel:GetAttribute("LastHitPlayerUserId")

	if type(lastHitUserId) ~= "number" or lastHitUserId <= 0 then
		return
	end

	local player = Players:GetPlayerByUserId(lastHitUserId)

	if not player then
		return
	end

	local enemyType = enemyModel:GetAttribute("EnemyType") or enemyModel.Name
	local rewardAmount = REWARD_BY_ENEMY_TYPE[enemyType] or 1
	local feathers = getOrCreateLeaderstats(player)
	feathers.Value += rewardAmount
end

local function trackEnemy(enemyModel)
	if trackedEnemies[enemyModel] then
		return
	end

	local humanoid = enemyModel:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	trackedEnemies[enemyModel] = true

	humanoid.Died:Connect(function()
		awardKillReward(enemyModel)
		trackedEnemies[enemyModel] = nil
	end)

	enemyModel.Destroying:Connect(function()
		trackedEnemies[enemyModel] = nil
	end)
end

local function onWorkspaceChildAdded(instance)
	if instance:IsA("Model") and instance:GetAttribute("IsDemonEnemy") then
		task.defer(trackEnemy, instance)
	end
end

Players.PlayerAdded:Connect(function(player)
	local feathers = loadFeathers(player)

	if playerSaveConnections[player] then
		playerSaveConnections[player]:Disconnect()
	end

	playerSaveConnections[player] = feathers.Changed:Connect(function()
		scheduleSave(player)
	end)
end)

for _, player in ipairs(Players:GetPlayers()) do
	local feathers = loadFeathers(player)
	playerSaveConnections[player] = feathers.Changed:Connect(function()
		scheduleSave(player)
	end)
end

Players.PlayerRemoving:Connect(function(player)
	local connection = playerSaveConnections[player]

	if connection then
		connection:Disconnect()
		playerSaveConnections[player] = nil
	end

	pendingSaveTasks[player] = nil
	saveFeathers(player)
end)

for _, instance in ipairs(Workspace:GetChildren()) do
	if instance:IsA("Model") and instance:GetAttribute("IsDemonEnemy") then
		trackEnemy(instance)
	end
end

Workspace.ChildAdded:Connect(onWorkspaceChildAdded)

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		saveFeathers(player)
	end
end)

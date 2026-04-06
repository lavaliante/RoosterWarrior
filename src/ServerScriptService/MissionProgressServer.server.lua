local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local MISSION_FEATHER_REWARD = 10
local MISSION_RESET_DELAY = 2.5

local MISSION_DEFINITIONS = {
	{
		Id = "DefeatDemons",
		Title = "Defeat 5 demons",
		Target = 5,
	},
	{
		Id = "ReachWave4",
		Title = "Reach wave 4",
		Target = 4,
	},
	{
		Id = "DefeatPurpleDemon",
		Title = "Defeat 1 PurpleDemon",
		Target = 1,
		EnemyType = "PurpleDemon",
	},
	{
		Id = "ScratchFinisher",
		Title = "Defeat 3 demons with Scratch",
		Target = 3,
		AttackName = "Scratch",
	},
	{
		Id = "ChicoHunter",
		Title = "Defeat 2 demons as Chico",
		Target = 2,
		RoosterName = "Chico",
	},
}

local trackedEnemies = {}
local waveConnections = {}

local function getMissionDefinition(index)
	local missionCount = #MISSION_DEFINITIONS
	local normalizedIndex = ((index - 1) % missionCount) + 1
	return MISSION_DEFINITIONS[normalizedIndex], normalizedIndex
end

local function getOrCreateMissionFolder(player)
	local missionFolder = player:FindFirstChild("MissionData")

	if not missionFolder then
		missionFolder = Instance.new("Folder")
		missionFolder.Name = "MissionData"
		missionFolder.Parent = player
	end

	local missionIndex = missionFolder:FindFirstChild("MissionIndex")

	if not missionIndex then
		missionIndex = Instance.new("IntValue")
		missionIndex.Name = "MissionIndex"
		missionIndex.Value = 1
		missionIndex.Parent = missionFolder
	end

	local missionId = missionFolder:FindFirstChild("MissionId")

	if not missionId then
		missionId = Instance.new("StringValue")
		missionId.Name = "MissionId"
		missionId.Value = ""
		missionId.Parent = missionFolder
	end

	local missionTitle = missionFolder:FindFirstChild("MissionTitle")

	if not missionTitle then
		missionTitle = Instance.new("StringValue")
		missionTitle.Name = "MissionTitle"
		missionTitle.Value = MISSION_DEFINITIONS[1].Title
		missionTitle.Parent = missionFolder
	end

	local missionProgress = missionFolder:FindFirstChild("MissionProgress")

	if not missionProgress then
		missionProgress = Instance.new("IntValue")
		missionProgress.Name = "MissionProgress"
		missionProgress.Value = 0
		missionProgress.Parent = missionFolder
	end

	local missionTarget = missionFolder:FindFirstChild("MissionTarget")

	if not missionTarget then
		missionTarget = Instance.new("IntValue")
		missionTarget.Name = "MissionTarget"
		missionTarget.Value = 0
		missionTarget.Parent = missionFolder
	end

	local missionComplete = missionFolder:FindFirstChild("MissionComplete")

	if not missionComplete then
		missionComplete = Instance.new("BoolValue")
		missionComplete.Name = "MissionComplete"
		missionComplete.Value = false
		missionComplete.Parent = missionFolder
	end

	return missionFolder, missionIndex, missionId, missionTitle, missionProgress, missionTarget, missionComplete
end

local function applyMissionDefinition(player, definition, missionIndexValue)
	local _, missionIndex, missionId, missionTitle, missionProgress, missionTarget, missionComplete = getOrCreateMissionFolder(player)
	local waveValue = player:FindFirstChild("Wave")

	missionIndex.Value = missionIndexValue
	missionId.Value = definition.Id
	missionTitle.Value = definition.Title
	missionTarget.Value = definition.Target
	missionComplete.Value = false

	if definition.Id == "ReachWave4" and waveValue then
		missionProgress.Value = math.clamp(waveValue.Value, 0, definition.Target)
	else
		missionProgress.Value = 0
	end
end

local function advanceToNextMission(player)
	local _, missionIndex = getOrCreateMissionFolder(player)
	local nextDefinition, nextIndex = getMissionDefinition(missionIndex.Value + 1)
	applyMissionDefinition(player, nextDefinition, nextIndex)
end

local function resetMissionAfterDelay(player)
	task.delay(MISSION_RESET_DELAY, function()
		if not player.Parent then
			return
		end

		local _, missionIndex, _, _, _, _, missionComplete = getOrCreateMissionFolder(player)

		if missionComplete.Value then
			local nextDefinition, nextIndex = getMissionDefinition(missionIndex.Value + 1)
			applyMissionDefinition(player, nextDefinition, nextIndex)
		end
	end)
end

local function completeMission(player, missionProgress, missionTarget, missionComplete)
	if missionComplete.Value then
		return
	end

	missionProgress.Value = missionTarget.Value
	missionComplete.Value = true

	local leaderstats = player:FindFirstChild("leaderstats")
	local feathers = leaderstats and leaderstats:FindFirstChild("Feathers")

	if feathers then
		feathers.Value += MISSION_FEATHER_REWARD
	end

	resetMissionAfterDelay(player)
end

local function recordKillForPlayer(player, enemyModel)
	local _, _, missionId, _, missionProgress, missionTarget, missionComplete = getOrCreateMissionFolder(player)

	if missionComplete.Value then
		return
	end

	local shouldCountKill = false

	if missionId.Value == "DefeatDemons" then
		shouldCountKill = true
	elseif missionId.Value == "DefeatPurpleDemon" then
		shouldCountKill = (enemyModel:GetAttribute("EnemyType") or enemyModel.Name) == "PurpleDemon"
	elseif missionId.Value == "ScratchFinisher" then
		shouldCountKill = enemyModel:GetAttribute("LastHitAttackName") == "Scratch"
	elseif missionId.Value == "ChicoHunter" then
		shouldCountKill = player:GetAttribute("SelectedRooster") == "Chico"
	end

	if not shouldCountKill then
		return
	end

	missionProgress.Value = math.min(missionProgress.Value + 1, missionTarget.Value)

	if missionProgress.Value >= missionTarget.Value then
		completeMission(player, missionProgress, missionTarget, missionComplete)
	end
end

local function awardMissionProgress(enemyModel)
	local lastHitUserId = enemyModel:GetAttribute("LastHitPlayerUserId")

	if type(lastHitUserId) ~= "number" or lastHitUserId <= 0 then
		return
	end

	local player = Players:GetPlayerByUserId(lastHitUserId)

	if player then
		recordKillForPlayer(player, enemyModel)
	end
end

local function refreshWaveMissionProgress(player)
	local _, _, missionId, _, missionProgress, missionTarget, missionComplete = getOrCreateMissionFolder(player)
	local waveValue = player:FindFirstChild("Wave")

	if missionId.Value ~= "ReachWave4" or not waveValue or missionComplete.Value then
		return
	end

	missionProgress.Value = math.clamp(waveValue.Value, 0, missionTarget.Value)

	if missionProgress.Value >= missionTarget.Value then
		completeMission(player, missionProgress, missionTarget, missionComplete)
	end
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
		awardMissionProgress(enemyModel)
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

local function onPlayerAdded(player)
	local _, missionIndex = getOrCreateMissionFolder(player)
	local definition, normalizedIndex = getMissionDefinition(missionIndex.Value)
	applyMissionDefinition(player, definition, normalizedIndex)

	local waveValue = player:WaitForChild("Wave")

	if waveConnections[player] then
		waveConnections[player]:Disconnect()
	end

	waveConnections[player] = waveValue.Changed:Connect(function()
		refreshWaveMissionProgress(player)
	end)

	refreshWaveMissionProgress(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)

Players.PlayerRemoving:Connect(function(player)
	local connection = waveConnections[player]

	if connection then
		connection:Disconnect()
		waveConnections[player] = nil
	end
end)

for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

for _, instance in ipairs(Workspace:GetChildren()) do
	if instance:IsA("Model") and instance:GetAttribute("IsDemonEnemy") then
		trackEnemy(instance)
	end
end

Workspace.ChildAdded:Connect(onWorkspaceChildAdded)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MISSION_FEATHER_REWARD = 10
local MISSION_RESET_DELAY = 2.5

local chapterQuestConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("ChapterQuestConfig"))
local trackedEnemies = {}
local waveConnections = {}
local talkConnections = {}
local worldWaveConnections = {}
local playerAttributeProgressConnections = {}
local connectPlayerAttributeProgress

local waveState = Workspace:WaitForChild("WaveState")
local globalWaveNumberValue = waveState:WaitForChild("WaveNumber")
local globalAliveEnemiesValue = waveState:WaitForChild("AliveEnemies")
local globalCountdownActiveValue = waveState:WaitForChild("CountdownActive")

local function getQuestDefinition(index)
	local quests = chapterQuestConfig.Quests
	if index < 1 then
		return quests[1], 1
	end

	if index > #quests then
		return nil, index
	end

	return quests[index], index
end

local function getOrCreateMissionFolder(player)
	local missionFolder = player:FindFirstChild("MissionData")

	if not missionFolder then
		missionFolder = Instance.new("Folder")
		missionFolder.Name = "MissionData"
		missionFolder.Parent = player
	end

	local values = {
		{ ClassName = "IntValue", Name = "MissionIndex", Default = 1 },
		{ ClassName = "StringValue", Name = "MissionId", Default = "" },
		{ ClassName = "StringValue", Name = "MissionTitle", Default = chapterQuestConfig.Quests[1].Title },
		{ ClassName = "IntValue", Name = "MissionProgress", Default = 0 },
		{ ClassName = "IntValue", Name = "MissionTarget", Default = 0 },
		{ ClassName = "BoolValue", Name = "MissionComplete", Default = false },
		{ ClassName = "StringValue", Name = "ChapterId", Default = chapterQuestConfig.ChapterId },
		{ ClassName = "StringValue", Name = "ChapterTitle", Default = chapterQuestConfig.ChapterTitle },
		{ ClassName = "BoolValue", Name = "CampaignComplete", Default = false },
	}

	local created = { Folder = missionFolder }

	for _, valueInfo in ipairs(values) do
		local valueObject = missionFolder:FindFirstChild(valueInfo.Name)
		if not valueObject then
			valueObject = Instance.new(valueInfo.ClassName)
			valueObject.Name = valueInfo.Name
			valueObject.Value = valueInfo.Default
			valueObject.Parent = missionFolder
		end
		created[valueInfo.Name] = valueObject
	end

	return created
end

local function getVillagersSpokenTo(player)
	local spokenTo = player:GetAttribute("VillagersSpokenTo")
	if type(spokenTo) ~= "number" then
		return 0
	end

	return spokenTo
end

local function getNpcInteractionCount(player, attributeName)
	if type(attributeName) ~= "string" or attributeName == "" then
		return 0
	end

	local value = player:GetAttribute(attributeName)
	if type(value) == "number" then
		return value
	end
	if value == true then
		return 1
	end

	return 0
end

local function getAttributeProgressValue(player, definition)
	if not definition then
		return 0
	end

	if definition.CompletionType == "TalkToVillagers" then
		return getVillagersSpokenTo(player)
	end

	if definition.CompletionType == "TalkToNpc" then
		return getNpcInteractionCount(player, definition.NpcAttribute)
	end

	if definition.CompletionType == "PlayerAttributeCount" then
		return getNpcInteractionCount(player, definition.AttributeName)
	end

	return 0
end

local function isTargetWaveCleared(targetWave)
	return globalWaveNumberValue.Value >= targetWave
		and globalAliveEnemiesValue.Value <= 0
		and globalCountdownActiveValue.Value == false
end

local function completeCampaign(player)
	local missionData = getOrCreateMissionFolder(player)
	missionData.CampaignComplete.Value = true
	missionData.MissionId.Value = "ChapterComplete"
	missionData.MissionTitle.Value = chapterQuestConfig.CompletionDescription
	missionData.MissionProgress.Value = 1
	missionData.MissionTarget.Value = 1
	missionData.MissionComplete.Value = true
end

local function applyQuestDefinition(player, definition, missionIndexValue)
	local missionData = getOrCreateMissionFolder(player)
	local waveValue = player:FindFirstChild("Wave")

	missionData.ChapterId.Value = chapterQuestConfig.ChapterId
	missionData.ChapterTitle.Value = chapterQuestConfig.ChapterTitle
	missionData.MissionIndex.Value = missionIndexValue
	missionData.MissionId.Value = definition.Id
	missionData.MissionTitle.Value = definition.Title
	missionData.MissionTarget.Value = definition.Target
	missionData.MissionComplete.Value = false
	missionData.CampaignComplete.Value = false

	if definition.CompletionType == "ReachWave" and waveValue then
		missionData.MissionProgress.Value = math.clamp(waveValue.Value, 0, definition.Target)
	elseif definition.CompletionType == "WaveCleared" then
		missionData.MissionProgress.Value = isTargetWaveCleared(definition.Target) and definition.Target or 0
	elseif definition.CompletionType == "TalkToVillagers"
		or definition.CompletionType == "TalkToNpc"
		or definition.CompletionType == "PlayerAttributeCount" then
		missionData.MissionProgress.Value = math.clamp(getAttributeProgressValue(player, definition), 0, definition.Target)
	else
		missionData.MissionProgress.Value = 0
	end

	connectPlayerAttributeProgress(player)
end

local function advanceToNextMission(player)
	local missionData = getOrCreateMissionFolder(player)
	local nextDefinition, nextIndex = getQuestDefinition(missionData.MissionIndex.Value + 1)

	if not nextDefinition then
		completeCampaign(player)
		return
	end

	applyQuestDefinition(player, nextDefinition, nextIndex)
end

local function resetMissionAfterDelay(player)
	task.delay(MISSION_RESET_DELAY, function()
		if not player.Parent then
			return
		end

		local missionData = getOrCreateMissionFolder(player)
		if missionData.MissionComplete.Value and not missionData.CampaignComplete.Value then
			advanceToNextMission(player)
		end
	end)
end

local function completeMission(player)
	local missionData = getOrCreateMissionFolder(player)
	if missionData.MissionComplete.Value then
		return
	end

	missionData.MissionProgress.Value = missionData.MissionTarget.Value
	missionData.MissionComplete.Value = true

	local leaderstats = player:FindFirstChild("leaderstats")
	local feathers = leaderstats and leaderstats:FindFirstChild("Feathers")
	if feathers then
		feathers.Value += MISSION_FEATHER_REWARD
	end

	resetMissionAfterDelay(player)
end

local function recordKillForPlayer(player, enemyModel)
	local missionData = getOrCreateMissionFolder(player)
	if missionData.MissionComplete.Value or missionData.CampaignComplete.Value then
		return
	end

	local definition = getQuestDefinition(missionData.MissionIndex.Value)
	if not definition then
		return
	end

	local enemyType = enemyModel:GetAttribute("EnemyType") or enemyModel.Name
	local shouldCountKill = false

	if definition.CompletionType == "KillAny" then
		shouldCountKill = true
	elseif definition.CompletionType == "KillEnemyType" then
		shouldCountKill = enemyType == definition.EnemyType
	elseif definition.CompletionType == "KillWithAttack" then
		shouldCountKill = enemyModel:GetAttribute("LastHitAttackName") == definition.AttackName
	elseif definition.CompletionType == "KillAsRooster" then
		shouldCountKill = player:GetAttribute("SelectedRooster") == definition.RoosterName
	end

	if not shouldCountKill then
		return
	end

	missionData.MissionProgress.Value = math.min(missionData.MissionProgress.Value + 1, missionData.MissionTarget.Value)
	if missionData.MissionProgress.Value >= missionData.MissionTarget.Value then
		completeMission(player)
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
	local missionData = getOrCreateMissionFolder(player)
	local waveValue = player:FindFirstChild("Wave")
	if missionData.MissionComplete.Value or missionData.CampaignComplete.Value then
		return
	end

	local definition = getQuestDefinition(missionData.MissionIndex.Value)
	if not definition then
		return
	end

	if definition.CompletionType == "ReachWave" then
		if not waveValue then
			return
		end

		missionData.MissionProgress.Value = math.clamp(waveValue.Value, 0, missionData.MissionTarget.Value)
		if missionData.MissionProgress.Value >= missionData.MissionTarget.Value then
			completeMission(player)
		end
	elseif definition.CompletionType == "WaveCleared" then
		missionData.MissionProgress.Value = isTargetWaveCleared(definition.Target) and missionData.MissionTarget.Value or 0
		if missionData.MissionProgress.Value >= missionData.MissionTarget.Value then
			completeMission(player)
		end
	end
end

local function refreshTalkMissionProgress(player)
	local missionData = getOrCreateMissionFolder(player)
	if missionData.MissionComplete.Value or missionData.CampaignComplete.Value then
		return
	end

	local definition = getQuestDefinition(missionData.MissionIndex.Value)
	if not definition or definition.CompletionType ~= "TalkToVillagers" then
		return
	end

	missionData.MissionProgress.Value = math.clamp(getVillagersSpokenTo(player), 0, missionData.MissionTarget.Value)
	if missionData.MissionProgress.Value >= missionData.MissionTarget.Value then
		completeMission(player)
	end
end

local function disconnectPlayerAttributeProgressConnection(player)
	local connection = playerAttributeProgressConnections[player]
	if connection then
		connection:Disconnect()
		playerAttributeProgressConnections[player] = nil
	end
end

local function refreshPlayerAttributeMissionProgress(player)
	local missionData = getOrCreateMissionFolder(player)
	if missionData.MissionComplete.Value or missionData.CampaignComplete.Value then
		return
	end

	local definition = getQuestDefinition(missionData.MissionIndex.Value)
	if not definition or (definition.CompletionType ~= "TalkToNpc" and definition.CompletionType ~= "PlayerAttributeCount") then
		return
	end

	missionData.MissionProgress.Value = math.clamp(getAttributeProgressValue(player, definition), 0, missionData.MissionTarget.Value)
	if missionData.MissionProgress.Value >= missionData.MissionTarget.Value then
		completeMission(player)
	end
end

connectPlayerAttributeProgress = function(player)
	disconnectPlayerAttributeProgressConnection(player)

	local missionData = getOrCreateMissionFolder(player)
	local definition = getQuestDefinition(missionData.MissionIndex.Value)
	if not definition then
		return
	end

	local attributeName
	if definition.CompletionType == "TalkToNpc" then
		attributeName = definition.NpcAttribute
	elseif definition.CompletionType == "PlayerAttributeCount" then
		attributeName = definition.AttributeName
	end

	if type(attributeName) ~= "string" or attributeName == "" then
		return
	end

	playerAttributeProgressConnections[player] = player:GetAttributeChangedSignal(attributeName):Connect(function()
		refreshPlayerAttributeMissionProgress(player)
	end)
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

local function disconnectWorldWaveConnections(player)
	local connections = worldWaveConnections[player]
	if not connections then
		return
	end

	for _, connection in ipairs(connections) do
		connection:Disconnect()
	end

	worldWaveConnections[player] = nil
end

local function onPlayerAdded(player)
	player:SetAttribute("VillagersSpokenTo", 0)
	if player:GetAttribute("MistClearedCount") == nil then
		player:SetAttribute("MistClearedCount", 0)
	end
	if player:GetAttribute("VillagersRescuedCount") == nil then
		player:SetAttribute("VillagersRescuedCount", 0)
	end
	if player:GetAttribute("TalkedToMasterKaien") == nil then
		player:SetAttribute("TalkedToMasterKaien", 0)
	end

	local missionData = getOrCreateMissionFolder(player)
	local definition, normalizedIndex = getQuestDefinition(missionData.MissionIndex.Value)
	if definition then
		applyQuestDefinition(player, definition, normalizedIndex)
	else
		completeCampaign(player)
	end

	local waveValue = player:WaitForChild("Wave")
	if waveConnections[player] then
		waveConnections[player]:Disconnect()
	end

	waveConnections[player] = waveValue.Changed:Connect(function()
		refreshWaveMissionProgress(player)
	end)

	if talkConnections[player] then
		talkConnections[player]:Disconnect()
	end

	talkConnections[player] = player:GetAttributeChangedSignal("VillagersSpokenTo"):Connect(function()
		refreshTalkMissionProgress(player)
	end)

	connectPlayerAttributeProgress(player)

	disconnectWorldWaveConnections(player)
	worldWaveConnections[player] = {
		globalWaveNumberValue.Changed:Connect(function()
			refreshWaveMissionProgress(player)
		end),
		globalAliveEnemiesValue.Changed:Connect(function()
			refreshWaveMissionProgress(player)
		end),
		globalCountdownActiveValue.Changed:Connect(function()
			refreshWaveMissionProgress(player)
		end),
	}

	refreshWaveMissionProgress(player)
	refreshTalkMissionProgress(player)
	refreshPlayerAttributeMissionProgress(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)

Players.PlayerRemoving:Connect(function(player)
	local waveConnection = waveConnections[player]
	if waveConnection then
		waveConnection:Disconnect()
		waveConnections[player] = nil
	end

	local talkConnection = talkConnections[player]
	if talkConnection then
		talkConnection:Disconnect()
		talkConnections[player] = nil
	end

	disconnectPlayerAttributeProgressConnection(player)
	disconnectWorldWaveConnections(player)
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

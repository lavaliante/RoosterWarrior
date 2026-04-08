local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local WAVE_BREAK_TIME = 4
local OPENING_TALK_REQUIREMENT = 3
local OPENING_STATUS = "Speak to the villagers before the attack begins"
local FINAL_WAVE = 3
local FINAL_WAVE_STATUS = "Suncrest Village is safe for now"
local SIREN_SOUND_ID = "rbxasset://sounds/alarm.wav"
local SIREN_DURATION = 3.5

local waveFolder
local activeEnemyConnections = {}
local aliveEnemies = {}
local waveInProgress = false
local countdownInProgress = false
local introComplete = false
local playerAttributeConnections = {}

local function getOrCreateAlarmBeacon()
	local beacon = Workspace:FindFirstChild("VillageAlarmBeacon")
	if beacon and beacon.Parent then
		return beacon
	end

	local village = Workspace:FindFirstChild("Village")
	local referencePart = village and (village:FindFirstChild("RoosterStatue") or village:FindFirstChild("TownSquare"))
	local position = referencePart and referencePart.Position + Vector3.new(0, 14, 0) or Vector3.new(0, 18, -12)

	beacon = Instance.new("Part")
	beacon.Name = "VillageAlarmBeacon"
	beacon.Anchored = true
	beacon.CanCollide = false
	beacon.CanQuery = false
	beacon.CanTouch = false
	beacon.Transparency = 1
	beacon.Size = Vector3.new(1, 1, 1)
	beacon.Position = position
	beacon.Parent = Workspace

	local sound = Instance.new("Sound")
	sound.Name = "SirenSound"
	sound.SoundId = SIREN_SOUND_ID
	sound.Volume = 0.85
	sound.RollOffMaxDistance = 180
	sound.Parent = beacon

	local light = Instance.new("PointLight")
	light.Name = "SirenLight"
	light.Brightness = 0
	light.Range = 36
	light.Color = Color3.fromRGB(255, 76, 76)
	light.Parent = beacon

	return beacon
end

local function playWaveSiren()
	local beacon = getOrCreateAlarmBeacon()
	local sound = beacon:FindFirstChild("SirenSound")
	local light = beacon:FindFirstChild("SirenLight")

	if sound and sound:IsA("Sound") then
		sound:Stop()
		sound.TimePosition = 0
		sound:Play()
	end

	if light and light:IsA("PointLight") then
		task.spawn(function()
			local pulses = math.floor(SIREN_DURATION / 0.25)
			for pulseIndex = 1, pulses do
				if not light.Parent then
					return
				end

				light.Brightness = pulseIndex % 2 == 0 and 0 or 4.5
				task.wait(0.125)
			end

			if light.Parent then
				light.Brightness = 0
			end
		end)
	end
end

local function getOrCreateWaveFolder()
	if waveFolder and waveFolder.Parent then
		return waveFolder
	end

	waveFolder = Workspace:FindFirstChild("WaveState")

	if not waveFolder then
		waveFolder = Instance.new("Folder")
		waveFolder.Name = "WaveState"
		waveFolder.Parent = Workspace
	end

	local waveNumber = waveFolder:FindFirstChild("WaveNumber")
	if not waveNumber then
		waveNumber = Instance.new("IntValue")
		waveNumber.Name = "WaveNumber"
		waveNumber.Value = 0
		waveNumber.Parent = waveFolder
	end

	local aliveCount = waveFolder:FindFirstChild("AliveEnemies")
	if not aliveCount then
		aliveCount = Instance.new("IntValue")
		aliveCount.Name = "AliveEnemies"
		aliveCount.Value = 0
		aliveCount.Parent = waveFolder
	end

	local targetCount = waveFolder:FindFirstChild("TargetEnemies")
	if not targetCount then
		targetCount = Instance.new("IntValue")
		targetCount.Name = "TargetEnemies"
		targetCount.Value = 0
		targetCount.Parent = waveFolder
	end

	local waveStatus = waveFolder:FindFirstChild("Status")
	if not waveStatus then
		waveStatus = Instance.new("StringValue")
		waveStatus.Name = "Status"
		waveStatus.Value = OPENING_STATUS
		waveStatus.Parent = waveFolder
	end

	local countdownActive = waveFolder:FindFirstChild("CountdownActive")
	if not countdownActive then
		countdownActive = Instance.new("BoolValue")
		countdownActive.Name = "CountdownActive"
		countdownActive.Value = false
		countdownActive.Parent = waveFolder
	end

	local alarmActive = waveFolder:FindFirstChild("AlarmActive")
	if not alarmActive then
		alarmActive = Instance.new("BoolValue")
		alarmActive.Name = "AlarmActive"
		alarmActive.Value = false
		alarmActive.Parent = waveFolder
	end

	return waveFolder
end

local function getWaveValues()
	local folder = getOrCreateWaveFolder()
	return folder.WaveNumber, folder.AliveEnemies, folder.TargetEnemies, folder.Status, folder.CountdownActive, folder.AlarmActive
end

local function countAliveEnemies()
	local count = 0
	for enemyModel in pairs(aliveEnemies) do
		if enemyModel.Parent then
			local humanoid = enemyModel:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				count += 1
			end
		end
	end
	return count
end

local function updateAliveCount()
	local _, aliveCount = getWaveValues()
	aliveCount.Value = countAliveEnemies()
end

local function clearTrackedEnemy(enemyModel)
	aliveEnemies[enemyModel] = nil
	local connectionData = activeEnemyConnections[enemyModel]
	if connectionData then
		for _, connection in ipairs(connectionData) do
			connection:Disconnect()
		end
		activeEnemyConnections[enemyModel] = nil
	end
	updateAliveCount()
end

local function getWaveComposition(waveNumber)
	local composition = {
		RedDemon = 0,
		BlueDemon = 0,
	}

	if waveNumber == 1 then
		composition.RedDemon = 1
	elseif waveNumber == 2 or waveNumber >= 3 then
		composition.RedDemon = 1
		composition.BlueDemon = 1
	end

	local targetEnemies = 0
	for _, count in pairs(composition) do
		targetEnemies += count
	end

	return composition, targetEnemies
end

local function shouldEnemyBeAlive(enemyModel)
	local enemyType = enemyModel:GetAttribute("EnemyType") or enemyModel.Name
	local waveNumber, aliveCount, targetCount = getWaveValues()
	local composition, _ = getWaveComposition(waveNumber.Value)

	if countdownInProgress or not introComplete then
		return false
	end

	local existingTypeCount = 0
	for trackedEnemy in pairs(aliveEnemies) do
		if trackedEnemy ~= enemyModel and trackedEnemy.Parent and (trackedEnemy:GetAttribute("EnemyType") or trackedEnemy.Name) == enemyType then
			local humanoid = trackedEnemy:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				existingTypeCount += 1
			end
		end
	end

	local aliveSlotsRemaining = targetCount.Value - aliveCount.Value
	local desiredForType = composition[enemyType] or 0
	if desiredForType <= 0 or existingTypeCount >= desiredForType then
		return false
	end

	return aliveSlotsRemaining > 0
end

local function beginWave(waveToStart)
	local waveNumber, aliveCount, targetCount, waveStatus, countdownActive, alarmActive = getWaveValues()
	local _, targetEnemyCount = getWaveComposition(waveToStart)

	introComplete = true
	waveInProgress = true
	countdownInProgress = false
	countdownActive.Value = false
	alarmActive.Value = true
	waveNumber.Value = waveToStart
	targetCount.Value = targetEnemyCount
	aliveCount.Value = countAliveEnemies()
if waveToStart == 1 then
	waveStatus.Value = "Alarm! Demons are attacking the farms"
else
	waveStatus.Value = "Wave " .. tostring(waveToStart)
end
	playWaveSiren()
end

local function completeFinalWave()
	local waveNumber, aliveCount, targetCount, waveStatus, countdownActive, alarmActive = getWaveValues()
	waveInProgress = false
	countdownInProgress = false
	countdownActive.Value = false
	alarmActive.Value = false
	waveNumber.Value = FINAL_WAVE
	aliveCount.Value = 0
	targetCount.Value = 0
	waveStatus.Value = FINAL_WAVE_STATUS
end

local function tryStartOpeningWave()
	if introComplete or waveInProgress or countdownInProgress then
		return
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if (player:GetAttribute("VillagersSpokenTo") or 0) >= OPENING_TALK_REQUIREMENT then
			beginWave(1)
			return
		end
	end

	local _, _, _, waveStatus, _, alarmActive = getWaveValues()
	alarmActive.Value = false
	waveStatus.Value = OPENING_STATUS
end

local function scheduleNextWave()
	local waveNumber, aliveCount, _, waveStatus, countdownActive, alarmActive = getWaveValues()
	if aliveCount.Value > 0 or not waveInProgress or countdownInProgress then
		return
	end

	alarmActive.Value = false

	if waveNumber.Value >= FINAL_WAVE then
		completeFinalWave()
		return
	end

	waveInProgress = false
	countdownInProgress = true
	countdownActive.Value = true

	task.spawn(function()
		for secondsRemaining = WAVE_BREAK_TIME, 1, -1 do
			local currentAliveCount = select(2, getWaveValues())
			if currentAliveCount.Value > 0 then
				countdownInProgress = false
				countdownActive.Value = false
				return
			end

			waveStatus.Value = "Next wave in " .. tostring(secondsRemaining) .. "..."
			task.wait(1)
		end

		local currentWaveNumber, currentAliveCount = getWaveValues()
		if currentAliveCount.Value == 0 then
			beginWave(math.min(FINAL_WAVE, currentWaveNumber.Value + 1))
		else
			countdownInProgress = false
			countdownActive.Value = false
			local latestWaveNumber, _, _, currentWaveStatus = getWaveValues()
			currentWaveStatus.Value = "Wave " .. tostring(latestWaveNumber.Value)
		end
	end)
end

local function trackEnemy(enemyModel)
	if activeEnemyConnections[enemyModel] then
		return
	end

	local humanoid = enemyModel:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	if not shouldEnemyBeAlive(enemyModel) then
		task.defer(function()
			if enemyModel.Parent then
				enemyModel:Destroy()
			end
		end)
		return
	end

	aliveEnemies[enemyModel] = true
	updateAliveCount()

	local diedConnection = humanoid.Died:Connect(function()
		clearTrackedEnemy(enemyModel)
		scheduleNextWave()
	end)

	local destroyingConnection = enemyModel.Destroying:Connect(function()
		clearTrackedEnemy(enemyModel)
	end)

	activeEnemyConnections[enemyModel] = { diedConnection, destroyingConnection }
end

local function onWorkspaceChildAdded(instance)
	if instance:IsA("Model") and instance:GetAttribute("IsDemonEnemy") then
		task.defer(trackEnemy, instance)
	end
end

local function connectOpeningTrigger(player)
	if playerAttributeConnections[player] then
		playerAttributeConnections[player]:Disconnect()
	end

	playerAttributeConnections[player] = player:GetAttributeChangedSignal("VillagersSpokenTo"):Connect(function()
		tryStartOpeningWave()
	end)
end

local function onPlayerAdded(player)
	local waveValue = player:FindFirstChild("Wave")
	if not waveValue then
		waveValue = Instance.new("IntValue")
		waveValue.Name = "Wave"
		waveValue.Value = 0
		waveValue.Parent = player
	end

	local waveNumber, _, _, waveStatus, _, alarmActive = getWaveValues()
	waveValue.Value = math.max(0, waveNumber.Value)

	waveNumber.Changed:Connect(function()
		if player.Parent then
			waveValue.Value = math.max(0, waveNumber.Value)
		end
	end)

	connectOpeningTrigger(player)

	if not introComplete then
		alarmActive.Value = false
		waveStatus.Value = OPENING_STATUS
		tryStartOpeningWave()
	end
end

getOrCreateWaveFolder()
getOrCreateAlarmBeacon()

for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(function(player)
	local connection = playerAttributeConnections[player]
	if connection then
		connection:Disconnect()
		playerAttributeConnections[player] = nil
	end
end)
Workspace.ChildAdded:Connect(onWorkspaceChildAdded)

for _, instance in ipairs(Workspace:GetChildren()) do
	if instance:IsA("Model") and instance:GetAttribute("IsDemonEnemy") then
		trackEnemy(instance)
	end
end



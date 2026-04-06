local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local WAVE_BREAK_TIME = 4

local waveFolder
local activeEnemyConnections = {}
local aliveEnemies = {}
local waveInProgress = false
local countdownInProgress = false

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
		waveStatus.Value = "Preparing"
		waveStatus.Parent = waveFolder
	end

	local countdownActive = waveFolder:FindFirstChild("CountdownActive")

	if not countdownActive then
		countdownActive = Instance.new("BoolValue")
		countdownActive.Name = "CountdownActive"
		countdownActive.Value = false
		countdownActive.Parent = waveFolder
	end

	return waveFolder
end

local function getWaveValues()
	local folder = getOrCreateWaveFolder()
	return folder.WaveNumber, folder.AliveEnemies, folder.TargetEnemies, folder.Status, folder.CountdownActive
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
		GreenDemon = 0,
		PurpleDemon = 0,
		WhiteDemon = 0,
	}

	if waveNumber >= 1 then
		composition.RedDemon = 1
	end

	if waveNumber >= 2 then
		composition.BlueDemon = 1
	end

	if waveNumber >= 3 then
		composition.GreenDemon = 1
	end

	if waveNumber >= 4 then
		composition.PurpleDemon = 1
	end

	if waveNumber >= 5 then
		composition.WhiteDemon = 1
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

	if countdownInProgress then
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

	if desiredForType <= 0 then
		return false
	end

	if existingTypeCount >= desiredForType then
		return false
	end

	return aliveSlotsRemaining > 0
end

local function beginWave(waveToStart)
	local waveNumber, aliveCount, targetCount, waveStatus, countdownActive = getWaveValues()
	local _, targetEnemyCount = getWaveComposition(waveToStart)

	waveInProgress = true
	countdownInProgress = false
	countdownActive.Value = false
	waveNumber.Value = waveToStart
	targetCount.Value = targetEnemyCount
	aliveCount.Value = countAliveEnemies()
	waveStatus.Value = "Wave " .. tostring(waveToStart)
end

local function scheduleNextWave()
	local waveNumber, aliveCount, _, waveStatus, countdownActive = getWaveValues()

	if aliveCount.Value > 0 or not waveInProgress or countdownInProgress then
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

		local currentAliveCount = select(2, getWaveValues())
		if currentAliveCount.Value == 0 then
			beginWave(waveNumber.Value + 1)
		else
			countdownInProgress = false
			countdownActive.Value = false
			local currentWaveNumber, _, _, currentWaveStatus = getWaveValues()
			currentWaveStatus.Value = "Wave " .. tostring(currentWaveNumber.Value)
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

local function onPlayerAdded(player)
	local waveValue = player:FindFirstChild("Wave")

	if not waveValue then
		waveValue = Instance.new("IntValue")
		waveValue.Name = "Wave"
		waveValue.Value = 1
		waveValue.Parent = player
	end

	local waveNumber = getOrCreateWaveFolder():WaitForChild("WaveNumber")
	waveValue.Value = math.max(1, waveNumber.Value)

	waveNumber.Changed:Connect(function()
		if player.Parent then
			waveValue.Value = math.max(1, waveNumber.Value)
		end
	end)
end

getOrCreateWaveFolder()

for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Workspace.ChildAdded:Connect(onWorkspaceChildAdded)

beginWave(1)

for _, instance in ipairs(Workspace:GetChildren()) do
	if instance:IsA("Model") and instance:GetAttribute("IsDemonEnemy") then
		trackEnemy(instance)
	end
end

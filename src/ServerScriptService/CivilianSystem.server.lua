local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TARGET_CIVILIANS = 8
local CIVILIAN_SPEED = 9
local CIVILIAN_FLEE_SPEED = 14
local RESPAWN_CHECK_DELAY = 3
local GROUND_RAY_HEIGHT = 24
local ROOT_GROUND_OFFSET = 1.35
local DEMON_FEAR_RANGE = 42
local WAYPOINT_REACHED_DISTANCE = 4
local MOVE_REPATH_DELAY = 0.15
local DEMON_SCAN_INTERVAL = 0.2
local CIVILIAN_ANIMATION_INTERVAL = 1 / 20
local TALK_DISTANCE = 10
local DIALOGUE_REMOTE_NAME = "StoryDialogue"
local TUTORIAL_PROGRESS_REMOTE_NAME = "TutorialProgress"

local CIVILIAN_NAMES = {
	"Mara",
	"Timo",
	"Lena",
	"Paco",
	"Nina",
	"Rafi",
	"Suri",
	"Enzo",
	"Kira",
	"Omar",
}

local FIRST_TALK_LINES = {
	"The mist keeps creeping closer to the fields. Something is wrong out there.",
	"My chickens would not settle last night. They kept staring at the forest.",
	"The elders whisper about demons, but I thought those were only stories.",
	"Please be careful near the farms. We heard screaming after sunset.",
	"Black rot spread across the wheat in a single night. That is no natural blight.",
	"If the old warrior legends are real, we may need one now more than ever.",
}

local REPEAT_TALK_LINES = {
	"Stay sharp. The village is counting on you.",
	"The roads are not safe after dark anymore.",
	"If you head east, watch the tree line.",
}

local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local storyDialogueRemote = remotesFolder:FindFirstChild(DIALOGUE_REMOTE_NAME)

if not storyDialogueRemote then
	storyDialogueRemote = Instance.new("RemoteEvent")
	storyDialogueRemote.Name = DIALOGUE_REMOTE_NAME
	storyDialogueRemote.Parent = remotesFolder
end

local tutorialProgressRemote = remotesFolder:FindFirstChild(TUTORIAL_PROGRESS_REMOTE_NAME)

if not tutorialProgressRemote then
	tutorialProgressRemote = Instance.new("RemoteEvent")
	tutorialProgressRemote.Name = TUTORIAL_PROGRESS_REMOTE_NAME
	tutorialProgressRemote.Parent = remotesFolder
end

local stateFolder = Workspace:FindFirstChild("CivilianState")

if stateFolder then
	stateFolder:Destroy()
end

stateFolder = Instance.new("Folder")
stateFolder.Name = "CivilianState"
stateFolder.Parent = Workspace

local civiliansFolder = Instance.new("Folder")
civiliansFolder.Name = "Civilians"
civiliansFolder.Parent = stateFolder

local existingProtectionFolder = Workspace:FindFirstChild("CivilianProtectionState")

if existingProtectionFolder then
	existingProtectionFolder:Destroy()
end

local protectionFolder = Instance.new("Folder")
protectionFolder.Name = "CivilianProtectionState"
protectionFolder.Parent = Workspace

local totalCiviliansValue = Instance.new("IntValue")
totalCiviliansValue.Name = "TotalCivilians"
totalCiviliansValue.Value = TARGET_CIVILIANS
totalCiviliansValue.Parent = protectionFolder

local activeCiviliansValue = Instance.new("IntValue")
activeCiviliansValue.Name = "ActiveCivilians"
activeCiviliansValue.Value = 0
activeCiviliansValue.Parent = protectionFolder

local lostThisWaveValue = Instance.new("IntValue")
lostThisWaveValue.Name = "LostThisWave"
lostThisWaveValue.Value = 0
lostThisWaveValue.Parent = protectionFolder

local maxLossesValue = Instance.new("IntValue")
maxLossesValue.Name = "MaxLosses"
maxLossesValue.Value = TARGET_CIVILIANS
maxLossesValue.Parent = protectionFolder

local protectionStatusValue = Instance.new("StringValue")
protectionStatusValue.Name = "Status"
protectionStatusValue.Value = "Protect the village"
protectionStatusValue.Parent = protectionFolder

local village = Workspace:WaitForChild("Village")
local waypointFolder = village:WaitForChild("CivilianWaypoints")
local spawnFolder = village:WaitForChild("CivilianSpawnPoints")
local waveState = Workspace:WaitForChild("WaveState")
local waveNumberValue = waveState:WaitForChild("WaveNumber")
local waveStatusValue = waveState:WaitForChild("Status")
local countdownActiveValue = waveState:WaitForChild("CountdownActive")
local FALLBACK_WAYPOINT_POSITIONS = {
	Vector3.new(-24, 3, -12),
	Vector3.new(0, 3, -12),
	Vector3.new(24, 3, -12),
	Vector3.new(-24, 3, 12),
	Vector3.new(0, 3, 12),
	Vector3.new(24, 3, 12),
	Vector3.new(-42, 3, -12),
	Vector3.new(42, 3, -12),
	Vector3.new(-12, 3, -42),
	Vector3.new(12, 3, -42),
}
local FALLBACK_SPAWN_POSITIONS = {
	Vector3.new(-28, 3, -8),
	Vector3.new(-10, 3, -26),
	Vector3.new(10, 3, -26),
	Vector3.new(28, 3, -8),
	Vector3.new(-28, 3, 8),
	Vector3.new(-10, 3, 20),
	Vector3.new(10, 3, 20),
	Vector3.new(28, 3, 8),
}

local function getMarkers(folder)
	local markers = {}

	for _, child in ipairs(folder:GetChildren()) do
		if child:IsA("BasePart") then
			table.insert(markers, child)
		end
	end

	return markers
end

local civilianRigData = {}
local countActiveCivilians
local overrunInProgress = false
local lastPreparedWave = 0
local suppressLossTracking = false
local suppressProtectionChecks = false
local cachedDemonRoots = {}
local demonScanElapsed = 0
local animationElapsed = 0
local nextCivilianId = 1
local villagerConversationsByPlayer = {}
local completedTutorialPlayers = {}
local villagersReleased = false
local villagersInitialized = false

local function getWaypoints()
	local waypoints = getMarkers(waypointFolder)

	if #waypoints > 0 then
		return waypoints
	end

	return FALLBACK_WAYPOINT_POSITIONS
end

local function getSpawnMarkers()
	local spawnMarkers = getMarkers(spawnFolder)

	if #spawnMarkers > 0 then
		return spawnMarkers
	end

	return FALLBACK_SPAWN_POSITIONS
end

local function getGroundedPosition(position)
	local rayOrigin = position + Vector3.new(0, GROUND_RAY_HEIGHT, 0)
	local rayDirection = Vector3.new(0, -GROUND_RAY_HEIGHT * 2, 0)
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = { civiliansFolder }

	local rayResult = Workspace:Raycast(rayOrigin, rayDirection, rayParams)

	if rayResult then
		return Vector3.new(position.X, rayResult.Position.Y + ROOT_GROUND_OFFSET, position.Z)
	end

	return position
end

local function createBodyPart(model, rootPart, name, size, offset, color)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Color = color
	part.Material = Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.CanCollide = true
	part.Massless = true
	part.CFrame = rootPart.CFrame * CFrame.new(offset)
	part.Parent = model

	local weld = Instance.new("Weld")
	weld.Name = name .. "Joint"
	weld.Part0 = rootPart
	weld.Part1 = part
	weld.C0 = rootPart.CFrame:ToObjectSpace(part.CFrame)
	weld.Parent = rootPart

	return part, weld
end

local function getConversationState(player)
	local userId = player.UserId
	local conversationState = villagerConversationsByPlayer[userId]

	if not conversationState then
		conversationState = {}
		villagerConversationsByPlayer[userId] = conversationState
	end

	return conversationState
end

local function getRandomLine(lines)
	return lines[math.random(1, #lines)]
end

local function registerConversation(player, civilianModel)
	if not player or not player.Parent or civilianModel:GetAttribute("IsPossessed") then
		return
	end

	local civilianId = civilianModel:GetAttribute("CivilianId")
	if type(civilianId) ~= "number" then
		return
	end

	local conversationState = getConversationState(player)
	local firstConversation = conversationState[civilianId] ~= true

	if firstConversation then
		conversationState[civilianId] = true
		local newCount = 0
		for _ in pairs(conversationState) do
			newCount += 1
		end
		player:SetAttribute("VillagersSpokenTo", newCount)
	end

	storyDialogueRemote:FireClient(player, {
		Speaker = civilianModel.Name,
		Text = firstConversation and getRandomLine(FIRST_TALK_LINES) or getRandomLine(REPEAT_TALK_LINES),
	})
end

local function attachTalkPrompt(targetPart, civilianModel)
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "TalkPrompt"
	prompt.ActionText = "Talk"
	prompt.ObjectText = civilianModel.Name
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = TALK_DISTANCE
	prompt.RequiresLineOfSight = false
	prompt.Style = Enum.ProximityPromptStyle.Default
	prompt.Parent = targetPart

	prompt.Triggered:Connect(function(player)
		registerConversation(player, civilianModel)
	end)
end

local function createCivilianModel(spawnPosition)
	local model = Instance.new("Model")
	model.Name = CIVILIAN_NAMES[math.random(1, #CIVILIAN_NAMES)]
	model:SetAttribute("IsCivilian", true)
	model:SetAttribute("IsPossessed", false)
	model:SetAttribute("CivilianId", nextCivilianId)
	nextCivilianId += 1

	local groundedSpawn = getGroundedPosition(spawnPosition)

	local rootPart = Instance.new("Part")
	rootPart.Name = "HumanoidRootPart"
	rootPart.Size = Vector3.new(2, 2, 1)
	rootPart.Transparency = 1
	rootPart.CanCollide = false
	rootPart.CFrame = CFrame.new(groundedSpawn)
	rootPart.Parent = model

	local shirtColor = Color3.fromRGB(math.random(80, 220), math.random(80, 220), math.random(80, 220))
	local pantsColor = Color3.fromRGB(math.random(50, 120), math.random(50, 120), math.random(50, 120))
	local skinColor = Color3.fromRGB(236, 194, 152)

	local torsoPart, torsoJoint = createBodyPart(model, rootPart, "Torso", Vector3.new(2.2, 2.4, 1.3), Vector3.new(0, 1.8, 0), shirtColor)
	local _, headJoint = createBodyPart(model, rootPart, "Head", Vector3.new(1.8, 1.8, 1.8), Vector3.new(0, 3.9, 0), skinColor)
	local _, leftArmJoint = createBodyPart(model, rootPart, "LeftArm", Vector3.new(0.8, 2.2, 0.8), Vector3.new(-1.45, 1.8, 0), shirtColor)
	local _, rightArmJoint = createBodyPart(model, rootPart, "RightArm", Vector3.new(0.8, 2.2, 0.8), Vector3.new(1.45, 1.8, 0), shirtColor)
	local _, leftLegJoint = createBodyPart(model, rootPart, "LeftLeg", Vector3.new(0.9, 2.5, 0.9), Vector3.new(-0.45, -0.2, 0), pantsColor)
	local _, rightLegJoint = createBodyPart(model, rootPart, "RightLeg", Vector3.new(0.9, 2.5, 0.9), Vector3.new(0.45, -0.2, 0), pantsColor)

	attachTalkPrompt(torsoPart, model)

	local humanoid = Instance.new("Humanoid")
	humanoid.Name = "Humanoid"
	humanoid.MaxHealth = 100
	humanoid.Health = 100
	humanoid.WalkSpeed = CIVILIAN_SPEED
	humanoid.HipHeight = 0
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
	humanoid.DisplayName = model.Name
	humanoid.Parent = model

	model.PrimaryPart = rootPart
	model.Parent = civiliansFolder

	civilianRigData[model] = {
		RootPart = rootPart,
		Humanoid = humanoid,
		Joints = {
			Torso = torsoJoint,
			Head = headJoint,
			LeftArm = leftArmJoint,
			RightArm = rightArmJoint,
			LeftLeg = leftLegJoint,
			RightLeg = rightLegJoint,
		},
		DefaultC0 = {
			Torso = torsoJoint.C0,
			Head = headJoint.C0,
			LeftArm = leftArmJoint.C0,
			RightArm = rightArmJoint.C0,
			LeftLeg = leftLegJoint.C0,
			RightLeg = rightLegJoint.C0,
		},
		TimeOffset = math.random() * math.pi * 2,
	}

	model.Destroying:Connect(function()
		if model:GetAttribute("IsPossessed") and not suppressLossTracking then
			lostThisWaveValue.Value += 1
		end

		civilianRigData[model] = nil
		task.defer(function()
			activeCiviliansValue.Value = countActiveCivilians()
		end)
	end)

	return model
end

local function pickRandomWaypoint()
	local waypoints = getWaypoints()

	if #waypoints == 0 then
		return nil
	end

	return waypoints[math.random(1, #waypoints)]
end

local function getNearestDemon(rootPosition)
	local nearestRoot
	local nearestDistance = DEMON_FEAR_RANGE

	for _, demonRoot in ipairs(cachedDemonRoots) do
		if demonRoot and demonRoot.Parent then
			local distance = (demonRoot.Position - rootPosition).Magnitude

			if distance < nearestDistance then
				nearestDistance = distance
				nearestRoot = demonRoot
			end
		end
	end

	return nearestRoot, nearestDistance
end

local function refreshCachedDemonRoots()
	table.clear(cachedDemonRoots)

	for _, candidate in ipairs(Workspace:GetChildren()) do
		if candidate:IsA("Model") and candidate:GetAttribute("IsDemonEnemy") then
			local humanoid = candidate:FindFirstChildOfClass("Humanoid")
			local demonRoot = candidate.PrimaryPart or candidate:FindFirstChild("HumanoidRootPart")

			if humanoid and humanoid.Health > 0 and demonRoot then
				table.insert(cachedDemonRoots, demonRoot)
			end
		end
	end
end

local function pickFleeWaypoint(rootPosition, demonPosition)
	local waypoints = getWaypoints()
	local bestWaypoint
	local bestScore = -math.huge

	for _, waypoint in ipairs(waypoints) do
		local waypointPosition = typeof(waypoint) == "Vector3" and waypoint or waypoint.Position
		local groundedWaypoint = getGroundedPosition(waypointPosition)
		local distanceFromDemon = (groundedWaypoint - demonPosition).Magnitude
		local distanceFromCivilian = (groundedWaypoint - rootPosition).Magnitude
		local score = distanceFromDemon - distanceFromCivilian * 0.35

		if score > bestScore then
			bestScore = score
			bestWaypoint = groundedWaypoint
		end
	end

	return bestWaypoint
end

local function moveCivilianTo(humanoid, rootPart, destination, shouldAbort)
	humanoid:MoveTo(destination)
	local startedAt = os.clock()

	while rootPart.Parent and humanoid.Parent do
		if shouldAbort and shouldAbort() then
			return false
		end

		local remainingDistance = (destination - rootPart.Position).Magnitude
		if remainingDistance <= WAYPOINT_REACHED_DISTANCE then
			return true
		end

		if os.clock() - startedAt > 3.5 then
			return false
		end

		task.wait(MOVE_REPATH_DELAY)
	end

	return false
end

local function startCivilianWander(civilianModel)
	task.spawn(function()
		local humanoid = civilianModel:WaitForChild("Humanoid")
		local rootPart = civilianModel:WaitForChild("HumanoidRootPart")

		while civilianModel.Parent == civiliansFolder and not civilianModel:GetAttribute("IsPossessed") do
			local nearestDemonRoot = getNearestDemon(rootPart.Position)

			if nearestDemonRoot then
				humanoid.WalkSpeed = CIVILIAN_FLEE_SPEED
				civilianModel:SetAttribute("IsFleeing", true)

				local fleeTarget = pickFleeWaypoint(rootPart.Position, nearestDemonRoot.Position)

				if fleeTarget then
					moveCivilianTo(humanoid, rootPart, fleeTarget, function()
						local activeDemonRoot = getNearestDemon(rootPart.Position)
						return not activeDemonRoot or civilianModel:GetAttribute("IsPossessed")
					end)
				else
					task.wait(0.2)
				end
			else
				humanoid.WalkSpeed = CIVILIAN_SPEED
				civilianModel:SetAttribute("IsFleeing", false)
				local waypoint = pickRandomWaypoint()

				if waypoint then
					local waypointPosition = typeof(waypoint) == "Vector3" and waypoint or waypoint.Position
					moveCivilianTo(humanoid, rootPart, getGroundedPosition(waypointPosition), function()
						local activeDemonRoot = getNearestDemon(rootPart.Position)
						return activeDemonRoot ~= nil or civilianModel:GetAttribute("IsPossessed")
					end)
				else
					task.wait(1)
				end

				task.wait(math.random(1, 2))
			end
		end
	end)
end

countActiveCivilians = function()
	local count = 0

	for _, civilian in ipairs(civiliansFolder:GetChildren()) do
		if civilian:IsA("Model") and civilian:GetAttribute("IsCivilian") and not civilian:GetAttribute("IsPossessed") then
			count += 1
		end
	end

	return count
end

local function areVillagersUnlocked()
	return villagersReleased
end

local function spawnCivilian()
	if not areVillagersUnlocked() then
		return
	end

	local spawnMarkers = getSpawnMarkers()

	if #spawnMarkers == 0 then
		return
	end

	local spawnMarker = spawnMarkers[math.random(1, #spawnMarkers)]
	local spawnPosition = typeof(spawnMarker) == "Vector3" and spawnMarker or spawnMarker.Position
	local civilian = createCivilianModel(spawnPosition)
	startCivilianWander(civilian)
	activeCiviliansValue.Value = countActiveCivilians()
end

local function clearCivilians()
	suppressLossTracking = true
	suppressProtectionChecks = true

	for _, civilian in ipairs(civiliansFolder:GetChildren()) do
		if civilian:GetAttribute("IsPossessed") then
			civilian:SetAttribute("IsPossessed", false)
		end

		civilian:Destroy()
	end

	suppressLossTracking = false
	activeCiviliansValue.Value = 0
end

local function repopulateCivilians(forceReset)
	if forceReset then
		clearCivilians()
	elseif countActiveCivilians() > 0 then
		activeCiviliansValue.Value = countActiveCivilians()
		suppressProtectionChecks = false
		return
	end

	if not areVillagersUnlocked() then
		activeCiviliansValue.Value = 0
		suppressProtectionChecks = true
		return
	end

	clearCivilians()

	for _ = 1, TARGET_CIVILIANS do
		spawnCivilian()
	end

	activeCiviliansValue.Value = countActiveCivilians()
	suppressProtectionChecks = false
end

local function prepareWaveProtection(waveNumber, forceRepopulate)
	if overrunInProgress and waveNumber == lastPreparedWave then
		return
	end

	lastPreparedWave = waveNumber
	lostThisWaveValue.Value = 0

	if not areVillagersUnlocked() then
		protectionStatusValue.Value = "Finish the combat tutorial"
		repopulateCivilians(forceRepopulate == true)
		return
	end

	protectionStatusValue.Value = "Protect the village"
	if forceRepopulate == true or not villagersInitialized then
		villagersInitialized = true
		repopulateCivilians(true)
	else
		activeCiviliansValue.Value = countActiveCivilians()
		suppressProtectionChecks = false
	end
end

local function releaseVillagersIfReady()
	if villagersReleased then
		return
	end

	local players = Players:GetPlayers()

	if #players == 0 then
		return
	end

	for _, player in ipairs(players) do
		if completedTutorialPlayers[player.UserId] ~= true then
			return
		end
	end

	villagersReleased = true
	prepareWaveProtection(math.max(1, waveNumberValue.Value), true)
end

local function triggerVillageOverrun()
	if overrunInProgress then
		return
	end

	overrunInProgress = true
	protectionStatusValue.Value = "Village overrun - regrouping"
	waveStatusValue.Value = "Retrying wave " .. tostring(math.max(1, waveNumberValue.Value)) .. "..."
	countdownActiveValue.Value = true

	task.spawn(function()
		for _, instance in ipairs(Workspace:GetChildren()) do
			if instance:IsA("Model") and instance:GetAttribute("IsDemonEnemy") then
				instance:Destroy()
			end
		end

		clearCivilians()
		task.wait(2.5)
		overrunInProgress = false
		prepareWaveProtection(math.max(1, waveNumberValue.Value), true)
		waveStatusValue.Value = "Wave " .. tostring(math.max(1, waveNumberValue.Value))
		countdownActiveValue.Value = false
	end)
end

activeCiviliansValue.Value = countActiveCivilians()

task.spawn(function()
	while true do
		while not overrunInProgress and areVillagersUnlocked() and waveNumberValue.Value <= 0 and countActiveCivilians() < TARGET_CIVILIANS do
			spawnCivilian()
			task.wait(0.2)
		end

		task.wait(RESPAWN_CHECK_DELAY)
	end
end)

waveNumberValue.Changed:Connect(function()
	local currentWave = math.max(1, waveNumberValue.Value)

	if currentWave ~= lastPreparedWave then
		prepareWaveProtection(currentWave)
	end
end)

lostThisWaveValue.Changed:Connect(function()
	if overrunInProgress or suppressProtectionChecks then
		return
	end

	local civiliansRemaining = activeCiviliansValue.Value

	if civiliansRemaining <= 0 then
		triggerVillageOverrun()
	elseif civiliansRemaining == 1 then
		protectionStatusValue.Value = "Protect the village - last civilian standing"
	else
		protectionStatusValue.Value = "Protect the village - " .. tostring(civiliansRemaining) .. " civilians remaining"
	end
end)

activeCiviliansValue.Changed:Connect(function()
	if overrunInProgress or suppressProtectionChecks then
		return
	end

	local civiliansRemaining = activeCiviliansValue.Value

	if civiliansRemaining <= 0 then
		triggerVillageOverrun()
	elseif civiliansRemaining == 1 then
		protectionStatusValue.Value = "Protect the village - last civilian standing"
	else
		protectionStatusValue.Value = "Protect the village - " .. tostring(civiliansRemaining) .. " civilians remaining"
	end
end)

tutorialProgressRemote.OnServerEvent:Connect(function(player, tutorialId)
	if tutorialId ~= "CombatTutorialComplete" then
		return
	end

	completedTutorialPlayers[player.UserId] = true
	player:SetAttribute("CombatTutorialComplete", true)
	releaseVillagersIfReady()
end)

Players.PlayerAdded:Connect(function(player)
	player:SetAttribute("CombatTutorialComplete", completedTutorialPlayers[player.UserId] == true)
end)

Players.PlayerRemoving:Connect(function(player)
	villagerConversationsByPlayer[player.UserId] = nil
	completedTutorialPlayers[player.UserId] = nil
end)

prepareWaveProtection(math.max(1, waveNumberValue.Value), true)
releaseVillagersIfReady()

task.delay(1, function()
	if not overrunInProgress and countActiveCivilians() <= 0 then
		prepareWaveProtection(math.max(1, waveNumberValue.Value), true)
	end
end)

RunService.Heartbeat:Connect(function(deltaTime)
	demonScanElapsed += deltaTime
	if demonScanElapsed >= DEMON_SCAN_INTERVAL then
		demonScanElapsed = 0
		refreshCachedDemonRoots()
	end

	animationElapsed += deltaTime
	if animationElapsed < CIVILIAN_ANIMATION_INTERVAL then
		return
	end

	animationElapsed = 0
	local timeNow = os.clock() * 7

	for civilianModel, rigData in pairs(civilianRigData) do
		local humanoid = rigData.Humanoid
		local rootPart = rigData.RootPart

		if not civilianModel.Parent or not humanoid.Parent or humanoid.Health <= 0 or not rootPart.Parent then
			civilianRigData[civilianModel] = nil
			continue
		end

		local moveAlpha = humanoid.MoveDirection.Magnitude > 0.05 and 1 or 0
		local phase = timeNow + rigData.TimeOffset
		local legSwing = math.sin(phase) * math.rad(26) * moveAlpha
		local armSwing = math.sin(phase) * math.rad(22) * moveAlpha
		local bob = math.abs(math.sin(phase)) * 0.08 * moveAlpha

		rigData.Joints.Torso.C0 = rigData.DefaultC0.Torso * CFrame.new(0, bob, 0)
		rigData.Joints.Head.C0 = rigData.DefaultC0.Head * CFrame.Angles(-legSwing * 0.08, 0, 0)
		rigData.Joints.LeftArm.C0 = rigData.DefaultC0.LeftArm * CFrame.Angles(-armSwing, 0, 0)
		rigData.Joints.RightArm.C0 = rigData.DefaultC0.RightArm * CFrame.Angles(armSwing, 0, 0)
		rigData.Joints.LeftLeg.C0 = rigData.DefaultC0.LeftLeg * CFrame.Angles(legSwing, 0, 0)
		rigData.Joints.RightLeg.C0 = rigData.DefaultC0.RightLeg * CFrame.Angles(-legSwing, 0, 0)
	end
end)








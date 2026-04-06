local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local TARGET_CIVILIANS = 8
local MAX_CIVILIAN_LOSSES_PER_WAVE = 3
local CIVILIAN_SPEED = 9
local CIVILIAN_FLEE_SPEED = 14
local RESPAWN_CHECK_DELAY = 3
local GROUND_RAY_HEIGHT = 24
local ROOT_GROUND_OFFSET = 1.35
local DEMON_FEAR_RANGE = 42
local WAYPOINT_REACHED_DISTANCE = 4
local MOVE_REPATH_DELAY = 0.15

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
maxLossesValue.Value = MAX_CIVILIAN_LOSSES_PER_WAVE
maxLossesValue.Parent = protectionFolder

local protectionStatusValue = Instance.new("StringValue")
protectionStatusValue.Name = "Status"
protectionStatusValue.Value = "Protect the village"
protectionStatusValue.Parent = protectionFolder

local village = Workspace:WaitForChild("Village")
local waypointFolder = village:WaitForChild("CivilianWaypoints")
local spawnFolder = village:WaitForChild("CivilianSpawnPoints")

local function getMarkers(folder)
	local markers = {}

	for _, child in ipairs(folder:GetChildren()) do
		if child:IsA("BasePart") then
			table.insert(markers, child)
		end
	end

	return markers
end

local waypoints = getMarkers(waypointFolder)
local spawnMarkers = getMarkers(spawnFolder)
local civilianRigData = {}
local countActiveCivilians

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

local function createCivilianModel(spawnPosition)
	local model = Instance.new("Model")
	model.Name = CIVILIAN_NAMES[math.random(1, #CIVILIAN_NAMES)]
	model:SetAttribute("IsCivilian", true)
	model:SetAttribute("IsPossessed", false)

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

	local _, torsoJoint = createBodyPart(model, rootPart, "Torso", Vector3.new(2.2, 2.4, 1.3), Vector3.new(0, 1.8, 0), shirtColor)
	local _, headJoint = createBodyPart(model, rootPart, "Head", Vector3.new(1.8, 1.8, 1.8), Vector3.new(0, 3.9, 0), skinColor)
	local _, leftArmJoint = createBodyPart(model, rootPart, "LeftArm", Vector3.new(0.8, 2.2, 0.8), Vector3.new(-1.45, 1.8, 0), shirtColor)
	local _, rightArmJoint = createBodyPart(model, rootPart, "RightArm", Vector3.new(0.8, 2.2, 0.8), Vector3.new(1.45, 1.8, 0), shirtColor)
	local _, leftLegJoint = createBodyPart(model, rootPart, "LeftLeg", Vector3.new(0.9, 2.5, 0.9), Vector3.new(-0.45, -0.2, 0), pantsColor)
	local _, rightLegJoint = createBodyPart(model, rootPart, "RightLeg", Vector3.new(0.9, 2.5, 0.9), Vector3.new(0.45, -0.2, 0), pantsColor)

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
		if model:GetAttribute("IsPossessed") then
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
	if #waypoints == 0 then
		return nil
	end

	return waypoints[math.random(1, #waypoints)]
end

local function getNearestDemon(rootPosition)
	local nearestRoot
	local nearestDistance = DEMON_FEAR_RANGE

	for _, candidate in ipairs(Workspace:GetChildren()) do
		if candidate:IsA("Model") and candidate:GetAttribute("IsDemonEnemy") then
			local humanoid = candidate:FindFirstChildOfClass("Humanoid")
			local demonRoot = candidate.PrimaryPart or candidate:FindFirstChild("HumanoidRootPart")

			if humanoid and humanoid.Health > 0 and demonRoot then
				local distance = (demonRoot.Position - rootPosition).Magnitude

				if distance < nearestDistance then
					nearestDistance = distance
					nearestRoot = demonRoot
				end
			end
		end
	end

	return nearestRoot, nearestDistance
end

local function pickFleeWaypoint(rootPosition, demonPosition)
	local bestWaypoint
	local bestScore = -math.huge

	for _, waypoint in ipairs(waypoints) do
		local groundedWaypoint = getGroundedPosition(waypoint.Position)
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
					moveCivilianTo(humanoid, rootPart, getGroundedPosition(waypoint.Position), function()
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

local function spawnCivilian()
	if #spawnMarkers == 0 then
		return
	end

	local spawnMarker = spawnMarkers[math.random(1, #spawnMarkers)]
	local civilian = createCivilianModel(spawnMarker.Position)
	startCivilianWander(civilian)
	activeCiviliansValue.Value = countActiveCivilians()
end

for _ = 1, TARGET_CIVILIANS do
	spawnCivilian()
end

activeCiviliansValue.Value = countActiveCivilians()

task.spawn(function()
	while true do
		while countActiveCivilians() < TARGET_CIVILIANS do
			spawnCivilian()
			task.wait(0.2)
		end

		task.wait(RESPAWN_CHECK_DELAY)
	end
end)

RunService.Heartbeat:Connect(function()
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

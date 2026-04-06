local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local GROUND_RAY_HEIGHT = 36
local GROUND_CLEARANCE = 0.1

local ENEMY_CONFIGS = {
	{
		Name = "RedDemon",
		UnlockWave = 1,
		SpawnPosition = Vector3.new(-18, 8, -30),
		MaxHealth = 80,
		MoveSpeed = 24,
		AggroRange = 110,
		AttackRange = 6,
		AttackDamage = 8,
		AttackCooldown = 1.45,
		AttackWindup = 0.4,
		RespawnDelay = 4,
		DeathCleanupDelay = 2,
		HipHeight = 2.2,
		RootSize = Vector3.new(3.2, 3.8, 3),
		TorsoSize = Vector3.new(3.8, 4.2, 3.2),
		HeadSize = Vector3.new(2.7, 2.7, 2.7),
		ArmSize = Vector3.new(1.2, 3.4, 1.2),
		LegSize = Vector3.new(1.25, 3.5, 1.25),
		TorsoOffset = Vector3.new(0, 2.45, 0),
		HeadOffset = Vector3.new(0, 5.7, 0),
		LeftArmOffset = Vector3.new(-2.15, 2.55, 0),
		RightArmOffset = Vector3.new(2.15, 2.55, 0),
		LeftLegOffset = Vector3.new(-0.92, 0.05, 0),
		RightLegOffset = Vector3.new(0.92, 0.05, 0),
		TorsoColor = Color3.fromRGB(184, 40, 40),
		HeadColor = Color3.fromRGB(228, 70, 70),
		ArmColor = Color3.fromRGB(150, 30, 30),
		LegColor = Color3.fromRGB(118, 18, 18),
		AttackHighlightColor = Color3.fromRGB(255, 126, 126),
		HitVFXColor = Color3.fromRGB(255, 80, 80),
		DevilStyle = true,
	},
	{
		Name = "BlueDemon",
		UnlockWave = 2,
		SpawnPosition = Vector3.new(18, 7, -30),
		MaxHealth = 95,
		MoveSpeed = 34,
		AggroRange = 140,
		AttackRange = 5.5,
		AttackDamage = 9,
		AttackCooldown = 1.05,
		AttackWindup = 0.24,
		RespawnDelay = 3.6,
		DeathCleanupDelay = 1.8,
		HipHeight = 1.9,
		RootSize = Vector3.new(2.9, 3.3, 2.8),
		TorsoSize = Vector3.new(3.2, 3.6, 2.9),
		HeadSize = Vector3.new(2.3, 2.3, 2.3),
		ArmSize = Vector3.new(1, 3.1, 1),
		LegSize = Vector3.new(1.05, 3.2, 1.05),
		TorsoOffset = Vector3.new(0, 2.1, 0),
		HeadOffset = Vector3.new(0, 4.9, 0),
		LeftArmOffset = Vector3.new(-1.95, 2.2, 0),
		RightArmOffset = Vector3.new(1.95, 2.2, 0),
		LeftLegOffset = Vector3.new(-0.76, -0.02, 0),
		RightLegOffset = Vector3.new(0.76, -0.02, 0),
		TorsoColor = Color3.fromRGB(48, 92, 196),
		HeadColor = Color3.fromRGB(88, 142, 255),
		ArmColor = Color3.fromRGB(42, 76, 156),
		LegColor = Color3.fromRGB(27, 54, 120),
		AttackHighlightColor = Color3.fromRGB(130, 196, 255),
		HitVFXColor = Color3.fromRGB(88, 170, 255),
		DevilStyle = true,
	},
	{
		Name = "GreenDemon",
		UnlockWave = 3,
		SpawnPosition = Vector3.new(0, 7.6, -42),
		MaxHealth = 135,
		MoveSpeed = 28,
		AggroRange = 125,
		AttackRange = 6.2,
		AttackDamage = 12,
		AttackCooldown = 1.15,
		AttackWindup = 0.3,
		RespawnDelay = 4,
		DeathCleanupDelay = 2,
		HipHeight = 2.05,
		RootSize = Vector3.new(3.5, 3.9, 3.1),
		TorsoSize = Vector3.new(4.1, 4.4, 3.4),
		HeadSize = Vector3.new(2.8, 2.8, 2.8),
		ArmSize = Vector3.new(1.24, 3.6, 1.24),
		LegSize = Vector3.new(1.3, 3.7, 1.3),
		TorsoOffset = Vector3.new(0, 2.55, 0),
		HeadOffset = Vector3.new(0, 6, 0),
		LeftArmOffset = Vector3.new(-2.25, 2.65, 0),
		RightArmOffset = Vector3.new(2.25, 2.65, 0),
		LeftLegOffset = Vector3.new(-0.95, 0.08, 0),
		RightLegOffset = Vector3.new(0.95, 0.08, 0),
		TorsoColor = Color3.fromRGB(48, 146, 57),
		HeadColor = Color3.fromRGB(88, 194, 97),
		ArmColor = Color3.fromRGB(33, 115, 42),
		LegColor = Color3.fromRGB(24, 86, 31),
		AttackHighlightColor = Color3.fromRGB(166, 255, 170),
		HitVFXColor = Color3.fromRGB(112, 255, 128),
		DevilStyle = true,
	},
	{
		Name = "PurpleDemon",
		UnlockWave = 4,
		SpawnPosition = Vector3.new(-28, 8.4, -44),
		MaxHealth = 190,
		MoveSpeed = 30,
		AggroRange = 135,
		AttackRange = 6.4,
		AttackDamage = 16,
		AttackCooldown = 0.95,
		AttackWindup = 0.28,
		RespawnDelay = 4.5,
		DeathCleanupDelay = 2.2,
		HipHeight = 2.25,
		RootSize = Vector3.new(3.9, 4.3, 3.3),
		TorsoSize = Vector3.new(4.5, 4.8, 3.7),
		HeadSize = Vector3.new(3.1, 3.1, 3.1),
		ArmSize = Vector3.new(1.38, 3.9, 1.38),
		LegSize = Vector3.new(1.5, 3.95, 1.5),
		TorsoOffset = Vector3.new(0, 2.75, 0),
		HeadOffset = Vector3.new(0, 6.45, 0),
		LeftArmOffset = Vector3.new(-2.5, 2.85, 0),
		RightArmOffset = Vector3.new(2.5, 2.85, 0),
		LeftLegOffset = Vector3.new(-1.02, 0.16, 0),
		RightLegOffset = Vector3.new(1.02, 0.16, 0),
		TorsoColor = Color3.fromRGB(106, 42, 162),
		HeadColor = Color3.fromRGB(160, 84, 220),
		ArmColor = Color3.fromRGB(82, 28, 132),
		LegColor = Color3.fromRGB(62, 18, 98),
		AttackHighlightColor = Color3.fromRGB(214, 118, 255),
		HitVFXColor = Color3.fromRGB(214, 118, 255),
		DevilStyle = true,
	},
	{
		Name = "WhiteDemon",
		UnlockWave = 5,
		SpawnPosition = Vector3.new(28, 8.8, -44),
		MaxHealth = 250,
		MoveSpeed = 32,
		AggroRange = 150,
		AttackRange = 6.8,
		AttackDamage = 20,
		AttackCooldown = 0.8,
		AttackWindup = 0.22,
		RespawnDelay = 5,
		DeathCleanupDelay = 2.4,
		HipHeight = 2.35,
		RootSize = Vector3.new(4.2, 4.6, 3.5),
		TorsoSize = Vector3.new(4.8, 5.1, 3.9),
		HeadSize = Vector3.new(3.25, 3.25, 3.25),
		ArmSize = Vector3.new(1.46, 4.1, 1.46),
		LegSize = Vector3.new(1.58, 4.1, 1.58),
		TorsoOffset = Vector3.new(0, 2.9, 0),
		HeadOffset = Vector3.new(0, 6.85, 0),
		LeftArmOffset = Vector3.new(-2.65, 3, 0),
		RightArmOffset = Vector3.new(2.65, 3, 0),
		LeftLegOffset = Vector3.new(-1.08, 0.2, 0),
		RightLegOffset = Vector3.new(1.08, 0.2, 0),
		TorsoColor = Color3.fromRGB(235, 235, 235),
		HeadColor = Color3.fromRGB(255, 255, 255),
		ArmColor = Color3.fromRGB(215, 215, 215),
		LegColor = Color3.fromRGB(180, 180, 180),
		AttackHighlightColor = Color3.fromRGB(255, 255, 255),
		HitVFXColor = Color3.fromRGB(255, 255, 255),
		DevilStyle = true,
	},
}

local enemyStates = {}

local function getCivilianFolder()
	local stateFolder = Workspace:FindFirstChild("CivilianState")
	return stateFolder and stateFolder:FindFirstChild("Civilians")
end

local function createPossessionBurst(position, color)
	local burst = Instance.new("Part")
	burst.Name = "PossessionBurst"
	burst.Shape = Enum.PartType.Ball
	burst.Size = Vector3.new(1.2, 1.2, 1.2)
	burst.Material = Enum.Material.Neon
	burst.Color = color
	burst.Transparency = 0.2
	burst.Anchored = true
	burst.CanCollide = false
	burst.CanQuery = false
	burst.CanTouch = false
	burst.CFrame = CFrame.new(position)
	burst.Parent = Workspace

	local tween = TweenService:Create(burst, TweenInfo.new(0.22), {
		Size = Vector3.new(7, 7, 7),
		Transparency = 1,
	})

	tween:Play()
	Debris:AddItem(burst, 0.3)
end

local function tryClaimCivilianHost(config)
	local civiliansFolder = getCivilianFolder()

	if not civiliansFolder then
		return nil
	end

	local availableHosts = {}

	for _, civilian in ipairs(civiliansFolder:GetChildren()) do
		if civilian:IsA("Model") and civilian:GetAttribute("IsCivilian") and not civilian:GetAttribute("IsPossessed") then
			local primaryPart = civilian.PrimaryPart or civilian:FindFirstChild("HumanoidRootPart")

			if primaryPart then
				table.insert(availableHosts, civilian)
			end
		end
	end

	if #availableHosts == 0 then
		return nil
	end

	local host = availableHosts[math.random(1, #availableHosts)]
	local hostRoot = host.PrimaryPart or host:FindFirstChild("HumanoidRootPart")

	if not hostRoot then
		return nil
	end

	host:SetAttribute("IsPossessed", true)
	createPossessionBurst(hostRoot.Position + Vector3.new(0, 3, 0), config.HitVFXColor)
	local spawnPosition = hostRoot.Position
	host:Destroy()
	return spawnPosition
end

local function getGroundedSpawnPosition(position, rootHeight, ignoreInstances)
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = ignoreInstances or {}

	local rayOrigin = position + Vector3.new(0, GROUND_RAY_HEIGHT, 0)
	local rayDirection = Vector3.new(0, -GROUND_RAY_HEIGHT * 2, 0)
	local result = Workspace:Raycast(rayOrigin, rayDirection, rayParams)

	if result then
		local groundedY = result.Position.Y + (rootHeight * 0.5) + GROUND_CLEARANCE
		return Vector3.new(position.X, groundedY, position.Z)
	end

	return position
end

local function getWaveState()
	return workspace:FindFirstChild("WaveState")
end

local function getCurrentWaveNumber()
	local waveState = getWaveState()
	local waveNumber = waveState and waveState:FindFirstChild("WaveNumber")

	if waveNumber and waveNumber:IsA("IntValue") then
		return math.max(1, waveNumber.Value)
	end

	return 1
end

local function isWaveCountdownActive()
	local waveState = getWaveState()
	local countdownActive = waveState and waveState:FindFirstChild("CountdownActive")
	local status = waveState and waveState:FindFirstChild("Status")

	if countdownActive and countdownActive:IsA("BoolValue") then
		return countdownActive.Value
	end

	if status and status:IsA("StringValue") then
		return string.find(status.Value, "Next wave", 1, true) ~= nil
			or string.find(status.Value, "Retry", 1, true) ~= nil
	end

	return false
end

local function shouldEnemyExistForCurrentWave(state)
	local currentWave = getCurrentWaveNumber()

	if isWaveCountdownActive() then
		return false
	end

	if currentWave < state.Config.UnlockWave then
		return false
	end

	return state.LastDefeatedWave ~= currentWave
end

local function createBodyPart(name, size, color, offset, rootPart, collidable)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Color = color
	part.Material = Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.CanCollide = collidable
	part.Massless = true
	part.CFrame = rootPart.CFrame * CFrame.new(offset)
	part.Parent = rootPart.Parent
	return part
end

local function weldTogether(part0, part1, jointName)
	local weld = Instance.new("Weld")
	weld.Name = jointName or (part1.Name .. "Joint")
	weld.Part0 = part0
	weld.Part1 = part1
	weld.C0 = part0.CFrame:ToObjectSpace(part1.CFrame)
	weld.Parent = part0
	return weld
end

local function createEnemyHitVFX(targetPosition, color)
	local ring = Instance.new("Part")
	ring.Name = "PlayerHitVFX"
	ring.Shape = Enum.PartType.Cylinder
	ring.Size = Vector3.new(0.2, 1.4, 1.4)
	ring.Material = Enum.Material.Neon
	ring.Color = color
	ring.Transparency = 0.2
	ring.CanCollide = false
	ring.CanQuery = false
	ring.CanTouch = false
	ring.Anchored = true
	ring.CFrame = CFrame.new(targetPosition) * CFrame.Angles(0, 0, math.rad(90))
	ring.Parent = workspace

	local tween = TweenService:Create(ring, TweenInfo.new(0.2), {
		Size = Vector3.new(0.2, 4.2, 4.2),
		Transparency = 1,
	})

	tween:Play()
	Debris:AddItem(ring, 0.25)
end

local function burstEnemyParts(enemyModel)
	local rootPart = enemyModel:FindFirstChild("HumanoidRootPart")

	if rootPart then
		for _, child in ipairs(rootPart:GetChildren()) do
			if child:IsA("WeldConstraint") or child:IsA("Weld") then
				child:Destroy()
			end
		end
	end

	for _, part in ipairs(enemyModel:GetChildren()) do
		if part:IsA("BasePart") and part ~= rootPart then
			for _, child in ipairs(part:GetChildren()) do
				if child:IsA("WeldConstraint") or child:IsA("Weld") then
					child:Destroy()
				end
			end
		end
	end

	for _, part in ipairs(enemyModel:GetChildren()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			part.Anchored = false
			part.CanCollide = true
			part.Massless = false

			local randomDirection = Vector3.new(
				math.random(-100, 100) / 100,
				math.random(45, 110) / 100,
				math.random(-100, 100) / 100
			)

			if randomDirection.Magnitude < 0.01 then
				randomDirection = Vector3.new(0, 1, 0)
			end

			randomDirection = randomDirection.Unit
			part.AssemblyLinearVelocity = randomDirection * math.random(26, 42) + Vector3.new(0, math.random(14, 24), 0)
			part.AssemblyAngularVelocity = Vector3.new(
				math.rad(math.random(-720, 720)),
				math.rad(math.random(-720, 720)),
				math.rad(math.random(-720, 720))
			)
		end
	end
end

local function ensureAttackHighlight(enemyModel, config)
	local highlight = enemyModel:FindFirstChild("AttackHighlight")

	if not highlight then
		highlight = Instance.new("Highlight")
		highlight.Name = "AttackHighlight"
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.FillColor = config.AttackHighlightColor
		highlight.OutlineColor = Color3.fromRGB(255, 240, 240)
		highlight.FillTransparency = 1
		highlight.OutlineTransparency = 1
		highlight.Enabled = false
		highlight.Parent = enemyModel
	end

	return highlight
end

local function playAttackWindup(enemyModel, config)
	local highlight = ensureAttackHighlight(enemyModel, config)
	highlight.Enabled = true
	highlight.FillTransparency = 0.45
	highlight.OutlineTransparency = 0.1

	task.delay(config.AttackWindup, function()
		if highlight.Parent then
			highlight.Enabled = false
		end
	end)
end

local function getNearestPlayer(position, aggroRange)
	local bestPlayer
	local bestDistance = aggroRange

	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local rootPart = character and character:FindFirstChild("HumanoidRootPart")

		if humanoid and humanoid.Health > 0 and rootPart then
			local distance = (rootPart.Position - position).Magnitude

			if distance < bestDistance then
				bestDistance = distance
				bestPlayer = player
			end
		end
	end

	return bestPlayer, bestDistance
end

local function applyJointMotion(rootPart, jointName, baseC0, offsetCFrame)
	local joint = rootPart:FindFirstChild(jointName)

	if joint and joint:IsA("Weld") and baseC0 then
		joint.C0 = baseC0 * offsetCFrame
	end
end

local function animateEnemy(state, rootPart, isMoving)
	local defaults = state.JointDefaults

	if not defaults then
		return
	end

	local timeNow = tick() * 8
	local moveAlpha = isMoving and 1 or 0
	local walkSwing = math.sin(timeNow) * math.rad(28) * moveAlpha
	local armSwing = math.sin(timeNow) * math.rad(18) * moveAlpha
	local bobAmount = math.abs(math.sin(timeNow)) * 0.08 * moveAlpha
	local tailSwing = math.sin(timeNow * 0.75) * math.rad(isMoving and 18 or 6)

	local attackSwing = 0
	local attackTwist = 0
	if state.AttackInProgress and state.AttackStartedAt then
		local attackAlpha = math.clamp((os.clock() - state.AttackStartedAt) / state.Config.AttackWindup, 0, 1)
		attackSwing = math.sin(attackAlpha * math.pi) * math.rad(state.Config.DevilStyle and 92 or 34)
		attackTwist = math.sin(attackAlpha * math.pi) * math.rad(state.Config.DevilStyle and -22 or 0)
	end

	applyJointMotion(rootPart, "TorsoJoint", defaults.TorsoJoint, CFrame.new(0, bobAmount, 0))
	applyJointMotion(rootPart, "HeadJoint", defaults.HeadJoint, CFrame.Angles(-walkSwing * 0.08, 0, 0))
	applyJointMotion(rootPart, "LeftLegJoint", defaults.LeftLegJoint, CFrame.Angles(walkSwing, 0, 0))
	applyJointMotion(rootPart, "RightLegJoint", defaults.RightLegJoint, CFrame.Angles(-walkSwing, 0, 0))
	applyJointMotion(rootPart, "LeftArmJoint", defaults.LeftArmJoint, CFrame.Angles(-armSwing, 0, 0))
	local rightArmRoll = state.Config.DevilStyle and math.rad(-14) or math.rad(-8) * moveAlpha
	applyJointMotion(rootPart, "RightArmJoint", defaults.RightArmJoint, CFrame.Angles(armSwing - attackSwing, attackTwist, rightArmRoll))

	if state.Config.DevilStyle then
		applyJointMotion(rootPart, "TailBaseJoint", defaults.TailBaseJoint, CFrame.Angles(0, tailSwing, 0))
		applyJointMotion(rootPart, "TailMidJoint", defaults.TailMidJoint, CFrame.Angles(0, tailSwing * 1.2, 0))
		applyJointMotion(rootPart, "TailTipJoint", defaults.TailTipJoint, CFrame.Angles(0, tailSwing * 1.5, 0))
	end
end

local function createEnemyModel(config)
	local model = Instance.new("Model")
	model.Name = config.Name
	model:SetAttribute("IsDemonEnemy", true)
	model:SetAttribute("EnemyType", config.Name)

	local spawnPosition = tryClaimCivilianHost(config) or config.SpawnPosition

	local rootPart = Instance.new("Part")
	rootPart.Name = "HumanoidRootPart"
	rootPart.Size = config.RootSize
	rootPart.Transparency = 1
	rootPart.CanCollide = false
	rootPart.Color = config.TorsoColor
	rootPart.TopSurface = Enum.SurfaceType.Smooth
	rootPart.BottomSurface = Enum.SurfaceType.Smooth
	rootPart.CFrame = CFrame.new(getGroundedSpawnPosition(spawnPosition, config.RootSize.Y))
	rootPart.Parent = model

	local torso = createBodyPart("Torso", config.TorsoSize, config.TorsoColor, config.TorsoOffset, rootPart, true)
	local head = createBodyPart("Head", config.HeadSize, config.HeadColor, config.HeadOffset, rootPart, false)
	local leftArm = createBodyPart("LeftArm", config.ArmSize, config.ArmColor, config.LeftArmOffset, rootPart, false)
	local rightArm = createBodyPart("RightArm", config.ArmSize, config.ArmColor, config.RightArmOffset, rootPart, false)
	local leftLeg = createBodyPart("LeftLeg", config.LegSize, config.LegColor, config.LeftLegOffset, rootPart, false)
	local rightLeg = createBodyPart("RightLeg", config.LegSize, config.LegColor, config.RightLegOffset, rootPart, false)

	local jointDefaults = {}

	for _, bodyPart in ipairs({ torso, head, leftArm, rightArm, leftLeg, rightLeg }) do
		local joint = weldTogether(rootPart, bodyPart)
		jointDefaults[joint.Name] = joint.C0
	end

	if config.DevilStyle then
		local leftHorn = createBodyPart("LeftHorn", Vector3.new(0.36, 1.95, 0.36), Color3.fromRGB(255, 239, 190), config.HeadOffset + Vector3.new(-0.92, 1.82, -0.3), rootPart, false)
		local rightHorn = createBodyPart("RightHorn", Vector3.new(0.36, 1.95, 0.36), Color3.fromRGB(255, 239, 190), config.HeadOffset + Vector3.new(0.92, 1.82, -0.3), rootPart, false)
		leftHorn.CFrame = leftHorn.CFrame * CFrame.Angles(math.rad(-44), 0, math.rad(40))
		rightHorn.CFrame = rightHorn.CFrame * CFrame.Angles(math.rad(-44), 0, math.rad(-40))
		jointDefaults.LeftHornJoint = weldTogether(rootPart, leftHorn).C0
		jointDefaults.RightHornJoint = weldTogether(rootPart, rightHorn).C0

		local leftEye = createBodyPart("LeftEye", Vector3.new(0.44, 0.44, 0.18), Color3.fromRGB(255, 245, 128), config.HeadOffset + Vector3.new(-0.6, 0.42, -1.6), rootPart, false)
		local rightEye = createBodyPart("RightEye", Vector3.new(0.44, 0.44, 0.18), Color3.fromRGB(255, 245, 128), config.HeadOffset + Vector3.new(0.6, 0.42, -1.6), rootPart, false)
		leftEye.Material = Enum.Material.Neon
		rightEye.Material = Enum.Material.Neon
		leftEye.CFrame = leftEye.CFrame * CFrame.Angles(0, 0, math.rad(16))
		rightEye.CFrame = rightEye.CFrame * CFrame.Angles(0, 0, math.rad(-16))
		jointDefaults.LeftEyeJoint = weldTogether(rootPart, leftEye).C0
		jointDefaults.RightEyeJoint = weldTogether(rootPart, rightEye).C0

		local smileLeft = createBodyPart("SmileLeft", Vector3.new(0.22, 0.92, 0.14), Color3.fromRGB(40, 0, 0), config.HeadOffset + Vector3.new(-0.46, -0.28, -1.58), rootPart, false)
		local smileMid = createBodyPart("SmileMid", Vector3.new(0.82, 0.18, 0.14), Color3.fromRGB(40, 0, 0), config.HeadOffset + Vector3.new(0, -0.72, -1.58), rootPart, false)
		local smileRight = createBodyPart("SmileRight", Vector3.new(0.22, 0.92, 0.14), Color3.fromRGB(40, 0, 0), config.HeadOffset + Vector3.new(0.46, -0.28, -1.58), rootPart, false)
		smileLeft.CFrame = smileLeft.CFrame * CFrame.Angles(0, 0, math.rad(-34))
		smileRight.CFrame = smileRight.CFrame * CFrame.Angles(0, 0, math.rad(34))
		jointDefaults.SmileLeftJoint = weldTogether(rootPart, smileLeft).C0
		jointDefaults.SmileMidJoint = weldTogether(rootPart, smileMid).C0
		jointDefaults.SmileRightJoint = weldTogether(rootPart, smileRight).C0

		local tailBase = createBodyPart("TailBase", Vector3.new(0.35, 1.5, 0.35), config.LegColor, config.TorsoOffset + Vector3.new(0, -0.2, 1.55), rootPart, false)
		local tailMid = createBodyPart("TailMid", Vector3.new(0.3, 1.35, 0.3), config.LegColor, config.TorsoOffset + Vector3.new(0, -0.85, 2.15), rootPart, false)
		local tailTip = createBodyPart("TailTip", Vector3.new(0.32, 0.45, 0.32), Color3.fromRGB(255, 239, 190), config.TorsoOffset + Vector3.new(0, -1.45, 2.72), rootPart, false)
		tailBase.CFrame = tailBase.CFrame * CFrame.Angles(math.rad(38), 0, 0)
		tailMid.CFrame = tailMid.CFrame * CFrame.Angles(math.rad(55), 0, 0)
		tailTip.CFrame = tailTip.CFrame * CFrame.Angles(math.rad(55), 0, math.rad(45))
		jointDefaults.TailBaseJoint = weldTogether(rootPart, tailBase).C0
		jointDefaults.TailMidJoint = weldTogether(rootPart, tailMid).C0
		jointDefaults.TailTipJoint = weldTogether(rootPart, tailTip).C0

	end

	local humanoid = Instance.new("Humanoid")
	humanoid.Name = "Humanoid"
	humanoid.MaxHealth = config.MaxHealth
	humanoid.Health = config.MaxHealth
	humanoid.WalkSpeed = config.MoveSpeed
	humanoid.BreakJointsOnDeath = false
	humanoid.HipHeight = 0
	humanoid.Parent = model

	model.PrimaryPart = rootPart
	model.Parent = workspace

	return model, jointDefaults
end

local function spawnEnemy(state)
	if state.Model and state.Model.Parent then
		return false
	end

	if not shouldEnemyExistForCurrentWave(state) then
		return false
	end

	state.Model, state.JointDefaults = createEnemyModel(state.Config)
	state.NextAttackTime = 0
	state.AttackInProgress = false
	state.AttackStartedAt = nil
	state.Model:SetAttribute("DeathHooked", false)
	return true
end

local function scheduleRespawn(state)
	if state.RespawnPending then
		return
	end

	state.RespawnPending = true

	task.delay(state.Config.RespawnDelay, function()
		state.RespawnPending = false

		if state.Model and state.Model.Parent then
			return
		end

		if not shouldEnemyExistForCurrentWave(state) then
			return
		end

		spawnEnemy(state)
	end)
end

local function hookEnemyDeath(state)
	local enemyModel = state.Model
	local humanoid = enemyModel and enemyModel:FindFirstChildOfClass("Humanoid")

	if not enemyModel or not humanoid or enemyModel:GetAttribute("DeathHooked") then
		return
	end

	enemyModel:SetAttribute("DeathHooked", true)

	humanoid.Died:Connect(function()
		state.LastDefeatedWave = getCurrentWaveNumber()

		local rootPart = enemyModel:FindFirstChild("HumanoidRootPart")

		if rootPart then
			rootPart.Anchored = true
			rootPart.CanCollide = false
			rootPart.Transparency = 1
		end

		burstEnemyParts(enemyModel)

		task.delay(state.Config.DeathCleanupDelay, function()
			if enemyModel.Parent then
				enemyModel:Destroy()
			end
		end)

		scheduleRespawn(state)
	end)

	enemyModel.Destroying:Connect(function()
		if state.Model == enemyModel then
			state.Model = nil
		end
	end)
end

local function ensureEnemy(state)
	state.Model = workspace:FindFirstChild(state.Config.Name)

	if not state.Model and shouldEnemyExistForCurrentWave(state) then
		spawnEnemy(state)
	end

	hookEnemyDeath(state)
end

local function tryAttackPlayer(state, targetPlayer)
	local enemyModel = state.Model
	local demonRoot = enemyModel and enemyModel:FindFirstChild("HumanoidRootPart")
	local demonHumanoid = enemyModel and enemyModel:FindFirstChildOfClass("Humanoid")
	local targetCharacter = targetPlayer.Character
	local targetHumanoid = targetCharacter and targetCharacter:FindFirstChildOfClass("Humanoid")
	local targetRoot = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")

	if not demonRoot or not demonHumanoid or demonHumanoid.Health <= 0 or not targetHumanoid or targetHumanoid.Health <= 0 or not targetRoot then
		return
	end

	local now = os.clock()
	if now < state.NextAttackTime or state.AttackInProgress then
		return
	end

	state.AttackInProgress = true
	state.AttackStartedAt = now
	state.NextAttackTime = now + state.Config.AttackCooldown
	playAttackWindup(enemyModel, state.Config)
	demonRoot.AssemblyLinearVelocity = Vector3.new(0, demonRoot.AssemblyLinearVelocity.Y, 0)

	task.delay(state.Config.AttackWindup, function()
		state.AttackInProgress = false
		state.AttackStartedAt = nil

		if not enemyModel.Parent or demonHumanoid.Health <= 0 then
			return
		end

		if not targetCharacter.Parent or targetHumanoid.Health <= 0 or not targetRoot.Parent then
			return
		end

		local pushDirection = targetRoot.Position - demonRoot.Position
		local currentDistance = pushDirection.Magnitude

		if currentDistance > state.Config.AttackRange + 1.5 then
			return
		end

		if currentDistance < 0.01 then
			pushDirection = Vector3.new(0, 0, -1)
		end

		targetHumanoid:TakeDamage(state.Config.AttackDamage)
		targetRoot.AssemblyLinearVelocity = targetRoot.AssemblyLinearVelocity + pushDirection.Unit * 34 + Vector3.new(0, 18, 0)
		createEnemyHitVFX(targetRoot.Position + Vector3.new(0, 2, 0), state.Config.HitVFXColor)
	end)
end

for _, config in ipairs(ENEMY_CONFIGS) do
	local state = {
		Config = config,
		Model = nil,
		JointDefaults = nil,
		NextAttackTime = 0,
		RespawnPending = false,
		AttackInProgress = false,
		AttackStartedAt = nil,
		LastDefeatedWave = nil,
	}

	table.insert(enemyStates, state)
	ensureEnemy(state)
end

RunService.Heartbeat:Connect(function()
	for _, state in ipairs(enemyStates) do
		local enemyModel = state.Model

		if not enemyModel or not enemyModel.Parent then
			if not state.RespawnPending and shouldEnemyExistForCurrentWave(state) then
				spawnEnemy(state)
			end

			continue
		end

		if not shouldEnemyExistForCurrentWave(state) then
			enemyModel:Destroy()
			continue
		end

		if not enemyModel:GetAttribute("DeathHooked") then
			hookEnemyDeath(state)
		end

		local humanoid = enemyModel:FindFirstChildOfClass("Humanoid")
		local rootPart = enemyModel:FindFirstChild("HumanoidRootPart")

		if not humanoid or humanoid.Health <= 0 or not rootPart then
			continue
		end

		local targetPlayer, distance = getNearestPlayer(rootPart.Position, state.Config.AggroRange)

		if not targetPlayer then
			rootPart.AssemblyLinearVelocity = Vector3.zero
			continue
		end

		local targetCharacter = targetPlayer.Character
		local targetRoot = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")

		if not targetRoot then
			continue
		end

		local offset = targetRoot.Position - rootPart.Position
		local flatOffset = Vector3.new(offset.X, 0, offset.Z)
		local isMoving = distance > state.Config.AttackRange

		if flatOffset.Magnitude > 0.1 then
			rootPart.CFrame = CFrame.lookAt(rootPart.Position, Vector3.new(targetRoot.Position.X, rootPart.Position.Y, targetRoot.Position.Z))
		end

		if isMoving then
			local moveDirection = flatOffset.Magnitude > 0 and flatOffset.Unit or Vector3.zero
			rootPart.AssemblyLinearVelocity = Vector3.new(moveDirection.X * state.Config.MoveSpeed, rootPart.AssemblyLinearVelocity.Y, moveDirection.Z * state.Config.MoveSpeed)
		else
			rootPart.AssemblyLinearVelocity = Vector3.new(0, rootPart.AssemblyLinearVelocity.Y, 0)
			tryAttackPlayer(state, targetPlayer)
		end

		animateEnemy(state, rootPart, isMoving)

		if math.abs(rootPart.AssemblyLinearVelocity.Y) < 0.01 then
			rootPart.AssemblyLinearVelocity = Vector3.new(rootPart.AssemblyLinearVelocity.X, -2, rootPart.AssemblyLinearVelocity.Z)
		end
	end
end)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local attackRemote = remotesFolder:WaitForChild("RoosterAttack")
local hitConfirmRemote = remotesFolder:WaitForChild("RoosterHitConfirm")

local ATTACKS = {
	Peck = {
		Damage = 24,
		Cooldown = 0.4,
		HitboxSize = Vector3.new(5, 4.5, 6),
		ForwardOffset = 4.5,
		Knockback = 55,
		HitBurstColor = Color3.fromRGB(255, 214, 97),
	},
	Scratch = {
		Damage = 14,
		Cooldown = 0.65,
		HitboxSize = Vector3.new(8, 4.5, 8),
		ForwardOffset = 3.2,
		Knockback = 32,
		HitBurstColor = Color3.fromRGB(255, 132, 74),
	},
}

local CHARACTER_ATTACK_MODIFIERS = {
	Kenchi = {
		Peck = {
			Cooldown = 0.32,
			Damage = 26,
			ForwardOffset = 5.2,
			Knockback = 48,
			HitBurstColor = Color3.fromRGB(255, 234, 126),
		},
		Scratch = {
			Cooldown = 0.58,
			Damage = 15,
			ForwardOffset = 3.6,
			Knockback = 28,
			HitBurstColor = Color3.fromRGB(255, 166, 92),
		},
	},
	Keijuke = {
		Peck = {
			Cooldown = 0.48,
			Damage = 22,
			ForwardOffset = 4.1,
			Knockback = 68,
			HitBurstColor = Color3.fromRGB(255, 132, 132),
		},
		Scratch = {
			Cooldown = 0.78,
			Damage = 20,
			HitboxSize = Vector3.new(9.5, 5, 9.5),
			ForwardOffset = 3.4,
			Knockback = 52,
			HitBurstColor = Color3.fromRGB(255, 94, 94),
		},
	},
}

local lastAttackTimes = {}

local function getSelectedRooster(player)
	return player:GetAttribute("SelectedRooster") or "Kenchi"
end

local function getAttackConfig(player, attackName)
	local baseConfig = ATTACKS[attackName]

	if not baseConfig then
		return nil
	end

	local config = table.clone(baseConfig)
	local roosterModifiers = CHARACTER_ATTACK_MODIFIERS[getSelectedRooster(player)]
	local attackModifiers = roosterModifiers and roosterModifiers[attackName]

	if attackModifiers then
		for key, value in pairs(attackModifiers) do
			config[key] = value
		end
	end

	return config
end

local function playDemonHitGroan(demonModel, attackName)
	local rootPart = demonModel:FindFirstChild("HumanoidRootPart")

	if not rootPart then
		return
	end

	local groan = Instance.new("Sound")
	groan.Name = "DemonHitGroan"
	groan.SoundId = "rbxasset://sounds/uuhhh.mp3"
	groan.Volume = attackName == "Peck" and 0.9 or 0.75
	groan.PlaybackSpeed = attackName == "Peck" and 0.92 or 1.04
	groan.RollOffMaxDistance = 70
	groan.Parent = rootPart
	groan:Play()
	Debris:AddItem(groan, 2)
end

local function createHitBurst(position, color)
	local burst = Instance.new("Part")
	burst.Name = "HitBurst"
	burst.Shape = Enum.PartType.Ball
	burst.Size = Vector3.new(0.7, 0.7, 0.7)
	burst.Material = Enum.Material.Neon
	burst.Color = color
	burst.Transparency = 0.15
	burst.CanCollide = false
	burst.CanQuery = false
	burst.CanTouch = false
	burst.Anchored = true
	burst.CFrame = CFrame.new(position)
	burst.Parent = workspace

	local tween = TweenService:Create(burst, TweenInfo.new(0.18), {
		Size = Vector3.new(3.2, 3.2, 3.2),
		Transparency = 1,
	})

	tween:Play()
	Debris:AddItem(burst, 0.25)
end

local function createHitConfirmBurst(position, attackName)
	local shard = Instance.new("Part")
	shard.Name = "HitConfirmBurst"
	shard.Material = Enum.Material.Neon
	shard.Color = attackName == "Peck" and Color3.fromRGB(255, 247, 180) or Color3.fromRGB(255, 171, 118)
	shard.Transparency = 0.05
	shard.CanCollide = false
	shard.CanQuery = false
	shard.CanTouch = false
	shard.Anchored = true

	if attackName == "Peck" then
		shard.Size = Vector3.new(0.2, 0.2, 2.4)
	else
		shard.Size = Vector3.new(0.16, 2.2, 0.3)
	end

	shard.CFrame = CFrame.new(position)
	shard.Parent = workspace

	local tweenGoal
	if attackName == "Peck" then
		tweenGoal = {
			Size = Vector3.new(0.08, 0.08, 4.2),
			Transparency = 1,
		}
	else
		tweenGoal = {
			Size = Vector3.new(0.08, 3.6, 0.18),
			Transparency = 1,
		}
	end

	local tween = TweenService:Create(shard, TweenInfo.new(0.12), tweenGoal)
	tween:Play()
	Debris:AddItem(shard, 0.15)
end

local function reactDemonToHit(demonModel, attackName)
	local rootPart = demonModel:FindFirstChild("HumanoidRootPart")

	if not rootPart then
		return
	end

	local originalCFrame = rootPart.CFrame
	local pitchAngle = attackName == "Peck" and math.rad(-12) or math.rad(8)
	rootPart.CFrame = originalCFrame * CFrame.Angles(pitchAngle, 0, 0)

	task.delay(0.08, function()
		if rootPart.Parent then
			rootPart.CFrame = originalCFrame
		end
	end)
end

local function flashDemon(demonModel)
	local highlight = demonModel:FindFirstChild("HitFlash")

	if not highlight then
		highlight = Instance.new("Highlight")
		highlight.Name = "HitFlash"
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.FillColor = Color3.fromRGB(255, 90, 90)
		highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		highlight.FillTransparency = 0.2
		highlight.OutlineTransparency = 0
		highlight.Enabled = false
		highlight.Parent = demonModel
	end

	highlight.Enabled = true

	task.delay(0.12, function()
		if highlight.Parent then
			highlight.Enabled = false
		end
	end)
end

local function findDemonFromParts(parts)
	for _, part in ipairs(parts) do
		local candidate = part:FindFirstAncestorOfClass("Model")

		if candidate and candidate:GetAttribute("IsDemonEnemy") then
			local humanoid = candidate:FindFirstChildOfClass("Humanoid")

			if humanoid and humanoid.Health > 0 then
				return candidate, humanoid
			end
		end
	end

	return nil, nil
end

local function knockbackDemon(demonModel, fromPosition, knockbackAmount)
	local rootPart = demonModel:FindFirstChild("HumanoidRootPart")

	if not rootPart then
		return
	end

	local direction = rootPart.Position - fromPosition

	if direction.Magnitude < 0.01 then
		direction = Vector3.new(0, 0, -1)
	end

	direction = direction.Unit
	rootPart.AssemblyLinearVelocity = Vector3.new(direction.X * knockbackAmount, 18, direction.Z * knockbackAmount)
end

local function getPlayerAttackCache(player)
	local playerCache = lastAttackTimes[player]

	if not playerCache then
		playerCache = {}
		lastAttackTimes[player] = playerCache
	end

	return playerCache
end

local function getAttackDamage(player, attackName, attackConfig)
	local damageLevel = player:GetAttribute("DamageUpgradeLevel") or 0
	local characterDamageBonus = player:GetAttribute("CharacterDamageBonus") or 0

	if attackName == "Peck" then
		return attackConfig.Damage + damageLevel * 4 + characterDamageBonus
	end

	if attackName == "Scratch" then
		return attackConfig.Damage + damageLevel * 2 + math.floor(characterDamageBonus * 0.5)
	end

	return attackConfig.Damage
end

local function handleAttack(player, attackName)
	local character = player.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoid or humanoid.Health <= 0 or not rootPart then
		return
	end

	local attackConfig = getAttackConfig(player, attackName)

	if not attackConfig then
		return
	end

	local now = os.clock()
	local playerAttackCache = getPlayerAttackCache(player)
	local lastAttack = playerAttackCache[attackName]

	if lastAttack and now - lastAttack < attackConfig.Cooldown then
		return
	end

	playerAttackCache[attackName] = now

	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Blacklist
	overlapParams.FilterDescendantsInstances = { character }

	local hitboxCFrame = rootPart.CFrame * CFrame.new(0, 0, -attackConfig.ForwardOffset)
	local parts = workspace:GetPartBoundsInBox(hitboxCFrame, attackConfig.HitboxSize, overlapParams)
	local demonModel, demonHumanoid = findDemonFromParts(parts)

	if not demonModel or not demonHumanoid then
		return
	end

	demonModel:SetAttribute("LastHitPlayerUserId", player.UserId)
	demonModel:SetAttribute("LastHitAttackName", attackName)
	demonHumanoid:TakeDamage(getAttackDamage(player, attackName, attackConfig))
	flashDemon(demonModel)
	reactDemonToHit(demonModel, attackName)
	knockbackDemon(demonModel, rootPart.Position, attackConfig.Knockback)
	playDemonHitGroan(demonModel, attackName)

	local demonRoot = demonModel:FindFirstChild("HumanoidRootPart")
	if demonRoot then
		createHitBurst(demonRoot.Position + Vector3.new(0, 1.5, 0), attackConfig.HitBurstColor)
		createHitConfirmBurst(demonRoot.Position + Vector3.new(0, 1.5, 0), attackName)
	end

	hitConfirmRemote:FireClient(player, attackName, demonRoot and demonRoot.Position or rootPart.Position)
end

attackRemote.OnServerEvent:Connect(handleAttack)

Players.PlayerRemoving:Connect(function(player)
	lastAttackTimes[player] = nil
end)

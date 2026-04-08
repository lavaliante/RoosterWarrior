local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local attackRemote = remotesFolder:WaitForChild("RoosterAttack")
local hitConfirmRemote = remotesFolder:WaitForChild("RoosterHitConfirm")
local playerGui = player:WaitForChild("PlayerGui")

local ATTACKS = {
	Peck = {
		Cooldown = 0.4,
		LungeSpeed = 52,
		RecoverySpeed = 12,
		CameraPunchFov = 76,
		PulseColor = Color3.fromRGB(255, 217, 78),
		PulseOffset = CFrame.new(0, -1.75, -3.2),
		PulseSize = Vector3.new(0.35, 1.2, 1.2),
		PulseExpandSize = Vector3.new(0.35, 5.5, 5.5),
		SoundId = "rbxasset://sounds/swordlunge.wav",
		SoundVolume = 0.85,
		SoundPitch = 1.25,
	},
	Scratch = {
		Cooldown = 0.65,
		LungeSpeed = 24,
		RecoverySpeed = 8,
		CameraPunchFov = 73,
		PulseColor = Color3.fromRGB(255, 146, 76),
		PulseOffset = CFrame.new(0, -1.2, -2.4),
		PulseSize = Vector3.new(0.35, 1.6, 1.6),
		PulseExpandSize = Vector3.new(0.35, 6.8, 6.8),
		SoundId = "rbxasset://sounds/swordslash.wav",
		SoundVolume = 0.8,
		SoundPitch = 1.05,
	},
}

local CHARACTER_ATTACK_MODIFIERS = {
	Kenchi = {
		Peck = {
			Cooldown = 0.32,
			LungeSpeed = 58,
			RecoverySpeed = 15,
			CameraPunchFov = 77,
			SoundPitch = 1.35,
			PulseExpandSize = Vector3.new(0.35, 6.2, 6.2),
		},
		Scratch = {
			Cooldown = 0.58,
			LungeSpeed = 28,
			RecoverySpeed = 10,
			CameraPunchFov = 74,
			SoundPitch = 1.12,
		},
	},
	Keijuke = {
		Peck = {
			Cooldown = 0.48,
			LungeSpeed = 42,
			RecoverySpeed = 8,
			CameraPunchFov = 74,
			SoundPitch = 0.95,
			PulseColor = Color3.fromRGB(255, 128, 128),
		},
		Scratch = {
			Cooldown = 0.78,
			LungeSpeed = 18,
			RecoverySpeed = 6,
			CameraPunchFov = 78,
			SoundPitch = 0.82,
			PulseColor = Color3.fromRGB(255, 98, 98),
			PulseExpandSize = Vector3.new(0.35, 8.4, 8.4),
		},
	},
}

local attackReadyTimes = {
	Peck = 0,
	Scratch = 0,
}

local tryAttack
local mobileButtons = {}

local function getSelectedRooster()
	return player:GetAttribute("SelectedRooster") or "Kenchi"
end

local function getAttackConfig(attackName)
	local baseConfig = ATTACKS[attackName]

	if not baseConfig then
		return nil
	end

	local config = table.clone(baseConfig)
	local roosterModifiers = CHARACTER_ATTACK_MODIFIERS[getSelectedRooster()]
	local attackModifiers = roosterModifiers and roosterModifiers[attackName]

	if attackModifiers then
		for key, value in pairs(attackModifiers) do
			config[key] = value
		end
	end

	return config
end

local function createAttackButton(parent, name, text, position, color, size, textSize)
	local button = Instance.new("TextButton")
	button.Name = name
	button.AnchorPoint = Vector2.new(1, 1)
	button.Position = position
	button.Size = size or UDim2.new(0, 130, 0, 54)
	button.BackgroundColor3 = color
	button.BackgroundTransparency = 0.08
	button.BorderSizePixel = 0
	button.AutoButtonColor = true
	button.Font = Enum.Font.GothamBold
	button.Text = ""
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = textSize or 18
	button.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 239, 196)
	stroke.Thickness = 2
	stroke.Parent = button

	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, color:Lerp(Color3.new(1, 1, 1), 0.18)),
		ColorSequenceKeypoint.new(1, color),
	})
	gradient.Rotation = -35
	gradient.Parent = button

	local shadow = Instance.new("Frame")
	shadow.Name = "Shadow"
	shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	shadow.Position = UDim2.new(0.5, 0, 0.5, 4)
	shadow.Size = UDim2.new(1, 8, 1, 8)
	shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	shadow.BackgroundTransparency = 0.72
	shadow.BorderSizePixel = 0
	shadow.ZIndex = button.ZIndex - 1
	shadow.Parent = button

	local shadowCorner = Instance.new("UICorner")
	shadowCorner.CornerRadius = UDim.new(1, 0)
	shadowCorner.Parent = shadow

	local iconLabel = Instance.new("TextLabel")
	iconLabel.Name = "IconLabel"
	iconLabel.BackgroundTransparency = 1
	iconLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	iconLabel.Position = UDim2.new(0.5, 0, 0.37, 0)
	iconLabel.Size = UDim2.new(0.9, 0, 0.36, 0)
	iconLabel.Font = Enum.Font.GothamBlack
	iconLabel.Text = string.sub(text, 1, 1)
	iconLabel.TextColor3 = Color3.fromRGB(255, 249, 225)
	iconLabel.TextSize = text == "Scratch" and 24 or 22
	iconLabel.Parent = button

	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "ButtonText"
	textLabel.BackgroundTransparency = 1
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.Position = UDim2.new(0.5, 0, 0.72, 0)
	textLabel.Size = UDim2.new(0.9, 0, 0.24, 0)
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Text = text
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextSize = textSize or 18
	textLabel.Parent = button

	local cooldownCover = Instance.new("Frame")
	cooldownCover.Name = "CooldownCover"
	cooldownCover.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
	cooldownCover.BackgroundTransparency = 0.35
	cooldownCover.BorderSizePixel = 0
	cooldownCover.Size = UDim2.new(1, 0, 0, 0)
	cooldownCover.Position = UDim2.new(0, 0, 1, 0)
	cooldownCover.ClipsDescendants = true
	cooldownCover.Visible = false
	cooldownCover.Parent = button

	local cooldownCorner = Instance.new("UICorner")
	cooldownCorner.CornerRadius = UDim.new(1, 0)
	cooldownCorner.Parent = cooldownCover

	local cooldownText = Instance.new("TextLabel")
	cooldownText.Name = "CooldownText"
	cooldownText.BackgroundTransparency = 1
	cooldownText.AnchorPoint = Vector2.new(0.5, 0.5)
	cooldownText.Position = UDim2.new(0.5, 0, 0.5, 0)
	cooldownText.Size = UDim2.new(0.85, 0, 0.28, 0)
	cooldownText.Font = Enum.Font.GothamBold
	cooldownText.Text = ""
	cooldownText.TextColor3 = Color3.fromRGB(255, 255, 255)
	cooldownText.TextSize = 11
	cooldownText.Parent = cooldownCover

	return button, cooldownCover, cooldownText
end

local function playButtonPress(button)
	local shrinkTween = TweenService:Create(button, TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, math.max(button.AbsoluteSize.X - 6, 40), 0, math.max(button.AbsoluteSize.Y - 6, 40)),
	})
	local restoreTween = TweenService:Create(button, TweenInfo.new(0.08, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = button.Size,
	})

	local originalSize = button.Size
	shrinkTween:Cancel()
	restoreTween:Cancel()
	shrinkTween = TweenService:Create(button, TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset - 6, originalSize.Y.Scale, originalSize.Y.Offset - 6),
	})
	restoreTween = TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = originalSize,
	})
	shrinkTween:Play()
	shrinkTween.Completed:Once(function()
		restoreTween:Play()
	end)
end

local function startMobileCooldown(attackName, duration)
	local entry = mobileButtons[attackName]

	if not entry then
		return
	end

	entry.Token += 1
	local token = entry.Token
	entry.Button.AutoButtonColor = false
	entry.Button.Active = false
	entry.CooldownCover.Visible = true

	local startTime = os.clock()

	task.spawn(function()
		while token == entry.Token do
			local elapsed = os.clock() - startTime
			local progress = math.clamp(elapsed / duration, 0, 1)
			local remaining = math.max(duration - elapsed, 0)
			entry.CooldownCover.Size = UDim2.new(1, 0, 1 - progress, 0)
			entry.CooldownCover.Position = UDim2.new(0, 0, progress, 0)
			entry.CooldownText.Text = remaining > 0.05 and string.format("%.1f", remaining) or ""

			if progress >= 1 then
				break
			end

			task.wait()
		end

		if token ~= entry.Token then
			return
		end

		entry.CooldownCover.Visible = false
		entry.CooldownCover.Size = UDim2.new(1, 0, 0, 0)
		entry.CooldownCover.Position = UDim2.new(0, 0, 1, 0)
		entry.CooldownText.Text = ""
		entry.Button.Active = true
		entry.Button.AutoButtonColor = true
	end)
end

local function setupMobileButtons()
	if not UserInputService.TouchEnabled then
		return
	end

	local existingGui = playerGui:FindFirstChild("MobileAttackGui")

	if existingGui then
		existingGui:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MobileAttackGui"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = false
	screenGui.Parent = playerGui

	local stackFrame = Instance.new("Frame")
	stackFrame.Name = "AttackStack"
	stackFrame.AnchorPoint = Vector2.new(1, 1)
	stackFrame.Position = UDim2.new(1, -132, 1, -162)
	stackFrame.Size = UDim2.new(0, 132, 0, 132)
	stackFrame.BackgroundTransparency = 1
	stackFrame.Parent = screenGui

	local hintLabel = Instance.new("TextLabel")
	hintLabel.Name = "HintLabel"
	hintLabel.AnchorPoint = Vector2.new(0.5, 1)
	hintLabel.Position = UDim2.new(0.5, 0, 0, -6)
	hintLabel.Size = UDim2.new(0, 112, 0, 18)
	hintLabel.BackgroundTransparency = 1
	hintLabel.Font = Enum.Font.GothamBold
	hintLabel.Text = "Tap Skills"
	hintLabel.TextColor3 = Color3.fromRGB(255, 243, 176)
	hintLabel.TextSize = 11
	hintLabel.Parent = stackFrame

	local peckButton, peckCooldownCover, peckCooldownText = createAttackButton(
		stackFrame,
		"PeckButton",
		"Peck",
		UDim2.new(1, 0, 0, 62),
		Color3.fromRGB(232, 172, 52),
		UDim2.new(0, 58, 0, 58),
		13
	)

	local scratchButton, scratchCooldownCover, scratchCooldownText = createAttackButton(
		stackFrame,
		"ScratchButton",
		"Scratch",
		UDim2.new(0, 62, 1, 0),
		Color3.fromRGB(214, 110, 66),
		UDim2.new(0, 64, 0, 64),
		13
	)

	mobileButtons.Peck = {
		Button = peckButton,
		CooldownCover = peckCooldownCover,
		CooldownText = peckCooldownText,
		Token = 0,
	}

	mobileButtons.Scratch = {
		Button = scratchButton,
		CooldownCover = scratchCooldownCover,
		CooldownText = scratchCooldownText,
		Token = 0,
	}

	peckButton.Activated:Connect(function()
		tryAttack("Peck")
	end)

	scratchButton.Activated:Connect(function()
		tryAttack("Scratch")
	end)
end

local function createAttackPulse(character, attackConfig)
	local rootPart = character:FindFirstChild("HumanoidRootPart")

	if not rootPart then
		return
	end

	local pulse = Instance.new("Part")
	pulse.Name = "AttackPulse"
	pulse.Shape = Enum.PartType.Cylinder
	pulse.Size = attackConfig.PulseSize
	pulse.Material = Enum.Material.Neon
	pulse.Color = attackConfig.PulseColor
	pulse.Transparency = 0.15
	pulse.CanCollide = false
	pulse.CanQuery = false
	pulse.CanTouch = false
	pulse.Anchored = true
	pulse.CFrame = rootPart.CFrame * attackConfig.PulseOffset * CFrame.Angles(0, 0, math.rad(90))
	pulse.Parent = Workspace

	local tween = TweenService:Create(pulse, TweenInfo.new(0.12), {
		Size = attackConfig.PulseExpandSize,
		Transparency = 1,
	})

	tween:Play()
	Debris:AddItem(pulse, 0.15)
end

local function playAttackSound(rootPart, attackConfig)
	if not rootPart or not attackConfig.SoundId then
		return
	end

	local sound = Instance.new("Sound")
	sound.Name = "KenchiAttackSound"
	sound.SoundId = attackConfig.SoundId
	sound.Volume = attackConfig.SoundVolume or 0.8
	sound.PlaybackSpeed = attackConfig.SoundPitch or 1
	sound.RollOffMaxDistance = 60
	sound.Parent = rootPart
	sound:Play()
	Debris:AddItem(sound, 2)
end

local function createPeckStreak(character)
	local rootPart = character:FindFirstChild("HumanoidRootPart")

	if not rootPart then
		return
	end

	local streak = Instance.new("Part")
	streak.Name = "PeckStreak"
	streak.Size = Vector3.new(0.3, 0.65, 2.8)
	streak.Material = Enum.Material.Neon
	streak.Color = Color3.fromRGB(255, 246, 178)
	streak.Transparency = 0.1
	streak.CanCollide = false
	streak.CanQuery = false
	streak.CanTouch = false
	streak.Anchored = true
	streak.CFrame = rootPart.CFrame * CFrame.new(0, -0.8, -3.8)
	streak.Parent = Workspace

	local tween = TweenService:Create(streak, TweenInfo.new(0.1), {
		Size = Vector3.new(0.12, 0.35, 5.6),
		Transparency = 1,
		CFrame = streak.CFrame * CFrame.new(0, 0, -1.3),
	})

	tween:Play()
	Debris:AddItem(streak, 0.12)
end

local function createScratchSlashes(character)
	local rootPart = character:FindFirstChild("HumanoidRootPart")

	if not rootPart then
		return
	end

	for index, angle in ipairs({ -28, 0, 28 }) do
		local slash = Instance.new("Part")
		slash.Name = "ScratchSlash"
		slash.Size = Vector3.new(0.18, 1.9, 0.45)
		slash.Material = Enum.Material.Neon
		slash.Color = Color3.fromRGB(255, 158, 96)
		slash.Transparency = 0.08
		slash.CanCollide = false
		slash.CanQuery = false
		slash.CanTouch = false
		slash.Anchored = true
		slash.CFrame = rootPart.CFrame * CFrame.new((index - 2) * 0.5, -1.6, -2.6) * CFrame.Angles(0, 0, math.rad(angle))
		slash.Parent = Workspace

		local tween = TweenService:Create(slash, TweenInfo.new(0.12), {
			Size = Vector3.new(0.1, 3.2, 0.3),
			Transparency = 1,
			CFrame = slash.CFrame * CFrame.new(0, 0, -1.1),
		})

		tween:Play()
		Debris:AddItem(slash, 0.14)
	end
end

local function createPeckHitConfirm(position)
	local flash = Instance.new("Part")
	flash.Name = "PeckHitConfirm"
	flash.Shape = Enum.PartType.Ball
	flash.Size = Vector3.new(0.8, 0.8, 0.8)
	flash.Material = Enum.Material.Neon
	flash.Color = Color3.fromRGB(255, 248, 188)
	flash.Transparency = 0.05
	flash.CanCollide = false
	flash.CanQuery = false
	flash.CanTouch = false
	flash.Anchored = true
	flash.CFrame = CFrame.new(position)
	flash.Parent = Workspace

	local tween = TweenService:Create(flash, TweenInfo.new(0.12), {
		Size = Vector3.new(2.8, 2.8, 2.8),
		Transparency = 1,
	})

	tween:Play()
	Debris:AddItem(flash, 0.14)
end

local function createScratchHitConfirm(position)
	for _, angle in ipairs({ -30, 0, 30 }) do
		local slash = Instance.new("Part")
		slash.Name = "ScratchHitConfirm"
		slash.Size = Vector3.new(0.12, 2.2, 0.22)
		slash.Material = Enum.Material.Neon
		slash.Color = Color3.fromRGB(255, 176, 120)
		slash.Transparency = 0.04
		slash.CanCollide = false
		slash.CanQuery = false
		slash.CanTouch = false
		slash.Anchored = true
		slash.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(angle))
		slash.Parent = Workspace

		local tween = TweenService:Create(slash, TweenInfo.new(0.12), {
			Size = Vector3.new(0.06, 3.4, 0.16),
			Transparency = 1,
		})

		tween:Play()
		Debris:AddItem(slash, 0.14)
	end
end

local function playCameraPunch(targetFov)
	local camera = Workspace.CurrentCamera

	if not camera then
		return
	end

	local originalFov = camera.FieldOfView
	local punchOut = TweenService:Create(camera, TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		FieldOfView = targetFov,
	})
	local settleBack = TweenService:Create(camera, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		FieldOfView = originalFov,
	})

	punchOut:Play()
	punchOut.Completed:Once(function()
		if camera then
			settleBack:Play()
		end
	end)
end

local function doLocalAttack(attackName)
	local character = player.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoid or humanoid.Health <= 0 or not rootPart then
		return
	end

	local attackConfig = getAttackConfig(attackName)

	if not attackConfig then
		return
	end

	local forward = rootPart.CFrame.LookVector
	rootPart.AssemblyLinearVelocity = Vector3.new(forward.X * attackConfig.LungeSpeed, rootPart.AssemblyLinearVelocity.Y, forward.Z * attackConfig.LungeSpeed)
	createAttackPulse(character, attackConfig)
	playAttackSound(rootPart, attackConfig)
	playCameraPunch(attackConfig.CameraPunchFov)

	if attackName == "Peck" then
		createPeckStreak(character)
	elseif attackName == "Scratch" then
		createScratchSlashes(character)
	end

	task.delay(0.08, function()
		if rootPart.Parent then
			rootPart.AssemblyLinearVelocity = Vector3.new(forward.X * attackConfig.RecoverySpeed, rootPart.AssemblyLinearVelocity.Y, forward.Z * attackConfig.RecoverySpeed)
		end
	end)
end

tryAttack = function(attackName)
	local attackConfig = getAttackConfig(attackName)

	if not attackConfig then
		return
	end

	local now = os.clock()

	if now < attackReadyTimes[attackName] then
		return
	end

	attackReadyTimes[attackName] = now + attackConfig.Cooldown
	if mobileButtons[attackName] then
		playButtonPress(mobileButtons[attackName].Button)
		startMobileCooldown(attackName, attackConfig.Cooldown)
	end
	doLocalAttack(attackName)

	local character = player.Character
	if character then
		local tickName = attackName .. "Tick"
		local currentTick = character:GetAttribute(tickName) or 0
		character:SetAttribute(tickName, currentTick + 1)
	end

	attackRemote:FireServer(attackName)
end

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if gameProcessedEvent then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		tryAttack("Peck")
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		tryAttack("Scratch")
	end
end)

hitConfirmRemote.OnClientEvent:Connect(function(attackName, hitPosition)
	if attackName == "Peck" then
		createPeckHitConfirm(hitPosition)
		playCameraPunch(78)
	elseif attackName == "Scratch" then
		createScratchHitConfirm(hitPosition)
		playCameraPunch(75)
	end
end)

setupMobileButtons()

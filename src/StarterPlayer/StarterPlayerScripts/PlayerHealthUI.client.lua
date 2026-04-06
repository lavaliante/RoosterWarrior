local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local function getPlayerGui()
	return player:WaitForChild("PlayerGui")
end

local function createHealthGui()
	local playerGui = getPlayerGui()
	local existingGui = playerGui:FindFirstChild("PlayerHealthGui")

	if existingGui then
		existingGui:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "PlayerHealthGui"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = false
	screenGui.Parent = playerGui

	local isMobile = UserInputService.TouchEnabled

	local container = Instance.new("Frame")
	container.Name = "Container"
	container.AnchorPoint = isMobile and Vector2.new(0.5, 0) or Vector2.new(0.5, 1)
	container.Position = isMobile and UDim2.new(0.5, 0, 0, 14) or UDim2.new(0.5, 0, 1, -36)
	container.Size = isMobile and UDim2.new(0, 150, 0, 48) or UDim2.new(0, 320, 0, 56)
	container.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	container.BackgroundTransparency = 0.2
	container.BorderSizePixel = 0
	container.Parent = screenGui

	local containerCorner = Instance.new("UICorner")
	containerCorner.CornerRadius = UDim.new(0, 12)
	containerCorner.Parent = container

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 215, 90)
	stroke.Thickness = 2
	stroke.Parent = container

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0, 12, 0, 4)
	title.Size = UDim2.new(1, -24, 0, 18)
	title.Font = Enum.Font.GothamBold
	title.Text = string.upper(player:GetAttribute("SelectedRooster") or "Kenchi")
	title.TextColor3 = Color3.fromRGB(255, 243, 176)
	title.TextSize = isMobile and 11 or 14
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = container

	local barBack = Instance.new("Frame")
	barBack.Name = "BarBack"
	barBack.Position = UDim2.new(0, 12, 0, isMobile and 22 or 24)
	barBack.Size = UDim2.new(1, -24, 0, isMobile and 14 or 20)
	barBack.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	barBack.BorderSizePixel = 0
	barBack.Parent = container

	local barBackCorner = Instance.new("UICorner")
	barBackCorner.CornerRadius = UDim.new(0, 8)
	barBackCorner.Parent = barBack

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.new(1, 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(98, 255, 111)
	fill.BorderSizePixel = 0
	fill.Parent = barBack

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 8)
	fillCorner.Parent = fill

	local healthText = Instance.new("TextLabel")
	healthText.Name = "HealthText"
	healthText.BackgroundTransparency = 1
	healthText.Size = UDim2.new(1, 0, 1, 0)
	healthText.Font = Enum.Font.GothamBold
	healthText.Text = "100 / 100"
	healthText.TextColor3 = Color3.fromRGB(255, 255, 255)
	healthText.TextSize = isMobile and 10 or 13
	healthText.Parent = barBack

	return fill, healthText, title
end

local function updateHealthBar(fill, healthText, humanoid)
	local maxHealth = math.max(humanoid.MaxHealth, 1)
	local currentHealth = math.max(humanoid.Health, 0)
	local healthPercent = math.clamp(currentHealth / maxHealth, 0, 1)

	fill.Size = UDim2.new(healthPercent, 0, 1, 0)
	healthText.Text = string.format("%d / %d", math.floor(currentHealth + 0.5), math.floor(maxHealth + 0.5))

	if healthPercent > 0.6 then
		fill.BackgroundColor3 = Color3.fromRGB(98, 255, 111)
	elseif healthPercent > 0.3 then
		fill.BackgroundColor3 = Color3.fromRGB(255, 211, 87)
	else
		fill.BackgroundColor3 = Color3.fromRGB(255, 94, 94)
	end
end

local function connectCharacter(character)
	local humanoid = character:WaitForChild("Humanoid")
	local fill, healthText, title = createHealthGui()

	local function refreshTitle()
		if title.Parent then
			title.Text = string.upper(player:GetAttribute("SelectedRooster") or "Kenchi")
		end
	end

	updateHealthBar(fill, healthText, humanoid)
	refreshTitle()

	humanoid.HealthChanged:Connect(function()
		if fill.Parent and healthText.Parent then
			updateHealthBar(fill, healthText, humanoid)
		end
	end)

	humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
		if fill.Parent and healthText.Parent then
			updateHealthBar(fill, healthText, humanoid)
		end
	end)

	player:GetAttributeChangedSignal("SelectedRooster"):Connect(refreshTitle)
end

if player.Character then
	task.spawn(connectCharacter, player.Character)
end

player.CharacterAdded:Connect(connectCharacter)

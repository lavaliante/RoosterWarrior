local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local function getPlayerGui()
	return player:WaitForChild("PlayerGui")
end

local function createValueLabel(parent, name, position, size, font, textSize, textColor)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.BackgroundTransparency = 1
	label.Position = position
	label.Size = size
	label.Font = font
	label.Text = ""
	label.TextColor3 = textColor
	label.TextSize = textSize
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	return label
end

local function createFeathersGui()
	local playerGui = getPlayerGui()
	local existingGui = playerGui:FindFirstChild("FeathersGui")

	if existingGui then
		existingGui:Destroy()
	end

	local isMobile = UserInputService.TouchEnabled

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "FeathersGui"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = false
	screenGui.Parent = playerGui

	local container = Instance.new("Frame")
	container.Name = "Container"
	container.AnchorPoint = isMobile and Vector2.new(0, 0) or Vector2.new(1, 0)
	container.Position = isMobile and UDim2.new(0, 12, 0, 14) or UDim2.new(1, -20, 0, 20)
	container.Size = UDim2.new(0, isMobile and 132 or 220, 0, isMobile and 48 or 64)
	container.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	container.BackgroundTransparency = 0.15
	container.BorderSizePixel = 0
	container.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = container

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 215, 90)
	stroke.Thickness = 2
	stroke.Parent = container

	local titleLabel = createValueLabel(
		container,
		"TitleLabel",
		UDim2.new(0, 12, 0, 8),
		UDim2.new(1, -24, 0, isMobile and 14 or 18),
		Enum.Font.GothamBold,
		isMobile and 13 or 14,
		Color3.fromRGB(255, 243, 176)
	)
	titleLabel.Text = "FEATHERS"

	local countLabel = createValueLabel(
		container,
		"CountLabel",
		UDim2.new(0, 12, 0, isMobile and 22 or 28),
		UDim2.new(1, -24, 0, isMobile and 18 or 24),
		Enum.Font.GothamBold,
		isMobile and 18 or 24,
		Color3.fromRGB(255, 255, 255)
	)

	return countLabel
end

local function connectLeaderstats()
	local leaderstats = player:WaitForChild("leaderstats")
	local feathers = leaderstats:WaitForChild("Feathers")
	local countLabel = createFeathersGui()

	local function refresh()
		if countLabel.Parent then
			countLabel.Text = tostring(feathers.Value)
		end
	end

	refresh()
	feathers.Changed:Connect(refresh)
end

connectLeaderstats()

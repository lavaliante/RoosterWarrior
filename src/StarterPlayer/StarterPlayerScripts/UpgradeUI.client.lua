local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local upgradePurchaseRemote = remotesFolder:WaitForChild("UpgradePurchase")

local UPGRADES = {
	{
		Name = "Health",
		Label = "Health",
		Description = "+20 max HP",
		MobileDescription = "+20 HP",
		BaseCost = 25,
		CostStep = 15,
		MaxLevel = 5,
		Color = Color3.fromRGB(98, 255, 111),
	},
	{
		Name = "Damage",
		Label = "Damage",
		Description = "Stronger peck and scratch",
		MobileDescription = "+attack dmg",
		BaseCost = 30,
		CostStep = 20,
		MaxLevel = 5,
		Color = Color3.fromRGB(255, 170, 88),
	},
}

local function getUpgradeCost(config, level)
	return config.BaseCost + level * config.CostStep
end

local function createTextLabel(parent, position, size, font, textSize, textColor, text)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = position
	label.Size = size
	label.Font = font
	label.TextSize = textSize
	label.TextColor3 = textColor
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.TextWrapped = false
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.ClipsDescendants = true
	label.Text = text or ""
	label.Parent = parent
	return label
end

local function createToggleButton(parent, name, text, position, color)
	local button = Instance.new("TextButton")
	button.Name = name
	button.AnchorPoint = Vector2.new(0, 0)
	button.Position = position
	button.Size = UDim2.new(0, 42, 0, 42)
	button.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	button.BackgroundTransparency = 0.12
	button.BorderSizePixel = 0
	button.Text = text
	button.Font = Enum.Font.GothamBold
	button.TextSize = 12
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = 2
	stroke.Parent = button

	return button
end

local function setPanelOpen(panel, openPosition, closedPosition, open)
	panel.Visible = true
	panel.Position = open and closedPosition or openPosition

	local tween = TweenService:Create(panel, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = open and openPosition or closedPosition,
	})

	tween:Play()

	if not open then
		tween.Completed:Once(function()
			panel.Visible = false
		end)
	end
end

local function createUpgradeButton(parent, title, color, isMobile)
	local button = Instance.new("TextButton")
	button.Name = title .. "Button"
	button.Size = UDim2.new(1, 0, 0, isMobile and 50 or 58)
	button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	button.BackgroundTransparency = 0.08
	button.BorderSizePixel = 0
	button.AutoButtonColor = true
	button.Text = ""
	button.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = 2
	stroke.Parent = button

	local titleLabel = createTextLabel(button, UDim2.new(0, 10, 0, isMobile and 4 or 6), UDim2.new(1, -20, 0, 16), Enum.Font.GothamBold, isMobile and 12 or 15, Color3.fromRGB(255, 255, 255), title)
	local descLabel = createTextLabel(button, UDim2.new(0, 10, 0, isMobile and 19 or 24), UDim2.new(1, -20, 0, 12), Enum.Font.Gotham, isMobile and 9 or 12, Color3.fromRGB(210, 210, 210), "")
	local costLabel = createTextLabel(button, UDim2.new(0, 10, 0, isMobile and 32 or 40), UDim2.new(1, -20, 0, 14), Enum.Font.GothamBold, isMobile and 10 or 13, color, "")

	return button, titleLabel, descLabel, costLabel
end

local function createUpgradeGui()
	local playerGui = player:WaitForChild("PlayerGui")
	local existingGui = playerGui:FindFirstChild("UpgradeGui")

	if existingGui then
		existingGui:Destroy()
	end

	local isMobile = UserInputService.TouchEnabled

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "UpgradeGui"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = false
	screenGui.Parent = playerGui

	local container = Instance.new("Frame")
	container.Name = "Container"
	container.AnchorPoint = isMobile and Vector2.new(0, 0) or Vector2.new(0, 1)
	local openPosition = isMobile and UDim2.new(0, 12, 0, 116) or UDim2.new(0, 20, 1, -36)
	local closedPosition = isMobile and UDim2.new(0, -168, 0, 116) or openPosition
	container.Position = openPosition
	container.Size = isMobile and UDim2.new(0, 156, 0, 158) or UDim2.new(0, 250, 0, 190)
	container.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	container.BackgroundTransparency = 0.15
	container.BorderSizePixel = 0
	container.Parent = screenGui
	container.Visible = not isMobile

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = container

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 215, 90)
	stroke.Thickness = 2
	stroke.Parent = container

	if isMobile then
		local toggleButton = createToggleButton(screenGui, "UpgradeToggle", "UP", UDim2.new(0, 12, 0, 66), Color3.fromRGB(255, 215, 90))
		local isOpen = false
		toggleButton.Activated:Connect(function()
			isOpen = not isOpen
			setPanelOpen(container, openPosition, closedPosition, isOpen)
			toggleButton.Rotation = isOpen and 12 or 0
		end)
	end

	local title = createTextLabel(container, UDim2.new(0, 10, 0, 8), UDim2.new(1, -20, 0, 16), Enum.Font.GothamBold, isMobile and 12 or 14, Color3.fromRGB(255, 243, 176), "UPGRADES")
	local subtitle = createTextLabel(container, UDim2.new(0, 10, 0, 24), UDim2.new(1, -20, 0, 12), Enum.Font.Gotham, isMobile and 9 or 12, Color3.fromRGB(210, 210, 210), isMobile and "Boosts" or "Spend feathers for permanent power")

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, isMobile and 6 or 10)

	local listFrame = Instance.new("Frame")
	listFrame.Name = "ListFrame"
	listFrame.BackgroundTransparency = 1
	listFrame.Position = UDim2.new(0, 10, 0, isMobile and 40 or 56)
	listFrame.Size = UDim2.new(1, -20, 1, isMobile and -48 or -66)
	listFrame.Parent = container
	listLayout.Parent = listFrame

	local entries = {}

	for _, upgradeConfig in ipairs(UPGRADES) do
		local button, _, descLabel, costLabel = createUpgradeButton(listFrame, upgradeConfig.Label, upgradeConfig.Color, isMobile)
		entries[upgradeConfig.Name] = {
			Button = button,
			Description = descLabel,
			Cost = costLabel,
			Config = upgradeConfig,
		}
	end

	return screenGui, entries
end

local function connectUpgradeUi()
	local leaderstats = player:WaitForChild("leaderstats")
	local feathers = leaderstats:WaitForChild("Feathers")
	local upgradeFolder = player:WaitForChild("UpgradeData")
	local _, entries = createUpgradeGui()
	local isMobile = UserInputService.TouchEnabled

	local function refresh()
		for upgradeName, entry in pairs(entries) do
			local levelValue = upgradeFolder:WaitForChild(upgradeName)
			local level = levelValue.Value
			local config = entry.Config

			local descriptionText = isMobile and (config.MobileDescription or config.Description) or config.Description
			entry.Description.Text = string.format("%s  |  Lv %d/%d", descriptionText, level, config.MaxLevel)

			if level >= config.MaxLevel then
				entry.Cost.Text = "MAXED"
				entry.Cost.TextColor3 = Color3.fromRGB(255, 221, 92)
				entry.Button.Active = false
				entry.Button.AutoButtonColor = false
			else
				local cost = getUpgradeCost(config, level)
				entry.Cost.Text = isMobile and string.format("Cost: %d", cost) or string.format("Buy for %d feathers", cost)
				entry.Button.Active = true
				entry.Button.AutoButtonColor = feathers.Value >= cost

				if feathers.Value >= cost then
					entry.Cost.TextColor3 = config.Color
				else
					entry.Cost.TextColor3 = Color3.fromRGB(180, 180, 180)
				end
			end
		end
	end

	for upgradeName, entry in pairs(entries) do
		entry.Button.Activated:Connect(function()
			upgradePurchaseRemote:FireServer(upgradeName)
		end)
	end

	feathers.Changed:Connect(refresh)

	for _, upgradeConfig in ipairs(UPGRADES) do
		upgradeFolder:WaitForChild(upgradeConfig.Name).Changed:Connect(refresh)
	end

	refresh()
end

connectUpgradeUi()

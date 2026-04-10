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

local function createOverlay(screenGui)
	local overlay = Instance.new("TextButton")
	overlay.Name = "Overlay"
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.Position = UDim2.fromScale(0, 0)
	overlay.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
	overlay.BackgroundTransparency = 1
	overlay.BorderSizePixel = 0
	overlay.Text = ""
	overlay.AutoButtonColor = false
	overlay.Visible = false
	overlay.Parent = screenGui

	return overlay
end

local function setOverlayOpen(overlay, panel, open, toggleButton)
	overlay.Visible = true
	panel.Visible = true

	local overlayTween = TweenService:Create(overlay, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = open and 0.28 or 1,
	})
	local panelTween = TweenService:Create(panel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = open and 0.08 or 1,
		Size = open and panel:GetAttribute("OpenSize") or panel:GetAttribute("ClosedSize"),
	})

	overlayTween:Play()
	panelTween:Play()

	if toggleButton then
		toggleButton.Rotation = open and 12 or 0
	end

	if not open then
		panelTween.Completed:Once(function()
			if panel.Parent then
				panel.Visible = false
			end
			if overlay.Parent then
				overlay.Visible = false
			end
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

	local overlay = createOverlay(screenGui)
	local container = Instance.new("Frame")
	container.Name = "Container"
	container.AnchorPoint = Vector2.new(0.5, 0.5)
	container.Position = UDim2.fromScale(0.5, 0.5)
	local openSize = isMobile and UDim2.new(0.92, 0, 0.7, 0) or UDim2.new(0.64, 0, 0.72, 0)
	local closedSize = isMobile and UDim2.new(0.92, 0, 0.62, 0) or UDim2.new(0.58, 0, 0.64, 0)
	container.Size = closedSize
	container.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.Parent = screenGui
	container.Visible = false
	container:SetAttribute("OpenSize", openSize)
	container:SetAttribute("ClosedSize", closedSize)

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = container

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 215, 90)
	stroke.Thickness = 2
	stroke.Parent = container

	local toggleButton = createToggleButton(screenGui, "UpgradeToggle", "UP", UDim2.new(0, 12, 0, 66), Color3.fromRGB(255, 215, 90))
	local isOpen = false

	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.AnchorPoint = Vector2.new(1, 0)
	closeButton.Position = UDim2.new(1, -12, 0, 12)
	closeButton.Size = UDim2.new(0, 34, 0, 34)
	closeButton.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
	closeButton.BackgroundTransparency = 0.12
	closeButton.BorderSizePixel = 0
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Text = "X"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextSize = 14
	closeButton.Parent = container

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(1, 0)
	closeCorner.Parent = closeButton

	local function setOpen(open)
		isOpen = open
		setOverlayOpen(overlay, container, open, toggleButton)
	end

	toggleButton.Activated:Connect(function()
		setOpen(not isOpen)
	end)

	closeButton.Activated:Connect(function()
		setOpen(false)
	end)

	overlay.Activated:Connect(function()
		setOpen(false)
	end)

	local title = createTextLabel(container, UDim2.new(0, 18, 0, 16), UDim2.new(1, -72, 0, 22), Enum.Font.GothamBold, isMobile and 18 or 24, Color3.fromRGB(255, 243, 176), "UPGRADES")
	local subtitle = createTextLabel(container, UDim2.new(0, 18, 0, 42), UDim2.new(1, -72, 0, 18), Enum.Font.Gotham, isMobile and 12 or 14, Color3.fromRGB(210, 210, 210), "Spend feathers for permanent power")

	local listPadding = isMobile and 10 or 12
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = "ScrollFrame"
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.BorderSizePixel = 0
	scrollFrame.Position = UDim2.new(0, 18, 0, 76)
	scrollFrame.Size = UDim2.new(1, -36, 1, -94)
	scrollFrame.ScrollBarThickness = isMobile and 5 or 7
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollFrame.Parent = container

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, listPadding)

	local listFrame = Instance.new("Frame")
	listFrame.Name = "ListFrame"
	listFrame.BackgroundTransparency = 1
	listFrame.Size = UDim2.new(1, -4, 0, 0)
	listFrame.AutomaticSize = Enum.AutomaticSize.Y
	listFrame.Parent = scrollFrame
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

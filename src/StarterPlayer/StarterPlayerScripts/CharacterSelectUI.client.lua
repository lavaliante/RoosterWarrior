local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local characterSelectRemote = remotesFolder:WaitForChild("CharacterSelect")

local CHARACTERS = {
	{
		Name = "Kenchi",
		Subtitle = "Balanced fighter",
		Stats = "Normal health, normal damage",
		MobileStats = "Balanced",
		Color = Color3.fromRGB(255, 221, 112),
	},
	{
		Name = "Chico",
		Subtitle = "Heavy bruiser",
		Stats = "+30 health, +4 damage, slower speed",
		MobileStats = "+30 HP, +4 DMG",
		Color = Color3.fromRGB(255, 120, 120),
	},
}

local function createLabel(parent, position, size, font, textSize, color, text)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = position
	label.Size = size
	label.Font = font
	label.TextSize = textSize
	label.TextColor3 = color
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
	button.AnchorPoint = Vector2.new(1, 0)
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

local function createCharacterButton(parent, characterInfo, isMobile)
	local button = Instance.new("TextButton")
	button.Name = characterInfo.Name .. "Button"
	button.Size = UDim2.new(1, 0, 0, isMobile and 52 or 62)
	button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	button.BackgroundTransparency = 0.08
	button.BorderSizePixel = 0
	button.Text = ""
	button.AutoButtonColor = true
	button.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.Color = characterInfo.Color
	stroke.Thickness = 2
	stroke.Parent = button

	createLabel(button, UDim2.new(0, 10, 0, isMobile and 5 or 7), UDim2.new(1, -20, 0, 16), Enum.Font.GothamBold, isMobile and 12 or 15, Color3.fromRGB(255, 255, 255), characterInfo.Name)
	createLabel(button, UDim2.new(0, 10, 0, isMobile and 20 or 24), UDim2.new(1, -20, 0, 12), Enum.Font.Gotham, isMobile and 9 or 12, Color3.fromRGB(210, 210, 210), characterInfo.Subtitle)
	local statusLabel = createLabel(button, UDim2.new(0, 10, 0, isMobile and 33 or 40), UDim2.new(1, -20, 0, 14), Enum.Font.GothamBold, isMobile and 9 or 12, characterInfo.Color, isMobile and (characterInfo.MobileStats or characterInfo.Stats) or characterInfo.Stats)

	return button, stroke, statusLabel
end

local function createCharacterGui()
	local playerGui = player:WaitForChild("PlayerGui")
	local existingGui = playerGui:FindFirstChild("CharacterSelectGui")

	if existingGui then
		existingGui:Destroy()
	end

	local isMobile = UserInputService.TouchEnabled

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CharacterSelectGui"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = false
	screenGui.Parent = playerGui

	local container = Instance.new("Frame")
	container.Name = "Container"
	container.AnchorPoint = isMobile and Vector2.new(1, 0) or Vector2.new(1, 1)
	local openPosition = isMobile and UDim2.new(1, -12, 0, 146) or UDim2.new(1, -20, 1, -36)
	local closedPosition = isMobile and UDim2.new(1, 176, 0, 146) or openPosition
	container.Position = openPosition
	container.Size = isMobile and UDim2.new(0, 164, 0, 160) or UDim2.new(0, 260, 0, 196)
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

	local setOpen = function() end

	if isMobile then
		local toggleButton = createToggleButton(screenGui, "RoosterToggle", "RO", UDim2.new(1, -12, 0, 96), Color3.fromRGB(255, 215, 90))
		local isOpen = false
		setOpen = function(open)
			isOpen = open
			setPanelOpen(container, openPosition, closedPosition, isOpen)
			toggleButton.Rotation = isOpen and -12 or 0
		end
		toggleButton.Activated:Connect(function()
			setOpen(not isOpen)
		end)
	end

	createLabel(container, UDim2.new(0, 10, 0, 8), UDim2.new(1, -20, 0, 16), Enum.Font.GothamBold, isMobile and 12 or 14, Color3.fromRGB(255, 243, 176), "ROOSTERS")
	createLabel(container, UDim2.new(0, 10, 0, 24), UDim2.new(1, -20, 0, 12), Enum.Font.Gotham, isMobile and 9 or 12, Color3.fromRGB(210, 210, 210), isMobile and "Tap to switch" or "Switch your fighter anytime")

	local listFrame = Instance.new("Frame")
	listFrame.Name = "ListFrame"
	listFrame.BackgroundTransparency = 1
	listFrame.Position = UDim2.new(0, 10, 0, isMobile and 40 or 56)
	listFrame.Size = UDim2.new(1, -20, 1, isMobile and -48 or -68)
	listFrame.Parent = container

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, isMobile and 6 or 10)
	layout.Parent = listFrame

	local entries = {}

	for _, characterInfo in ipairs(CHARACTERS) do
		local button, entryStroke, statusLabel = createCharacterButton(listFrame, characterInfo, isMobile)
		entries[characterInfo.Name] = {
			Button = button,
			Stroke = entryStroke,
			Status = statusLabel,
			Color = characterInfo.Color,
			Stats = characterInfo.Stats,
			MobileStats = characterInfo.MobileStats or characterInfo.Stats,
		}
	end

	return entries, container, isMobile, setOpen
end

local function connectCharacterUi()
	local entries, container, isMobile, setOpen = createCharacterGui()

	local function refresh()
		local selectedRooster = player:GetAttribute("SelectedRooster") or "Kenchi"

		for roosterName, entry in pairs(entries) do
			if roosterName == selectedRooster then
				entry.Stroke.Thickness = 3
				entry.Status.Text = isMobile and "Selected" or "Selected  |  " .. entry.Stats
				entry.Status.TextColor3 = entry.Color
			else
				entry.Stroke.Thickness = 2
				entry.Status.Text = isMobile and entry.MobileStats or entry.Stats
				entry.Status.TextColor3 = entry.Color
			end
		end
	end

	for roosterName, entry in pairs(entries) do
		entry.Button.Activated:Connect(function()
			characterSelectRemote:FireServer(roosterName)
			if isMobile then
				setOpen(false)
			end
		end)
	end

	player:GetAttributeChangedSignal("SelectedRooster"):Connect(refresh)
	refresh()
end

connectCharacterUi()

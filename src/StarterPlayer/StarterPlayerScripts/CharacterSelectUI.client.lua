local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local configFolder = ReplicatedStorage:WaitForChild("Config")
local characterSelectRemote = remotesFolder:WaitForChild("CharacterSelect")
local CharacterConfig = require(configFolder:WaitForChild("CharacterConfig"))
local CHARACTERS = CharacterConfig.List
local cooldownRefreshToken = 0

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
		toggleButton.Rotation = open and -12 or 0
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
	stroke.Color = characterInfo.ThemeColor
	stroke.Thickness = 2
	stroke.Parent = button

	createLabel(button, UDim2.new(0, 10, 0, isMobile and 5 or 7), UDim2.new(1, -20, 0, 16), Enum.Font.GothamBold, isMobile and 12 or 15, Color3.fromRGB(255, 255, 255), characterInfo.Name)
	createLabel(button, UDim2.new(0, 10, 0, isMobile and 20 or 24), UDim2.new(1, -20, 0, 12), Enum.Font.Gotham, isMobile and 9 or 12, Color3.fromRGB(210, 210, 210), characterInfo.Subtitle)
	local statusLabel = createLabel(button, UDim2.new(0, 10, 0, isMobile and 33 or 40), UDim2.new(1, -20, 0, 14), Enum.Font.GothamBold, isMobile and 9 or 12, characterInfo.ThemeColor, isMobile and (characterInfo.MobileStats or characterInfo.Stats) or characterInfo.Stats)

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

	local overlay = createOverlay(screenGui)
	local container = Instance.new("Frame")
	container.Name = "Container"
	container.AnchorPoint = Vector2.new(0.5, 0.5)
	container.Position = UDim2.fromScale(0.5, 0.5)
	local openSize = isMobile and UDim2.new(0.92, 0, 0.72, 0) or UDim2.new(0.64, 0, 0.74, 0)
	local closedSize = isMobile and UDim2.new(0.92, 0, 0.64, 0) or UDim2.new(0.58, 0, 0.66, 0)
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

	local toggleButton = createToggleButton(screenGui, "RoosterToggle", "RO", UDim2.new(1, -12, 0, 96), Color3.fromRGB(255, 215, 90))
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

	createLabel(container, UDim2.new(0, 18, 0, 16), UDim2.new(1, -72, 0, 22), Enum.Font.GothamBold, isMobile and 18 or 24, Color3.fromRGB(255, 243, 176), "ROOSTERS")
	createLabel(container, UDim2.new(0, 18, 0, 42), UDim2.new(1, -72, 0, 18), Enum.Font.Gotham, isMobile and 12 or 14, Color3.fromRGB(210, 210, 210), "Switch your fighter anytime")

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

	local listFrame = Instance.new("Frame")
	listFrame.Name = "ListFrame"
	listFrame.BackgroundTransparency = 1
	listFrame.Size = UDim2.new(1, -4, 0, 0)
	listFrame.AutomaticSize = Enum.AutomaticSize.Y
	listFrame.Parent = scrollFrame

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
			Color = characterInfo.ThemeColor,
			Stats = characterInfo.Stats,
			MobileStats = characterInfo.MobileStats or characterInfo.Stats,
		}
	end

	return entries, container, isMobile, setOpen
end

local function connectCharacterUi()
	local entries, container, isMobile, setOpen = createCharacterGui()

	local function getSwapRemaining()
		local availableAt = player:GetAttribute("RoosterSwapAvailableAt") or 0
		return math.max(0, availableAt - Workspace:GetServerTimeNow())
	end

	local function refresh()
		local selectedRooster = player:GetAttribute("SelectedRooster") or "Kenchi"
		local remaining = getSwapRemaining()
		local cooldownActive = remaining > 0.05

		for roosterName, entry in pairs(entries) do
			local isSelected = roosterName == selectedRooster
			entry.Button.Active = not cooldownActive
			entry.Button.AutoButtonColor = not cooldownActive
			entry.Button.BackgroundTransparency = cooldownActive and 0.22 or 0.08

			if isSelected then
				entry.Stroke.Thickness = 3
				entry.Status.Text = isMobile and "Selected" or "Selected  |  " .. entry.Stats
				entry.Status.TextColor3 = entry.Color
			elseif cooldownActive then
				entry.Stroke.Thickness = 2
				entry.Status.Text = string.format("Ready in %.1fs", remaining)
				entry.Status.TextColor3 = Color3.fromRGB(255, 221, 92)
			else
				entry.Stroke.Thickness = 2
				entry.Status.Text = isMobile and entry.MobileStats or entry.Stats
				entry.Status.TextColor3 = entry.Color
			end
		end

		cooldownRefreshToken += 1
		local token = cooldownRefreshToken
		if cooldownActive then
			task.spawn(function()
				while token == cooldownRefreshToken and getSwapRemaining() > 0.05 do
					task.wait(0.1)
				end

				if token == cooldownRefreshToken then
					refresh()
				end
			end)
		end
	end

	for roosterName, entry in pairs(entries) do
		entry.Button.Activated:Connect(function()
			if getSwapRemaining() > 0.05 then
				return
			end

			characterSelectRemote:FireServer(roosterName)
			if isMobile then
				setOpen(false)
			end
		end)
	end

	player:GetAttributeChangedSignal("SelectedRooster"):Connect(refresh)
	player:GetAttributeChangedSignal("RoosterSwapAvailableAt"):Connect(refresh)
	refresh()
end

connectCharacterUi()


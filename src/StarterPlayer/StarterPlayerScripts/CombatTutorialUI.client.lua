local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local tutorialProgressRemote = remotesFolder:WaitForChild("TutorialProgress")

local function getPlayerGui()
	return player:WaitForChild("PlayerGui")
end

local function createLabel(parent, text, position, size, font, textSize, textColor)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = position
	label.Size = size
	label.Font = font
	label.Text = text
	label.TextColor3 = textColor
	label.TextSize = textSize
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.Parent = parent
	return label
end

local function ensureTutorialAttributes()
	if player:GetAttribute("TutorialPeckLearned") == nil then
		player:SetAttribute("TutorialPeckLearned", false)
	end

	if player:GetAttribute("TutorialScratchLearned") == nil then
		player:SetAttribute("TutorialScratchLearned", false)
	end

	if player:GetAttribute("CombatTutorialComplete") == nil then
		player:SetAttribute("CombatTutorialComplete", false)
	end
end

local function buildTutorialGui()
	local playerGui = getPlayerGui()
	local existingGui = playerGui:FindFirstChild("CombatTutorialGui")
	if existingGui then
		existingGui:Destroy()
	end

	local isMobile = UserInputService.TouchEnabled

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CombatTutorialGui"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = false
	screenGui.Parent = playerGui

	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.AnchorPoint = Vector2.new(0.5, 0)
	panel.Position = isMobile and UDim2.new(0.5, 0, 0, 112) or UDim2.new(0.5, 0, 0, 100)
	panel.Size = isMobile and UDim2.new(0, 300, 0, 118) or UDim2.new(0, 360, 0, 126)
	panel.BackgroundColor3 = Color3.fromRGB(23, 20, 16)
	panel.BackgroundTransparency = 0.12
	panel.BorderSizePixel = 0
	panel.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 14)
	corner.Parent = panel

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 215, 90)
	stroke.Thickness = 2
	stroke.Parent = panel

	createLabel(panel, "Combat Tutorial", UDim2.new(0, 16, 0, 12), UDim2.new(1, -32, 0, 22), Enum.Font.GothamBold, isMobile and 15 or 17, Color3.fromRGB(255, 240, 184))
	createLabel(panel, isMobile and "Use both attacks once before the fighting starts." or "Practice both attacks once before the fighting starts.", UDim2.new(0, 16, 0, 36), UDim2.new(1, -32, 0, 18), Enum.Font.Gotham, isMobile and 12 or 13, Color3.fromRGB(229, 229, 229))
	createLabel(panel, isMobile and "Peck: tap the Peck button" or "Peck: Left Mouse or F", UDim2.new(0, 16, 0, 62), UDim2.new(1, -32, 0, 18), Enum.Font.Gotham, isMobile and 12 or 13, Color3.fromRGB(255, 216, 116))
	createLabel(panel, isMobile and "Scratch: tap the Scratch button" or "Scratch: Right Mouse or G", UDim2.new(0, 16, 0, 80), UDim2.new(1, -32, 0, 18), Enum.Font.Gotham, isMobile and 12 or 13, Color3.fromRGB(255, 166, 116))

	local peckStatus = createLabel(panel, "[ ] Use Peck", UDim2.new(0, 190, 0, 62), UDim2.new(0, 150, 0, 18), Enum.Font.GothamBold, isMobile and 12 or 13, Color3.fromRGB(255, 255, 255))
	local scratchStatus = createLabel(panel, "[ ] Use Scratch", UDim2.new(0, 190, 0, 80), UDim2.new(0, 150, 0, 18), Enum.Font.GothamBold, isMobile and 12 or 13, Color3.fromRGB(255, 255, 255))

	return panel, peckStatus, scratchStatus
end

ensureTutorialAttributes()

local panel, peckStatus, scratchStatus = buildTutorialGui()
local dismissed = false
local tutorialReported = false

local function refreshTutorialState()
	local peckLearned = player:GetAttribute("TutorialPeckLearned") == true
	local scratchLearned = player:GetAttribute("TutorialScratchLearned") == true
	local tutorialComplete = player:GetAttribute("CombatTutorialComplete") == true

	peckStatus.Text = peckLearned and "[X] Use Peck" or "[ ] Use Peck"
	peckStatus.TextColor3 = peckLearned and Color3.fromRGB(117, 255, 130) or Color3.fromRGB(255, 255, 255)

	scratchStatus.Text = scratchLearned and "[X] Use Scratch" or "[ ] Use Scratch"
	scratchStatus.TextColor3 = scratchLearned and Color3.fromRGB(117, 255, 130) or Color3.fromRGB(255, 255, 255)

	if tutorialComplete and not tutorialReported then
		tutorialReported = true
		tutorialProgressRemote:FireServer("CombatTutorialComplete")
	end

	if tutorialComplete and not dismissed then
		dismissed = true
		local fadeTween = TweenService:Create(panel, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1,
		})
		local moveTween = TweenService:Create(panel, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = panel.Position - UDim2.new(0, 0, 0, 10),
		})
		fadeTween:Play()
		moveTween:Play()
		for _, descendant in ipairs(panel:GetDescendants()) do
			if descendant:IsA("TextLabel") or descendant:IsA("UIStroke") then
				TweenService:Create(descendant, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Transparency = 1,
				}):Play()
			end
		end
		fadeTween.Completed:Once(function()
			if panel.Parent then
				panel.Parent:Destroy()
			end
		end)
	else
		panel.Visible = not tutorialComplete
	end
end

player:GetAttributeChangedSignal("TutorialPeckLearned"):Connect(refreshTutorialState)
player:GetAttributeChangedSignal("TutorialScratchLearned"):Connect(refreshTutorialState)
player:GetAttributeChangedSignal("CombatTutorialComplete"):Connect(refreshTutorialState)

refreshTutorialState()



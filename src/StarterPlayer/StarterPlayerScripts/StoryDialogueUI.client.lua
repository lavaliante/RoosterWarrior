local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local storyDialogueRemote = remotesFolder:WaitForChild("StoryDialogue")

local function getPlayerGui()
	return player:WaitForChild("PlayerGui")
end

local function buildDialogueGui()
	local playerGui = getPlayerGui()
	local existingGui = playerGui:FindFirstChild("StoryDialogueGui")
	if existingGui then
		existingGui:Destroy()
	end

	local isMobile = UserInputService.TouchEnabled

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "StoryDialogueGui"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = false
	screenGui.Parent = playerGui

	local container = Instance.new("Frame")
	container.Name = "Container"
	container.AnchorPoint = Vector2.new(0.5, 1)
	container.Position = isMobile and UDim2.new(0.5, 0, 1, -74) or UDim2.new(0.5, 0, 1, -84)
	container.Size = isMobile and UDim2.new(0, 320, 0, 92) or UDim2.new(0, 420, 0, 108)
	container.BackgroundColor3 = Color3.fromRGB(25, 19, 15)
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.Visible = false
	container.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 14)
	corner.Parent = container

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(201, 149, 60)
	stroke.Thickness = 2
	stroke.Transparency = 1
	stroke.Parent = container

	local speakerLabel = Instance.new("TextLabel")
	speakerLabel.Name = "SpeakerLabel"
	speakerLabel.BackgroundTransparency = 1
	speakerLabel.Position = UDim2.new(0, 16, 0, 10)
	speakerLabel.Size = UDim2.new(1, -32, 0, 20)
	speakerLabel.Font = Enum.Font.GothamBold
	speakerLabel.Text = ""
	speakerLabel.TextColor3 = Color3.fromRGB(255, 229, 164)
	speakerLabel.TextSize = isMobile and 14 or 16
	speakerLabel.TextXAlignment = Enum.TextXAlignment.Left
	speakerLabel.Parent = container

	local bodyLabel = Instance.new("TextLabel")
	bodyLabel.Name = "BodyLabel"
	bodyLabel.BackgroundTransparency = 1
	bodyLabel.Position = UDim2.new(0, 16, 0, 34)
	bodyLabel.Size = UDim2.new(1, -32, 1, -46)
	bodyLabel.Font = Enum.Font.Gotham
	bodyLabel.Text = ""
	bodyLabel.TextColor3 = Color3.fromRGB(244, 239, 228)
	bodyLabel.TextSize = isMobile and 13 or 15
	bodyLabel.TextWrapped = true
	bodyLabel.TextXAlignment = Enum.TextXAlignment.Left
	bodyLabel.TextYAlignment = Enum.TextYAlignment.Top
	bodyLabel.Parent = container

	return screenGui, container, stroke, speakerLabel, bodyLabel
end

local _, container, stroke, speakerLabel, bodyLabel = buildDialogueGui()
local activeDialogueToken = 0

local function showDialogue(payload)
	activeDialogueToken += 1
	local dialogueToken = activeDialogueToken

	speakerLabel.Text = tostring(payload.Speaker or "Villager")
	bodyLabel.Text = tostring(payload.Text or "...")
	container.Visible = true

	TweenService:Create(container, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.08,
	}):Play()

	TweenService:Create(stroke, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Transparency = 0,
	}):Play()

	task.delay(3.25, function()
		if dialogueToken ~= activeDialogueToken or not container.Parent then
			return
		end

		local fadeFrame = TweenService:Create(container, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1,
		})
		local fadeStroke = TweenService:Create(stroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 1,
		})
		fadeFrame:Play()
		fadeStroke:Play()
		fadeFrame.Completed:Once(function()
			if dialogueToken == activeDialogueToken and container.Parent then
				container.Visible = false
			end
		end)
	end)
end

storyDialogueRemote.OnClientEvent:Connect(showDialogue)

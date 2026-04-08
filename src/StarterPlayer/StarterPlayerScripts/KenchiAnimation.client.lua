local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local ATTACK_FLAP_DURATION = 0.22
local ANIMATION_UPDATE_INTERVAL = 1 / 30

local activeConnection
local activeTrack = {
	lastPeck = 0,
	lastScratch = 0,
}
local animationElapsed = 0

local function applyJointC0(joint, baseC0, offset)
	if joint and joint.Parent then
		joint.C0 = baseC0 * offset
	end
end

local function hookAttackTracking(character)
	character:GetAttributeChangedSignal("PeckTick"):Connect(function()
		activeTrack.lastPeck = os.clock()
	end)

	character:GetAttributeChangedSignal("ScratchTick"):Connect(function()
		activeTrack.lastScratch = os.clock()
	end)

	activeTrack.lastPeck = 0
	activeTrack.lastScratch = 0
end

local function startAnimation(character)
	if activeConnection then
		activeConnection:Disconnect()
		activeConnection = nil
	end

	local humanoid = character:WaitForChild("Humanoid")
	local morphModel = character:WaitForChild("RoosterMorph")
	local jointsFolder = morphModel:WaitForChild("Joints")

	local bodyJoint = jointsFolder:FindFirstChild("RoosterBodyJoint")
	local chestJoint = jointsFolder:FindFirstChild("RoosterChestJoint")
	local headJoint = jointsFolder:FindFirstChild("RoosterFaceJoint")
	local leftWingJoint = jointsFolder:FindFirstChild("LeftWingJoint")
	local rightWingJoint = jointsFolder:FindFirstChild("RightWingJoint")
	local leftWingTipJoint = jointsFolder:FindFirstChild("LeftWingTipJoint")
	local rightWingTipJoint = jointsFolder:FindFirstChild("RightWingTipJoint")
	local tail1Joint = jointsFolder:FindFirstChild("Tail1Joint")
	local tail2Joint = jointsFolder:FindFirstChild("Tail2Joint")
	local tail3Joint = jointsFolder:FindFirstChild("Tail3Joint")

	local baseC0 = {
		body = bodyJoint and bodyJoint.C0,
		chest = chestJoint and chestJoint.C0,
		head = headJoint and headJoint.C0,
		leftWing = leftWingJoint and leftWingJoint.C0,
		rightWing = rightWingJoint and rightWingJoint.C0,
		leftWingTip = leftWingTipJoint and leftWingTipJoint.C0,
		rightWingTip = rightWingTipJoint and rightWingTipJoint.C0,
		tail1 = tail1Joint and tail1Joint.C0,
		tail2 = tail2Joint and tail2Joint.C0,
		tail3 = tail3Joint and tail3Joint.C0,
	}

	hookAttackTracking(character)
	animationElapsed = 0

	activeConnection = RunService.RenderStepped:Connect(function(deltaTime)
		animationElapsed += deltaTime
		if animationElapsed < ANIMATION_UPDATE_INTERVAL then
			return
		end

		animationElapsed = 0

		if not character.Parent or humanoid.Health <= 0 then
			return
		end

		if player:GetAttribute("SelectedRooster") == "Keijuke" then
			return
		end

		local now = os.clock()
		local moveSpeed = humanoid.MoveDirection.Magnitude
		local moving = moveSpeed > 0.05
		local bobTime = tick() * 8
		local idleTime = tick() * 3
		local bobAmount = moving and math.sin(bobTime) * 0.12 or math.sin(idleTime) * 0.05
		local swayAmount = moving and math.sin(bobTime * 0.5) * 0.05 or 0
		local headNod = moving and math.sin(bobTime) * math.rad(4) or math.sin(idleTime) * math.rad(2)
		local wingFlap = moving and math.sin(bobTime) * math.rad(8) or math.sin(idleTime) * math.rad(3)
		local tailSwing = moving and math.sin(bobTime * 0.7) * math.rad(7) or math.sin(idleTime * 0.8) * math.rad(3)

		local peckAlpha = 1 - math.clamp((now - activeTrack.lastPeck) / ATTACK_FLAP_DURATION, 0, 1)
		local scratchAlpha = 1 - math.clamp((now - activeTrack.lastScratch) / ATTACK_FLAP_DURATION, 0, 1)
		local attackBodyDip = peckAlpha * -0.28
		local attackHeadThrust = peckAlpha * 0.42
		local attackWingBurst = math.max(peckAlpha, scratchAlpha) * math.rad(28)
		local scratchSway = scratchAlpha * math.rad(18)
		local scratchHeadTurn = scratchAlpha * math.rad(10)
		local scratchHeadDip = scratchAlpha * math.rad(8)
		local scratchBodyDip = scratchAlpha * -0.16
		local scratchWingSplit = scratchAlpha * math.rad(16)

		applyJointC0(bodyJoint, baseC0.body, CFrame.new(0, bobAmount + attackBodyDip + scratchBodyDip, 0) * CFrame.Angles(0, swayAmount + scratchSway, 0))
		applyJointC0(chestJoint, baseC0.chest, CFrame.new(0, bobAmount * 0.4, -attackHeadThrust * 0.4))
		applyJointC0(headJoint, baseC0.head, CFrame.new(0, bobAmount * 0.3, -attackHeadThrust) * CFrame.Angles(headNod + peckAlpha * math.rad(-16) + scratchHeadDip, scratchHeadTurn, 0))
		applyJointC0(leftWingJoint, baseC0.leftWing, CFrame.Angles(0, 0, math.rad(42) + wingFlap - attackWingBurst - scratchWingSplit))
		applyJointC0(rightWingJoint, baseC0.rightWing, CFrame.Angles(0, 0, math.rad(-42) - wingFlap + attackWingBurst + scratchWingSplit))
		applyJointC0(leftWingTipJoint, baseC0.leftWingTip, CFrame.Angles(0, 0, math.rad(58) + wingFlap * 1.3 - attackWingBurst * 1.2 - scratchWingSplit * 0.8))
		applyJointC0(rightWingTipJoint, baseC0.rightWingTip, CFrame.Angles(0, 0, math.rad(-58) - wingFlap * 1.3 + attackWingBurst * 1.2 + scratchWingSplit * 0.8))
		applyJointC0(tail1Joint, baseC0.tail1, CFrame.Angles(0, tailSwing - scratchSway * 0.35, 0))
		applyJointC0(tail2Joint, baseC0.tail2, CFrame.Angles(0, tailSwing * 1.2, 0))
		applyJointC0(tail3Joint, baseC0.tail3, CFrame.Angles(0, tailSwing + scratchSway * 0.35, 0))
	end)
end

local function onCharacterAdded(character)
	task.defer(startAnimation, character)
end

if player.Character then
	task.defer(startAnimation, player.Character)
end

player.CharacterAdded:Connect(onCharacterAdded)

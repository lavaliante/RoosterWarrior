local Workspace = game:GetService("Workspace")

local function createPart(parent, name, size, cframe, color, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function createHouse(parent, position, bodyColor, roofColor)
	local house = Instance.new("Model")
	house.Name = "House"
	house.Parent = parent

	createPart(house, "Body", Vector3.new(18, 12, 16), CFrame.new(position + Vector3.new(0, 6, 0)), bodyColor, Enum.Material.WoodPlanks)
	createPart(house, "Roof", Vector3.new(20, 4, 18), CFrame.new(position + Vector3.new(0, 14, 0)) * CFrame.Angles(0, 0, math.rad(8)), roofColor, Enum.Material.Slate)
	createPart(house, "Door", Vector3.new(3, 6, 0.6), CFrame.new(position + Vector3.new(0, 3, -8.2)), Color3.fromRGB(76, 50, 32), Enum.Material.Wood)
	createPart(house, "WindowLeft", Vector3.new(3, 3, 0.4), CFrame.new(position + Vector3.new(-5, 6, -8.25)), Color3.fromRGB(170, 220, 255), Enum.Material.Glass)
	createPart(house, "WindowRight", Vector3.new(3, 3, 0.4), CFrame.new(position + Vector3.new(5, 6, -8.25)), Color3.fromRGB(170, 220, 255), Enum.Material.Glass)
end

local function createTree(parent, position)
	local tree = Instance.new("Model")
	tree.Name = "Tree"
	tree.Parent = parent

	createPart(tree, "Trunk", Vector3.new(2, 8, 2), CFrame.new(position + Vector3.new(0, 4, 0)), Color3.fromRGB(92, 64, 51), Enum.Material.Wood)
	createPart(tree, "Leaves", Vector3.new(8, 8, 8), CFrame.new(position + Vector3.new(0, 11, 0)), Color3.fromRGB(77, 139, 71), Enum.Material.Grass)
end

local function createMarker(parent, name, position)
	local marker = Instance.new("Part")
	marker.Name = name
	marker.Size = Vector3.new(1, 1, 1)
	marker.CFrame = CFrame.new(position)
	marker.Transparency = 1
	marker.Anchored = true
	marker.CanCollide = false
	marker.CanQuery = false
	marker.CanTouch = false
	marker.Parent = parent
	return marker
end

local oldVillage = Workspace:FindFirstChild("Village")

if oldVillage then
	oldVillage:Destroy()
end

local village = Instance.new("Model")
village.Name = "Village"
village.Parent = Workspace

createPart(village, "VillageGround", Vector3.new(180, 2, 180), CFrame.new(0, 0, -10), Color3.fromRGB(107, 165, 92), Enum.Material.Grass)
createPart(village, "MainRoad", Vector3.new(22, 1, 120), CFrame.new(0, 1, -12), Color3.fromRGB(94, 84, 76), Enum.Material.Cobblestone)
createPart(village, "CrossRoad", Vector3.new(120, 1, 22), CFrame.new(0, 1, -12), Color3.fromRGB(94, 84, 76), Enum.Material.Cobblestone)
createPart(village, "TownSquare", Vector3.new(34, 1, 34), CFrame.new(0, 1.05, -12), Color3.fromRGB(128, 120, 105), Enum.Material.Slate)

createHouse(village, Vector3.new(-34, 1, -42), Color3.fromRGB(201, 170, 132), Color3.fromRGB(116, 73, 54))
createHouse(village, Vector3.new(34, 1, -42), Color3.fromRGB(180, 193, 150), Color3.fromRGB(88, 58, 50))
createHouse(village, Vector3.new(-34, 1, 20), Color3.fromRGB(173, 160, 198), Color3.fromRGB(86, 72, 108))
createHouse(village, Vector3.new(34, 1, 20), Color3.fromRGB(196, 176, 149), Color3.fromRGB(115, 94, 58))

createTree(village, Vector3.new(-60, 1, -60))
createTree(village, Vector3.new(60, 1, -60))
createTree(village, Vector3.new(-64, 1, 36))
createTree(village, Vector3.new(58, 1, 36))

local waypointFolder = Instance.new("Folder")
waypointFolder.Name = "CivilianWaypoints"
waypointFolder.Parent = village

local spawnFolder = Instance.new("Folder")
spawnFolder.Name = "CivilianSpawnPoints"
spawnFolder.Parent = village

local waypointPositions = {
	Vector3.new(-24, 3, -12),
	Vector3.new(0, 3, -12),
	Vector3.new(24, 3, -12),
	Vector3.new(-24, 3, 12),
	Vector3.new(0, 3, 12),
	Vector3.new(24, 3, 12),
	Vector3.new(-42, 3, -12),
	Vector3.new(42, 3, -12),
	Vector3.new(-12, 3, -42),
	Vector3.new(12, 3, -42),
}

for index, position in ipairs(waypointPositions) do
	createMarker(waypointFolder, "Waypoint" .. tostring(index), position)
end

local spawnPositions = {
	Vector3.new(-28, 3, -8),
	Vector3.new(-10, 3, -26),
	Vector3.new(10, 3, -26),
	Vector3.new(28, 3, -8),
	Vector3.new(-28, 3, 8),
	Vector3.new(-10, 3, 20),
	Vector3.new(10, 3, 20),
	Vector3.new(28, 3, 8),
}

for index, position in ipairs(spawnPositions) do
	createMarker(spawnFolder, "Spawn" .. tostring(index), position)
end

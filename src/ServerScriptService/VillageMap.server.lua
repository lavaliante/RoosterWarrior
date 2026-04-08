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

local function createWedge(parent, name, size, cframe, color, material)
	local wedge = Instance.new("WedgePart")
	wedge.Name = name
	wedge.Size = size
	wedge.CFrame = cframe
	wedge.Color = color
	wedge.Material = material or Enum.Material.SmoothPlastic
	wedge.Anchored = true
	wedge.TopSurface = Enum.SurfaceType.Smooth
	wedge.BottomSurface = Enum.SurfaceType.Smooth
	wedge.Parent = parent
	return wedge
end

local function createPalmTree(parent, name, position, height)
	local tree = Instance.new("Model")
	tree.Name = name
	tree.Parent = parent

	createPart(tree, "Trunk", Vector3.new(2, height, 2), CFrame.new(position + Vector3.new(0, height * 0.5, 0)) * CFrame.Angles(math.rad(2), 0, math.rad(4)), Color3.fromRGB(120, 86, 52), Enum.Material.Wood)
	createPart(tree, "LeafNorth", Vector3.new(9, 0.6, 3.4), CFrame.new(position + Vector3.new(0, height + 2.6, -1.2)) * CFrame.Angles(math.rad(24), 0, math.rad(10)), Color3.fromRGB(69, 141, 86), Enum.Material.Grass)
	createPart(tree, "LeafSouth", Vector3.new(9, 0.6, 3.4), CFrame.new(position + Vector3.new(0, height + 2.6, 1.2)) * CFrame.Angles(math.rad(-24), 0, math.rad(-10)), Color3.fromRGB(69, 141, 86), Enum.Material.Grass)
	createPart(tree, "LeafWest", Vector3.new(3.4, 0.6, 9), CFrame.new(position + Vector3.new(-1.2, height + 2.6, 0)) * CFrame.Angles(math.rad(10), 0, math.rad(24)), Color3.fromRGB(69, 141, 86), Enum.Material.Grass)
	createPart(tree, "LeafEast", Vector3.new(3.4, 0.6, 9), CFrame.new(position + Vector3.new(1.2, height + 2.6, 0)) * CFrame.Angles(math.rad(-10), 0, math.rad(-24)), Color3.fromRGB(69, 141, 86), Enum.Material.Grass)
	return tree
end

local function createVillageHouse(parent, name, position, bodyColor, roofColor)
	local house = Instance.new("Model")
	house.Name = name
	house.Parent = parent

	createPart(house, "Body", Vector3.new(18, 12, 16), CFrame.new(position + Vector3.new(0, 6, 0)), bodyColor, Enum.Material.WoodPlanks)
	createPart(house, "RoofBase", Vector3.new(20, 1.5, 18), CFrame.new(position + Vector3.new(0, 13.6, 0)), Color3.fromRGB(93, 69, 48), Enum.Material.WoodPlanks)
	createWedge(house, "RoofLeft", Vector3.new(10, 4, 18), CFrame.new(position + Vector3.new(-5, 15.1, 0)) * CFrame.Angles(0, 0, math.rad(180)), roofColor, Enum.Material.WoodPlanks)
	createWedge(house, "RoofRight", Vector3.new(10, 4, 18), CFrame.new(position + Vector3.new(5, 15.1, 0)), roofColor, Enum.Material.WoodPlanks)
	createPart(house, "Door", Vector3.new(3.2, 6.5, 0.8), CFrame.new(position + Vector3.new(0, 3.3, -8.4)), Color3.fromRGB(89, 60, 36), Enum.Material.Wood)
	createPart(house, "WindowLeft", Vector3.new(3, 3, 0.35), CFrame.new(position + Vector3.new(-5, 6.4, -8.45)), Color3.fromRGB(177, 225, 255), Enum.Material.Glass)
	createPart(house, "WindowRight", Vector3.new(3, 3, 0.35), CFrame.new(position + Vector3.new(5, 6.4, -8.45)), Color3.fromRGB(177, 225, 255), Enum.Material.Glass)
	return house
end

local function createFenceLine(parent, namePrefix, startPos, endPos, count)
	for index = 0, count do
		local alpha = index / count
		local position = startPos:Lerp(endPos, alpha)
		createPart(parent, namePrefix .. tostring(index + 1), Vector3.new(1.1, 3, 0.8), CFrame.new(position + Vector3.new(0, 1.5, 0)), Color3.fromRGB(140, 104, 65), Enum.Material.WoodPlanks)
	end
end

local function createField(parent, name, center, size, cropColor)
	local field = Instance.new("Model")
	field.Name = name
	field.Parent = parent

	createPart(field, "Soil", Vector3.new(size.X, 0.8, size.Z), CFrame.new(center + Vector3.new(0, 0.4, 0)), Color3.fromRGB(111, 80, 51), Enum.Material.Ground)

	for row = -2, 2 do
		for col = -3, 3 do
			local cropHeight = 2.4 + ((row + col) % 2) * 0.4
			createPart(field, string.format("Crop_%d_%d", row + 3, col + 4), Vector3.new(2.1, cropHeight, 2.1), CFrame.new(center + Vector3.new(col * 5.2, cropHeight * 0.5 + 0.8, row * 4.7)), cropColor, Enum.Material.Grass)
		end
	end

	return field
end

local function createMarketStall(parent, name, position, awningColor)
	local stall = Instance.new("Model")
	stall.Name = name
	stall.Parent = parent

	createPart(stall, "Counter", Vector3.new(9, 2.2, 5.5), CFrame.new(position + Vector3.new(0, 1.1, 0)), Color3.fromRGB(118, 85, 55), Enum.Material.WoodPlanks)
	createPart(stall, "LeftPost", Vector3.new(0.8, 5.6, 0.8), CFrame.new(position + Vector3.new(-3.5, 2.8, -1.9)), Color3.fromRGB(94, 66, 43), Enum.Material.Wood)
	createPart(stall, "RightPost", Vector3.new(0.8, 5.6, 0.8), CFrame.new(position + Vector3.new(3.5, 2.8, -1.9)), Color3.fromRGB(94, 66, 43), Enum.Material.Wood)
	createPart(stall, "Awning", Vector3.new(10, 0.8, 6.5), CFrame.new(position + Vector3.new(0, 5.8, -1.7)), awningColor, Enum.Material.Fabric)
	return stall
end

local function createDock(parent, origin)
	local dock = Instance.new("Model")
	dock.Name = "EasternDocks"
	dock.Parent = parent

	createPart(dock, "PierMain", Vector3.new(46, 2, 10), CFrame.new(origin + Vector3.new(18, 1, 0)), Color3.fromRGB(128, 92, 59), Enum.Material.WoodPlanks)
	createPart(dock, "PierBranch", Vector3.new(14, 2, 22), CFrame.new(origin + Vector3.new(34, 1, -8)), Color3.fromRGB(128, 92, 59), Enum.Material.WoodPlanks)
	createPart(dock, "Boat", Vector3.new(13, 3, 6), CFrame.new(origin + Vector3.new(46, 1.6, -8)), Color3.fromRGB(109, 72, 47), Enum.Material.Wood)
	createPart(dock, "BoatSail", Vector3.new(0.8, 8, 5), CFrame.new(origin + Vector3.new(46, 6, -8)), Color3.fromRGB(236, 233, 215), Enum.Material.Fabric)
	return dock
end

local function createBoulder(parent, name, position, size, rotation)
	local rock = createPart(parent, name, size, CFrame.new(position) * CFrame.Angles(math.rad(rotation.X), math.rad(rotation.Y), math.rad(rotation.Z)), Color3.fromRGB(123, 118, 109), Enum.Material.Rock)
	rock.Shape = Enum.PartType.Ball
	return rock
end

local oldVillage = Workspace:FindFirstChild("Village")
if oldVillage then
	oldVillage:Destroy()
end

local village = Instance.new("Model")
village.Name = "Village"
village.Parent = Workspace

createPart(village, "Ocean", Vector3.new(680, 20, 560), CFrame.new(0, -8, 10), Color3.fromRGB(80, 176, 222), Enum.Material.Glass)

createPart(village, "IslandBase", Vector3.new(430, 8, 320), CFrame.new(0, -1, 8), Color3.fromRGB(93, 154, 94), Enum.Material.Grass)
createPart(village, "VillageMeadow", Vector3.new(250, 4, 160), CFrame.new(-8, 4, 0), Color3.fromRGB(101, 169, 102), Enum.Material.Grass)
createPart(village, "FarmMeadow", Vector3.new(150, 3, 130), CFrame.new(-112, 3.5, 48), Color3.fromRGB(104, 171, 104), Enum.Material.Grass)
createPart(village, "DockMeadow", Vector3.new(120, 3, 100), CFrame.new(118, 3.5, 34), Color3.fromRGB(104, 171, 104), Enum.Material.Grass)

createPart(village, "NorthBeach", Vector3.new(388, 2, 42), CFrame.new(0, -4, -118), Color3.fromRGB(229, 212, 171), Enum.Material.Sand)
createPart(village, "SouthBeach", Vector3.new(394, 2, 46), CFrame.new(0, -4, 134), Color3.fromRGB(229, 212, 171), Enum.Material.Sand)
createPart(village, "WestBeach", Vector3.new(58, 2, 244), CFrame.new(-186, -4, 10), Color3.fromRGB(229, 212, 171), Enum.Material.Sand)
createPart(village, "EastBeach", Vector3.new(74, 2, 252), CFrame.new(180, -4, 12), Color3.fromRGB(229, 212, 171), Enum.Material.Sand)
createPart(village, "NorthwestBeach", Vector3.new(88, 2, 58), CFrame.new(-138, -3.9, -96), Color3.fromRGB(229, 212, 171), Enum.Material.Sand)
createPart(village, "NortheastBeach", Vector3.new(108, 2, 60), CFrame.new(136, -3.9, -94), Color3.fromRGB(229, 212, 171), Enum.Material.Sand)
createPart(village, "SouthwestBeach", Vector3.new(100, 2, 68), CFrame.new(-138, -3.9, 106), Color3.fromRGB(229, 212, 171), Enum.Material.Sand)
createPart(village, "SoutheastBeach", Vector3.new(116, 2, 74), CFrame.new(140, -3.9, 108), Color3.fromRGB(229, 212, 171), Enum.Material.Sand)
createPart(village, "DockBeach", Vector3.new(104, 2, 62), CFrame.new(132, -3.8, 30), Color3.fromRGB(229, 212, 171), Enum.Material.Sand)

createWedge(village, "NorthSlope", Vector3.new(388, 8, 24), CFrame.new(0, -1, -94) * CFrame.Angles(0, math.rad(180), 0), Color3.fromRGB(206, 194, 150), Enum.Material.Sand)
createWedge(village, "SouthSlope", Vector3.new(394, 8, 26), CFrame.new(0, -1, 108), Color3.fromRGB(206, 194, 150), Enum.Material.Sand)
createWedge(village, "WestSlope", Vector3.new(244, 8, 26), CFrame.new(-160, -1, 10) * CFrame.Angles(0, math.rad(90), 0), Color3.fromRGB(206, 194, 150), Enum.Material.Sand)
createWedge(village, "EastSlope", Vector3.new(252, 8, 34), CFrame.new(152, -1, 12) * CFrame.Angles(0, math.rad(-90), 0), Color3.fromRGB(206, 194, 150), Enum.Material.Sand)

createPart(village, "VillageSquare", Vector3.new(76, 0.8, 52), CFrame.new(-8, 6.45, -8), Color3.fromRGB(181, 164, 130), Enum.Material.Ground)
createPart(village, "MainPath", Vector3.new(22, 0.6, 170), CFrame.new(-8, 6.35, 0), Color3.fromRGB(195, 177, 131), Enum.Material.Sand)
createPart(village, "CrossPath", Vector3.new(142, 0.6, 20), CFrame.new(-8, 6.36, -8), Color3.fromRGB(195, 177, 131), Enum.Material.Sand)
createPart(village, "FarmPath", Vector3.new(120, 0.6, 18), CFrame.new(-88, 6.36, 38), Color3.fromRGB(195, 177, 131), Enum.Material.Sand)
createPart(village, "DockPath", Vector3.new(128, 0.6, 18), CFrame.new(74, 6.36, 24), Color3.fromRGB(195, 177, 131), Enum.Material.Sand)
createPart(village, "SouthPath", Vector3.new(18, 0.6, 74), CFrame.new(-30, 6.36, 70), Color3.fromRGB(195, 177, 131), Enum.Material.Sand)
createPart(village, "MarketGround", Vector3.new(40, 0.6, 28), CFrame.new(26, 6.38, -6), Color3.fromRGB(193, 173, 136), Enum.Material.Ground)

createVillageHouse(village, "MayorHouse", Vector3.new(-10, 6.8, -52), Color3.fromRGB(221, 208, 164), Color3.fromRGB(162, 95, 64))
createVillageHouse(village, "WestHouse", Vector3.new(-64, 6.8, -8), Color3.fromRGB(211, 193, 154), Color3.fromRGB(131, 85, 58))
createVillageHouse(village, "EastHouse", Vector3.new(42, 6.8, -10), Color3.fromRGB(194, 214, 172), Color3.fromRGB(102, 129, 73))
createVillageHouse(village, "SouthHouse", Vector3.new(-18, 6.8, 42), Color3.fromRGB(214, 193, 167), Color3.fromRGB(136, 97, 67))
createVillageHouse(village, "DockHouse", Vector3.new(92, 6.8, 26), Color3.fromRGB(208, 182, 151), Color3.fromRGB(122, 78, 54))

createMarketStall(village, "FruitStall", Vector3.new(28, 6.8, -14), Color3.fromRGB(217, 91, 59))
createMarketStall(village, "TraderStall", Vector3.new(30, 6.8, 8), Color3.fromRGB(212, 175, 83))

createField(village, "WestFarm", Vector3.new(-134, 6.8, 30), Vector3.new(60, 1, 48), Color3.fromRGB(209, 190, 92))
createField(village, "SouthFarm", Vector3.new(-58, 6.8, 96), Vector3.new(70, 1, 38), Color3.fromRGB(186, 211, 103))
createFenceLine(village, "WestFarmFenceA", Vector3.new(-166, 6.8, 2), Vector3.new(-166, 6.8, 58), 11)
createFenceLine(village, "WestFarmFenceB", Vector3.new(-102, 6.8, 2), Vector3.new(-102, 6.8, 58), 11)
createFenceLine(village, "SouthFarmFenceA", Vector3.new(-96, 6.8, 72), Vector3.new(-18, 6.8, 72), 14)
createFenceLine(village, "SouthFarmFenceB", Vector3.new(-96, 6.8, 120), Vector3.new(-18, 6.8, 120), 14)

createDock(village, Vector3.new(102, 0, 26))

createPalmTree(village, "Palm1", Vector3.new(-170, 0, -72), 18)
createPalmTree(village, "Palm2", Vector3.new(-116, 1, -104), 17)
createPalmTree(village, "Palm3", Vector3.new(-22, 1, -112), 18)
createPalmTree(village, "Palm4", Vector3.new(88, 1, -102), 19)
createPalmTree(village, "Palm5", Vector3.new(168, 0, -28), 18)
createPalmTree(village, "Palm6", Vector3.new(176, 0, 70), 18)
createPalmTree(village, "Palm7", Vector3.new(70, 1, 146), 17)
createPalmTree(village, "Palm8", Vector3.new(-30, 1, 150), 16)
createPalmTree(village, "Palm9", Vector3.new(-150, 0, 102), 18)
createPalmTree(village, "Palm10", Vector3.new(-182, 0, 18), 19)

createBoulder(village, "Boulder1", Vector3.new(-178, -1.2, -96), Vector3.new(10, 9, 8), Vector3.new(0, 18, 10))
createBoulder(village, "Boulder2", Vector3.new(170, -1.4, -88), Vector3.new(9, 8, 7), Vector3.new(0, -14, -8))
createBoulder(village, "Boulder3", Vector3.new(182, -1.5, 118), Vector3.new(10, 8, 8), Vector3.new(0, 20, 12))
createBoulder(village, "Boulder4", Vector3.new(-182, -1.4, 120), Vector3.new(9, 8, 7), Vector3.new(0, -16, 10))
createBoulder(village, "Boulder5", Vector3.new(184, -1.3, 14), Vector3.new(8, 7, 7), Vector3.new(0, 10, -8))
createBoulder(village, "Boulder6", Vector3.new(-188, -1.6, 28), Vector3.new(8, 7, 6), Vector3.new(0, 22, 0))

createPart(village, "RoosterStatueBase", Vector3.new(9, 2.4, 9), CFrame.new(-8, 7.4, -8), Color3.fromRGB(111, 101, 88), Enum.Material.Slate)
createPart(village, "RoosterStatue", Vector3.new(3.4, 7.5, 3.4), CFrame.new(-8, 12.3, -8), Color3.fromRGB(206, 185, 110), Enum.Material.Metal)

local waypointFolder = Instance.new("Folder")
waypointFolder.Name = "CivilianWaypoints"
waypointFolder.Parent = village

local spawnFolder = Instance.new("Folder")
spawnFolder.Name = "CivilianSpawnPoints"
spawnFolder.Parent = village

local farmDemonSpawnFolder = Instance.new("Folder")
farmDemonSpawnFolder.Name = "FarmDemonSpawnPoints"
farmDemonSpawnFolder.Parent = village

local waypointPositions = {
	Vector3.new(-70, 8.6, -10),
	Vector3.new(-30, 8.6, -8),
	Vector3.new(10, 8.6, -8),
	Vector3.new(46, 8.6, -8),
	Vector3.new(-52, 8.6, 28),
	Vector3.new(-14, 8.6, 32),
	Vector3.new(26, 8.6, 28),
	Vector3.new(70, 8.6, 24),
	Vector3.new(-116, 8.6, 30),
	Vector3.new(-138, 8.6, 32),
	Vector3.new(-62, 8.6, 92),
	Vector3.new(-28, 8.6, 96),
}

for index, position in ipairs(waypointPositions) do
	createMarker(waypointFolder, "Waypoint" .. tostring(index), position)
end

local spawnPositions = {
	Vector3.new(-54, 8.6, -40),
	Vector3.new(-10, 8.6, -42),
	Vector3.new(38, 8.6, -34),
	Vector3.new(-72, 8.6, 8),
	Vector3.new(22, 8.6, 12),
	Vector3.new(-22, 8.6, 48),
	Vector3.new(48, 8.6, 30),
	Vector3.new(96, 8.6, 30),
}

for index, position in ipairs(spawnPositions) do
	createMarker(spawnFolder, "Spawn" .. tostring(index), position)
end

local farmDemonSpawnPositions = {
	Vector3.new(-168, 8.6, 8),
	Vector3.new(-158, 8.6, 24),
	Vector3.new(-148, 8.6, 42),
	Vector3.new(-126, 8.6, 10),
	Vector3.new(-110, 8.6, 28),
	Vector3.new(-82, 8.6, 92),
}

for index, position in ipairs(farmDemonSpawnPositions) do
	createMarker(farmDemonSpawnFolder, "FarmSpawn" .. tostring(index), position)
end

local ConvertBoundsFolder = require("./ConvertBoundsFolder")
local ConvertDoorsFolder = require("./ConvertDoorsFolder")
local ConvertItemsFolder = require("./ConvertItemsFolder")
local ConvertPropsFolder = require("./ConvertPropsFolder")
local ConvertScript = require("./ConvertScript")
local ConvertSpawnsFolder = require("./ConvertSpawnsFolder")

local function Convert(oldMap: Instance): Instance
	local oldFolder = if oldMap:IsA("Folder") then oldMap else oldMap:FindFirstChildOfClass("Folder")
	if not oldFolder then
		error("Could not find map folder")
	end

	local newMap = Instance.new("Folder")
	newMap.Name = oldFolder.Name

	local creators = oldFolder:GetAttribute("Creator")
	if typeof(creators) ~= "string" then
		error(if creators == nil then "Creator attribute not found" else "Creator attribute is not a string")
	end

	local icon = oldFolder:GetAttribute("Icon")
	if typeof(icon) ~= "string" then
		error(if icon == nil then "Icon attribute not found" else "Icon attribute is not a string")
	end

	newMap:SetAttribute("Authors", creators)
	newMap:SetAttribute("Icon", icon)
	newMap:SetAttribute("Description", "No description")
	newMap:SetAttribute("CompatiblityMode", "TT2")

	local newLighting = Instance.new("Configuration")
	newLighting.Name = "LightingSettings"
	newLighting.Parent = newMap

	local oldLighting = oldFolder:FindFirstChild("Lighting")
	if oldLighting then
		for i, v in oldLighting:GetAttributes() do
			newLighting:SetAttribute(i, v)
		end

		for _, v in oldLighting:GetChildren() do
			v:Clone().Parent = newLighting
		end
	end

	local newTerrainColors = Instance.new("Configuration")
	newTerrainColors.Name = "TerrainColors"
	newTerrainColors.Parent = newMap

	local newWaterSettings = Instance.new("Configuration")
	newWaterSettings.Name = "WaterSettings"
	newWaterSettings.Parent = newMap

	local oldTerrain = oldFolder:FindFirstChild("Terrain")
	if oldTerrain then
		for i, v in oldTerrain:GetAttributes() do
			if i:sub(1, 5) == "Water" then
				newWaterSettings:SetAttribute(i, v)
			else
				newTerrainColors:SetAttribute(i, v)
			end
		end
	end

	local newMaterials = Instance.new("Configuration")
	newMaterials.Name = "MaterialVariants"
	newMaterials.Parent = newMap

	local oldMaterials = oldFolder:FindFirstChild("MaterialService")
	if oldMaterials then
		for _, v in oldMaterials:GetChildren() do
			v:Clone().Parent = newMaterials
		end
	end

	local terrainRegion = oldFolder:FindFirstChild("TerrainRegion")
	if terrainRegion and terrainRegion:IsA("TerrainRegion") then
		terrainRegion = terrainRegion:Clone()
		terrainRegion.Name = "Terrain"
		terrainRegion.Parent = newMap
	end

	if oldTerrain then
		local clouds = oldTerrain:FindFirstChildOfClass("Clouds")
		if clouds then
			clouds:Clone().Parent = newMap
		end
	end

	local dynamicMap = Instance.new("Folder")
	dynamicMap.Name = "Dynamic"
	dynamicMap.Parent = newMap

	local staticMap = Instance.new("Folder")
	staticMap.Name = "Static"
	staticMap.Parent = newMap

	local playerSpawns = Instance.new("Folder")
	playerSpawns.Name = "PlayerSpawns"
	playerSpawns.Parent = newMap

	local workspaceFolder = oldFolder:FindFirstChild("Workspace")
	if workspaceFolder then
		local actionFolder = workspaceFolder:FindFirstChild("Action")
		if actionFolder then
			actionFolder:Clone().Parent = dynamicMap
		end

		local doorsFolder = workspaceFolder:FindFirstChild("Doors")
		if doorsFolder then
			ConvertDoorsFolder(doorsFolder, dynamicMap)
		end

		local boundsFolder = workspaceFolder:FindFirstChild("Bounds")
		if boundsFolder then
			ConvertBoundsFolder(boundsFolder, staticMap)
		end

		local mapFolder = workspaceFolder:FindFirstChild("Map")
		if mapFolder then
			for _, v in mapFolder:GetChildren() do
				v:Clone().Parent = staticMap
			end
		end

		local propsFolder = workspaceFolder:FindFirstChild("Props")
		if propsFolder then
			ConvertPropsFolder(propsFolder, dynamicMap)
		end

		local itemsFolder = workspaceFolder:FindFirstChild("Items")
		if itemsFolder then
			ConvertItemsFolder(itemsFolder, dynamicMap)
		end

		local gravityAttr = workspaceFolder:GetAttribute("Gravity")
		if typeof(gravityAttr) == "number" then
			newMap:SetAttribute("Gravity", gravityAttr)
		elseif gravityAttr ~= nil then
			warn(`Unknown Gravity attribute type: {gravityAttr}`)
		end
	end

	local spawnsFolder = oldFolder:FindFirstChild("Spawns")
	if spawnsFolder then
		ConvertSpawnsFolder(spawnsFolder, playerSpawns)
	end

	local oldCustomItems = oldFolder:FindFirstChild("CustomItems")
	if oldCustomItems then
		local customItems = Instance.new("Configuration")
		customItems.Name = "ItemDefinitions"

		oldCustomItems.Name = "Old"
		oldCustomItems.Parent = customItems

		customItems.Parent = newMap
	end

	for _, v in newMap:GetDescendants() do
		if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then
			ConvertScript(v)
		end
	end

	newMap.Parent = oldMap.Parent

	return newMap
end

return Convert
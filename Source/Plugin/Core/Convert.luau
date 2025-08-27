local Codify = require("../../Lib/Codify")
local ConvertBoundsFolder = require("./ConvertBoundsFolder")
local ConvertCustomItems = require("./ConvertCustomItems")
local ConvertDoorsFolder = require("./ConvertDoorsFolder")
local ConvertInteractables = require("./ConvertInteractables")
local ConvertItemsFolder = require("./ConvertItemsFolder")
local ConvertPropsFolder = require("./ConvertPropsFolder")
local ConvertScript = require("./ConvertScript")
local ConvertSpawnsFolder = require("./ConvertSpawnsFolder")

local mapScriptTemplate = [[
--!strict
local Types = require(game:GetService("ReplicatedStorage").Shared.RoundRule.Types)
local map: Types.MapDefinition = {
	Name = [MAPNAME],
	Description = "No description",
	Authors = [AUTHORS],

	Extras = {
		CompatibilityMode = true
	},

	MapIcons = {
		["16:9"] = [ICON],
	},

	Gravity = [GRAVITY],

	LightingSettings = {
		[LIGHTING]
	},

	FutureLightingSettings = {},

	WaterSettings = {
		[WATER]
	},

	TerrainColors = {
		[TERRAIN]
	},

	AvailableItems = [CUSTOMITEMS],
	AvailableAmmo = {},

	Map = script,
}

return map
]]

local function Convert(oldMap: Instance): ModuleScript
	local oldFolder = if oldMap:IsA("Folder") then oldMap else oldMap:FindFirstChildOfClass("Folder")
	if not oldFolder then
		error("Could not find map folder")
	end

	local newMap = Instance.new("ModuleScript")

	local name = oldFolder.Name
	local creators = oldFolder:GetAttribute("Creator")

	if typeof(creators) ~= "string" then
		error(if creators == nil then "Creator attribute not found" else "Creator attribute is not a string")
	end

	local icon = oldFolder:GetAttribute("Icon")
	if typeof(icon) ~= "string" then
		error(if icon == nil then "Icon attribute not found" else "Icon attribute is not a string")
	end

	local newLighting = Instance.new("Folder")
	newLighting.Name = "Lighting"
	newLighting.Parent = newMap

	local lightingString = ""
	local oldLighting = oldFolder:FindFirstChild("Lighting")
	if oldLighting then
		local isFirstIteration = true
		for i, v in oldLighting:GetAttributes() do
			local valueString = Codify(v)
			if not valueString then
				warn(`Unknown Lighting attribute type {i}: {v}`)
			end
			lightingString ..= `{if not isFirstIteration then "\n		" else ""}["{i}"] = {valueString},`
			isFirstIteration = false
		end

		for _, v in oldLighting:GetChildren() do
			v:Clone().Parent = newLighting
		end
	end

	local waterString = ""
	local terrainString = ""
	local oldTerrain = oldFolder:FindFirstChild("Terrain")
	if oldTerrain then
		local isFirstWater, isFirstTerrainColor = true, true
		for i, v in oldTerrain:GetAttributes() do
			local valueString = Codify(v)
			if not valueString then
				warn(`Unknown Terrain attribute type {i}: {v}`)
			end

			if i:sub(1, 5) == "Water" then
				waterString ..= `{if not isFirstWater then "\n		" else ""}["{i}"] = {valueString},`
				isFirstWater = false
			else
				terrainString ..= `{if not isFirstTerrainColor then "\n		" else ""}["{i}"] = {valueString},`
				isFirstTerrainColor = false
			end
		end
	end

	local newMaterials = Instance.new("Folder")
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
			clouds:Clone().Parent = terrainRegion or Instance.new("TerrainRegion", newMap)
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

	local gravity = 80

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
			gravity = gravityAttr
		elseif gravityAttr ~= nil then
			warn(`Unknown Gravity attribute type: {gravityAttr}`)
		end
	end

	gravity = Codify(gravity) or "80"

	local spawnsFolder = oldFolder:FindFirstChild("Spawns")
	if spawnsFolder then
		ConvertSpawnsFolder(spawnsFolder, playerSpawns)
	end

	local customItemsString = "{}"
	local customItems = oldFolder:FindFirstChild("CustomItems")
	if customItems then
		customItemsString = ConvertCustomItems(customItems, staticMap) or "{}"
	end

	for _, v in newMap:GetDescendants() do
		if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then
			ConvertScript(v)
		end
	end

	local mapScript = mapScriptTemplate
		:gsub("%[MAPNAME%]", Codify(name) or name)
		:gsub("%[AUTHORS%]", Codify(creators) or creators)
		:gsub("%[ICON%]", Codify(icon) or icon)
		:gsub("%[LIGHTING%]", lightingString)
		:gsub("%[WATER%]", waterString)
		:gsub("%[TERRAIN%]", terrainString)
		:gsub("%[CUSTOMITEMS%]", customItemsString)
		:gsub("%[GRAVITY%]", gravity)
	newMap.Source = mapScript

	newMap.Name = name
	newMap.Parent = oldMap.Parent

	return newMap
end

return Convert
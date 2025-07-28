local Codify = require("../../Lib/Codify")
local ConvertCustomItems = require("./ConvertCustomItems")
local ConvertDoorsFolder = require("./ConvertDoorsFolder")
local ConvertItemsFolder = require("./ConvertItemsFolder")
local ConvertPropsFolder = require("./ConvertPropsFolder")
local ConvertSpawnsFolder = require("./ConvertSpawnsFolder")

local mapScriptTemplate = [[
--!strict
local Types = require(game:GetService("ReplicatedStorage").Shared.RoundRule.Types)
local map: Types.MapDefinition = {
	Name = [MAPNAME],
	Description = "No description",
	Authors = [AUTHORS],

	MapIcons = {
		["1:1"] = [ICON],
	},

	Gravity = 80,

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

	InteractableDefinitions = {},
}

return map
]]

local function Convert(oldMap: Instance): ModuleScript | string
	local oldFolder = if oldMap:IsA("Folder") then oldMap else oldMap:FindFirstChildOfClass("Folder")
	if not oldFolder then
		return "Could not find map folder"
	end

	local newMap = Instance.new("ModuleScript")

	local name = oldFolder.Name
	local creators = oldFolder:GetAttribute("Creator")

	if typeof(creators) ~= "string" then
		return if creators == nil then "Creator attribute not found" else "Creator attribute is not a string"
	end

	local icon = oldFolder:GetAttribute("Icon")
	if typeof(icon) ~= "string" then
		return if icon == nil then "Icon attribute not found" else "Icon attribute is not a string"
	end

	local newLighting = Instance.new("Folder")
	newLighting.Name = "LightingModifiers"
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
		terrainRegion:Clone().Parent = newMap
	end

	local dynamicMap = Instance.new("Folder")
	dynamicMap.Name = "DynamicMap"
	dynamicMap.Parent = newMap

	local doors = Instance.new("Folder")
	doors.Name = "Doors"
	doors.Parent = dynamicMap

	local bounds = Instance.new("Folder")
	bounds.Name = "Bounds"
	bounds.Parent = newMap

	local staticMap = Instance.new("Folder")
	staticMap.Name = "StaticMap"
	staticMap.Parent = newMap

	local itemSpawns = Instance.new("Folder")
	itemSpawns.Name = "ItemSpawns"
	itemSpawns.Parent = newMap

	local ammoSpawns = Instance.new("Folder")
	ammoSpawns.Name = "AmmoSpawns"
	ammoSpawns.Parent = newMap

	local playerSpawns = Instance.new("Folder")
	playerSpawns.Name = "PlayerSpawns"
	playerSpawns.Parent = newMap

	local props = Instance.new("Folder")
	props.Name = "Props"
	props.Parent = newMap

	local workspaceFolder = oldFolder:FindFirstChild("Workspace")
	if workspaceFolder then
		local actionFolder = workspaceFolder:FindFirstChild("Action")
		if actionFolder then
			for _, v in actionFolder:GetChildren() do
				v:Clone().Parent = dynamicMap
			end
		end

		local doorsFolder = workspaceFolder:FindFirstChild("Doors")
		if doorsFolder then
			ConvertDoorsFolder(doorsFolder, doors)
		end

		local boundsFolder = workspaceFolder:FindFirstChild("Bounds")
		if boundsFolder then
			for _, v in boundsFolder:GetChildren() do
				v:Clone().Parent = bounds
			end
		end

		local mapFolder = workspaceFolder:FindFirstChild("Map")
		if mapFolder then
			for _, v in mapFolder:GetChildren() do
				v:Clone().Parent = staticMap
			end
		end

		local propsFolder = workspaceFolder:FindFirstChild("Props")
		if propsFolder then
			ConvertPropsFolder(propsFolder, props)
		end

		local itemsFolder = workspaceFolder:FindFirstChild("Items")
		if itemsFolder then
			ConvertItemsFolder(itemsFolder, itemSpawns, ammoSpawns)
		end
	end

	local spawnsFolder = oldFolder:FindFirstChild("Spawns")
	if spawnsFolder then
		ConvertSpawnsFolder(spawnsFolder, playerSpawns)
	end

	local customItemsString = "{}"
	local customItems = oldFolder:FindFirstChild("CustomItems")
	if customItems then
		customItemsString = ConvertCustomItems(customItems, staticMap) or "{}"
	end

	local interactablesFolder = Instance.new("Folder")
	interactablesFolder.Name = "Interactables"
	interactablesFolder.Parent = newMap

	local futureLightingModifiers = Instance.new("Folder")
	futureLightingModifiers.Name = "FutureLightingModifiers"
	futureLightingModifiers.Parent = newMap

	local windows = Instance.new("Folder")
	windows.Name = "Windows"
	windows.Parent = newMap

	local mapScript = mapScriptTemplate
		:gsub("%[MAPNAME%]", Codify(name) or name)
		:gsub("%[AUTHORS%]", Codify(creators) or creators)
		:gsub("%[ICON%]", Codify(icon) or icon)
		:gsub("%[LIGHTING%]", lightingString)
		:gsub("%[WATER%]", waterString)
		:gsub("%[TERRAIN%]", terrainString)
		:gsub("%[CUSTOMITEMS%]", customItemsString)
	newMap.Source = mapScript

	newMap.Name = name
	newMap.Parent = oldMap.Parent

	return newMap
end

return Convert
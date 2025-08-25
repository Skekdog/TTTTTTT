
local nameRemap = {
	OnDestroying = "OnBreak",
}

-- note: we replace the speech marks also because Props is scarily common, don't want to replace it incorrectly.
local function convertCollisionGroups(source: string): string
	local converted = source
		:gsub('"Character_Colliders"', '"PlayerCharacterParts"')
		:gsub('"Props"', '"Default"')
	return converted
end

local baseItemNameRemap: {[string]: string} = {
	["Five-seveN"] = "Pistol",
	["M4A1 Carbine"] = "Assault Rifle",
	["G18"] = "Glock",
	["M11"] = "SMG",
	["M1014"] = "XM1014",
	["M249 SAW"] = "HUGE",
	["Desert Eagle"] = "Deagle",
}

local function convertBaseItemReferences(source: string): string
	local function replace(input: string): string
		local pattern = "Assets%.Items%[([^%]]-)%]%.Shared%)%.Properties"
    	local replaced = input:gsub(pattern, "Shared.GameDefinition.Items.Items)[%1]")
		return replaced
	end

	source = replace(source)

	for i, v in baseItemNameRemap do
		local escaped = i:gsub("(%W)", "%%%1")
		source = source:gsub(escaped, v)
	end

	return source
end

local function convertWorkspaceMapReferences(source: string): string
	local converted = source
		:gsub('workspace%.Map', 'workspace.Map:WaitForChild("Static")')
		:gsub('workspace:WaitForChild%("Map"%)', 'workspace.Map:WaitForChild("Static")')
		:gsub('workspace%.Items', 'workspace.Map:WaitForChild("Dynamic"):WaitForChild("Items")')
		:gsub('workspace:WaitForChild%("Items"%)', 'workspace.Map:WaitForChild("Dynamic"):WaitForChild("Items")')
		:gsub('workspace%.Bounds', 'workspace.Map:WaitForChild("Static"):WaitForChild("Bounds")')
		:gsub('workspace:WaitForChild%("Bounds"%)', 'workspace.Map:WaitForChild("Static"):WaitForChild("Bounds")')
		:gsub('workspace%.Action', 'workspace.Map:WaitForChild("Dynamic"):WaitForChild("Action")')
		:gsub('workspace:WaitForChild%("Action"%)', 'workspace.Map:WaitForChild("Dynamic"):WaitForChild("Action")')
		:gsub('workspace%.ActionItems', 'workspace.Map:WaitForChild("Dynamic"):WaitForChild("ActionItems")')
		:gsub('workspace:WaitForChild%("ActionItems"%)', 'workspace.Map:WaitForChild("Dynamic"):WaitForChild("ActionItems")')
		:gsub('workspace%.Props', 'workspace.Map:WaitForChild("Dynamic"):WaitForChild("Props")')
		:gsub('workspace:WaitForChild%("Props"%)', 'workspace.Map:WaitForChild("Dynamic"):WaitForChild("Props")')
		:gsub('workspace%._Local', 'workspace.Camera') -- todo: what is workspace._Local?
		:gsub('workspace:WaitForChild%("_Local"%)', 'workspace.Camera')
		:gsub('workspace%.Doors', 'workspace.Map:WaitForChild("Dynamic"):WaitForChild("Doors")')
		:gsub('workspace:WaitForChild%("Doors"%)', 'workspace.Map:WaitForChild("Dynamic"):WaitForChild("Doors")')
	return converted
end

local function convertReplicationFocusUse(source: string): string
	local converted = source
		:gsub("ReplicationFocus", "Character")

	return converted
end

local function ConvertScript(targetScript: Script | LocalScript | ModuleScript): ()
	if targetScript:IsA("ModuleScript") then
		targetScript.Name = nameRemap[targetScript.Name] or targetScript.Name
	end

	local source = targetScript.Source
	source = convertCollisionGroups(source)
	source = convertWorkspaceMapReferences(source)
	source = convertBaseItemReferences(source)
	source = convertReplicationFocusUse(source)

	targetScript.Source = source
end

return ConvertScript
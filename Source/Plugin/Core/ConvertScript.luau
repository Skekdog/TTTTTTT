
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

local function convertWorkspaceMapReferences(source: string): string
	local converted = source
		:gsub('workspace.Map', 'workspace.Map:WaitForChild("StaticMap")')
		:gsub('workspace:WaitForChild("Map")', 'workspace.Map:WaitForChild("StaticMap")')
		:gsub('workspace.Items', 'workspace.Map:WaitForChild("ItemSpawns")')
		:gsub('workspace:WaitForChild("Items")', 'workspace.Map:WaitForChild("ItemSpawns")')
		:gsub('workspace.Bounds', 'workspace.Map:WaitForChild("Bounds")')
		:gsub('workspace:WaitForChild("Bounds")', 'workspace.Map:WaitForChild("Bounds")')
		:gsub('workspace.Action', 'workspace.Map:WaitForChild("DynamicMap")')
		:gsub('workspace:WaitForChild("Action")', 'workspace.Map:WaitForChild("DynamicMap")')
		:gsub('workspace.ActionItems', 'workspace.Map:WaitForChild("DynamicMap")')
		:gsub('workspace:WaitForChild("ActionItems")', 'workspace.Map:WaitForChild("DynamicMap")')
		:gsub('workspace.Props', 'workspace.Map:WaitForChild("Props")')
		:gsub('workspace:WaitForChild("Props")', 'workspace.Map:WaitForChild("Props")')
		:gsub('workspace._Local', 'workspace.Camera') -- todo: what is workspace._Local?
		:gsub('workspace:WaitForChild("_Local")', 'workspace.Camera')
		:gsub('workspace.Doors', 'workspace.Map:WaitForChild("DynamicMap"):WaitForChild("Doors")')
		:gsub('workspace:WaitForChild("Doors")', 'workspace.Map:WaitForChild("DynamicMap"):WaitForChild("Doors")')
	return converted
end

local function ConvertScript(targetScript: Script | LocalScript | ModuleScript): ()
	if targetScript:IsA("ModuleScript") then
		targetScript.Name = nameRemap[targetScript.Name] or targetScript.Name
	end

	local source = targetScript.Source
	source = convertCollisionGroups(source)
	source = convertWorkspaceMapReferences(source)

	targetScript.Source = source
end

return ConvertScript
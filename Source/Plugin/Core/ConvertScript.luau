
local function ConvertScript(targetScript: Script | LocalScript | ModuleScript): ()
	targetScript.Source = targetScript.Source
		:gsub("workspace.Items", "workspace.Map.ItemSpawns")
		:gsub("workspace:WaitForChild(\"Items\")", "workspace.Map.ItemSpawns")
		:gsub("workspace.Bounds", "workspace.Map.Bounds")
		:gsub("workspace:WaitForChild(\"Bounds\")", "workspace.Map.Bounds")
		:gsub("workspace.Action", "workspace.Map.DynamicMap")
		:gsub("workspace:WaitForChild(\"Action\")", "workspace.Map.DynamicMap")
		:gsub("workspace.ActionItems", "workspace.Map.DynamicMap")
		:gsub("workspace:WaitForChild(\"ActionItems\")", "workspace.Map.DynamicMap")
		:gsub("workspace.Map", "workspace.Map.StaticMap")
		:gsub("workspace:WaitForChild(\"Map\")", "workspace.Map.StaticMap")
		:gsub("workspace.Props", "workspace.Map.Props")
		:gsub("workspace:WaitForChild(\"Props\")", "workspace.Map.Props")
		:gsub("workspace._Local", "workspace.Camera") -- todo: what is workspace._Local?
		:gsub("workspace:WaitForChild(\"_Local\")", "workspace.Camera")
		:gsub("workspace.Doors", "workspace.Map.DynamicMap.Doors")
		:gsub("workspace:WaitForChild(\"Doors\")", "workspace.Map.DynamicMap.Doors")
end

return ConvertScript
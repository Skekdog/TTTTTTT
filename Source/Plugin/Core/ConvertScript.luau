
local function ConvertScript(targetScript: Script | LocalScript | ModuleScript): ()
	targetScript.Source = targetScript.Source
		:gsub("workspace.Map", "workspace.Map:WaitForChild(\"StaticMap\")")
		:gsub("workspace:WaitForChild(\"Map\")", "workspace.Map:WaitForChild(\"StaticMap\")")
		:gsub("workspace.Items", "workspace.Map:WaitForChild(\"ItemSpawns\")")
		:gsub("workspace:WaitForChild(\"Items\")", "workspace.Map:WaitForChild(\"ItemSpawns\")")
		:gsub("workspace.Bounds", "workspace.Map:WaitForChild(\"Bounds\")")
		:gsub("workspace:WaitForChild(\"Bounds\")", "workspace.Map:WaitForChild(\"Bounds\")")
		:gsub("workspace.Action", "workspace.Map:WaitForChild(\"DynamicMap\")")
		:gsub("workspace:WaitForChild(\"Action\")", "workspace.Map:WaitForChild(\"DynamicMap\")")
		:gsub("workspace.ActionItems", "workspace.Map:WaitForChild(\"DynamicMap\")")
		:gsub("workspace:WaitForChild(\"ActionItems\")", "workspace.Map:WaitForChild(\"DynamicMap\")")
		:gsub("workspace.Props", "workspace.Map:WaitForChild(\"Props\")")
		:gsub("workspace:WaitForChild(\"Props\")", "workspace.Map:WaitForChild(\"Props\")")
		:gsub("workspace._Local", "workspace.Camera") -- todo: what is workspace._Local?
		:gsub("workspace:WaitForChild(\"_Local\")", "workspace.Camera")
		:gsub("workspace.Doors", "workspace.Map:WaitForChild(\"DynamicMap\"):WaitForChild(\"Doors\")")
		:gsub("workspace:WaitForChild(\"Doors\")", "workspace.Map:WaitForChild(\"DynamicMap\"):WaitForChild(\"Doors\")")
end

return ConvertScript
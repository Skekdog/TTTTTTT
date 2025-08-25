
local function ConvertPropsFolder(propsFolder: Instance, dynamic: Folder): ()
	propsFolder = propsFolder:Clone()
	for _, prop in propsFolder:GetChildren() do
		if not prop:IsA("Model") then
			warn(`Unknown type {prop.ClassName} for Prop {prop.Name}`)
			continue
		end

		prop:AddTag("Prop")
	end

	propsFolder.Parent = dynamic
end

return ConvertPropsFolder
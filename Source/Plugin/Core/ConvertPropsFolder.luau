
local function ConvertPropsFolder(propsFolder: Instance, dynamic: Folder): ()
	propsFolder = propsFolder:Clone()
	for _, prop in propsFolder:GetDescendants() do
		if not prop:IsA("Model") then
			continue
		end
		prop:AddTag("Prop")
	end

	propsFolder.Parent = dynamic
end

return ConvertPropsFolder
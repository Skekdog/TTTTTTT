
local function ConvertPropsFolder(propsFolder: Instance, props: Folder): ()
	for _, prop in propsFolder:GetChildren() do
		if not prop:IsA("Model") then
			warn(`Unknown type {prop.ClassName} for Prop {prop.Name}`)
			continue
		end

		prop = prop:Clone()

		local root = prop.PrimaryPart
		if not root then
			warn(`Prop {prop.Name} has no PrimaryPart`)
			continue
		end

		for _, v in prop:GetChildren() do
			if v ~= root then
				v.Parent = root
			end
		end

		for i, v in prop:GetAttributes() do
			root:SetAttribute(i, v)
		end

		root.Name = prop.Name
		root.Parent = props
	end
end

return ConvertPropsFolder
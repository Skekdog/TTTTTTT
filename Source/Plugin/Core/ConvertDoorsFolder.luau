
local function ConvertDoorsFolder(doorsFolder: Instance, doors: Folder): ()
	for _, model in doorsFolder:GetDescendants() do
		if not model:IsA("Model") then
			warn(`Unknown type {model.ClassName} for Door {model.Name}`)
			continue
		end

		model = model:Clone()

		local root = model.PrimaryPart
		if not root then
			warn(`Door {model.Name} has no PrimaryPart`)
			continue
		end

		for _, v in model:GetChildren() do
			if v ~= root then
				v.Parent = root
			end
		end

		root.Name = model.Name
		root.Parent = doors
	end
end

return ConvertDoorsFolder
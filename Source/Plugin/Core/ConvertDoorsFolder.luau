
local function ConvertDoorsFolder(doorsFolder: Instance, doors: Folder): ()
	for _, model in doorsFolder:GetDescendants() do
		if not model:IsA("Model") then
			continue
		end

		model = model:Clone()

		local root = model.PrimaryPart
		if not root then
			warn(`Door {model.Name} has no PrimaryPart`)
			continue
		end

		local doorConfig = model:FindFirstChild("DoorConfig")
		if doorConfig then
			for i, v in doorConfig:GetAttributes() do
				root:SetAttribute(i, v)
			end

			local sounds = doorConfig:FindFirstChild("Sounds")
			if sounds then
				local close = sounds:FindFirstChild("Close")
				if close then
					for _, v in close:GetChildren() do
						v.Name = "CloseSound"
						v.Parent = root
					end
				end

				local open = sounds:FindFirstChild("Open")
				if open then
					for _, v in open:GetChildren() do
						v.Name = "OpenSound"
						v.Parent = root
					end
				end
			end
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
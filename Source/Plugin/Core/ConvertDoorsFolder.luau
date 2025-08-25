
local function ConvertDoorsFolder(doorsFolder: Instance, dynamic: Folder): ()
	doorsFolder = doorsFolder:Clone()
	for _, model in doorsFolder:GetDescendants() do
		if not model:IsA("Model") then
			continue
		end

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
				sounds.Parent = root
			end
		end

		model:AddTag("Door")
		model:AddTag("Interactable")
	end
	doorsFolder.Parent = dynamic
end

return ConvertDoorsFolder
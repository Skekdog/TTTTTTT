
local function ConvertDoorsFolder(doorsFolder: Instance, dynamic: Folder): ()
	doorsFolder = doorsFolder:Clone()
	for _, model in doorsFolder:GetDescendants() do
		if not model:IsA("Model") then
			continue
		end

		local doorConfig = model:FindFirstChild("DoorConfig")
		if doorConfig then
			for i, v in doorConfig:GetAttributes() do
				model:SetAttribute(i, v)
			end

			local sounds = doorConfig:FindFirstChild("Sounds")
			if sounds then
				sounds.Parent = model
			end
		end

		model:AddTag("Door")
		model:AddTag("Interactable")
	end
	doorsFolder.Parent = dynamic
end

return ConvertDoorsFolder
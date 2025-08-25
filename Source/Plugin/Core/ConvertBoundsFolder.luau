
local function ConvertBoundsFolder(bounds: Instance, static: Folder): ()
	bounds = bounds:Clone()

	for _, v in bounds:GetDescendants() do
		if v:IsA("BasePart") then
			if v.CollisionGroup == "Ladder" then
				v.CanCollide = false
				v:AddTag("Ladder")
				v:AddTag("Interactable")
			end
			if v:GetAttribute("MaterialOverride") == "Water" then
				v.CanCollide = false
				v:AddTag("Water")
			end
			v.CollisionGroup = "Bounds"
		end
	end

	bounds.Parent = static
end

return ConvertBoundsFolder
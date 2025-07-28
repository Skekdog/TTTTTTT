
local function ConvertSpawnsFolder(spawnsFolder: Instance, playerSpawns: Folder): ()
	for _, v in spawnsFolder:GetChildren() do
		local spawnPart: BasePart?
		if v:IsA("Attachment") then
			spawnPart = Instance.new("Part")
			spawnPart.CFrame = v.WorldCFrame
		elseif v:IsA("BasePart") then
			spawnPart = v:Clone()
		else
			warn(`Unknown spawn type {v.ClassName} for {v.Name}`)
		end

		if spawnPart then
			spawnPart.Name = v.Name
			spawnPart.Anchored = true
			spawnPart.CanCollide = false
			spawnPart.CanQuery = false
			spawnPart.CanTouch = false
			spawnPart.Size = Vector3.one
			spawnPart.Color = Color3.fromRGB(140, 0, 98)
			spawnPart.Position += Vector3.new(0, 1.5, 0)
			spawnPart.Material = Enum.Material.Neon
			spawnPart.Parent = playerSpawns
		end
	end
end

return ConvertSpawnsFolder
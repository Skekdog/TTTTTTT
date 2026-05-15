
local nameMap = {
	["High-Cal Ammo"] = "High-Cal",
	["Mil-Spec Ammo"] = "Mil-Spec",
	["Rifle Ammo"] = "Rifle",
	["SMG Ammo"] = "Sub-Spec",
	["Shotgun Ammo"] = "Shotgun",

	["Desert Eagle"] = "Deagle",
	["Five-seveN"] = "Five-Seven",
	["M1014"] = "XM1014",
	["M249 SAW"] = "HUGE",
	["M4A1 Carbine"] = "M4A1",
}

local function ConvertItemsFolder(itemsFolder: Instance, dynamic: Folder): ()
	itemsFolder = itemsFolder:Clone()
	for _, item in itemsFolder:GetChildren() do
		if item.Name:split(" ")[2] == "Ammo" then
			item:AddTag("AmmoBox")
		else
			item:AddTag("Item")
		end

		if item:IsA("BasePart") then
			item.Anchored = false
			item.CanCollide = true
		end

		local newName = nameMap[item.Name] or item.Name
		item.Name = newName
	end
	itemsFolder.Parent = dynamic
end

return ConvertItemsFolder
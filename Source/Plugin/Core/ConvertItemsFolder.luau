
local nameMap = {
	["High-Cal Ammo"] = "Deagle",
	["Mil-Spec Ammo"] = "9mm",
	["Rifle Ammo"] = "Rifle",
	["SMG Ammo"] = "SMG1",
	["Shotgun Ammo"] = "Shotgun",

	["Desert Eagle"] = "Deagle",
	["Five-seveN"] = "Pistol",
	["G18"] = "Glock",
	["M1014"] = "XM1014",
	["M11"] = "SMG",
	["M249 SAW"] = "HUGE",
	["M4A1 Carbine"] = "Assault Rifle",
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
		end

		local newName = nameMap[item.Name] or item.Name
		item.Name = newName
	end
	itemsFolder.Parent = dynamic
end

return ConvertItemsFolder
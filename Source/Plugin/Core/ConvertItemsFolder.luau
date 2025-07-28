
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

local function ConvertItemsFolder(itemsFolder: Instance, itemSpawns: Folder, ammoSpawns: Folder): ()
	for _, v in itemsFolder:GetChildren() do
		local newName = nameMap[v.Name] or v.Name
		local newObject = v:Clone()
		newObject.Name = newName

		if v.Name:split(" ")[2] == "Ammo" then
			newObject.Parent = ammoSpawns
		else
			newObject.Parent = itemSpawns
		end
	end
end

return ConvertItemsFolder
local Codify = require("../../Lib/Codify")

local function ConvertCustomItems(customItems: Instance, staticMap: Folder): string?
	local items = {}
	for _, item in customItems:GetChildren() do
		local itemDefinition = {}
		itemDefinition.Kind = "Item"
		itemDefinition.Name = item.Name
		itemDefinition.CanDrop = true

		local worldModel = item:FindFirstChild("WorldModel")
		if worldModel then
			if worldModel:IsA("BasePart") then
				worldModel:Clone().Parent = staticMap
				itemDefinition.Model = worldModel.Name
			else
				warn(`Unknown WorldModel type {worldModel.ClassName} for Custom Item {item.Name}`)
			end
		end

		items[item.Name] = itemDefinition
	end

	return Codify(items)
end

return ConvertCustomItems
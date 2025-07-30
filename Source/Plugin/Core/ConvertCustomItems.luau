local Codify = require("../../Lib/Codify")


local function ConvertCustomItems(customItems: Instance, staticMap: Folder): string?
	local items = {}
	for _, item in customItems:GetChildren() do
		local itemDefinition = {}
		itemDefinition.Kind = {__CodifyCode = '"Item" :: "Item"'}
		itemDefinition.Name = item.Name
		itemDefinition.CanDrop = true
		itemDefinition.Slot = 9

		local worldModel = item:FindFirstChild("WorldModel")
		if worldModel then
			if worldModel:IsA("BasePart") then
				worldModel = worldModel:Clone()
				worldModel.Name = item.Name
				worldModel.Parent = staticMap
				itemDefinition.Model = {__CodifyCode = `script.StaticMap["{worldModel.Name}"]`}
			else
				warn(`Unknown WorldModel type {worldModel.ClassName} for Custom Item {item.Name}`)
			end
		end

		items[item.Name] = itemDefinition
	end

	return Codify(items)
end

return ConvertCustomItems
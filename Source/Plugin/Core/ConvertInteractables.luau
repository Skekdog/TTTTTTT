local Codify = require("../../Lib/Codify")

local function generateServerInteract(): {__CodifyCode: string}
	return {__CodifyCode = [[
		function(object: Types.Interactable, participant: Types.Participant)
			if not object.Object:FindFirstChild("ButtonServer") then return end -- Some maps spawn the ModuleScript in at runtime
			return (require)(object.Object.ButtonServer).Began(participant.Player, nil)
		end
	]]}
end

local function generateClientInteract(): {__CodifyCode: string}
	return {__CodifyCode = [[
		function(object: Types.Interactable)
			if not object.Object:FindFirstChild("ButtonClient") then return end
			return (require)(object.Object.ButtonClient).Began()
		end
	]]}
end

local function convertOne(model: Model, map: Instance): any
	local newName = model.Name
	local index = 0
	while map:FindFirstChild(newName, true) do
		newName = model.Name .. index
		index += 1
		task.wait()
	end

	local hintText: string?
	local hintTextAttr = model:GetAttribute("UseText")
	if hintTextAttr ~= nil then
		hintText = tostring(hintTextAttr)
	end

	local definition = {}
	definition.Name = newName
	definition.DisplayName = model.Name
	definition.DefaultHintText = hintText
	definition.IsContinuousInteraction = false
	definition.Model = {__CodifyCode = `script:FindFirstChild("{newName}", true) or error("Could not find interactable {newName}")`}
	definition.InteractionRange = 7.5

	definition.OnInteractServer = generateServerInteract()
	definition.OnInteractClient = generateClientInteract()

	model.Name = newName
	model:AddTag("Interactable")

	return definition
end

local function ConvertInteractables(map: Instance): string?
	local interactables = {}
	for _, model in map:GetDescendants() do
		if model:IsA("Model") and model:GetAttribute("Button") == true and not model:HasTag("Door") then
			local result = convertOne(model, map)
			if result then
				interactables[result.Name] = result
			end
		end
	end

	return Codify(interactables)
end

return ConvertInteractables
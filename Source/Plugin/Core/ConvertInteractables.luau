local Codify = require("../../Lib/Codify")

local function generateServerInteract(buttonServer: ModuleScript): {__CodifyCode: string}
	return {__CodifyCode = [[
		function(object: Types.Interactable, participant: Types.Participant)
			return (require)(object.Object.ButtonServer).Began(participant.Player, nil)
		end
	]]}
end

local function generateClientInteract(buttonClient: ModuleScript): {__CodifyCode: string}
	return {__CodifyCode = [[
		function(object: Types.Interactable)
			return (require)(object.Object.ButtonClient).Began()
		end
	]]}
end

local function convertOne(model: Model, interactablesFolder: Folder): any
	local root = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
	if not root then
		warn("Could not find root for interactable", model.Name)
		return nil
	end

	for _, v in model:GetChildren() do
		if v ~= root then
			v.Parent = root
		end
	end

	for i, v in model:GetAttributes() do
		root:SetAttribute(i, v)
	end

	local newName = model.Name
	local index = 0
	while interactablesFolder:FindFirstChild(newName) do
		newName = model.Name .. index
		index += 1
		task.wait()
	end

	root.Name = newName
	root.Parent = interactablesFolder

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
	definition.Model = {__CodifyCode = `script.Interactables["{newName}"]`}
	definition.InteractionRange = 7.5

	local buttonServer = root:FindFirstChild("ButtonServer")
	if buttonServer and buttonServer:IsA("ModuleScript") then
		definition.OnInteractServer = generateServerInteract(buttonServer)
	end

	local buttonClient = root:FindFirstChild("ButtonClient")
	if buttonClient and buttonClient:IsA("ModuleScript") then
		definition.OnInteractClient = generateClientInteract(buttonClient)
	end

	model.Parent = nil

	return definition
end

local function ConvertInteractables(map: Instance, doorsFolder: Folder, interactablesFolder: Folder): string?
	local interactables = {}
	for _, model in map:GetDescendants() do
		if model:IsA("Model") and model:GetAttribute("Button") == true and not model:IsDescendantOf(doorsFolder) then
			local result = convertOne(model, interactablesFolder)
			if result then
				interactables[result.Name] = result
			end
		end
	end

	return Codify(interactables)
end

return ConvertInteractables
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local RunService = game:GetService("RunService")
local Selection = game:GetService("Selection")

if RunService:IsRunning() then
	return
end

local Convert = require("./Plugin/Core/Convert")
local Toolbar = require("./Plugin/Toolbar")

Toolbar.OnClick = function()
	local selection = Selection:Get()
	if #selection == 0 then
		return warn("Nothing selected, no conversion will be made.")
	end

	local folder = selection[1]
	if not folder:IsA("ModuleScript") and not folder:IsA("Folder") then
		return warn("Selected Instance is not a ModuleScript or Folder, no conversion will be made.")
	end

	local waypoint = ChangeHistoryService:TryBeginRecording("TTTTTTT Conversion")

	local success, result: ModuleScript | string = pcall(Convert, folder)
	if not success then
		warn(result)
	end

	if waypoint then
		ChangeHistoryService:FinishRecording(waypoint, if success then Enum.FinishRecordingOperation.Commit else Enum.FinishRecordingOperation.Cancel)
	end

	print("Conversion", if success then "succeeded" else "failed")
end
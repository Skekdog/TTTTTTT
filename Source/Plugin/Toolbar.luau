local GetPlugin = require("../Lib/GetPlugin")

local plugin = GetPlugin

local module = {}

local toolbar = plugin:CreateToolbar("TTTTTTT")
local button = toolbar:CreateButton("Convert", "Converts the selected TT2 map into a TYT map", "rbxassetid://108635454194584")
button.ClickableWhenViewportHidden = true

module.Toolbar = toolbar
module.Button = button
module.OnClick = nil :: () -> ()?

button.Click:Connect(function()
	if module.OnClick then
		module.OnClick()
	end
end)

return module
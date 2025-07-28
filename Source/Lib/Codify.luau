
local function Codify(value: any): string?
	local valueString: string?
	if typeof(value) == "Color3" then
		valueString = `Color3.fromHex("{value:ToHex()}")`
	elseif typeof(value) == "number" then
		valueString = tostring(value)
	elseif typeof(value) == "string" then
		valueString = `"{value}"`
	elseif typeof(value) == "boolean" then
		valueString = tostring(value)
	elseif typeof(value) == "table" then
		valueString = "{"
		for i, v in value do
			valueString ..= `\n[{Codify(i)}] = {Codify(v)},`
		end
		valueString ..= "\n}"
	end

	return valueString
end

return Codify
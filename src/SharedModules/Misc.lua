local module = {}

--[[
    Converts a string of a vector3 back into a Vector3 object
]]
---@param str string
---@return Vector3
function module.stringToVector3(str)
	local parts = string.split(str, ", ")
	return Vector3.new(tonumber(parts[1]), tonumber(parts[2]), tonumber(parts[3]))
end

return module
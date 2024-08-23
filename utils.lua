--[[
	Common/useful utilities
	@module utils
--]]

local GYATT_SCRIPT = require("gyatt-script")

Utils = {}

--[[
	Function that checks if a table has a specific value

	@treturn Boolean
--]]
function Utils.table_contains(list, value)
	for _, v in pairs(list) do
		if v == value then return true end
	end

	return false
end

function Utils.dprint(...)
	if GYATT_SCRIPT.is_debug_build then print(...) end
end

return Utils

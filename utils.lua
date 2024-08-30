--[[
	Common/useful utilities
	@module utils
--]]

local GYATT_SCRIPT = require("config")

--[[
	The main table.
	@table Utils
--]]
local Utils = {}

--[[
	Function that checks if a table has a specific value
	@function table_contains
	@treturn Boolean
--]]
function Utils.table_contains(list, value)
	for _, v in pairs(list) do
		if v == value then return true end
	end

	return false
end

--[[
	A debug print statement that only runs if the language is
	ran in debug mode.
	@function dprint
--]]
function Utils.dprint(...)
	if GYATT_SCRIPT.is_debug_build then print(...) end
end

return Utils

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

--[[
	Print formatted tables.
	@function pretty_print
--]]
function Utils.pretty_print(o, indent)
	if not indent then
		indent = ""
	end
	local indent_str = indent .. "  "

	if type(o) == 'table' then
		local s = "{\n"
		for k, v in pairs(o) do
			if type(k) ~= 'number' then k = '"'..k..'"' end
			s = s .. indent_str .. "["..k.."] = " .. Utils.pretty_print(v, indent_str) .. ",\n"
		end
		return s .. indent .. "}"
	else
		return tostring(o)
	end
end

--[[
	Print formatted arrays:3 (probably works)
	@function print_array
--]]
function Utils.print_array(a)
	io.write("{")
	for _, v in ipairs(a) do
		if type(v) ~= "table" then
			io.write(tostring(v))
		else
			io.write(Utils.pretty_print(v, ""))
		end
	end
	print("}")
end

return Utils

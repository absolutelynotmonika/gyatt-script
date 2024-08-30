--[[
	Token related info for the lexer.
	@module Token
--]]

local Utils = require("utils")

--[[
	A token class.
	@module Token

	@field type  Number The token type
	@field value Any The lexeme
--]]
local Token = {}
-- class instance init
function Token:new(ttype, value)
	local o = {}

	if not type then
		error("Token type expected in function call, not'" .. tostring(ttype) .. "(value of type " .. type(ttype) .. "'.")
	end
	assert(self:is_valid_type(ttype), "Unknown token type given '" .. tostring(ttype) .. "'.")

	o.type  = ttype
	o.value = value

	setmetatable(o, self)
	self.__index = self
	return o
end

--[[
	The available token types.
	@table TokenType
--]]
Token.types = {
	IDENTF    = "IDENTIFIER",
	WHITESPC  = "WHITESPACE",
	NUMBER    = "NUMBER",
	STRING    = "STRING",
	KEYWORD   = "KEYWORD",
	COMP_OPER = "COMPARISON",
	BIN_OPER  = "BINARY OPERATOR",
	PUNCT     = "PUNCTUATION",
	ASSIGN    = "ASSIGNMENT OPERATOR",
	UNARY     = "UNARY OPERATOR",
	EOF       = "EOF"
}
function Token:is_valid_type(ttype)
	return Utils.table_contains(self.types, string.upper(tostring(ttype)))
end

return Token

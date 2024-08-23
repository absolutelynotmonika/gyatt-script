local Utils = require("utils")

--[[
	A token class.
	@class Token

	@field type  Number The token type
	@field value String The lexeme
--]]
local Token = {}

-- class instance init
function Token:new(ttype, value)
	local o = {}

	if not ttype then
		error("Token type expected in function call.")
	end

	o.type  = ttype
	o.value = value

	setmetatable(o, self)
	self.__index = self
	return o
end

--[[
	The lexer class
	@class Lexer
	@field tokens Array  The array of tokens
--]]
local Lexer = {}
Lexer.src_code     = nil
Lexer.pos          = 1
Lexer.current_char = nil
Lexer.tokens       = {}
Lexer.token_types  = {
	IDENTF  = "IDENTIFIER",
	NUMBER  = "NUMBER",
	STRING  = "STRING",
	KEYWORD = "KEYWORD",
	OPER    = "OPERATOR",
	COMPAR  = "COMPARISON",
	EOF     = "EOF"
}

--[[
	Stuff for token types
--]]
local operators    = {"+", "-", "*", "/"}
local dc_operators = {"<", ">", "="}
--[[
	Advance in the source code n amount of times.
	@function advance
	@field n Number  Advance a specific number of times. (default: 1)
--]]
function Lexer:advance(n)
	n = n or 1
	self.pos = self.pos + n
	Utils.dprint("advanced by " .. n .. " (current pos is " .. tostring(self.pos) .. ")")
end

--[[
	Get the next character in the source code.
	@function peek
	@treturn Char or Nil
--]]
function Lexer:peek()
	return self.src_code:sub(self.pos+1, self.pos+1)
end

--[[
	Add a token.in the Lexer.tokens array.
	@function add_token
--]]
function Lexer:add_token(token_type, value)
	table.insert(self.tokens, Token:new(token_type, value))
	Utils.dprint("added new token " .. "(" .. value .. ": ".. token_type .. ")")
end

--[[
	This function checks if the lexer got at the end of the source code
	@function is_at_end
	@treturn  Boolean
--]]
function Lexer:is_at_end()
	return self.pos > #self.src_code
end

--[[
	The function that lexes the source code and returns the tokens array.
	@function get_tokens
	@treturn  Array
--]]
function Lexer:get_tokens(src_code)
	self.src_code = src_code
	Utils.dprint("==== LEXING START ====\n")

	while not self:is_at_end() do
		Utils.dprint("--- loop start ---")

		self.current_char = self.src_code:sub(self.pos, self.pos)
		Utils.dprint("current char: " .. (self.current_char or "<nil>"))
		Utils.dprint("peek: " .. (self:peek() or "<nil>"))

		-- check if it meets always-single character operators.
		if Utils.table_contains(operators, self.current_char) then
			self:add_token(self.token_types.OPER, self.current_char)
			self:advance()
			goto continue
		end

		-- check if it meets possibily double character tokens.
		if Utils.table_contains(dc_operators, self.current_char) then
			if self:peek() == "=" then
				self:add_token(self.token_types.COMPAR, self.current_char .. "=")
				self:advance(2)
			else
				-- since = isnt a comparisn operator, we specifically checks
				-- against it using a "ternary".
				self:add_token (
					self.current_char ~= "=" and self.token_types.COMPAR or self.token_types.OPER,
					self.current_char
				)
				self:advance(1)
			end

			goto continue
		end

		--- if it doesnt match any case then
		-- check if number
		if string.match(self.current_char, "%d") then
			Utils.dprint("# is number")
			local number_value = self.current_char

			--- continue adding the number value
			while string.match(self:peek(), "%d") do
				number_value = number_value .. self:peek()
				self:advance()
			end

			-- check if the next character is a dot, and if the character
			-- after is it again a number then continue the number token. 
			if self:peek() == "." and string.match(self.src_code:gsub(self.pos+2, self.pos+2), "%d") then
				number_value = number_value .. "."
				self:advance() -- eat the dot away

				--- continue adding the number value again
				while string.match(self:peek(), "%d") do
					number_value = number_value .. self:peek()
					self:advance()
				end
			end

			-- finally add the token
			self:add_token(self.token_types.NUMBER, number_value)
			self:advance()
			goto continue
		end

		-- if it doesnt match anything fom above, then it is an error
		Utils.dprint("=== Invalid token found ===")
		self:advance()
		goto continue

		::continue::
			Utils.dprint("--- end loop ---\n")
	end

	Utils.dprint("==== REACHED END ====")
	self:add_token(self.token_types.EOF, "eof")
	return self.tokens
end

return Lexer

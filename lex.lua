local Token = require("token")
local Utils = require("utils")

--[[
	The lexer class
	@class Lexer
	@field tokens Array  The array of tokens
--]]
local Lexer = {}
Lexer.pos          = 1
Lexer.current_char = nil
Lexer.err_count    = 0
Lexer.tokens       = {}

--[[
	Representative values (idk what to call them)
--]]
Lexer.value_repr = {}
Lexer.value_repr.binary_oper = {"+", "-", "*", "/"}
Lexer.value_repr.punct = {"(", ")", ";"}
Lexer.value_repr.compr = {"<", ">", "="}
Lexer.value_repr.unary = {"-"}
Lexer.value_repr.identf = "^[%a_][%w_]*$" -- regex
Lexer.keywords = {
	"if",
	"else",
	"elseif",
	"return",
	"while",
	"const",
	"let"
}

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
	Increment the error counter.
	@function add_error
--]]
function Lexer:add_error()
	self.err_count = self.err_count + 1
	Utils.dprint("=== New error added, now count is " .. self.err_count)
end

--[[
	Get the next character in the source code.
	@function peek
	@treturn Char or Nil
--]]
function Lexer:peek()
	return self.src_code:sub(self.pos+1, self.pos+1)
end

function Lexer:lookback()
	return self.src_code:sub(self.pos-1, self.pos-1)
end

--[[
	Add a token.in the Lexer.tokens array.
	@function add_token
--]]
function Lexer:add_token(token_type, value)
	table.insert(self.tokens, Token:new(token_type, value))
	Utils.dprint("added new token " .. "(\"" .. (value or "<nil>") .. "\": ".. (token_type or "<nil>") .. ")")
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
	These functions (or this section) check for the value type of a
	character and all will return true if it matches.

	@section Value Type Check
	@treturn Boolean
--]]
function Lexer.is_whitespace(char)
	return Utils.table_contains({" ", "\t", "\n"}, char)
end

-- check if the character is a number.
function Lexer.is_number(char)
	return string.match(char, "%d+")
end

-- check if the character is a binary oper.
function Lexer.is_bin_oper(char)
	return Utils.table_contains(Lexer.value_repr.binary_oper, char)
end

-- check if the character is a comparison operator.
function Lexer.is_comp_oper(char)
	return Utils.table_contains(Lexer.value_repr.compr, char)
end

-- check if the character is a punctuation.
function Lexer.is_punct(char)
	return Utils.table_contains(Lexer.value_repr.punct, char)
end

-- check if the character is a ", meaning it starts a string.
function Lexer.is_string(char)
	return char == "\""
end

function Lexer:is_unary(char)
	return
		char == "-"
		and self.is_number(self:peek())
		and self.is_whitespace(self:lookback())
		and not self.is_number(self:lookback())
end

-- check if the character is a-Z, 0-9 or _.
function Lexer:is_alphanumeric(char)
	return string.match(char, self.value_repr.identf) ~= nil
end

--[[
	From now on, these functions return longer values based on their
	type, like an entire identifier, an entire number and so on.

	@section Get Value Based On Type

	@treturn String
--]]
function Lexer:get_number()
	local number_value = self.current_char

	--- continue adding the number value
	while self.is_number(self:peek()) do
		number_value = number_value .. self:peek()
		self:advance() -- eat the number
	end

	-- check if the next character is a dot, and if the character
	-- after is it again a number then continue the number token. 
	if self:peek() == "." and self.is_number(self.src_code:gsub(self.pos+2, self.pos+2)) then
		number_value = number_value .. "."
		self:advance() -- eat the dot away

		--- continue adding the number value again
		while self.is_number(self:peek()) do
			number_value = number_value .. self:peek()
			self:advance()
		end
	end

	return number_value
end

-- this should run if Lexer.is_string() returns true, it gives the contents of the string.
function Lexer:get_string()
	local str = ""

	while self:peek() ~= "\"" do
		str = str .. self:peek()
		self:advance()

		assert(self:is_at_end(), "Unterminated string")
	end

	self:advance() -- eat the last character of the string
	return str ~= "" and str or nil
end


-- same as get_string, but it returns a whole identifier.
function Lexer:get_identf()
	local identf = self.current_char

	while self:is_alphanumeric(self:peek()) do
		identf = identf .. self:peek()
		self:advance()
	end

	return identf
end

--[[
	The function that lexes the source code and returns the tokens array.
	@function get_tokens
	@treturn  Array
--]]
function Lexer:get_tokens(src_code)
	self.src_code = src_code -- define the input source code here
	Utils.dprint("==== LEXING START ====\n")

	while not self:is_at_end() do
		Utils.dprint("--- loop start ---")

		self.current_char = self.src_code:sub(self.pos, self.pos)
		Utils.dprint("current char: " .. (self.current_char or "<nil>"))
		Utils.dprint("peek: " .. (self:peek() or "<nil>"))

		-- skip if whitespace
		if Lexer.is_whitespace(self.current_char) then
			self:advance()
			goto continue
		end

		if Lexer.is_punct(self.current_char) then
			self:add_token(Token.types.PUNCT, self.current_char)
			self:advance()
			goto continue
		end

		-- this checks against unary too.
		if self.is_bin_oper(self.current_char) then
			self:add_token(
				self:is_unary(self.current_char) and Token.types.UNARY or Token.types.BIN_OPER,
				self.current_char
			)
			self:advance()
			goto continue
		end

		if self.is_comp_oper(self.current_char) then
			if self:peek() == "=" then
				self:add_token(Token.types.COMP_OPER, self.current_char .. "=")
				self:advance(2)
			else
				-- since, for example = isnt a comparisn operator, we specifically checks
				-- against it using ternary logic, also if its just standalone <, push it too.
				self:add_token (
					self.current_char ~= "=" and Token.types.COMP_OPER or Token.types.ASSIGN,
					self.current_char
				)
				self:advance(1)
			end

			goto continue
		end

		-- check if its the start of a string.
		if Lexer.is_string(self.current_char) then
			self:add_token(Token.types.STRING, self:get_string())
			self:advance() -- eat the ending "
			goto continue
		end

		if self.is_number(self.current_char) then
			self:add_token(
				Token.types.NUMBER,
				self:get_number()
			)
			self:advance()
			goto continue
		end

		if self:is_alphanumeric(self.current_char) then
			local value = self:get_identf()

			print(Utils.table_contains(self.keywords, value) and
					Token.types.KEYWORD
				or
					Token.types.IDENTF
			)

			self:add_token(
				Utils.table_contains(self.keywords, value) and Token.types.KEYWORD or Token.types.IDENTF,
				value
			)
			self:advance() -- eat the last identifier character
			goto continue
		end

		-- if it doesnt match anything from above, then it is an error
		-- but the code execution continues
		Utils.dprint("=== Invalid token found ===")
		self:add_error()
		self:advance()
		goto continue

		::continue::
			Utils.dprint("--- end loop ---\n")
	end

	self:add_token(Token.types.EOF, "eof")
	Utils.dprint("==== LEXING END ====")
	return self.tokens
end

return Lexer

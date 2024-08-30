local Lexer = require("lex")
local Token = require("token")
local NodeTypes = require("ast")
local Utils = require("utils")

local Parser = {}
Parser.pos = 1

--[[
	Advance in the tokens array.
	@function advance
--]]
function Parser:advance()
	self.pos = self.pos + 1
	Utils.dprint("advanced by 1")
end

--[[
	Get the current token according to Parser.pos.
	@function get_current_token
	@treturn  Token
--]]
function Parser:get_current_token()
	return self.tokens[self.pos]
end

--[[
	Check if the current token: is eof.
	@function is_eof
	@treturn  Bool
--]]
function Parser:is_eof()
	return self.tokens[self.pos].type == Token.types.EOF
end

--[[
	Function that parses statement node types.
	@function parse_stmt
	@treturn  Stmt

	@NOTE: since we have no expressions, it just returns a statement.
--]]
function Parser:parse_stmt()
	return self:parse_expr()
end

--[[
	Function that parses expression node types.
	@function parse_expr
	@treturn  Expr
--]]
function Parser:parse_expr()
	return self:parse_primary_expr()
end

function Parser:parse_primary_expr()
	local token = self:get_current_token()

	local type = token.type
	local value = token.value

	if type == Token.types.IDENTF then
		return NodeTypes.Identifier:new(value)
	elseif type == Token.types.NUMBER then
		return NodeTypes.NumericLiteral:new(value)
	else
		return nil -- gonna be changed.
	end
end

--[[
	Get the abstract syntax tree of the program.
	@function Parser

	@param    src_code  The input source code of the program.
	@treturn  Program
--]]
function Parser:produce_ast(src_code)
	self.tokens = Lexer:get_tokens(src_code)
	Utils.dprint("\ntokens:")
	Utils.print_array(self.tokens)

	Utils.dprint("\n==== PARSING START ====")
	self.program = NodeTypes.Program:new()

	while not self:is_eof() do
		Utils.dprint("--- loop start ---")

		local stmt = self:parse_stmt()
		table.insert(self.program.body, stmt)
		Utils.dprint("added stmt (kind: " .. (stmt.kind or "<nil>") .. ")")
		self:advance()

		Utils.dprint("--- loop end ---")
	end

	Utils.dprint("==== PARSING END ====")

	return self.program
end

return Parser

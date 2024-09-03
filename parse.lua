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
function Parser:advance(n)
	n = n or 1
	self.pos = self.pos + n
	Utils.dprint("advanced by " .. n)
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
	Check if the current token is eof.
	@function is_eof
	@treturn  Bool
--]]
function Parser:is_eof()
--	return self.tokens[self.pos].type == Token.types.EOF
	return self.pos >= #self.tokens
end

--[[
	Function that parses statement node types.
	@function parse_stmt
	@treturn  Stmt

	@NOTE: since we have no statements, it just returns an expression.
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
	return self:parse_additive_expr()
end

--[[
	Orders of presidence

	Logical expr
	Comparison expr
	Aditive expr
	Multiplicative expr
	Unary expr
	Primary expr
--]]

function Parser:parse_additive_expr()
	local left = self:parse_primary_expr()
	self:advance()
	local token <const> = self:get_current_token()

	while token.type == Token.types.BIN_OPER and (token.value == "+" or token.value == "-") do
		local oper <const> = token.value
		self:advance()
		local right <const> = self:parse_primary_expr()

		print(oper)
		left = NodeTypes.BinaryExpr:new(left, right, oper)
	end

	return left
end

function Parser:parse_primary_expr()
	local token <const> = self:get_current_token()

	if token.type == Token.types.IDENTF then
		Utils.dprint("returned an identifier")
		return NodeTypes.Identifier:new(token.value)
	elseif token.type == Token.types.NUMBER then
		Utils.dprint("returned a numeric literal")
		return NodeTypes.NumericLiteral:new(token.value)
	else
		Utils.dprint(string.format(
			"Unexpected token found during parsing:\n\t%s\nof type: %s.",
			token.value,
			token.type
		))
		os.exit(1)
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

		local stmt <const> = self:parse_stmt()

		table.insert(self.program.body, stmt)
		Utils.dprint("added stmt (kind: " .. (stmt.kind or "<nil>") .. ")")
		self:advance()

		Utils.dprint("--- loop end ---")
	end

	Utils.dprint("==== PARSING END ====")

	return self.program
end

return Parser

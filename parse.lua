local Lexer = require("lex")
local Token, TokenType = require("token")
local Program, Identifier, BinaryExpr, Identifier, NumericLiteral = require("ast")

local Parser = {}
Parser.pos = 0
Parser.program = Program:new()

function Parser:is_eof()
	return self.tokens[self.pos].type == TokenType.EOF
end

function Parser:eat()
end

function Parser:parse_stmt()
	
end

--[[
	Get the abstract syntax tree of the program.
	@function Parser

	@param    src_code  The input source code of the program.
	@treturn  Program
--]]
function Parser:produce_ast(src_code)
	self.tokens = Lexer:get_tokens(src_code)

	while not self:is_eof() do
		table.insert(self.program, self:parse_stmt())
	end

	return self.program
end

local Lexer = require("lex")
local Parser = require("parse")
local Utils = require("utils")

local ast = Parser:produce_ast("let variable")
print("ast:")
if ast == nil then
	print("no.")
	return
end
print(Utils.pretty_print(ast.body), "   ")

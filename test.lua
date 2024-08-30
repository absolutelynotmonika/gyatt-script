local Lexer = require("lex")
local Parser = require("parse")
local Utils = require("utils")

local ast = Parser:produce_ast("variable")
print("ast:")
print(Utils.pretty_print(ast.body), "   ")

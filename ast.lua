--[[
	Gyatt Script's ast types.
	@module ast
--]]

--[[
	The available types for nodes like stmt.
--]]
local NodeTypes = {
	"Program",
	"NumericLiteral",
	"BinaryExpr",
	"Identifier",
}

function NodeTypes:is_valid(type)
	for _, v in pairs(self) do
		if string.lower(type) == string.lower(v) then return true end
	end

	return false
end

--[[
	Interface for statements.
	@interface    Stmt
	@param kind   The kind of statement.
	@param.generic_kind The internal variable that holds across all instances for checking, like a generic kind.
--]]
local Stmt = {}
function Stmt:new(kind)
	local o = {}

	o.kind = kind
	o.generic_kind = "Expr"
	assert(NodeTypes:is_valid(kind), "Invalid node kind '" .. kind .. "'.")

	setmetatable(o, self)
	self.__index = self
	return o
end

--[[
	Interface for expressions.
	@interface Expr
	@inherit   Stmt
	@see       Stmt
--]]
local Expr = {}
function Expr:new(kind)
	local o = Stmt:new(kind)
	o.generic_kind = "Expr"

	setmetatable(o, self)
	self.__index = self
	return o
end

--[[
	The implementation of all node types.
	@section implementation
--]]

--[[
	The main program statement that holds all statements and expressions.
	@class Program
	@field body  The program's body, the parent node of all.
	@inherit Stmt
--]]
local Program = {}
function Program:new()
	local o = Stmt:new("Program")

	o.body = {}

	setmetatable(o, self)
	self.__index = self
	return o
end

--[[
	Binary expression like 2 + 2.
	@class BinaryExpr
	@field left  The left side of the expression.
	@field right The right side of the expression.
--]]
local BinaryExpr = {}
function BinaryExpr:new(left, right, op)
	local o = Expr:new("BinaryExpr")

	-- make sure both sides of the expression are Expr internally.
	assert(left.generic_kind ~= "Expr", "Left side of BinaryExpr should be 'expr' not '" .. left.generic_kind .. "'.")
	assert(right.generic_kind ~= "Expr", "Right side of BinaryExpr should be 'expr' not '" .. right.generic_kind .. "'.")

	o.left = left
	o.right = right
	o.operator = op

	setmetatable(o, self)
	self.__index = self
	return o
end

--[[
	Identifiers like "x".
	@class   Identifier
	@inherit Expr
--]]
local Identifier = {}
function Identifier:new(symbol)
	local o = Expr:new("Identifier")

	o.symbol = symbol

	setmetatable(o, self)
	self.__index = self
	return o
end

--[[
	Numeric values like "-2".
	@class   NumericLiteral
	@inherit Expr
--]]
local NumericLiteral = {}
function NumericLiteral:new(value)
	local o = Expr:new("NumericLiteral")

	o.value = value

	setmetatable(o, self)
	self.__index = self
	return o
end

return Program, Identifier, BinaryExpr, Identifier, NumericLiteral

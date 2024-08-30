--[[
	Gyatt Script's ast types.
	@module ast
--]]

--[[
	Interface for statements.
	@interface    Stmt
	@param kind   The kind of statement.
	@param.general_kind The internal variable that holds across all instances for checking, like a general kind.
--]]
local Stmt = {}
function Stmt:new(kind)
	local o = {}

	o.kind = kind
	o.general_kind = "Expr"

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
	o.general_kind = "Expr"

	setmetatable(o, self)
	self.__index = self
	return o
end

--[[
	The implementation of all node types.
	@section implementation
--]]
local NodeTypes = {}

--[[
	The main program statement that holds all statements and expressions.
	@class Program
	@field body  The program's body, the parent node of all.
	@inherit Stmt
--]]
NodeTypes.Program = {}
function NodeTypes.Program:new()
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
NodeTypes.BinaryExpr = {}
function NodeTypes.BinaryExpr:new(left, right, op)
	local o = Expr:new("BinaryExpr")

	-- make sure both sides of the expression are Expr internally.
	assert(left.general_kind ~= "Expr", "Left side of BinaryExpr should be 'expr' not '" .. left.general_kind .. "'.")
	assert(right.general_kind ~= "Expr", "Right side of BinaryExpr should be 'expr' not '" .. right.general_kind .. "'.")

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
NodeTypes.Identifier = {}
function NodeTypes.Identifier:new(symbol)
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
NodeTypes.NumericLiteral = {}
function NodeTypes.NumericLiteral:new(value)
	local o = Expr:new("NumericLiteral")

	o.value = value

	setmetatable(o, self)
	self.__index = self
	return o
end

return NodeTypes

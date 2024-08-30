local Lexer = require("lex")

for i, v in ipairs(Lexer:get_tokens("const x = 2---2")) do
	print("token " .. i .. ": " .. v.value .. " (" .. v.type .. ")")
end

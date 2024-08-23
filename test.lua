local Lexer = require("lex")

for i, v in ipairs(Lexer:get_tokens("11.70")) do
	print("token " .. i .. ": " .. v.value .. " (" .. v.type .. ")")
end

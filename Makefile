LUA       = lua
SRC_LEXER = lex.lua
TEST_FILE = test.lua

all: test

test:
	$(LUA) $(TEST_FILE)

.PHONY: test

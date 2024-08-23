LUA       = lua
SRC_LEXER = src/lex.lua
TEST_FILE = test.lua

all: test

test:
	$(LUA) $(TEST_FILE)

.PHONY: test

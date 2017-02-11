BIN=./bin
SOURCE=./src
INPUT=./test

$(BIN)/lexer : parse.tab.c lex.yy.c
	g++ -std=c++11 -w parse.tab.c lex.yy.c $(SOURCE)/nodes.cpp -o $(BIN)/lexer -I $(SOURCE)

parse.tab.c : 
	bison -d $(SOURCE)/parse.y

lex.yy.c : 
	lex $(SOURCE)/scan.l

clean : 
	rm -f $(BIN)/lexer  parse.tab.c lex.yy.c \
	  parse.tab.h

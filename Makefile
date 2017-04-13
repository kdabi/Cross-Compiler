BIN=./bin
SOURCE=./src
INPUT=./test

$(BIN)/lexer : parse.tab.c lex.yy.c
	g++ -std=c++11 -w parse.tab.c lex.yy.c $(SOURCE)/nodes.cpp  $(SOURCE)/typeCheck.cpp $(SOURCE)/symTable.cpp $(SOURCE)/symTable.h $(SOURCE)/3ac.cpp -o $(BIN)/lexer -I $(SOURCE)

parse.tab.c : 
	bison -d $(SOURCE)/parse.y

lex.yy.c : 
	lex $(SOURCE)/scan.l

%.png: %.gv
	dot -Tpng $? -o $@

clean : 
	rm -f $(BIN)/lexer  parse.tab.c lex.yy.c \
	  parse.tab.h *.csv

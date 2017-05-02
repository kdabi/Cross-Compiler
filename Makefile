BIN=./bin
SOURCE=./src
INPUT=./test
CC=g++ -ggdb3
$(BIN)/lexer : parse.tab.c lex.yy.c
	$(CC) -std=c++11 -w parse.tab.c lex.yy.c $(SOURCE)/nodes.cpp  $(SOURCE)/typeCheck.cpp $(SOURCE)/symTable.cpp $(SOURCE)/symTable.h $(SOURCE)/3ac.cpp $(SOURCE)/codeGen.cpp $(SOURCE)/runTime.cpp -o $(BIN)/lexer -I $(SOURCE)

parse.tab.c : 
	bison -d $(SOURCE)/parse.y

lex.yy.c : 
	lex $(SOURCE)/scan.l

%.png: %.gv
	dot -Tpng $? -o $@

clean : 
	rm -f $(BIN)/lexer  parse.tab.c lex.yy.c \
	  parse.tab.h *.csv

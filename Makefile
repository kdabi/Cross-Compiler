BIN=./bin
SOURCE=./src
INPUT=./test
OUTPUT=./out
plot : $(OUTPUT)/digraph.gv
	dot -Tps $(OUTPUT)/digraph.gv -o $(OUTPUT)/graph.ps

$(OUTPUT)/digraph.gv : $(BIN)/lexer
	./$(BIN)/lexer $(INPUT)/test2.c

$(BIN)/lexer : parse.tab.c lex.yy.c
	g++ -w parse.tab.c lex.yy.c $(SOURCE)/nodes.cpp -o $(BIN)/lexer -I $(SOURCE)

parse.tab.c : 
	bison -d $(SOURCE)/parse.y

lex.yy.c : 
	lex $(SOURCE)/scan.l

clean : 
	rm $(OUTPUT)/graph.ps $(BIN)/lexer $(OUTPUT)/digraph.gv parse.tab.c lex.yy.c \
	  parse.tab.h

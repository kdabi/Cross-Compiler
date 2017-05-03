CC=g++ -ggdb3 -std=c++11 -w
BIN=./bin
SOURCE=./src
INPUT=./test
BUILD=./build
OBJ=$(BUILD)/nodes.o     \
		$(BUILD)/typeCheck.o \
		$(BUILD)/symTable.o  \
		$(BUILD)/3ac.o       \
		$(BUILD)/codeGen.o   \
		$(BUILD)/runTime.o

all: $(BIN)/compile

$(BIN)/compile: $(SOURCE)/compile $(BIN)/compiler
	@mkdir -p $(BIN)
	cp $< $@

$(BIN)/compiler: $(BUILD)/parse.tab.c $(BUILD)/lex.yy.c $(OBJ)
	@mkdir -p $(BIN)
	$(CC) $^ -o $@ -I$(BUILD) -I$(SOURCE)

$(BUILD)/parse.tab.c: $(SOURCE)/parse.y
	@mkdir -p $(BUILD)
	bison -d $^ -o $@

$(BUILD)/lex.yy.c: $(SOURCE)/scan.l
	@mkdir -p $(BUILD)
	lex -t $^ > $@

$(BUILD)/%.o: $(SOURCE)/%.cpp
	@mkdir -p $(BUILD)
	$(CC) -c $^ -o $@ -I$(BUILD) -I$(SOURCE)

%.png: %.gv
	dot -Tpng $? -o $@

clean : 
	rm -rf $(BIN)  $(BUILD)
	rm -f *.csv *.asm *.txt *.gv

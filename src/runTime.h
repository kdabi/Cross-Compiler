#include <vector>
#include <map>
#include <string>
#include <iostream>
#include <fstream>
#include <iomanip>
#include <stack>
#include <queue>
#include "nodes.h"
using namespace std;

extern string currFunction;

void addLine(string a);
void printCode();
void printCodeFunc(string a);
void resetRegister();
string getNextReg(qid temporary);
string checkTemporaryInReg(string t);
void addData(string a);
void saveOnJump();
void loadArrayElement(qid temporary, string registerTmp);

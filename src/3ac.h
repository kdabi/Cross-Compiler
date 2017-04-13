#include <iostream>
#include <string>
#include <vector>
#include <iomanip>
#include "symTable.h"
using namespace std;

typedef pair <string, sEntry*> qid;

typedef struct quadruple{
  qid id1;
  qid id2;
  qid op;
  qid res;
  int stmtNum;
} quad;

extern vector <quad> emittedCode;
string getTmpVar();
pair<string, sEntry*> getTmpSym(string type);
int emit (qid id1, qid id2, qid op, qid  res, int stmtNum);
void backPatch(int p, int i);
void display3ac();
void display(quad q, int i);
int getNextIndex();

#include <iostream>
#include <string>
#include <cstring>
#include <vector>
#include <list>
#include <map>
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
extern map<int , string> gotoLabels;

string getTmpVar();
pair<string, sEntry*> getTmpSym(string type);
int emit (qid id1, qid id2, qid op, qid  res, int stmtNum);
void backPatch(list<int> li, int i);
void display3ac();
void display(quad q, int p);
int getNextIndex();
void setResult(int a, qid p);
void setId1(int a, qid p);
void setListId1(list<int> li, qid p);
int assignmentExpression(char *op, string type, string type1, string type3, qid place1, qid place3);
void assignment2(char *op, string type, string type1, string type3, qid place1, qid place3);
bool gotoIndexStorage (string id, int loc);
void gotoIndexPatchListStorage (string id, int loc);
char* backPatchGoto();

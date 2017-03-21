#include <iostream>
#include <string>
#include <cstring>
#include <unordered_map>
#include <map>
using namespace std;

typedef long long ll;
typedef unsigned long long ull;

char* primaryExpr(char* identifier);
char* constant(int nType);
char* postfixExpr(string type, int prodNum);
char* argumentExpr(string type1, string type2, int prodNum);
char* unaryExpr(string op, string type, int prodNum);
bool isInt (string type);
bool isSignedInt (string type);
bool isFloat (string type);
bool isSignedFloat (string type);
char* multilplicativeExpr(string type1, string type2, char op);
char* additiveExpr(string type1, string type2, char op);
char* shiftExpr(string type1,string type2);
char* relationalExpr(string type1,string type2,char * op);
char * equalityExpr(string type1,string type2);
char * bitwiseExpr(string type1,string type2);
char* conditionalExpr(string type1,string type2);
char* validAssign(string type1,string type2);
char* assignmentExpr(string type1,string type2,char* op);

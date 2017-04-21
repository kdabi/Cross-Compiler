#include <string>
#include <iostream>
#include <sstream>
#include <list>
#include <stdio.h>
#include "3ac.h"

using namespace std;

typedef struct {
  long long size;
  long long int iVal;
  long double rVal;
  char *str;
  char cVal;
  int isInit;
  int exprType;
  string name;
  string nodeType;
  string nodeKey;
  //===============//
//  string code;
  qid place;
  list<int> truelist;
  list<int> nextlist;
  list<int> falselist;
  list<int> breaklist;
  list<int> continuelist;
  list<int> caselist;
  //===============//
  int id;
} node;

enum ntype {
    N_INT , N_LONG , N_LONGLONG , N_FLOAT , N_DOUBLE, N_LONGDOUBLE
};
typedef struct{
   int nType; /* 0 int , 1 long , 2 long long ,3 float,4 : double , 5:long double */
   int is_unsigned;
   char * str;
   long long int iVal;
   long double rVal;
} numb;
typedef struct{
   long long int iVal;
   long double rVal;
   char *str;
   char cVal;
   int exprType;
   node * nPtr;
} exprNode;

int getNodeId();
void graphInitialization();
void graphEnd();
node *nonTerminal(char *str,char *op, node *l, node *r);
node *nonTerminal1(char *str,char *op1, node *l,char *op2);
node *nonTerminal3(char *str,char *op1,char *op3, node *l,char *op2);
node *terminal(char *str);
node *nonTerminal2(char *str,node *l,node *m, node *r);
node *nonTerminalFourChild(char *str,node *a1,node *a2, node *a3, node*a4,char* op);
node *nonTerminalFiveChild(char *str,node *a1,node *a2, node *a3, node*a4,node *a5);
node *nonTerminalRoundB(char *str, node *a);
node *nonTerminalSquareB(char *str, node *a);
node *nonTerminalCurlyB(char *str, node *a);

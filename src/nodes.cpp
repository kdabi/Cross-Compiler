#include "nodes.h"

extern FILE *digraph;

int getNodeId() {
  static int nodeId = 0;
  nodeId += 1;
  return nodeId;
}

void graphInitialization() {
  fprintf(digraph, "digraph G {\n");
  fprintf(digraph, "\tordering=out;\n");
}

void graphEnd() {
  fprintf(digraph, "}\n");
}

node *nonTerminal(char *str,char *op, node *l, node *r) {
  node *n = new node;
  n->name = str;
  n->id = getNodeId();
  int op_id = getNodeId();
  char *op_str = op;
  if(op){

    fprintf(digraph, "\t%lu [label=\"%s\"];\n", op_id, op_str);
  }
  fprintf(digraph, "\t%lu [label=\"%s\"];\n", n->id, n->name.c_str());
  if(l) fprintf(digraph, "\t%lu -> %lu;\n", n->id, l->id);
  if(op) fprintf(digraph, "\t%lu -> %lu;\n", n->id, op_id);
  if(r)fprintf(digraph, "\t%lu -> %lu;\n", n->id, r->id);
  return n;
}
node *nonTerminal1(char *str,char *op1, node *l,char *op2) {
  node *n = new node;
  n->name = str;
  n->id = getNodeId();
  int op1_id = getNodeId();
  char *op1_str = op1;
  int op2_id = getNodeId();
  char *op2_str = op2;
  if(op1){

    fprintf(digraph, "\t%lu [label=\"%s\"];\n", op1_id, op1_str);
  }
  if(op2){

    fprintf(digraph, "\t%lu [label=\"%s\"];\n", op2_id, op2_str);
  }
  fprintf(digraph, "\t%lu [label=\"%s\"];\n", n->id, n->name.c_str());
  if(op1) fprintf(digraph, "\t%lu -> %lu;\n", n->id, op1_id);
  if(l)fprintf(digraph, "\t%lu -> %lu;\n", n->id, l->id);
  if(op2) fprintf(digraph, "\t%lu -> %lu;\n", n->id, op2_id);
  return n;
}
node *nonTerminal3(char *str,char *op1,char *op3, node *l,char *op2) {
  node *n = new node;
  n->name = str;
  n->id = getNodeId();
  int op1_id = getNodeId();
  char *op1_str = op1;
  int op3_id = getNodeId();
  char *op3_str = op3;
  int op2_id = getNodeId();
  char *op2_str = op2;
  if(op1){

    fprintf(digraph, "\t%lu [label=\"%s\"];\n", op1_id, op1_str);
  }
  if(op3){

    fprintf(digraph, "\t%lu [label=\"%s\"];\n", op3_id, op3_str);
  }

  if(op2){

    fprintf(digraph, "\t%lu [label=\"%s\"];\n", op2_id, op2_str);
  }
  fprintf(digraph, "\t%lu [label=\"%s\"];\n", n->id, n->name.c_str());
  if(op1) fprintf(digraph, "\t%lu -> %lu;\n", n->id, op1_id);
  if(op3) fprintf(digraph, "\t%lu -> %lu;\n", n->id, op3_id);
  if(l)fprintf(digraph, "\t%lu -> %lu;\n", n->id, l->id);
  if(op2) fprintf(digraph, "\t%lu -> %lu;\n", n->id, op2_id);
  return n;
}
node *nonTerminal2(char *str,node *l,node *m, node *r) {
  node *n = new node;
  n->name = str;
  n->id = getNodeId();
  fprintf(digraph, "\t%lu [label=\"%s\"];\n", n->id, n->name.c_str());
  if(l) fprintf(digraph, "\t%lu -> %lu;\n", n->id, l->id);
  if(m) fprintf(digraph, "\t%lu -> %lu;\n", n->id, m->id);
  if(r)fprintf(digraph, "\t%lu -> %lu;\n", n->id, r->id);
  return n;
}

node *nonTerminalFourChild(char *str,node *a1,node *a2, node *a3, node*a4, char* op) {
  node *n = new node;
  n->name = str;
  n->id = getNodeId();
  int op_id = getNodeId();
  char *op_str = op;
  if(op){
    fprintf(digraph,"\t%lu [label=\"%s\"];\n",op_id,op_str);
  }
  fprintf(digraph, "\t%lu [label=\"%s\"];\n", n->id, n->name.c_str());
  if(a1) fprintf(digraph, "\t%lu -> %lu;\n", n->id, a1->id);
  if(a2) fprintf(digraph, "\t%lu -> %lu;\n", n->id, a2->id);
  if(a3)fprintf(digraph, "\t%lu -> %lu;\n", n->id, a3->id);
  if(a4) fprintf(digraph,"\t%lu -> %lu;\n",n->id,a4->id);
  if(op) fprintf(digraph,"\t%lu -> %lu;\n",n->id,op_id);
  return n;
}

node *nonTerminalFiveChild(char *str,node *a1,node *a2, node *a3, node*a4, node* a5) {
  node *n = new node;
  n->name = str;
  n->id = getNodeId();
  fprintf(digraph, "\t%lu [label=\"%s\"];\n", n->id, n->name.c_str());
  if(a1) fprintf(digraph, "\t%lu -> %lu;\n", n->id, a1->id);
  if(a2) fprintf(digraph, "\t%lu -> %lu;\n", n->id, a2->id);
  if(a3)fprintf(digraph, "\t%lu -> %lu;\n", n->id, a3->id);
  if(a4) fprintf(digraph,"\t%lu -> %lu;\n",n->id,a4->id);
  if(a5) fprintf(digraph,"\t%lu -> %lu;\n",n->id,a5->id);
  return n;
}

node *terminal(char *str) {
  node *n = new node;
  n->name=str;
  n->id = getNodeId();
  // checking '\n' character
  // the loop run til len because the last character is ""
  stringstream ss;
  for(int i=0; i < n->name.size(); ++i){
    if(n->name[i]=='\\'){
      char tmp = '\\';
      ss << tmp;
    }
    ss << n->name[i];
  }
  n->name = ss.str();

  // printing sting token
  if(str[0] == '"'){
    n->name = n->name.substr(1, n->name.size()-2);
    fprintf(digraph, "\t%lu [label=\"\\\"%s\\\"\"];\n", n->id,n->name.c_str() );
  }
  else{
    fprintf(digraph, "\t%lu [label=\"%s\"];\n", n->id,n->name.c_str() );
  }
  return n;
}

node *nonTerminalRoundB(char *str, node *a) {
  node *n = new node;
  n->name=str;
  n->id = getNodeId();
  fprintf(digraph, "\t%lu [label=\"%s\"];\n", n->id,n->name.c_str() );
  int newBracketId = getNodeId();
  fprintf(digraph, "\t%lu [label=\"( )\"];\n", newBracketId );
  if(a) fprintf(digraph, "\t%lu -> %lu;\n", n->id, a->id);
  fprintf(digraph, "\t%lu -> %lu;\n", n->id, newBracketId);
  return n;
}
node *nonTerminalSquareB(char *str, node *a) {
  node *n = new node;
  n->name=str;
  n->id = getNodeId();
  fprintf(digraph, "\t%lu [label=\"%s\"];\n", n->id,n->name.c_str() );
  int newBracketId = getNodeId();
  fprintf(digraph, "\t%lu [label=\"[ ]\"];\n", newBracketId );
  if(a) fprintf(digraph, "\t%lu -> %lu;\n", n->id, a->id);
  fprintf(digraph, "\t%lu -> %lu;\n", n->id, newBracketId);
  return n;
}

node *nonTerminalCurlyB(char *str, node *a) {
  node *n = new node;
  n->name=str;
  n->id = getNodeId();
  fprintf(digraph, "\t%lu [label=\"%s\"];\n", n->id,n->name.c_str() );
  int newBracketId = getNodeId();
  fprintf(digraph, "\t%lu [label=\"{ }\"];\n", newBracketId );
  if(a) fprintf(digraph, "\t%lu -> %lu;\n", n->id, a->id);
  fprintf(digraph, "\t%lu -> %lu;\n", n->id, newBracketId);
  return n;
}

#include <string>
#include <iostream>
#include "nodes.h"
#include <stdio.h>
using namespace std;

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

node *terminal(char *str) {
  node *n = new node;
  n->name=str;
  n->id = getNodeId();
  fprintf(digraph, "\t%lu [label=\"%s\"];\n", n->id,n->name.c_str() );
  return n;
}

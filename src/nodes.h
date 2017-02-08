#include <string>
using namespace std;

typedef struct {
  string name;
  int id;
} node;

int getNodeId();
void graphInitialization();
void graphEnd();
node *nonTerminal(char *str,char *op, node *l, node *r);
node *terminal(char *str);

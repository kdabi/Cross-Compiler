#include "3ac.h"

using namespace std;
using std::setw;

long long Index = -1;

vector <quad> emittedCode;
string getTmpVar(){
  static long a = 0;
  a++;
  string tmp =  string("__t");
  tmp = tmp + to_string(a);
  tmp = tmp + string("__");
  return tmp;
}

pair<string, sEntry*> getTmpSym(string type){
  string tmp = getTmpVar();
  char *cstr = new char[type.length() + 1];
  strcpy(cstr, type.c_str());
  insertSymbol(*curr, tmp, type, getSize(cstr),0, 1);
  return pair <string, sEntry* >(tmp, lookup(tmp));
}

int emit (qid op, qid id1, qid id2, qid  res, int stmtNum){
  quad t;
  t.id1 = id1;
  t.id2 = id2;
  t.res = res;
  t.op = op;
  t.stmtNum = stmtNum;
  emittedCode.push_back(t);
  Index++;
  return emittedCode.size()-1;
}

int getNextIndex(){
  return emittedCode.size();
}

void backPatch(list<int> li, int p){
  for(int i=0; i<li.size(); ++i){
    unsigned N = i;
    if (li.size() > N)
    {
      std::list<int>::iterator it = li.begin();
      std::advance(it, N);
      emittedCode[*it].stmtNum = p;
  }
}
return;
}

void setResult(int a, qid p){
  emittedCode[a].res = p;
  return;
}

void setId1(int a, qid p){
  emittedCode[a].id1 = p;
  return;
}

void display3ac(){
  for(int i = 0; i<emittedCode.size(); ++i)  {
    display(emittedCode[i], i);
  }
  return;
}


void display(quad q, int i){
  if(q.stmtNum==-1){
    cout << setw(5) << "[" << i << "]" << ": " << setw(15) << q.op.first << " " <<
      setw(15) << q.id1.first << " " <<
      setw(15) << q.id2.first << " " <<
      setw(15) << q.res.first << '\n';
  }
  else{
    cout << setw(5) << "[" << i << "]" << ": " << setw(15) << q.op.first << " " <<
      setw(15) << q.id1.first << " " <<
      setw(15) << q.id2.first << " " <<
      setw(15) << q.stmtNum << "---" << '\n';
  }
}

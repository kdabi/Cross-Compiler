#include "runTime.h"


using std::setw;

int regCount = 1;

map <string, vector<string>> code;

queue <pair<string, sEntry*>>  regInUse;
queue <pair<string, sEntry*> > freeReg;
map <string, string> reg;

string currFunction;
ofstream codeFile;

void addLine(string a){
  code[currFunction].push_back(a);
}

void printCode(){
  cout<<"1"<<endl;
  codeFile.open("code.asm");
  cout<<"12"<<endl;
  for(auto it = code.begin(); it!=code.end(); ++it){
    cout<<"a"<<endl;
    cout<<it->first << endl;
    printCodeFunc(it->first);
    cout<<"13"<<endl;
  }
  cout<<"1"<<endl;
  //codeFile.close();
  cout<<"1"<<endl;
}

void printCodeFunc(string a){
  codeFile << a << ":" << endl;
  for(int i = 0; i<code[a].size(); ++i)
    codeFile << '\t' << code[a][i]<< endl;
  codeFile << endl;
}



string getNextReg(qid temporary){
  //checking if the temporary is already in a register
  cout<<"a1"<<endl;
  string r = checkTemporaryInReg(temporary.first);
  if( r!=""){ r.erase(r.begin(), r.begin()+1); return r; }
    cout<<"a2"<<endl;

  //Check if we have a freeReg
  if(freeReg.size()) {

    pair<string, sEntry*> t = freeReg.front();
    freeReg.pop();
          
    int offset1 = temporary.second->offset;
          cout<<"a2"<<endl;

    if(currFunction!="main") offset1 = offset1+72;
    r = t.first;
      cout<<"a1"<<endl;

    // now we store value to the location in the stack
    addLine("li $s6, "+ to_string(offset1) );       // put the offset in s6
  //  addLine("add $s6, $s6, $s6");        // double the offset
  //  addLine("add $s6, $s6, $s6");        // double the offset again(4x)
    addLine("add $s7, $fp, $s6");        //combine the two components of the address
    addLine("lw "+ r +", 0($s7)");
    t.second  = temporary.second;
    regInUse.push(t);
    string tmp = "_" + r;
    reg[tmp] = temporary.first;
  }
  else{
    pair<string, sEntry*> t = regInUse.front();
    regInUse.pop();
    // Update the exisiting identifier value from resetRegister
    sEntry* currTmp = t.second;
    r = t.first;
    int offset = currTmp->offset;
    if(currFunction!="main") offset = offset+72;

    addLine("li $s6, "+ to_string(offset));
    addLine("add $s7, $fp, $s6");        //combine the two components of the address

    addLine("sw "+ r +", 0($s7)");

    // Load this register with temporary
    offset = temporary.second->offset;
    if(currFunction!="main") offset = offset+72;

    // now we store value to the location in the stack
    addLine("li $s6, "+ to_string(offset) );       // put the offset in s6
  //  addLine("add $s6, $s6, $s6");        // double the offset
  //  addLine("add $s6, $s6, $s6");        // double the offset again(4x)
    addLine("add $s7, $fp, $s6");        //combine the two components of the address

    addLine("lw "+ r +", 0($s7)");
    t.second  = temporary.second;
    regInUse.push(t);
    string tmp = "_" + r;
    reg[tmp] = temporary.first;
  }
}

string checkTemporaryInReg(string t){
  for(auto it = reg.begin(); it!= reg.end(); ++it){
    if (it->second == t) return it->first;
  }
  return string("");
}


void resetRegister(){
  pair<string, sEntry*> t0 = pair<string, sEntry*>("$t0", NULL);
  pair<string, sEntry*> t1 = pair<string, sEntry*>("$t1", NULL);
  pair<string, sEntry*> t2 = pair<string, sEntry*>("$t2", NULL);
  pair<string, sEntry*> t3 = pair<string, sEntry*>("$t3", NULL);
  pair<string, sEntry*> t4 = pair<string, sEntry*>("$t4", NULL);
  pair<string, sEntry*> t5 = pair<string, sEntry*>("$t5", NULL);
  pair<string, sEntry*> t6 = pair<string, sEntry*>("$t6", NULL);
  pair<string, sEntry*> t7 = pair<string, sEntry*>("$t7", NULL);
  pair<string, sEntry*> t8 = pair<string, sEntry*>("$t8", NULL);
  pair<string, sEntry*> t9 = pair<string, sEntry*>("$t9", NULL);
  pair<string, sEntry*> s0 = pair<string, sEntry*>("$s0", NULL);
  pair<string, sEntry*> s1 = pair<string, sEntry*>("$s1", NULL);
  pair<string, sEntry*> s2 = pair<string, sEntry*>("$s2", NULL);
  pair<string, sEntry*> s3 = pair<string, sEntry*>("$s3", NULL);
  pair<string, sEntry*> s4 = pair<string, sEntry*>("$s4", NULL);
  freeReg.push(t1);
  freeReg.push(t2);
  freeReg.push(t3);
  freeReg.push(t4);
  freeReg.push(t0);
  freeReg.push(t5);
  freeReg.push(t6);
  freeReg.push(t7);
  freeReg.push(t8);
  freeReg.push(t9);
  freeReg.push(s0);
  freeReg.push(s1);
  freeReg.push(s2);
  freeReg.push(s3);
  freeReg.push(s4);
  //----------MAP to store the identifier--------------------------//
  pair<string, string> _t0 = pair<string, string>("$t0", "");
  pair<string, string> _t1 = pair<string, string>("$t1", "");
  pair<string, string> _t2 = pair<string, string>("$t2", "");
  pair<string, string> _t3 = pair<string, string>("$t3", "");
  pair<string, string> _t4 = pair<string, string>("$t4", "");
  pair<string, string> _t5 = pair<string, string>("$t5", "");
  pair<string, string> _t6 = pair<string, string>("$t6", "");
  pair<string, string> _t7 = pair<string, string>("$t7", "");
  pair<string, string> _t8 = pair<string, string>("$t8", "");
  pair<string, string> _t9 = pair<string, string>("$t9", "");
  pair<string, string> _s0 = pair<string, string>("$s0", "");
  pair<string, string> _s1 = pair<string, string>("$s1", "");
  pair<string, string> _s2 = pair<string, string>("$s2", "");
  pair<string, string> _s3 = pair<string, string>("$s3", "");
  pair<string, string> _s4 = pair<string, string>("$s4", "");
  reg.insert(_t1);
  reg.insert(_t2);
  reg.insert(_t3);
  reg.insert(_t4);
  reg.insert(_t0);
  reg.insert(_t5);
  reg.insert(_t6);
  reg.insert(_t7);
  reg.insert(_t8);
  reg.insert(_t9);
  reg.insert(_s0);
  reg.insert(_s1);
  reg.insert(_s2);
  reg.insert(_s3);
  reg.insert(_s4);

}

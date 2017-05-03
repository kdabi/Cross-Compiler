#include "runTime.h"


using std::setw;

int regCount = 1;

map <string, vector<string>> code;

std::vector<string> dataSection;
queue <pair<string, sEntry*>>  regInUse;
queue <pair<string, sEntry*> > freeReg;
map <string, string> reg;

string currFunction;
ofstream codeFile;

void addLine(string a){
  code[currFunction].push_back(a);
}

void addData(string a){
  dataSection.push_back(a);
}

void printCode(){
  codeFile.open("code.asm");
  for(int m=0;m<dataSection.size();m++){
    codeFile << dataSection[m]<<endl;
  }
  codeFile<<endl;
  codeFile<<".text"<<endl;
  printCodeFunc("main");
  std::map<string , std::vector<string>>::iterator it;
  it = code.find("main");
  code.erase(it);
  for(auto it = code.begin(); it!=code.end(); ++it){
    printCodeFunc(it->first);
  }
  //codeFile.close();
}

void printCodeFunc(string a){
  codeFile << a << ":" << endl;
  for(int i = 0; i<code[a].size(); ++i)
    codeFile << '\t' << code[a][i]<< endl;
  codeFile << endl;
}



string getNextReg(qid temporary){
  //checking if the temporary is already in a register
  string r = checkTemporaryInReg(temporary.first);
  if( r!=""){ r.erase(r.begin(), r.begin()+1);return r; }

  //Check if we have a freeReg
  if(freeReg.size()) {

    pair<string, sEntry*> t = freeReg.front();
    freeReg.pop();
          
    int offset1 = temporary.second->offset;

    if(currFunction!="main") offset1 = offset1+76;
    r = t.first;

    // now we store value to the location in the stack
    addLine("li $s6, "+ to_string(offset1) );       // put the offset in s6
  //  addLine("add $s6, $s6, $s6");        // double the offset
  //  addLine("add $s6, $s6, $s6");        // double the offset again(4x)
    addLine("sub $s7, $fp, $s6");        //combine the two components of the address
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
    if(currFunction!="main") offset = offset+76;

    addLine("li $s6, "+ to_string(offset));
    addLine("sub $s7, $fp, $s6");        //combine the two components of the address

    addLine("sw "+ r +", 0($s7)");

    // Load this register with temporary
    offset = temporary.second->offset;
    if(currFunction!="main") offset = offset+76;

    // now we store value to the location in the stack
    addLine("li $s6, "+ to_string(offset) );       // put the offset in s6
  //  addLine("add $s6, $s6, $s6");        // double the offset
  //  addLine("add $s6, $s6, $s6");        // double the offset again(4x)
    addLine("sub $s7, $fp, $s6");        //combine the two components of the address

    addLine("lw "+ r +", 0($s7)");
    t.second  = temporary.second;
    regInUse.push(t);
    string tmp = "_" + r;
    reg[tmp] = temporary.first;
  }
}
void loadArrayElement(qid temporary, string registerTmp){
    if(currFunction == "main") {
      addLine("li $s6, "+to_string(temporary.second->size) );
      addLine("sub $s7, $fp, $s6");
      addLine("lw $t8, 0($s7)");
      addLine("li $t7, 4");
      addLine("mult $t8, $t7");
      addLine("mflo $t7");
      addLine("li $s6, " + to_string(temporary.second->offset)); // put the offset in s6
      addLine("add $s6, $s6, $t7");
      addLine("sub $s7, $fp, $s6"); // combine the two components of the
    }else{
      addLine("li $s6, "+to_string(temporary.second->size) );
      addLine("addi $s6, 76");
      addLine("sub $s7, $fp, $s6");
      addLine("lw $t8, 0($s7)");
      addLine("li $t7, 4");
      addLine("mult $t8, $t7");
      addLine("mflo $t7");
      addLine("li $s6, "+ to_string(temporary.second->offset));
      addLine("addi $s6, 76");
      addLine("sub $s7, $fp, $s6");
      addLine("lw $t8, 0($s7)");
      addLine("sub $s7, $t8, $t7");
    }  
    addLine("lw "+ registerTmp +", 0($s7)");
}

// flush all registers on jump
void saveOnJump(){
  pair<string, sEntry*> t;
  while(regInUse.size()){
    t = regInUse.front();
    regInUse.pop();
    // Update the exisiting identifier value from resetRegister
    sEntry* currTmp = t.second;
    string r = t.first;
    int offset = currTmp->offset;
    if(currFunction!="main") offset = offset+76;

    addLine("li $s6, "+ to_string(offset));
    addLine("sub $s7, $fp, $s6");        //combine the two components of the address

    addLine("sw "+ r +", 0($s7)");
    t.second  = NULL;
    freeReg.push(t);
    string tmp = "_" + r;
    reg[tmp] = "";
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
//  pair<string, sEntry*> t6 = pair<string, sEntry*>("$t6", NULL);
// pair<string, sEntry*> t7 = pair<string, sEntry*>("$t7", NULL);
//  pair<string, sEntry*> t8 = pair<string, sEntry*>("$t8", NULL);
//  pair<string, sEntry*> t9 = pair<string, sEntry*>("$t9", NULL);
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
//  freeReg.push(t6);
//  freeReg.push(t7);
//  freeReg.push(t8);
//  freeReg.push(t9); for using in calculations
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
//  pair<string, string> _t6 = pair<string, string>("$t6", "");
//  pair<string, string> _t7 = pair<string, string>("$t7", "");
//  pair<string, string> _t8 = pair<string, string>("$t8", "");
//  pair<string, string> _t9 = pair<string, string>("$t9", "");
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
//  reg.insert(_t6);
//  reg.insert(_t7);
//  reg.insert(_t8);
//  reg.insert(_t9);
  reg.insert(_s0);
  reg.insert(_s1);
  reg.insert(_s2);
  reg.insert(_s3);
  reg.insert(_s4);

}

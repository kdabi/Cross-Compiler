#include "codeGen.h"

int counter;
string reg1,reg2,reg3;
void generateCode(){
  currFunction = "main";
 //    cout << "Inside generateCode" << endl;
  for(int i=0; i<emittedCode.size(); ++i){
    if(emittedCode[i].stmtNum == -2){
      // this is a function
     // cout << "Inside generateCode function" << endl;

      counter=0;
      currFunction = emittedCode[i].op.first;
      currFunction.erase(currFunction.begin(), currFunction.begin()+5);
      currFunction.erase(currFunction.end()-7 , currFunction.end());
      if(currFunction=="main"){
                        
        //set the frame pointer of the callee
        addLine("la $fp, $sp");
        int sizeF = lookup("main")->size;
        //allocate space for the registers by updating the stack pointer
        addLine("sub $sp, $sp, "+to_string(sizeF));
        }
      else{
        int sizeF = lookup(currFunction)->size;

        //allocate space for the registers by updating the stack pointer
        addLine("sub $sp, $sp, 72");


        //store return address of the caller
        addLine("sw $ra, 0($sp)");

        //store the frame pointe of the caller
        addLine("sw $fp, 4($sp)");

       //set the frame pointer of the callee
       addLine("la $fp, 72($sp)");

      //storing the remaining registers
       addLine("sw $t0, 12($sp)");
       addLine("sw $t1, 16($sp)");
       addLine("sw $t2, 20($sp)");
       addLine("sw $t3, 24($sp)");
       addLine("sw $t4, 28($sp)");
       addLine("sw $t5, 32($sp)");
       addLine("sw $t6, 36($sp)");
       addLine("sw $t7, 40($sp)");
       addLine("sw $t8, 44($sp)");
       addLine("sw $t9, 48($sp)");
       addLine("sw $s0, 52($sp)");
       addLine("sw $s1, 56($sp)");
       addLine("sw $s2, 60($sp)");
       addLine("sw $s3, 64($sp)");
       addLine("sw $s4, 68($sp)");

       // create space for local data
       addLine("li $v0, "+to_string(sizeF));
       addLine("sub $sp, $sp, $v0");

       //copy the parameters 
       string parameterList = funcArgList(currFunction);
       int paramNum = 0;
       int paramSize = 0;
       string temp = parameterList;
       if(parameterList!=""){
        string delim = string(",");
        string temp1;
        int f1 = temp.find_first_of(delim);
        while(f1!=-1){
                    temp1 = temp.substr(0,f1);temp=temp.substr(f1+1);
                    f1 = temp.find_first_of(delim);
                    addLine("sw $a"+to_string(paramNum)+", "+to_string(paramSize)+"($sp)");
                    char * a ;
                    strcpy(a,temp1.c_str());
                    paramSize += getSize(a);
                    paramNum++;
        }
        addLine("sw $a"+to_string(paramNum)+", "+to_string(paramSize)+"($sp)");
      }


      }
    }
    else if(emittedCode[i].stmtNum == -1){
       // for parameters of the functional call
      cout<<"start "<<i<<endl;    
      if(emittedCode[i].op.first=="param"){
        cout<<emittedCode[i].op.first <<" "<< i <<endl;
        if(emittedCode[i].id1.second!=NULL){
          reg1 = getNextReg(emittedCode[i].id1);
          addLine("move $a "+to_string(counter)+", "+reg1);
          counter ++;
        } else{
          addLine("addi $a ,$0, "+emittedCode[i].id1.first);
          counter ++;
        }
      }

      // for assignment operators 
      else if(emittedCode[i].op.first == "="){
        cout<<emittedCode[i].op.first <<" "<< i <<endl;
       if(emittedCode[i].res.second==NULL) cout<<"no sentry"<<endl;
       reg3 = getNextReg(emittedCode[i].res);
       
        if(emittedCode[i].id1.second!=NULL){
          cout<<"aa"<<endl;
          reg2 = getNextReg(emittedCode[i].id1);  
          addLine("move "+reg3+", "+reg2);
        }
        else {
          cout<<emittedCode[i].id1.first<<endl;
          addLine("addi "+reg3+", $0, "+emittedCode[i].id1.first);
                    cout<<emittedCode[i].id1.first<<endl;

        }

      }
      cout<<"exit "<<i<<endl;
    }


    // allocating
  }
}

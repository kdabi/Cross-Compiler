#include "codeGen.h"

int counter;
int dataCounter;
string reg1,reg2,reg3;
void generateCode(){
  dataCounter=0;
  addData(".data");
  addData("_newline: .asciiz \"\\n\"");
  currFunction = "main";
  addLine("");
 //    cout << "Inside generateCode" << endl;
  for(int i=0; i<emittedCode.size(); ++i){
    if( gotoLabels.find(i) != gotoLabels.end() ) { saveOnJump(); addLine(gotoLabels[i]+":");  }
    if(emittedCode[i].stmtNum == -2){
      // this is a function
     // cout << "Inside generateCode function" << endl;

      counter=0;
      currFunction = emittedCode[i].op.first;
      currFunction.erase(currFunction.begin(), currFunction.begin()+5);
      currFunction.erase(currFunction.end()-7 , currFunction.end());
      if(currFunction=="main"){
                        
        //set the frame pointer of the callee
        addLine("sub $sp, $sp, 200");
        addLine("la $fp, ($sp)");
        int sizeF = lookup("main")->size;
        //allocate space for the registers by updating the stack pointer
        addLine("sub $sp, $sp, "+to_string(sizeF));
        }
      else{
        int sizeF = lookup(currFunction)->size+4;

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
       int paramSize = 76;
       string temp = parameterList;
       if(parameterList!=""){
        string delim = string(",");
        string temp1;
        int f1 = temp.find_first_of(delim);
        while(f1!=-1){
                    temp1 = temp.substr(0,f1);temp=temp.substr(f1+1);
                    f1 = temp.find_first_of(delim);
                    addLine("li $s6, "+to_string(paramSize));
                    addLine("sub $s7, $fp, $s6");
                    addLine("sw $a"+to_string(paramNum)+", 0($s7)");
                    char * a ;
                    strcpy(a,temp1.c_str());
                    paramSize += getSize(a);
                    paramNum++;
        }
        addLine("li $s6, "+to_string(paramSize));
        addLine("sub $s7, $fp, $s6");
        addLine("sw $a"+to_string(paramNum)+", 0($s7)");
      }


      }
    }
    else if(emittedCode[i].stmtNum == -4){         // this stmtNum is specially set for param with constant string
       addData("DataString"+to_string(dataCounter)+": .asciiz " + emittedCode[i].id1.first  );
       addLine("la $a"+to_string(counter)+", DataString"+to_string(dataCounter));
       counter++;
       dataCounter++;
    }

    else if(emittedCode[i].stmtNum == -1){
       // for parameters of the functional call
      cout<<"start "<<i<<endl;    
      if(emittedCode[i].op.first=="param"){
        cout<<emittedCode[i].op.first <<" "<< i <<endl;
        if(emittedCode[i].id1.second!=NULL){
          reg1 = getNextReg(emittedCode[i].id1);
          addLine("move $a"+to_string(counter)+", "+reg1);
          counter ++;
        } else{
          addLine("addi $a"+to_string(counter)+",$0, "+emittedCode[i].id1.first);
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

      // for unary operators 
      else if(emittedCode[i].op.first=="&"){
        reg1 = getNextReg(emittedCode[i].res);
        int off = emittedCode[i].id1.second->offset;
        if(currFunction!="main") off+= 76;
        off = -off;
        addLine("addi "+reg1+", $fp, "+to_string(off));
      }

      else if(emittedCode[i].op.first=="unary*"){
        reg1 = getNextReg(emittedCode[i].res);
        reg2 = getNextReg(emittedCode[i].id1);
        addLine("lw "+reg1+", 0("+reg2+")");        
      }

      else if(emittedCode[i].op.first=="unary-"){
        reg1 = getNextReg(emittedCode[i].res);
        if(emittedCode[i].id1.second!=NULL){
          reg2 = getNextReg(emittedCode[i].id1);
          addLine("neg "+reg1+", "+reg2);
        }
        else addLine("addi "+reg1+", $0, -"+emittedCode[i].id1.first);  
      }

      else if(emittedCode[i].op.first=="~"){
        reg1 = getNextReg(emittedCode[i].res);
        reg2 = getNextReg(emittedCode[i].id1);
        addLine("not "+reg1+", "+reg2);
      }

      else if(emittedCode[i].op.first=="unary+"){
        reg1 = getNextReg(emittedCode[i].res);
        reg2 = getNextReg(emittedCode[i].id1);
        addLine("lw "+reg1+", "+reg2);
      }

      else if(emittedCode[i].op.first=="!"){
        reg1 = getNextReg(emittedCode[i].res);
        reg2 = getNextReg(emittedCode[i].id1);
        addLine("not "+reg1+", "+reg2);
      }

      // addition of integer operator 
      else if(emittedCode[i].op.first=="+int"){
        reg1= getNextReg(emittedCode[i].res);
        reg2 = getNextReg(emittedCode[i].id1);
        if(emittedCode[i].id2.second!=NULL){
          reg3 = getNextReg(emittedCode[i].id2);
          addLine("add "+reg1+", "+reg2+", "+reg3);
        }
        else addLine("addi "+reg1+", "+reg2+", "+emittedCode[i].id2.first);
      }

      // substraction of integer
      else if(emittedCode[i].op.first=="-int"){
        reg1= getNextReg(emittedCode[i].res);
        reg2 = getNextReg(emittedCode[i].id1);
        if(emittedCode[i].id2.second!=NULL){
          reg3 = getNextReg(emittedCode[i].id2);
          addLine("sub "+reg1+", "+reg2+", "+reg3);
        }
        else addLine("addi "+reg1+", "+reg2+", -"+emittedCode[i].id2.first);
      }

      // multiplication of integer
      else if(emittedCode[i].op.first=="*int"){
        reg1= getNextReg(emittedCode[i].res);
        reg2 = getNextReg(emittedCode[i].id1);
        if(emittedCode[i].id2.second!=NULL){
          reg3 = getNextReg(emittedCode[i].id2);
          addLine("mult "+reg2+", "+reg3);
          addLine("mflo "+reg1);
        }
        else{ 
          addLine("addi $t9, $0, "+emittedCode[i].id2.first);
          addLine("mult "+reg2+", $t9");
          addLine("mflo "+reg1);
        }  
      }
      // division of integers
      else if(emittedCode[i].op.first=="/int"){
        reg1= getNextReg(emittedCode[i].res);
        reg2 = getNextReg(emittedCode[i].id1);
        if(emittedCode[i].id2.second!=NULL){
          reg3 = getNextReg(emittedCode[i].id2);
          addLine("div "+reg2+", "+reg3);
          addLine("mflo "+reg1);
        }
        else{ 
          addLine("addi $t9, $0, "+emittedCode[i].id2.first);
          addLine("div "+reg2+", $t9");
          addLine("mflo "+reg1);
        }  
      }
      // modulo of integers
      else if(emittedCode[i].op.first=="%"){
        reg1= getNextReg(emittedCode[i].res);
        reg2 = getNextReg(emittedCode[i].id1);
        if(emittedCode[i].id2.second!=NULL){
          reg3 = getNextReg(emittedCode[i].id2);
          addLine("div "+reg2+", "+reg3);
          addLine("mfhi "+reg1);
        }
        else{ 
          addLine("addi "+reg1+", $0, "+emittedCode[i].id2.first);
          addLine("div "+reg2+", "+reg1);
          addLine("mfhi "+reg1);
        }  
      }

      // printing one integer
      else if(emittedCode[i].op.first=="CALL" && emittedCode[i].id1.first =="printf"){
          addLine("li $v0, 1");
          addLine("syscall");
          addLine("li $v0, 4");
          addLine("la $a0, _newline");
          addLine("syscall");
          counter=0; 
      }
      // printing string
      else if(emittedCode[i].op.first=="CALL" && emittedCode[i].id1.first =="prints"){
          // string is already in a0;
          addLine("li $v0, 4");
          addLine("syscall");
          counter=0; 
      }
      // implementing '<'
      else if(emittedCode[i].op.first== "<"){
          if(emittedCode[i].id2.second == NULL){
            addLine("addi $t9, $0, "+emittedCode[i].id2.first);
            reg1 = "$t9";
          }
          else reg1 = getNextReg(emittedCode[i].id2);
          reg2 = getNextReg(emittedCode[i].id1);
          reg3 = getNextReg(emittedCode[i].res);
          addLine("slt "+reg3+", "+reg2+", "+reg1);
      }
      // implementing '>'
      else if(emittedCode[i].op.first== ">"){
          if(emittedCode[i].id2.second == NULL){
            addLine("addi $t9, $0, "+emittedCode[i].id2.first);
            reg1 = "$t9";
          }
          else reg1 = getNextReg(emittedCode[i].id2);
          reg2 = getNextReg(emittedCode[i].id1);
          reg3 = getNextReg(emittedCode[i].res);
          addLine("sgt "+reg3+", "+reg2+", "+reg1);
      }

      // implementing '>='
      else if(emittedCode[i].op.first== "GE_OP"){
          if(emittedCode[i].id2.second == NULL){
            addLine("addi $t9, $0, "+emittedCode[i].id2.first);
            reg1 = "$t9";
          }
          else reg1 = getNextReg(emittedCode[i].id2);
          reg2 = getNextReg(emittedCode[i].id1);
          reg3 = getNextReg(emittedCode[i].res);
          addLine("sge "+reg3+", "+reg2+", "+reg1);
      }

      // implementing '<='
      else if(emittedCode[i].op.first== "LE_OP"){
          if(emittedCode[i].id2.second == NULL){
            addLine("addi $t9, $0, "+emittedCode[i].id2.first);
            reg1 = "$t9";
          }
          else reg1 = getNextReg(emittedCode[i].id2);
          reg2 = getNextReg(emittedCode[i].id1);
          reg3 = getNextReg(emittedCode[i].res);
          addLine("sle "+reg3+", "+reg2+", "+reg1);
      }

      // implementing 'EQ_OP' i.e. '=='
      else if(emittedCode[i].op.first== "EQ_OP"){
          if(emittedCode[i].id2.second == NULL){
            addLine("addi $t9, $0, "+emittedCode[i].id2.first);
            reg1 = "$t9";
          }
          else reg1 = getNextReg(emittedCode[i].id2);
          reg2 = getNextReg(emittedCode[i].id1);
          reg3 = getNextReg(emittedCode[i].res);
          addLine("seq "+reg3+", "+reg2+", "+reg1);
      }
      
      // implementing 'NE_OP' i.e. '!='
      else if(emittedCode[i].op.first== "NE_OP"){
          if(emittedCode[i].id2.second == NULL){
            addLine("addi $t9, $0, "+emittedCode[i].id2.first);
            reg1 = "$t9";
          }
          else reg1 = getNextReg(emittedCode[i].id2);
          reg2 = getNextReg(emittedCode[i].id1);
          reg3 = getNextReg(emittedCode[i].res);
          addLine("sne "+reg3+", "+reg2+", "+reg1);
      }

      else if(emittedCode[i].op.first == "RETURN" && currFunction == "main"){
          addLine("li $a0, 0");
          addLine("li $v0, 10");
          addLine("syscall");
      }
      else if(emittedCode[i].op.first=="CALL" && emittedCode[i].id1.first == "scanf"){
          reg1 = getNextReg(emittedCode[i].res);
          addLine("li $v0, 5");
          addLine("syscall");
          addLine("move "+reg1+", $v0");
      }    
      else if(emittedCode[i].op.first == "RETURN" && currFunction != "main"){
          if(emittedCode[i].id1.second!= NULL){
            reg1 = getNextReg(emittedCode[i].id1);
            addLine("move $v0, "+ reg1);
          }else { addLine("li $v0, "+emittedCode[i].id1.first ); }  
          addLine("b "+currFunction +"end");
      }
      else if(emittedCode[i].op.first == "CALL"){
          addLine("jal "+emittedCode[i].id1.first);
          if(emittedCode[i].res.second != NULL){
            reg1 = getNextReg(emittedCode[i].res);
            addLine("move "+reg1+", $v0");
            counter = 0;
          }
      }    
      

      cout<<"exit "<<i<<endl;
    }
    // implementing returns from non-main functions
    else if(emittedCode[i].stmtNum == -3 && currFunction != "main"){
          addLine(currFunction+"end:");

          // Removing the local data of the functions
          int sizeEnd = lookup(currFunction)->size+4;
          addLine("addi $sp, $sp, "+to_string(sizeEnd));

          // Get environment pointers
          addLine("lw $ra, 0($sp)");
          addLine("lw $fp, 4($sp)");
          addLine("lw $a0, 8($sp)");

          // Restoring all the Registers
          addLine("lw $t0, 12($sp)"); 
          addLine("lw $t1, 16($sp)"); 
          addLine("lw $t2, 20($sp)"); 
          addLine("lw $t3, 24($sp)"); 
          addLine("lw $t4, 28($sp)"); 
          addLine("lw $t5, 32($sp)"); 
          addLine("lw $t6, 36($sp)"); 
          addLine("lw $t7, 40($sp)"); 
          addLine("lw $t8, 44($sp)"); 
          addLine("lw $t9, 48($sp)"); 
          addLine("lw $s0, 52($sp)"); 
          addLine("lw $s1, 56($sp)");
          addLine("lw $s2, 60($sp)"); 
          addLine("lw $s3, 64($sp)"); 
          addLine("lw $s4, 68($sp)");
          addLine("addi $sp, $sp, 72");

          // jump to the calling procedure
          addLine("jr $ra"); 


    }
    // jump statements
    else{
         if(emittedCode[i].op.first == "GOTO" && emittedCode[i].id1.first == ""){
            saveOnJump();
            addLine("j "+gotoLabels[emittedCode[i].stmtNum]);
         }
         else if(emittedCode[i].op.first == "GOTO" && emittedCode[i].id1.first == "IF"){
            saveOnJump();
            if(emittedCode[i].id2.second != NULL){
              reg1 = getNextReg(emittedCode[i].id2);
              addLine("bne $0, "+reg1+", "+gotoLabels[emittedCode[i].stmtNum]);
            }
            else{
              addLine("addi $t9, $0, "+ emittedCode[i].id2.first);
              addLine("bne $0, $t9, "+gotoLabels[emittedCode[i].stmtNum]);
            }  
         }

    }
    
    // allocating
  }
}

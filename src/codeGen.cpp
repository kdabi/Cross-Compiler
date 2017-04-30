#include "codeGen.h"

void generateCode(){
  currFunction = "main";
  for(int i=0; i<emittedCode.size(); ++i){
    if(emittedCode[i].stmtNum == -2){
      // this is a function
      currFunction = emittedCode[i].op.first;
      if(currFunction=="main"){
        //set the frame pointer of the callee
        addLine("la $fp, $sp");
        int sizeF = lookup("main")->size;
        cout << "main size is" << sizeF << endl;
        //allocate space for the registers by updating the stack pointer
        addLine("sub $sp, $sp, "+sizeF);
        }
      else{
        int sizeF = lookup(currFunction)->size;
        cout << currFunction << " size is" << sizeF << endl;

        //allocate space for the registers by updating the stack pointer
        addLine("sub $sp, $sp, "72);

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
       addLine("li $v0, "+sizeF);
       addLine("sub $sp, $sp, $v0");

      }
    }
    else if(emittedCode[i].stmtNum == -1){
      //not goto
    }


    // allocating
  }
}

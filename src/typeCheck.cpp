#include "typeCheck.h"
#include "symTable.h"

char* primaryExpr(char* identifier){
    sEntry* n = lookup(identifier);
    if(n){
	char* s = new char();
	strcpy(s, (n->type).c_str());
	return s;
    }
    return NULL;	
}

char* constant(int nType){
    if(nType==1) return "int";
    if(nType==2) return "long";
    if(nType==3) return "long long";
    if(nType==4) return "float";
    if(nType==5) return "double";
    if(nType==6) return "long double";
    return "default";
}
 
char* postfixExpr(string type, int prodNum){
    char* newtype = new char();
    strcpy(newtype, type.c_str());
    if(prodNum==1){ // postfix_expression '[' expression ']' 
        if(type[type.size()-1]=='*'){
	    newtype[type.size()-1]='\0';	
	    return newtype;
	}
	else 
	    return NULL;
    }
    if (prodNum==2){ // postfix_expression '(' argument_expression_list ')'
	string tmp = type.substr(0,5);
	if(tmp==string("FUNC_")){
	    newtype += 5;
	    return newtype;
	}
	else 
	    return NULL;
    }
    if (prodNum==3){
	string tmp = type.substr(0,5);
	if(tmp==string("FUNC_")){
	    newtype += 5;
	    return newtype;
	}
	else 
	    return NULL;
    }
    if (prodNum==6 || prodNum==7){ // postfix_expression INC_OP/DEC_OP
	if(isInt(type)){
	    return newtype;
	}
	else 
	    return NULL;
    }
    if (prodNum==8|| prodNum==9){
        return newtype;
    }
}

char* argumentExpr(string type1, string type2, int prodNum){
    char* a = new char();
    a = "void";
    if(prodNum==1){ //assignment_expression
	if(type1==string("void"))
	     return a;
	else {
	    a = "error";
	    return a;
	}	
    }
    if(prodNum==2){
	if(type1==string("void") && type2==string("void"))
	     return a;
	else {
	    a = "error";
	    return a;
	}	
    }
}

bool isInt (string type){
   if(type==string("int")) return true;
   if(type==string("long")) return true;
   if(type==string("long long")) return true;
   if(type==string("long int")) return true;
   if(type==string("long long int")) return true;
   if(type==string("unsigned int")) return true;
   if(type==string("unsigned long")) return true;
   if(type==string("unsigned long long")) return true;
   if(type==string("unsigned long int")) return true;
   if(type==string("unsigned long long int")) return true;
   if(type==string("signed int")) return true;
   if(type==string("signed long")) return true;
   if(type==string("signed long long")) return true;
   if(type==string("signed long int")) return true;
   if(type==string("signed long long int")) return true;

   if(type==string("short")) return true;
   if(type==string("short int")) return true;
   if(type==string("signed short")) return true;
   if(type==string("unsigned short")) return true;
   if(type==string("unsigned short int")) return true;
   if(type==string("signed short int")) return true;
   return false;
}

bool isSignedInt (string type){
   if(type==string("int")) return true;
   if(type==string("long")) return true;
   if(type==string("long long")) return true;
   if(type==string("long int")) return true;
   if(type==string("long long int")) return true;
   if(type==string("signed int")) return true;
   if(type==string("signed long")) return true;
   if(type==string("signed long long")) return true;
   if(type==string("signed long int")) return true;
   if(type==string("signed long long int")) return true;

   if(type==string("short")) return true;
   if(type==string("short int")) return true;
   if(type==string("signed short")) return true;
   if(type==string("signed short int")) return true;

   return false;
}


bool isFloat (string type){
   if(type==string("float")) return true;
   if(type==string("double")) return true;
   if(type==string("long double")) return true;
   if(type==string("unsigned float")) return true;
   if(type==string("unsigned double")) return true;
   if(type==string("unsigned long double")) return true;
   if(type==string("signed float")) return true;
   if(type==string("signed double")) return true;
   if(type==string("signed long double")) return true;

   return false;
}

bool isSignedFloat (string type){
   if(type==string("float")) return true;
   if(type==string("double")) return true;
   if(type==string("long double")) return true;
   if(type==string("signed float")) return true;
   if(type==string("signed double")) return true;
   if(type==string("signed long double")) return true;

   return false;
}

char* unaryExpr(string op, string type, int prodNum){
    char* a= new char();
    if(prodNum==1){ //unary_operator cast_expression
	    if (op==string("&")){
		    type = type+ string("*");
	    }
            if (op==string("*")){
                 return postfixExpr(type, 1);
	     }
	    if (op==string("+")){
		if(isFloat(type) || isInt(type)|| type==string("_Complex")|| type==string("_Imaginary") ){;}
		else return NULL;
	     }
	    if (op==string("-")){
		if(isFloat(type) || isInt(type)|| type==string("_Complex")|| type==string("_Imaginary") ){;}
		else return NULL;
	     }
	    if	(op == string("~")){	
		if(isInt(type)|| type =="bool") {;}
		else return NULL;
            }
            if	(op == string("!")){	
		if(type =="bool") {;}
		else return NULL;
            }    
	    strcpy(a, type.c_str());
    }
    return a;
}

char* multilplicativeExpr(string type1, string type2, char op){
    char* a = new char();
    if(isInt(type1)|| isFloat(type1)){
	if(isInt(type2)||isFloat(type2)){
		if(op == '%'){
			if(isInt(type1)&&isInt(type2)){
			    a = "int";
			    return a;
			}
		}
		if(op == '*'|| op == '/'){
                     if(isInt(type1) && isInt(type2)){ a="int"; }
                     else { a="float"; }
                     return a;
	        }
        }	
  }
  return NULL;
}
char* additiveExpr(string type1,string type2,char op){
	char *a = new char();
	if(isInt(type1)|| isFloat(type1)){
		if(isInt(type2)||isFloat(type2)){
			if(isInt(type1)&&isInt(type2)){ a="int"; }
			else { a="real"; }
			return a;
		} 
	}
	else if(isInt(type1)||isFloat(type1)||isInt(type2)||isFloat(type2)){
		if(type1==string("_Complex")||type2==string("_Complex")){ a="_Complex"; return a;}
		if(type1==string("_Imaginary")||type2==string("_Imaginary")){ a="_Imaginary"; return a;}
	}
        if(type1==string("_Complex")&&type2==string("_Complex")) {
		a="_Complex";return a;
	}
        else if(type1==string("_Imaginary")&&type2==string("_Imaginary")){
		a="_Imaginary";return a;
	}
	else if(type1==string("_Imaginary")&&type2==string("_Complex")) {
		a="_Complex";return a;
	}
	else if(type1==string("_Complex")&&type2==string("_Imaginary")) {
		a="_Complex";return a;
	}
	else if(type1==string("char")&&isInt(type2)) {
		a="char";return a;
	}
        else if(type2==string("char")&&isInt(type1)){
               a="char";return a;
        }
        else if((type1[type1.size()-1]=='*')&&isInt(type2)){
            strcpy(a,type1.c_str());
          return a; 
        }
        else if((type2[type2.size()-1]=='*')&&isInt(type1)){
            strcpy(a,type2.c_str());return a;
        }        
	return NULL;
}

char* shiftExpr(string type1,string type2){
      char *a =new char();
      a = "True";
      if(isInt(type1)&&isInt(type2))
          return a;
      else return NULL;
} 
char* relationalExpr(string type1,string type2,char * op){
     char *a = new char();
     if(isInt(type1)||isFloat(type1)||(type1==string("char"))){
         if(isInt(type2)||isFloat(type2)||(type2==string("char")))
         {
             a="bool";return a;
         }  
         else if(type2[type2.size()-1]=='*')
         {
             if(isInt(type1)||(type1==string("char"))){ a = "Bool"; 
                        return a; }
             else return NULL;
         }
     }
     if(type1[type1.size()-1]=='*')
       {
             if(isInt(type2)||(type2==string("char"))){ a = "Bool"; 
                  return a; }
             else return NULL;

       }
       return NULL;
}
char * equalityExpr(string type1,string type2){
       char *a = new char();
       if(isInt(type1)||isFloat(type1)||(type1=="char")){
             if(isInt(type2)||isFloat(type2)||(type2=="char")){
             a="True";return a;
             }
       }
       else if(type1[type1.size()-1]=='*' && isInt(type2)){
           a="true";return a;
       }
       else if(type2[type2.size()-1]=='*' && isInt(type1)){
           a="true";return a;
       }
       else if(!strcmp(type1.c_str(),type2.c_str())){
            a = "True";return a;
       }
   return NULL;
}

char* bitwiseExpr(string type1,string type2){ // ^,&,|
      char * a = new char();
      if((type1==string("bool"))&&(type2==string("bool"))){
          a="true";return a;
      }
      if(isInt(type1) || type1==string("bool")){
            if(isInt(type2) || type2==string("bool")){
                a="True"; return a;
            }               
      } 
      return NULL;
}

char* conditionalExpr(string type1,string type2){
     char* a = new char();
     if(type1==string("char")) type1 = string("long long");
     if(isInt(type1))          type1 = string("long double");
     if(type2==string("char")) type2 = string("long long");
     if(isInt(type2))          type2 = string("long double");
     if(isFloat(type1) && isFloat(type2)){ a="long double";
                                          return a; }
     if( type1 == type2 ){
          strcpy(a,type1.c_str()); return a;
     }
     if((type1[type1.size()-1]=='*') && type2[type2.size()-1]=='*'){
         a = "void*"; return a;
     }
     
   return NULL;
}

char* validAssign(string type1,string type2){
    char * a =new char();
   if(isInt(type2) && (type1[type1.size()-1]=='*')){
      a="warning";return a;
   }
   if(isInt(type1) && (type2[type2.size()-1]=='*')){
      a="warning";return a;
   }
    if(type1==string("char"))  type1=string("long long");
    if(isInt(type1))   type1=string("long double");
    if(type2==string("char"))  type2=string("long long");
    if(isInt(type2))   type2=string("long double");
    
   if(isFloat(type1) && isFloat(type2)){ a = "true";return a; } 
   if(type1==string("void*") && (type2[type2.size()-1]=='*')){
      a="true";return a;
   }
   if(type2==string("void*") && (type1[type1.size()-1]=='*')){
      a="true";return a;
   }
   if(type1==type2){
     a="true";return a;
   }
   if((type2[type2.size()-1]=='*') && (type1[type1.size()-1]=='*')){
      a="warning";return a;
   }
   return NULL;
}

char* assignmentExpr(string type1,string type2,char* op){
    char *a = new char();
    if(!strcmp(op,"=")){
        a = validAssign(type1,type2);
        if(a) return a;
        else return NULL;
    }
    else if((!strcmp(op,"*="))||(!strcmp(op,"/="))||(!strcmp(op,"%="))){
        a = multilplicativeExpr(type1,type2,op[0]);
        if(a){ a="true"; return a; }
    }
    else if((!strcmp(op,"+="))||(!strcmp(op,"-="))){
        a = additiveExpr(type1,type2,op[0]);
        if(a){ a="true"; return a;}
    }
    else if((!strcmp(op,">>="))||(!strcmp(op,"<<="))){
        a = shiftExpr(type1,type2);
        if(a){ a="true"; return a;}
    }
    else if((!strcmp(op,"&="))||(!strcmp(op,"^="))||(!strcmp(op,"|="))){
        a = bitwiseExpr(type1,type2);
        if(a){ a="true"; return a;}
    }
    return NULL;
}


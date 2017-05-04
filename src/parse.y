%{
#include <iostream>
#include <cstring>
#include <list>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <stdarg.h>
using namespace std;
#define MAX_STR_LEN 1024

int scope;
int symNumber = 0;
int funcSym=0;
int isFunc;
int blockSym=0;
int yylex(void);
void yyerror(char *s,...);
#include "typeCheck.h"
#include "codeGen.h"


FILE *digraph;
FILE *duplicate;
node *temp,*temp1,*temp2;
char filename[1000];
string typeName="";
extern int yylineno;
string symFileName;
string funcName;
string funcType;
int structCounter=0;
string funcArguments;
string currArguments;
qid tempQid;
int tempodd;
int tempeven;
%}


/* Reference LexxAndYaccTutorial : by Tom Niemann*/
%union {
  int number;     /*integer value*/
  char *str;
  node *ptr;     /*node pointer */
  exprNode *expr;
  numb * num;
};

/* Grammar from quut.com/c/ANSI-C-grammar-y.html */
%token <str> CHAR CONST CASE CONTINUE DEFAULT DO DOUBLE
%token <str> ELSE ENUM EXTERN FLOAT FOR IF INLINE INT LONG
%token <str> REGISTER RESTRICT RETURN SHORT SIGNED STATIC STRUCT SWITCH TYPEDEF UNION
%token <str> UNSIGNED VOID VOLATILE WHILE ALIGNAS ALIGNOF ATOMIC BOOL COMPLEX
%token <str> GENERIC IMAGINARY NORETURN STATIC_ASSERT THREAD_LOCAL FUNC_NAME
%token <str> AUTO BREAK GOTO TYPEDEF_NAME IDENTIFIER ENUMERATION_CONSTANT
%token <str> STRING_LITERAL
%token <num> I_CONSTANT F_CONSTANT
%left <str> PTR_OP
%token <str> INC_OP DEC_OP
%token <str> LEFT_OP RIGHT_OP
%left <str> LE_OP GE_OP EQ_OP NE_OP
%left <str> AND_OP OR_OP
%right <str> MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%right <str> SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN
%right <str> XOR_ASSIGN OR_ASSIGN
%token <str> ELLIPSIS
%type <str> assignment_operator E1 E2 E3 E4 E5 E6

%start translation_unit

%left <str> ',' '^' '|' ';' '{' '}' '[' ']' '(' ')' '+' '-' '%' '/' '*' '.' '>' '<' SIZEOF
%right <str> '&' '=' '!' '~' ':' '?'

%type <ptr> multiplicative_expression additive_expression cast_expression primary_expression expression assignment_expression postfix_expression unary_expression shift_expression relational_expression equality_expression and_expression exclusive_or_expression inclusive_or_expression logical_or_expression logical_and_expression conditional_expression constant_expression
%type <ptr> constant string generic_selection enumeration_constant M1 M2 M3 M4 M5 M6 M7
%type <ptr> generic_assoc_list generic_association type_name argument_expression_list initializer_list
%type <ptr> unary_operator
%type <ptr> declaration declaration_specifiers
%type <ptr> init_declarator_list static_assert_declaration storage_class_specifier type_specifier function_specifier type_qualifier alignment_specifier
%type <ptr> init_declarator declarator initializer atomic_type_specifier struct_or_union_specifier enum_specifier struct_or_union struct_declaration_list
%type <ptr> struct_declaration specifier_qualifier_list struct_declarator_list struct_declarator enumerator_list enumerator enumerator_constant pointer
%type <ptr> direct_declarator type_qualifier_list parameter_type_list identifier_list parameter_list parameter_declaration
%type <ptr> abstract_declarator direct_abstract_declarator designation designator_list designator labeled_statement compound_statement expression_statement declaration_list
%type <ptr> selection_statement iteration_statement jump_statement block_item_list block_item external_declaration translation_unit function_definition statement jump_statement_error
%type <number> M N GOTO_emit

%%

primary_expression
  : IDENTIFIER                    {$$=terminal($1);
				    char* a = primaryExpr($1);
				    if (a) {string as(a);
                                         $$->isInit = lookup($1)->is_init;
                                         $$->nodeType=as;
                                         string key($1);
                                         $$->exprType = 3;
                                         $$->nodeKey = key;
                                        //-----------3AC----------------------//
                                         $$->place = pair<string,sEntry*>(key,lookup(key));
                                         $$->nextlist={};
                                      //----------------3AC--------------------//
                                    }
				    else{ yyerror("Error: %s is not declared in this scope", $1);
                                      $$->nodeType = string("");}
				  }
  | constant                      {$$=$1; }
  | string                        {$$=$1; }
  | '(' expression ')'            {$$=$2; }
  | generic_selection             {$$=$1; }
  ;

constant
  : I_CONSTANT                    { long long val = $1->iVal;
                                   $$=terminal($1->str);
				   char * a = constant($1->nType);
                                   $$->isInit=1;
                                   string as(a);
				   $$->nodeType=as;        
                                   $$->rVal = -5;
                                   $$->iVal = val;
                                   $$->exprType=5;
                                //-----------3AC-------------------------//
                                   $$->place = pair<string,sEntry*>($1->str,NULL);
                                    $$->nextlist={};
                                //-----------3AC-----------------------------//
				   }
  | F_CONSTANT                    { long long val = (int) $1->rVal;
                                   $$=terminal($1->str);
                                   char * a = constant($1->nType);
                                   $$->isInit =1;
                                   string as(a);
                                   $$->nodeType=as;
                                   $$->iVal = val;
                                   $$->exprType=5;
                                 //--------------3AC-----------------------//
                                   $$->place = pair<string,sEntry*>($1->str,NULL);
                                    $$->nextlist={};
                                 //-------------------3AC---------------------//
                                   }
  | ENUMERATION_CONSTANT           {$$=terminal($1);
                              $$->isInit=1;
                              $$->place = pair<string,sEntry*>($1,NULL);
                             $$->nodeType=string("ENUMERATION_CONSTANT");}
  ;
enumeration_constant    /* before it has been defined as such */
  : IDENTIFIER                    {$$=terminal($1);
                                  }
  ;

string
  : STRING_LITERAL                {$$=terminal($1); $$->nodeType = string("char*"); $$->isInit =1;
                                 //---------------3AC-------------------------------//
                                  $$->place = pair<string,sEntry*>($1,NULL);
                                    $$->nextlist={};
                                 //--------------3AC------------------------------------//
                                  }
  | FUNC_NAME                     {$$=terminal($1); $$->nodeType = string(); $$->isInit=1;
                                 //---------------3AC-------------------------------//
                                  $$->place = pair<string,sEntry*>($1,NULL);
                                    $$->nextlist={};
                                 //--------------3AC------------------------------------//
                                  }
  ;

generic_selection
  : GENERIC '(' assignment_expression ',' generic_assoc_list ')' {temp=terminal($1);$$=nonTerminal2("generic_selection",temp,$3,$5);}
  ;
generic_assoc_list
  : generic_association                        {$$=$1;}
  | generic_assoc_list ',' generic_association  {$$=nonTerminal2("generic_assoc_list",NULL,$1,$3);}
  ;

generic_association
  : type_name ':' assignment_expression      {$$ = nonTerminal2("generic_association", $1, $3, NULL);}
  | DEFAULT ':' assignment_expression        {   temp = terminal("DEFAULT");
                                                 $$ = nonTerminal2("generic_association", temp, $3, NULL);
                                             }
  ;
 postfix_expression
  : primary_expression                       {$$ = $1;}
  | postfix_expression '[' expression ']'
                                             {
						$$ = nonTerminal("postfix_expression[experssion]", NULL, $1, $3);
                         if($1->isInit==1 && $3->isInit==1)$$->isInit=1;
						char* s = postfixExpr($1->nodeType, 1);
						if(s){string as(s);
							$$->nodeType =as;
                                                //---------------3AC-------------------------------//
                                                 $$->place = getTmpSym($$->nodeType);
                                                 //qid opT  = pair<string,sEntry*>("[]",NULL);
                                                 // int k = emit(opT, $1->place, $3->place, $$->place, -1);
                                                 $$->place.second->size = $3->place.second->offset;
                                                 $$->place.second->offset = $1->place.second->offset;
                                                 $$->place.second->is_init = -5;

                                                 $$->nextlist = {};
                                                 //backPatch($3->truelist, k);
                                                 //backPatch($3->falselist, k);
                                               //----------------3AC------------------------------------//
						 }
						else {
						  yyerror("Error:  array indexed with more indices than its dimension ");
						}
                                             }
  | postfix_expression '(' ')'               {  $$ = $1;
              $$->isInit=1;

	  char* s = postfixExpr($1->nodeType, 2);
	  if(s){
		  string as(s);
		  $$->nodeType =as;
                  if($1->exprType==3){
                        string funcArgs = funcArgList($1->nodeKey);
                      //----------------------------3AC-------------------------------------------------//
                         qid t = getTmpSym($$->nodeType);
                        int k=emit(pair<string, sEntry*>("refParam", NULL), pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), t, -1);
                        int k1=emit(pair<string, sEntry*>("CALL", NULL), $1->place, pair<string, sEntry*>("1", NULL), t, -1);
                        $$->nextlist ={};
                        $$->place = t;
                     //-------------------------3AC---------------------------------------//
                        if(!(funcArgs==string(""))) {
                            yyerror("Error:\'%s\' function call requires arguments to be passed \n     \'%s %s\( %s \)\'",($1->nodeKey).c_str(),($$->nodeType).c_str(),($1->nodeKey).c_str(),funcArgs.c_str());
                        }
                  }
	  }
	  else {
		  yyerror("Error: Invalid Function call");
	  }
          currArguments=string("");

  }
  | postfix_expression '(' argument_expression_list ')'   {$$ = nonTerminal("postfix_expression", NULL, $1, $3);
          if($3->isInit==1) $$->isInit=1;
	  char* s = postfixExpr($1->nodeType, 3);
	  if(s){
		  string as(s);
		  $$->nodeType =as;
                  if($1->exprType==3){
                       string funcArgs = funcArgList($1->nodeKey);
                       char* a =new char();
                       string temp1 = currArguments;
                       string temp2 = funcArgs;
                       string typeA,typeB;
                       string delim = string(",");
                       unsigned f1=1;
                       unsigned f2=1;
                       int argNo = 0;
                       while(f1!=-1 && f2!=-1){
                          f1 = temp1.find_first_of(delim);
                          f2 = temp2.find_first_of(delim);
                            argNo++;
                            if(f1==-1) typeA = temp1; else{ typeA = temp1.substr(0,f1); temp1 = temp1.substr(f1+1);}
                            if(f2==-1) typeB = temp2 ; else{ typeB = temp2.substr(0,f2); temp2 = temp2.substr(f2+1); }
                            if(typeB==string("...")) break;
                            a = validAssign(typeA,typeB);
                            if(a){
                                   if(!strcmp(a,"warning")) { yyerror("Warning: Passing argumnet %d of \'%s\' from incompatible pointer type.\n Note : expected \'%s\' but argument is of type \'%s\'\n     \'%s %s\( %s \)\'",argNo,($1->nodeKey).c_str(),typeB.c_str(),typeA.c_str(),($$->nodeType).c_str(),($1->nodeKey).c_str(),funcArgs.c_str()); }
                            }
                            else{
                                  yyerror("Error: Incompatible type for argumnet %d of \'%s\' .\n Note : expected \'%s\' but argument is of type \'%s\'\n     \'%s %s\( %s \)\'",argNo,($1->nodeKey).c_str(),typeB.c_str(),typeA.c_str(),($$->nodeType).c_str(),($1->nodeKey).c_str(),funcArgs.c_str());
                            }
                            if((f1!=-1)&&(f2!=-1)){
                                 continue;
                           }else if(f2!=-1){
                                 if(!(temp2==string("..."))) yyerror("Error: Too few arguments for the function \'%s\'\n    \'%s %s\( %s \)\'",($1->nodeKey).c_str(),($$->nodeType).c_str(),($1->nodeKey).c_str(),funcArgs.c_str());
                                 break;
                           }else if(f1!=-1){
                                   yyerror("Error: Too many arguments for the function \'%s\'\n    \'%s %s\( %s \)\'",($1->nodeKey).c_str(),($$->nodeType).c_str(),($1->nodeKey).c_str(),funcArgs.c_str());
                                   break;
                          }else{ break; }
                  }
                   //--------------------------3AC----------------------------------//
                       unsigned fT=1;
                       unsigned carg=1;
                  while(fT!=-1){
                          carg++;
                          fT = currArguments.find_first_of(delim);
                          if(fT==-1) typeA = currArguments; else{ typeA = currArguments.substr(0,fT); currArguments = currArguments.substr(fT+1);}

                  }
                  qid t = getTmpSym($$->nodeType);
                  emit(pair<string, sEntry*>("refParam", NULL), pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), t, -1);
                  int k=emit(pair<string, sEntry*>("CALL", NULL), $1->place, pair<string, sEntry*>(to_string(carg), NULL), t, -1);
                  $$->place = t;
                  $$->nextlist ={};
                  //----------------------------3AC-----------------------------------------//
                 }

	  }
	  else {
		  yyerror("Error: Invalid Function call");
	  }
          currArguments=string("");
}
  | postfix_expression '.' IDENTIFIER       {
                                                temp = terminal($3);
                                                $$ = nonTerminal("postfix_expression.IDENTIFIER",NULL, $1, temp);
                                                string as($3);
                                                int k = structLookup($1->nodeType, as);
                                                if(k==1) yyerror("Error: \'.\' is an invalid operator on \'%s\'", $1->nodeKey.c_str() );
                                                else if(k==2) yyerror("Error: \'%s\' is not a member of struct \'%s\'", $3,$1->nodeKey.c_str() );
                                                else $$->nodeType = structMemberType($1->nodeType, as);
                                                $$->nodeKey = $1->nodeKey+ string(".") + as;
                                            }
  | postfix_expression PTR_OP IDENTIFIER    {
                                                temp=terminal($3);
                                                $$ = nonTerminal($2,NULL, $1, temp);
                                                string as($3);
                                                string as1 = ($1->nodeType).substr(0,($1->nodeType).length()-1);
                                                int k = structLookup(as1, as);
                                                cout<<k<<endl;
                                                if(k==1){ yyerror("Error: \'%s\' is an invalid operator on \'%s\'", $2, $1->nodeKey.c_str() );
                                                }
                                                else if(k==2){ yyerror("Error: \'%s\' is not a member of struct \'%s\'", $3,$1->nodeKey.c_str() );
                                                }
                                                else $$->nodeType = structMemberType(as1, as);
                                                $$->nodeKey = $1->nodeKey+ string("->") + as;
                                            }
  | postfix_expression INC_OP               {

                                               $$=  nonTerminal($2, NULL,$1, NULL);
         if($1->isInit==1) $$->isInit=1;
	  char* s = postfixExpr($1->nodeType, 6);
	  if(s){
		  string as(s);
		  $$->nodeType =as;
      $$->iVal = $1->iVal +1;
                  //------------------3AC------------//
                  qid t1 = getTmpSym($$->nodeType);
                  int k=  emit(pair<string, sEntry*>("++S", lookup("++")), $1->place, pair<string, sEntry*>("", NULL), t1, -1);
                  $$->place = t1;
                  $$->nextlist = {};
                 //-----------------3AC-----------------//
	  }
	  else {
		  yyerror("Error: Increment not defined for this type");
	  }

                                            }
  | postfix_expression DEC_OP               {
	  $$=  nonTerminal($2,NULL, $1,NULL);
          if($1->isInit==1) $$->isInit =1;
	  char* s = postfixExpr($1->nodeType, 7);
	  if(s){
		  string as(s);
		  $$->nodeType =as;
      $$->iVal = $1->iVal -1;
                  //-----------------3AC-------------//
                  qid t1 = getTmpSym($$->nodeType);
                  int k=emit(pair<string, sEntry*>("--S", lookup("--")), $1->place, pair<string, sEntry*>("", NULL), t1, -1);
                  $$->place = t1;
                  $$->nextlist={};
                  //--------------3AC-------------//
	  }
	  else {
		  yyerror("Error: Decrement not defined for this type");
	  }

  }
  | '(' type_name ')' '{' initializer_list '}' {
	  $$=  nonTerminal("postfix_expression", NULL, $2, $5);
          if($5->isInit==1) $$->isInit =1;
	  char* s = postfixExpr($2->nodeType, 8);
	  if(s){
		  string as(s);
		  $$->nodeType =as;
                  //-----------3AC-----------------//
                  $$->place = getTmpSym($$->nodeType);
                  string t = "\(" + $$->nodeType + "\)";
                  int k=emit(pair<string, sEntry*>(t, NULL), $5->place, pair<string, sEntry*>("", NULL), $$->place, -1);
                  $$->nextlist={};
                  //-----------3AC-----------------//
	  }
	  else {
		  yyerror("Error: typecasting error");
	  }

  }
  | '(' type_name ')' '{' initializer_list ',' '}' {
	  $$=nonTerminalFourChild("postfix_expression",$2,$5,NULL,NULL,$6);
          if($5->isInit==1) $$->isInit =1;
	  char* s = postfixExpr($2->nodeType, 9);
	  if(s){
		  string as(s);
		  $$->nodeType =as;
                 //----------3AC-----------------//
                  qid t1 = getTmpSym($$->nodeType);
                  string t = "\(" + $$->nodeType + "\)";
                  int k=emit(pair<string, sEntry*>(t, NULL), $5->place, pair<string, sEntry*>(",", NULL), t1, -1);
                  $$->nextlist = {};
                  $$->place = t1;
                 //-----------3AC----------------//
	  }
	  else {
		  yyerror("Error: typecasting error");
	  }
  }
  ;

argument_expression_list
  : assignment_expression
	  {
		$$ = $1;
		if($1->isInit==1)$$->isInit = 1;
                currArguments = $1->nodeType;
                //----------------3AC------------//
                if($$->place.second == NULL && $$->nodeType == "char*"){
                  int k=emit(pair<string, sEntry*>("param", NULL), $$->place, pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), -4);
                }
                else int k=emit(pair<string, sEntry*>("param", NULL), $$->place, pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), -1);
                $$->nextlist={};
                //---------------3AC------------//
          }
  | argument_expression_list ',' assignment_expression
	    {
             $$ = nonTerminal("argument_expression_list",NULL, $1, $3);
	     char* a =  argumentExpr($1->nodeType, $3->nodeType, 2);
		string as(a);
		$$->nodeType = as;
		if($1->isInit == 1 && $3->isInit==1) $$->isInit=1;
                currArguments = currArguments +string(",")+ $3->nodeType;
             //-------3AC-------------//
             if($3->place.second == NULL && $3->nodeType == "char*"){
                  int k=emit(pair<string, sEntry*>("param", NULL), $3->place, pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), -4);
             }
             else int k=emit(pair<string, sEntry*>("param", NULL), $3->place, pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), -1);
             $$->nextlist={};
             //------3AC--------------//

              }
  ;


unary_expression
  : postfix_expression            {$$ = $1;}
  | INC_OP unary_expression       {
	  $$=  nonTerminal($1, NULL,NULL, $2);
	  if($2->isInit == 1 ) $$->isInit=1;
	  char* s = postfixExpr($2->nodeType, 6);
	  if(s){
		  string as(s);
		  $$->nodeType =as;
      $$->iVal = $2->iVal +1;
                  //===========3AC======================//
                  qid t1 = getTmpSym($$->nodeType);
                  int k = emit(pair<string, sEntry*>("++P", lookup("++")), $2->place, pair<string, sEntry*>("", NULL), t1, -1);
                  $$->place = t1;
                  $$->nextlist = {};
              //    $$->code =  $2->code + '\n' +\
                //         $$->nodeKey + string("= ") + "INC_OP" + string(" ") + $2->nodeKey;
                  //====================================//
	  }
	  else {
		  yyerror("Error: Increment not defined for this type");
	  }

  }

  | DEC_OP unary_expression       {
          $$->iVal =$2->iVal -1;
       	  $$=  nonTerminal($1, NULL,NULL, $2);
	  if($2->isInit == 1 ) $$->isInit=1;
	  char* s = postfixExpr($2->nodeType, 7);
	  if(s){
		  string as(s);
		  $$->nodeType =as;
                  //===========3AC======================//
                  qid t1 = getTmpSym($$->nodeType);
                  int k = emit(pair<string, sEntry*>("--P", lookup("--")), $2->place, pair<string, sEntry*>("", NULL), t1, -1);
                  $$->place = t1;
                  $$->nextlist={};

                  //====================================//
	  }
	  else {
		  yyerror("Error: Decrement not defined for this type");
	  }

  }
  | unary_operator cast_expression {
    $$->iVal = $2->iVal;
		$$ = nonTerminal("unary_expression", NULL, $1, $2);
		if( $2->isInit==1) $$->isInit=1;
		char* a= unaryExpr($1->name, $2->nodeType, 1);
		if(a){
		    string as(a);
		    $$->nodeType= as;
                  //===========3AC======================//
                  qid t1 = getTmpSym($$->nodeType);
                  int k = emit($1->place, $2->place, pair<string, sEntry*>("", NULL), t1, -1);
                  $$->place = t1;
                  $$->nextlist={};

                  //====================================//
		}
		else{
		    yyerror("Error: Type inconsistent with operator %s", $1->name.c_str());
		}
 	}
  | SIZEOF unary_expression       {
                $$=  nonTerminal($1, NULL,NULL, $2);
		$$->nodeType = string("int");
		$$->isInit=1;
                //===========3AC======================//
                  qid t1 = getTmpSym($$->nodeType);
                  int k = emit(pair<string, sEntry*>("SIZEOF", lookup("sizeof")), $2->place, pair<string, sEntry*>("", NULL), t1, -1);
                  $$->place = t1;
                  $$->nextlist={};

                //====================================//
                                   }
  | SIZEOF '(' type_name ')'   {
                $$=  nonTerminal($1, NULL,NULL, $3);
		$$->nodeType = string("int");
		$$->isInit=1;
                //===========3AC======================//
                  qid t1 = getTmpSym($$->nodeType);
                  int k = emit(pair<string, sEntry*>("SIZEOF", lookup("sizeof")), $3->place, pair<string, sEntry*>("", NULL), t1, -1);
                  $$->place = t1;
                  $$->nextlist={};

                //====================================//
                                   }
  | ALIGNOF '(' type_name ')'   {
		$$=  nonTerminal($1, NULL,NULL, $3);
		$$->nodeType = string("int");
		$$->isInit=1;
                //===========3AC======================//
                  qid t1 = getTmpSym($$->nodeType);
                  int k= emit(pair<string, sEntry*>("ALIGNOF", lookup("_Alignof")), $3->place, pair<string, sEntry*>("", NULL), t1, -1);
                  $$->nextlist={};
                  $$->place = t1;

                //====================================//
                                   }
  ;

unary_operator
  : '&'      { $$ = terminal("&"); $$->place = pair<string, sEntry*>("&", lookup("&")); }
  | '*'      { $$ = terminal("*"); $$->place = pair<string, sEntry*>("unary*", lookup("*")); }
  | '+'      { $$ = terminal("+"); $$->place = pair<string, sEntry*>("unary+", lookup("+")); }
  | '-'      { $$ = terminal("-"); $$->place = pair<string, sEntry*>("unary-", lookup("-")); }
  | '~'      { $$ = terminal("~"); $$->place = pair<string, sEntry*>("~", lookup("~")); }
  | '!'      { $$ = terminal("!"); $$->place = pair<string, sEntry*>("!", lookup("!")); }
  ;

cast_expression
        : unary_expression        {$$ = $1;}
        | '(' type_name ')' cast_expression
		{
			$$ = nonTerminal("cast_expression", NULL, $2, $4);
			$$->nodeType = $2->nodeType;
                        if($4->isInit==1) $$->isInit=1;
                        //=============3AC====================//
                        qid t1 = getTmpSym($$->nodeType);
                        string t = $4->nodeType+ "to" + $$->nodeType ;
                        int k = emit(pair<string, sEntry*>(t, NULL), $4->place, pair<string, sEntry*>(",", NULL), t1, -1);
                        $$->nextlist={};
                        $$->place = t1;

                        //====================================//

		}
        ;

multiplicative_expression
        : cast_expression                                     {$$=$1;}
        | multiplicative_expression '*' cast_expression       { 
            char* a=multilplicativeExpr($1->nodeType, $3->nodeType, '*');
           if(a){
               int k;
               if(strcmp(a,"int")==0){
                 $$=nonTerminal("*int",NULL,$1,$3);
                 $$->nodeType = string("long long");
                 //---------------3AC----------------//
                  qid t1 = getTmpSym($$->nodeType);
                  k=emit(pair<string, sEntry*>("*int", lookup("*")), $1->place, $3->place, t1, -1);
                  $$->place = t1;
                  $$->nextlist={};
                //--------------3AC--------------------//
	       }
               else if (strcmp(a, "float")==0){
                 $$=nonTerminal("*float",NULL,$1,$3);
                 $$->nodeType = string("long double");
                 //-------------3AC---------------------//
                  qid t1 = getTmpSym($$->nodeType);

                  if(isInt($1->nodeType)){
                        qid t2 = getTmpSym($$->nodeType);
                        emit(pair<string, sEntry*>("inttoreal",NULL),$1->place,pair<string, sEntry*>("",NULL),t2,-1);
                        k=emit(pair<string, sEntry*>("*real", lookup("*")), t2, $3->place, t1, -1);
                  }
                  else if(isInt($3->nodeType)){
                        qid t2 = getTmpSym($$->nodeType);
                        emit(pair<string, sEntry*>("inttoreal",NULL),$3->place,pair<string, sEntry*>("",NULL),t2,-1);
                        k=emit(pair<string, sEntry*>("*real", lookup("*")), $1->place, t2, t1, -1);
                  }
                  else {

                        k=emit(pair<string, sEntry*>("*real", lookup("*")), $1->place, $3->place, t1, -1);
                  }
                  $$->place = t1;
                  $$->nextlist={};
                //------------3AC-----------------------------//
               }
            }
            else{
                $$=nonTerminal("*",NULL,$1,$3);
		yyerror("Error: Incompatible type for * operator");
            }
	    if($1->isInit==1 && $3->isInit==1) $$->isInit=1;
        }
        | multiplicative_expression '/' cast_expression       {
            if ($3->iVal != 0)
                $$->iVal = $1->iVal/ $3->iVal;
            char* a=multilplicativeExpr($1->nodeType, $3->nodeType, '/');
           if(a){int k;
                if(!strcmp(a,"int")){
                  $$=nonTerminal("/int",NULL,$1,$3);
                  $$->nodeType = string("long long");
                  //---------------3AC----------------------//
                  qid t1 = getTmpSym($$->nodeType);
                  k = emit(pair<string, sEntry*>("/int", lookup("/")), $1->place, $3->place, t1, -1);
                  $$->place = t1;
                  $$->nextlist= {};
                 //--------------3AC------------------------//
	        }
	        else if (!strcmp(a,"float")){
                  $$=nonTerminal("/float",NULL,$1,$3);
                  $$->nodeType = string("long double");
                 //-------------3AC---------------------//
                  qid t1 = getTmpSym($$->nodeType);

                  if(isInt($1->nodeType)){
                        qid t2 = getTmpSym($$->nodeType);
                        emit(pair<string, sEntry*>("inttoreal",NULL),$1->place,pair<string, sEntry*>("",NULL),t2,-1);
                        k=emit(pair<string, sEntry*>("/real", lookup("/")), t2, $3->place, t1, -1);
                  }
                  else if(isInt($3->nodeType)){
                        qid t2 = getTmpSym($$->nodeType);
                        emit(pair<string, sEntry*>("inttoreal",NULL),$3->place,pair<string, sEntry*>("",NULL),t2,-1);
                        k=emit(pair<string, sEntry*>("/real", lookup("/")), $1->place, t2, t1, -1);
                  }
                  else {
                        k=emit(pair<string, sEntry*>("/real", lookup("/")), $1->place, $3->place, t1, -1);
                  }
                  $$->place =t1;
                  $$->nextlist={};
                 //-------------------------------------------//
                }
            }
            else{
               $$=nonTerminal("/",NULL,$1,$3);
		yyerror("Error: Incompatible type for / operator");
            }
	    if($1->isInit==1 && $3->isInit==1) $$->isInit=1;
}
        | multiplicative_expression '%' cast_expression       {
           if($3->iVal != 0) $$->iVal = $1->iVal % $3->iVal;
            $$=nonTerminal("%",NULL,$1,$3);
            char* a=multilplicativeExpr($1->nodeType, $3->nodeType, '/');
            if(!strcmp(a,"int")){
		$$->nodeType= string("long long");
                  //===========3AC======================//
                  qid t1 = getTmpSym($$->nodeType);
                  int k =emit(pair<string, sEntry*>("%", lookup("%")), $1->place, $3->place, t1, -1);
                  $$->nextlist={};
                  $$->place = t1;

                  //====================================//
	    }
	    else {
		yyerror("Error: Incompatible type for % operator");
            }
	    if($1->isInit==1 && $3->isInit==1) $$->isInit=1;
           }
        ;

additive_expression
        : multiplicative_expression                           {$$=$1;}
        | additive_expression '+' multiplicative_expression   {
                $$->iVal = $1->iVal + $3->iVal;
                char *a = additiveExpr($1->nodeType,$3->nodeType,'+');
                 char *q=new char();
                 string p;
                 if(a){string as(a);
                 p = string("+")+as;
                 strcpy(q,p.c_str());}
                 else q = "+";
                 $$=nonTerminal(q,NULL,$1,$3);
                 if(a){ string as(a);
                   if(!strcmp(a,"int")) $$->nodeType=string("long long");
                   else if(!strcmp(a,"real")) $$->nodeType=string("long double");
                   else $$->nodeType=as; // for imaginary and complex returns
                  //===========3AC======================//
                   qid t1 = getTmpSym($$->nodeType);
                   if(isInt($1->nodeType) && isFloat($3->nodeType)){
                        qid t2 = getTmpSym($$->nodeType);
                        emit(pair<string, sEntry*>("inttoreal",NULL),$1->place,pair<string, sEntry*>("",NULL),t2,-1);
                        emit(pair<string, sEntry*>(p, lookup("+")), t2, $3->place, t1, -1);
                   }
                   else if(isInt($3->nodeType) && isFloat($1->nodeType)){
                        qid t2 = getTmpSym($$->nodeType);
                        emit(pair<string, sEntry*>("inttoreal",NULL),$3->place,pair<string, sEntry*>("",NULL),t2,-1);
                        emit(pair<string, sEntry*>(p, lookup("+")), $1->place, t2, t1, -1);
                   }
                   else {
                        emit(pair<string, sEntry*>(p, lookup("+")), $1->place, $3->place, t1, -1);
                   }
                   $$->place = t1;
                  $$->nextlist = {};
                  //====================================//
                 }
                 else {
                       yyerror("Error: Incompatible type for + operator");
                      }
		 if($1->isInit==1 && $3->isInit==1) $$->isInit=1;

                 }
        | additive_expression '-' multiplicative_expression   {
                 $$->iVal = $1->iVal - $3->iVal;
                 char *a = additiveExpr($1->nodeType,$3->nodeType,'-');
		 char *q = new char();
                 string p;
		 if(a){ string as(a);
                         p =string("-")+as;
                         strcpy(q,p.c_str());
                      }
		  $$=nonTerminal(q,NULL,$1,$3);
	          if(a){ string as(a);
                   if(!strcmp(a,"int")) $$->nodeType=string("long long");
                   else if(!strcmp(a,"real")) $$->nodeType=string("long double");
	           else $$->nodeType=as;   // for imaginary and complex returns
                  //===========3AC======================//
                   qid t1 = getTmpSym($$->nodeType);
                   if(isInt($1->nodeType) && isFloat($3->nodeType)){
                        qid t2 = getTmpSym($$->nodeType);
                        emit(pair<string, sEntry*>("inttoreal",NULL),$1->place,pair<string, sEntry*>("",NULL),t2,-1);
                        emit(pair<string, sEntry*>(p, lookup("-")), t2, $3->place, t1, -1);
                   }
                   else if(isInt($3->nodeType) && isFloat($1->nodeType)){
                        qid t2 = getTmpSym($$->nodeType);
                        emit(pair<string, sEntry*>("inttoreal",NULL),$3->place,pair<string, sEntry*>("",NULL),t2,-1);
                        emit(pair<string, sEntry*>(p, lookup("-")), $1->place, t2, t1, -1);
                   }
                   else {
                        emit(pair<string, sEntry*>(p, lookup("-")), $1->place, $3->place, t1, -1);
                   }
                   $$->place = t1;
                   $$->nextlist = {};
                  //====================================//
                 }
		 else {
			 yyerror("Error: Incompatible type for - operator");
		 }
		 if($1->isInit==1 && $3->isInit==1) $$->isInit=1;

	}
        ;


shift_expression
  : additive_expression     {$$ = $1;}
  | shift_expression LEFT_OP additive_expression {
                          $$ = nonTerminal2("<<", $1,NULL, $3);
                          char* a = shiftExpr($1->nodeType,$3->nodeType);                        if(a){
                            $$->nodeType = $1->nodeType;
                         //===========3AC======================//
                          qid t1 = getTmpSym($$->nodeType);
                          int k = emit(pair<string, sEntry*>("LEFT_OP", lookup("<<")), $1->place, $3->place, t1, -1);
                          $$->place = t1;
                          $$->nextlist={};
                        //====================================//
                           }
                       else{
                          yyerror("Error: Invalid operands to binary <<");
                           }
		       if($1->isInit==1 && $3->isInit==1) $$->isInit=1;
                     }
  | shift_expression RIGHT_OP additive_expression {
                              $$ = nonTerminal2(">>", $1, NULL, $3);
                       char* a = shiftExpr($1->nodeType,$3->nodeType);
                          if(a){
                                $$->nodeType = $1->nodeType;
                                //===========3AC======================//
                                 qid t1 = getTmpSym($$->nodeType);
                                 int k = emit(pair<string, sEntry*>("RIGHT_OP", lookup(">>")), $1->place, $3->place, t1, -1);
                                 $$->place = t1;
                                 $$->nextlist={};
                                //====================================//
                               }
                        else{
                          yyerror("Error: Invalid operands to binary <<");
                            }

			if($1->isInit==1 && $3->isInit==1) $$->isInit=1;
                       }
  ;

relational_expression
  : shift_expression     {$$ = $1;}
  | relational_expression '<' shift_expression
      {                $$ = nonTerminal("<", NULL, $1, $3);
                    char* a=relationalExpr($1->nodeType,$3->nodeType,"<");
                 if(a) { 

                         if(!strcmp(a,"bool")) $$->nodeType = string("bool");
                        else if(!strcmp(a,"Bool")){
                        $$->nodeType = string("bool");
                       yyerror("Warning: comparison between pointer and integer");}
                       //===========3AC======================//
                        qid t1 = getTmpSym($$->nodeType);
                        int k =  emit(pair<string, sEntry*>("<", lookup("<")), $1->place, $3->place, t1, -1);
                        $$->place = t1;
                        $$->nextlist={};
                       //====================================//
                    }
                  else {
                         yyerror("Error: invalid operands to binary <");
                    }
                  if($1->isInit==1 && $3->isInit==3) $$->isInit=1;

      }
  | relational_expression '>' shift_expression
 {                $$ = nonTerminal(">", NULL, $1, $3);
                  char* a=relationalExpr($1->nodeType,$3->nodeType,">");
                   if(a){ if(!strcmp(a,"bool")) $$->nodeType = string("bool");
                          else if(!strcmp(a,"Bool")){
                           $$->nodeType = string("bool");
                          yyerror("Warning: comparison between pointer and integer");}
                         //===========3AC======================//
                           qid t1 = getTmpSym($$->nodeType);
                           int k = emit(pair<string, sEntry*>(">", lookup(">")), $1->place, $3->place, t1, -1);
                           $$->place = t1;
                           $$->nextlist = {};
                       //====================================//
                    } else {
                         yyerror("Error: invalid operands to binary >");
                    }
                  if($1->isInit==1 && $3->isInit==3) $$->isInit=1;

  }
  | relational_expression LE_OP shift_expression
   {
                                  $$ = nonTerminal2("<=", $1,NULL, $3);
                    char* a=relationalExpr($1->nodeType,$3->nodeType,"<=");
                    if(a){if(!strcmp(a,"bool")) $$->nodeType = string("bool");
                       else if(!strcmp(a,"Bool")){
                        $$->nodeType = string("bool");
                        yyerror("Warning: comparison between pointer and integer");}
                         //===========3AC======================//
                           qid t1 = getTmpSym($$->nodeType);
                          int k= emit(pair<string, sEntry*>("LE_OP", lookup("<=")), $1->place, $3->place, t1, -1);
                           $$->place = t1;
                           $$->nextlist = {};
                       //====================================//
                    }else {
                         yyerror("Error: invalid operands to binary <=");
                    }
                  if($1->isInit==1 && $3->isInit==3) $$->isInit=1;
      }
  | relational_expression GE_OP shift_expression
    {
                       $$ = nonTerminal2(">=", $1,NULL, $3);
                  char* a=relationalExpr($1->nodeType,$3->nodeType,">=");
              if(a){  if(!strcmp(a,"bool")) $$->nodeType = string("bool");
                      else if(!strcmp(a,"Bool")){
                        $$->nodeType = string("bool");
                         yyerror("Warning: comparison between pointer and integer");}
                         //===========3AC======================//
                           qid t1 = getTmpSym($$->nodeType);
                           int k = emit(pair<string, sEntry*>("GE_OP", lookup(">=")), $1->place, $3->place, t1, -1);
                           $$->place = t1;
                           $$->nextlist ={};
                       //====================================//
                    }else {
                         yyerror("Error: invalid operands to binary >=");
                    }
                  if($1->isInit==1 && $3->isInit==3) $$->isInit=1;
      }
  ;

equality_expression
  : relational_expression   {$$ = $1;}
  | equality_expression EQ_OP relational_expression {
                                                    $$ = nonTerminal2("==", $1, NULL, $3);
                    char* a = equalityExpr($1->nodeType,$3->nodeType);
                    if(a){ if(!strcmp(a,"true")){
                            yyerror("Warning: Comparision between pointer and Integer");
                            }
                            $$->nodeType = "bool";
                         //===========3AC======================//
                           qid t1 = getTmpSym($$->nodeType);
                           int k = emit(pair<string, sEntry*>("EQ_OP", lookup("\=\=")), $1->place, $3->place, t1, -1);
                           $$->place = t1;
                           $$->nextlist = {};
                       //====================================//
                    }
                   else{ yyerror("Error:Invalid operands to binary =="); }
                 if($1->isInit==1 && $3->isInit==3) $$->isInit=1;
                                                  }
  | equality_expression NE_OP relational_expression {
                      $$ = nonTerminal2("!=", $1, NULL, $3);
                      char* a = equalityExpr($1->nodeType,$3->nodeType);
                    if(a){   if(!strcmp(a,"true")){
                            yyerror("Warning: Comparision between pointer and Integer");
                            }
                            $$->nodeType = "bool";
                         //===========3AC======================//
                           qid t1 = getTmpSym($$->nodeType);
                           int k = emit(pair<string, sEntry*>("NE_OP", lookup("!=")), $1->place, $3->place, t1, -1);
                           $$->place = t1;
                           $$->nextlist ={};
                       //====================================//
                    }
                   else{ yyerror("Error:Invalid operands to binary !="); }
                 if($1->isInit==1 && $3->isInit==3) $$->isInit=1;
                                                  }
  ;

and_expression
  : equality_expression  { $$ = $1;}
  | and_expression '&' equality_expression  {
               $$ = nonTerminal("&",NULL, $1, $3);
               char* a = bitwiseExpr($1->nodeType,$3->nodeType);
               if(a){
                  if(!strcmp(a,"true")) { $$->nodeType = string("bool"); }
                  else{   $$->nodeType = string("long long");}
                         //===========3AC======================//
                           qid t1 = getTmpSym($$->nodeType);
                           int k= emit(pair<string, sEntry*>("&", lookup("&")), $1->place, $3->place, t1, -1);
                           $$->place = t1;
                           $$->nextlist={};
                       //====================================//
               }
               else {
                 yyerror("Error:Invalid operands to the binary &");
               }
                 if($1->isInit==1 && $3->isInit==3) $$->isInit=1;
          }
  ;

exclusive_or_expression
  : and_expression   { $$ = $1;}
  | exclusive_or_expression '^' and_expression  {
           $$ = nonTerminal("^", NULL, $1, $3);
               char* a = bitwiseExpr($1->nodeType,$3->nodeType);
               if(a){
                  if(!strcmp(a,"true")) { $$->nodeType = string("bool"); }
                  else{   $$->nodeType = string("long long");}
                         //===========3AC======================//
                           qid t1 = getTmpSym($$->nodeType);
                           int k = emit(pair<string, sEntry*>("^", lookup("^")), $1->place, $3->place, t1, -1);
                           $$->place = t1;
                           $$->nextlist={};
                       //====================================//
               }
               else {
                 yyerror("Error:Invalid operands to the binary ^");
               }
                 if($1->isInit==1 && $3->isInit==3) $$->isInit=1;

        }
  ;

inclusive_or_expression
  : exclusive_or_expression    { $$ = $1;}
  | inclusive_or_expression '|' exclusive_or_expression  {
            $$ = nonTerminal("|", NULL, $1, $3);
               char* a = bitwiseExpr($1->nodeType,$3->nodeType);
               if(a){
                  if(!strcmp(a,"true")) { $$->nodeType = string("bool"); }
                  else{   $$->nodeType = string("long long");}
                         //===========3AC======================//
                           qid t1 = getTmpSym($$->nodeType);
                           int k =  emit(pair<string, sEntry*>("|", lookup("|")), $1->place, $3->place, t1, -1);
                           $$->place = t1;
                           $$->nextlist={};
                       //====================================//
               }
               else {
                 yyerror("Error:Invalid operands to the binary |");
               }
                 if($1->isInit==1 && $3->isInit==3) $$->isInit=1;

      }
  ;
M1
  : logical_and_expression AND_OP {
                        if($1->truelist.begin()==$1->truelist.end()){
                            int k = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("IF", lookup("if")), $1->place, pair<string, sEntry*>("", NULL ),0);
                            int k1 = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL ),0);
                            $1->truelist.push_back(k);
                            $1->falselist.push_back(k1);

                        }
                        $$ = $1;
  }
  ;

M
 : %empty {
           $$ = getNextIndex();
 }
 ;

logical_and_expression
  : inclusive_or_expression { $$ = $1;}
  |  M1 M  inclusive_or_expression  {
                          $$ = nonTerminal2("&&", $1,NULL, $3);
                        $$->nodeType == string("bool");
                         //===========3AC======================//
                            if($3->truelist.begin()==$3->truelist.end()){
                                int k = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("IF", lookup("if")), $3->place, pair<string, sEntry*>("", NULL ),0);
                                int k1 = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL ),0);
                                $3->truelist.push_back(k);
                                $3->falselist.push_back(k1);
                        }
                           backPatch($1->truelist,$2);
                           $$->truelist = $3->truelist;
                           $1->falselist.merge($3->falselist);
                           $$->falselist = $1->falselist;
                           $$->nextlist ={};
                       //====================================//
                 if($1->isInit==1 && $3->isInit==3) $$->isInit=1;
                  }
  ;

M2
  : logical_or_expression OR_OP {
                        if($1->truelist.begin()==$1->truelist.end()){
                            int k = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("IF", lookup("if")), $1->place, pair<string, sEntry*>("", NULL ),0);
                            int k1 = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL ),0);
                            $1->truelist.push_back(k);
                            $1->falselist.push_back(k1);

                        }
                        $$ = $1;
  }
  ;

logical_or_expression
  : logical_and_expression  { $$ = $1; tempQid = $$->place;}
  | M2 M logical_and_expression  {
                                $$ = nonTerminal2("||", $1,NULL, $3);
                 if($1->isInit==1 && $3->isInit==3) $$->isInit=1;
                        $$->nodeType == string("bool");
                         //===========3AC======================//
                         if($3->truelist.begin()==$3->truelist.end()){
                                int k = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("IF", lookup("if")), $3->place, pair<string, sEntry*>("", NULL ),0);
                                int k1 = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL ),0);
                                $3->truelist.push_back(k);
                                $3->falselist.push_back(k1);
                        }
                         backPatch($1->falselist, $2);
                         $$->falselist = $3->falselist;
                         $1->truelist.merge($3->truelist);
                         $$->truelist = $1->truelist;
                         $$->nextlist = {};
                        //====================================//
                                                        }
  ;


M3
  : logical_or_expression '?' {
                        if($1->truelist.begin()==$1->truelist.end()){
                            int k = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("IF", lookup("if")), $1->place, pair<string, sEntry*>("", NULL ),0);
                            int k1 = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL ),0);
                            $1->truelist.push_back(k);
                            $1->falselist.push_back(k1);

                        }
                        $$ = $1;
  }
  ;

N
 : %empty {
                emit(pair<string, sEntry*>("=", lookup("=")), pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), -1);
                $$ = emit(pair<string, sEntry*>("GOTO", lookup("goto")), pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), 0);
 }
 ;

conditional_expression
  : logical_or_expression  { $$ = $1;}
  | M3 M  expression ':' N  conditional_expression  {

            $$ = nonTerminal2("conditional_expression", $1, $3, $6);
            $$->rVal = -11;
            char* a = conditionalExpr($3->nodeType,$6->nodeType);
            if(a){
                 string as(a);
                 $$->nodeType = string("int");
                 //--------------------3AC--------------------------//
                    qid t = getTmpSym($$->nodeType);
                    emit(pair<string, sEntry*>("=", lookup("=")), $6->place, pair<string, sEntry*>("", NULL), t, -1);
                    int k = emit(pair<string, sEntry*>("GOTO", lookup("goto")), pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), 0);
                     backPatch($1->truelist , $2);
                     backPatch($1->falselist , $5+1);
                     setId1($5-1 , $3->place);
                     setResult($5-1 , t);
                     $$->nextlist = $3->nextlist;
                     $$->nextlist.push_back($5);
                     $$->nextlist.push_back(k);
                     $$->place = t;
                 //--------------------------------------------------//
                 }
            else
                {
                 yyerror("Error:Type mismatch in conditional expression");
                }
           if($1->isInit==1 && $3->isInit==1 && $6->isInit==1) $$->isInit=1;

          }
  ;


assignment_expression
  : conditional_expression  { $$ = $1;}
  | unary_expression assignment_operator assignment_expression
             { $$ = nonTerminal2($2, $1,NULL, $3);
               
               char* a = assignmentExpr($1->nodeType,$3->nodeType,$2);
               if(a){
                    if(!strcmp(a,"true")){ $$->nodeType = $1->nodeType;
                      }
                    if(!strcmp(a,"warning")){ $$->nodeType = $1->nodeType;
                         yyerror("Warning: Assignment with incompatible pointer type");
                         }
                      //-------------3AC------------------------------------//
                      int k;
		     if(!strcmp($2,"=") || !strcmp($2,"+=") || !strcmp($2,"-=") || !strcmp($2,"*=") || !strcmp($2,"/=")) k= assignmentExpression($2, $$->nodeType,$1->nodeType, $3->nodeType, $1->place, $3->place)	;
		     else assignment2($2, $$->nodeType,$1->nodeType, $3->nodeType, $1->place, $3->place);
                       $$->place = $1->place;

                      backPatch($3->nextlist, k);
                       
                      
                     //-------------------------------------------------------//
                    }
                else{ yyerror("Error: Incompatible types when assigning type \'%s\' to \'%s\' ",($1->nodeType).c_str(),($3->nodeType).c_str()); }
     if($1->exprType==3){ if($3->isInit==1) update_isInit($1->nodeKey); }
             }
  ;

assignment_operator
  : '='    { $$ = "=";}
  | MUL_ASSIGN  {
                  $$ = "*=";
                }
  | DIV_ASSIGN  {
                  $$ = "/=";
                }
  | MOD_ASSIGN  {
                  $$ = "%=";
                }
  | ADD_ASSIGN  {
                  $$ = "+=";
                }
  | SUB_ASSIGN  {
                  $$ = "-=";
                }
  | LEFT_ASSIGN {
                  $$ = "<<=";
                }
  | RIGHT_ASSIGN  {
                  $$ = ">>=";
                }
  | AND_ASSIGN  {
                  $$ = "&=";
                }
  | XOR_ASSIGN  {
                  $$ = "^=";
                }
  | OR_ASSIGN    {
                  $$ = "|=";
                }
  ;

expression
  : assignment_expression    { $$ = $1;}
  | expression ',' M assignment_expression   {
                 $$ = nonTerminal("expression",NULL, $1, $4); $$->nodeType = string("void");
                 //--------------3AC--------------------//
                    backPatch($1->nextlist,$3);
                    $$->nextlist = $4->nextlist;
                 //-------------------------------------//
                 }
  ;

constant_expression
  : conditional_expression  { $$ = $1;}
  ;

declaration
  : declaration_specifiers ';'  { typeName=string("");}
  | declaration_specifiers init_declarator_list ';'  { typeName=string(""); $$ = nonTerminal("declaration", NULL, $1, $2);
                                                      //----------------3AC-----------------------//
                                                        $$->nextlist = $2->nextlist;
                                                      //-----------------------------------------//
                                                     }
  | static_assert_declaration   { typeName=string("");$$ = $1;}
  ;

declaration_specifiers
  : storage_class_specifier declaration_specifiers { $$ = nonTerminal("declaration_specifiers", NULL, $1, $2);}
  | storage_class_specifier      { $$ = $1;}
  | type_specifier declaration_specifiers   { $$ = nonTerminal("declaration_specifiers", NULL, $1, $2);}
  | type_specifier              { $$ = $1;}
  | type_qualifier declaration_specifiers  { $$ = nonTerminal("declaration_specifiers", NULL, $1, $2);}
  | type_qualifier         { $$ = $1;}
  | function_specifier declaration_specifiers   { $$ = nonTerminal("declaration_specifiers", NULL, $1, $2);}
  | function_specifier  { $$ = $1;}
  | alignment_specifier declaration_specifiers { $$ = nonTerminal("declaration_specifiers", NULL, $1, $2);}
  | alignment_specifier  { $$ = $1;}
  ;

init_declarator_list
  : init_declarator    { $$ = $1;}
  | init_declarator_list ',' M init_declarator  { $$ = nonTerminal("init_declaration_list",NULL, $1, $4);
                                               //-----------3AC------------------//
                                                 backPatch($1->nextlist, $3);
                                                 $$->nextlist = $4->nextlist;
                                               //--------------------------------//
                                              }
  ;

init_declarator
  : declarator '=' M initializer  {
                $$ = nonTerminal("=", NULL, $1, $4);
                    if($1->exprType==1||$1->exprType==15){ char *t=new char();
                      strcpy(t,($1->nodeType).c_str());
                      char *key =new char();
                      strcpy(key,($1->nodeKey).c_str());
                if(scopeLookup($1->nodeKey)){
                     yyerror("Error: Redeclaration of \'%s\'",key);
                }else if($1->nodeType==string("void")){
                     yyerror("Error: Variable or field \'%s\' declared void",key);
                }
                else { if($$->exprType==15) { insertSymbol(*curr,key,t,($4->exprType*$1->iVal),0,1); }
                        insertSymbol(*curr,key,t,$1->size,0,1);
                        //----------------- 3AC ------------------------//
                             char *a = validAssign($1->nodeType, $4->nodeType);
                             if(a){
                                    if(strcmp(a,"true")){ yyerror("Warning: Invalid assignment of \'%s\' to \'%s\' ",$1->nodeType.c_str(),$4->nodeType.c_str()); }
                  $1->place = pair<string, sEntry*>($1->nodeKey, lookup($1->nodeKey));
		             assignmentExpression("=", $1->nodeType,$1->nodeType, $4->nodeType, $1->place, $4->place);
                             $$->place = $1->place;
                             backPatch($1->nextlist, $3);
                             $$->nextlist = $4->nextlist;
                              }
                              else { yyerror("Error: Invalid assignment of \'%s\' to \'%s\' ",$1->nodeType.c_str(),$4->nodeType.c_str()); }
                           $$->place = pair<string, sEntry*>($1->nodeKey, lookup($1->nodeKey));

                        //-----------------------------------------------//
                     }
                }
               }
  | declarator     {
                     $$= $1;
                     if($1->exprType==1){ char *t=new char();
                     strcpy(t,($1->nodeType).c_str());
                     char *key =new char();
                     strcpy(key,($1->nodeKey).c_str());
                  if(scopeLookup($1->nodeKey)){
                        yyerror("Error: redeclaration of \'%s\'",key);
                  }else if($1->nodeType==string("void")){
                     yyerror("Error: Variable or field \'%s\' declared void",key);
                  }else {  insertSymbol(*curr,key,t,$1->size,0,0);}
                           $$->place = pair<string, sEntry*>($1->nodeKey, lookup($1->nodeKey));
                     }
               }
  ;

storage_class_specifier
  : TYPEDEF   {   //typeName = typeName+string(" ")+string($1);
                  $$=terminal($1);
              }
  | EXTERN    {   //typeName = typeName+string(" ")+string($1);
                  $$=terminal($1);
              }
  | STATIC    {    //typeName = typeName+string(" ")+string($1);
                  $$=terminal($1);
              }
  | THREAD_LOCAL { //typeName = typeName+string(" ")+string($1);
                  $$=terminal($1);
              }
  | AUTO      {    //typeName = typeName+string(" ")+string($1);
                  $$=terminal($1);
              }
  | REGISTER  {    //typeName = typeName+string(" ")+string($1);
                  $$=terminal($1);
              }
  ;

type_specifier
  : VOID     {     if(typeName==string(""))typeName = string($1);
                   else typeName = typeName+string(" ")+string($1);
                  $$=terminal($1);
              }
  | CHAR     {     if(typeName==string(""))typeName = string($1);
                   else typeName = typeName+string(" ")+string($1);
                  $$=terminal($1);
              }
  | SHORT     {   if(typeName==string(""))typeName = string($1);
                   else typeName = typeName+string(" ")+string($1);
                  $$=terminal($1);
              }
  | INT       {   if(typeName==string(""))typeName = string($1);
                   else typeName = typeName+string(" ")+string($1);
                  $$=terminal($1);
              }
  | LONG      {    if(typeName==string(""))typeName = string($1);
                   else typeName = typeName+string(" ")+string($1);
                  $$=terminal($1);
              }
  | FLOAT     {   if(typeName==string(""))typeName = string($1);
                   else typeName = typeName+string(" ")+string($1);
                  $$=terminal($1);
              }
  | DOUBLE    {    if(typeName==string(""))typeName = string($1);
                   else typeName = typeName+string(" ")+string($1);
                  $$=terminal($1);
              }
  | SIGNED    {    if(typeName==string(""))typeName = string($1);
                   else typeName = typeName+string(" ")+string($1);
                  $$=terminal($1);
              }
  | UNSIGNED  {   if(typeName==string(""))typeName = string($1);
                   else typeName = typeName+string(" ")+string($1);
                  $$=terminal($1);
              }
  | BOOL      {   if(typeName==string(""))typeName = string($1);
                   else typeName = typeName+string(" ")+string($1);
                  $$=terminal($1);
              }
  | COMPLEX   {   if(typeName==string(""))typeName = string($1);
                   else typeName = typeName+string(" ")+string($1);
                  $$=terminal($1);
              }
  | IMAGINARY {   if(typeName==string(""))typeName = string($1);
                   else typeName = typeName+string(" ")+string($1);
                  $$=terminal($1);
              }


  | atomic_type_specifier  {$$ = $1;yyerror("Error : Not implemented atomic_type_specifier");}
  | struct_or_union_specifier  {$$ = $1; if(typeName==string(""))typeName =  $$->nodeType;
                                         else typeName = typeName +string("")+ $$->nodeType;
                                    }
  | enum_specifier  {$$ =$1;yyerror("Error : not implemented Enum specifier");}
  | TYPEDEF_NAME    {  if(typeName==string(""))typeName = string($1);
                   else typeName = typeName+string(" ")+string($1);
                  $$ = terminal($1);
              }
  ;

struct_or_union_specifier
  : struct_or_union E5 '{' struct_declaration_list '}' {$$ = nonTerminal("struct_or_union_specifier", NULL, $1, $4);
                                                                  structCounter++;
                                                                  string as = to_string(structCounter);
                                                                  if(endStructTable(as)){
                                                                  $$->nodeType = string("STRUCT_")+as; }
                                                                  else yyerror("Error: struct \'%s\' is already defined\n", $2);
                                                    }
  | struct_or_union IDENTIFIER  E5 '{' struct_declaration_list '}'  {
                                                                  string as($2);
                                                                  $$ = nonTerminal("struct_or_union_specifier", $2, $1, $5);
                                                                  if(endStructTable(as)){
                                                                  $$->nodeType = string("STRUCT_")+as; }
                                                                  else yyerror("Error: struct \'%s\' is already defined\n", $2);
                                                                }
  | struct_or_union IDENTIFIER   {
                                    $$ = nonTerminal("struct_or_union_specifier", $2,$1, NULL);
                                    string as($2);
                                    as = "STRUCT_" + as;
                                    if(isStruct(as)) $$->nodeType = as;
                                    else yyerror("Error: No struct \'%s\' is defined",$2);
                                  }
  ;

E5
  : %empty{
           makeStructTable();
  };


struct_or_union
  : STRUCT   {
              $$=terminal($1);
              }
  | UNION     {
                $$=terminal($1);
              }
  ;

struct_declaration_list
  : struct_declaration   {$$ = $1;}
  | struct_declaration_list struct_declaration  {$$ = nonTerminal("struct_declaration_list", NULL, $1, $2);}
  ;

struct_declaration
  : specifier_qualifier_list ';'  {$$ = $1; typeName = string(""); }
  | specifier_qualifier_list struct_declarator_list ';' {$$ = nonTerminal("struct_declaration", NULL, $1, $2);
                                                          typeName = string("");
                                                        }
  | static_assert_declaration  {$$ = $1;}
  ;

specifier_qualifier_list
	: type_specifier specifier_qualifier_list {$$ = nonTerminal("specifier_qualifier_list", NULL, $1, $2);}
	| type_specifier  {$$ = $1;}
	| type_qualifier specifier_qualifier_list  {$$ = nonTerminal("specifier_qualifier_list", NULL, $1, $2);}
	| type_qualifier  {$$ = $1;}
	;

struct_declarator_list
	: struct_declarator  {$$ = $1;}
	| struct_declarator_list ',' struct_declarator  {$$ = nonTerminal("struct_declarator_list",NULL, $1, $3);}
	;

struct_declarator
	: ':' constant_expression {$$ = $2;}
	| declarator ':' constant_expression  {$$ = nonTerminal("struct_declarator", NULL, $1, $3);
                                               if(!insertStructSymbol($1->nodeKey, $1->nodeType, $1->size, 0, 1)) yyerror("Error: \'%s\' is already declared in the same struct", $1->nodeKey.c_str());
                                              }
	| declarator {$$ = $1;
                                               if(!insertStructSymbol($1->nodeKey, $1->nodeType, $1->size, 0, 0)) yyerror("Error: \'%s\' is already declared in the same struct", $1->nodeKey.c_str());
                     }
	;

enum_specifier
	: ENUM '{' enumerator_list '}' {
                                       	  $$ = nonTerminal("enum_specifier", $1, NULL, $3);
                                       }
	| ENUM '{' enumerator_list ',' '}' {
						$$ = nonTerminal1("enum_specifier", $1, $3,$4);
					   }
	| ENUM IDENTIFIER '{' enumerator_list '}'  {
						    $$ = nonTerminal3("enum_specifier", $1,$2, $4,NULL);
                                                   }
	| ENUM IDENTIFIER '{' enumerator_list ',' '}' {
							$$ = nonTerminal3("enum_specifier",$1,$2,$4,$5);
                                                   }

	| ENUM IDENTIFIER                          {
							$$ = nonTerminal3("enum_specifier",$1, $2,NULL, NULL);
                                                   }

	;

enumerator_list
	: enumerator  {$$ = $1;}
	| enumerator_list ',' enumerator {$$ = nonTerminal("enumerator_list", NULL, $1,  $3);}
	;

enumerator
	: enumeration_constant '=' constant_expression {$$ = nonTerminal("=",NULL, $1,  $3);}
	| enumeration_constant {$$ = $1;}
	;

atomic_type_specifier
	: ATOMIC '(' type_name ')' {
					$$ = nonTerminal("atomic_type_specifier", $1, NULL, $3);
				   }
	;

type_qualifier
        : CONST {    // typeName = typeName+string(" ")+string($1);
                     $$ = terminal($1);
                }
        | RESTRICT {   //typeName = typeName+string(" ")+string($1);
                     $$ = terminal($1);
                   }
        | VOLATILE {  //typeName = typeName+string(" ")+string($1);
                     $$ = terminal($1);
                   }
        | ATOMIC {   // typeName = typeName+string(" ")+string($1);
                     $$ = terminal($1);
                 }
        ;

function_specifier
        : INLINE{    //typeName = typeName+string(" ")+string($1);
                     $$ = terminal($1);
                }
        | NORETURN{    //typeName = typeName+string(" ")+string($1);
                     $$ = terminal($1);
                }
        ;



alignment_specifier
	: ALIGNAS '(' type_name ')'{yyerror("Error : alignment specifier not implemented");
				     $$ = nonTerminal("alignment_specifier", $1,NULL, $3);
				   }
	| ALIGNAS '(' constant_expression ')'{ yyerror("Error : alignment specifier not implemented");

					     $$ = nonTerminal("alignment_specifier",$1, NULL, $3);
					   }
	;

declarator
	: pointer direct_declarator {$$ = nonTerminal("declarator", NULL, $1, $2);
               if($2->exprType==1){$$->nodeType=$2->nodeType+$1->nodeType;
               $$->nodeKey = $2->nodeKey;
               $$->exprType=1;}
               if($2->exprType==2){ funcName = $2->nodeKey; funcType = $2->nodeType; }
                char* a = new char();
                strcpy(a,($$->nodeType).c_str());$$->size = getSize(a);
                        //------------------3AC---------------------------------//
                        $$->place = pair<string, sEntry*>($$->nodeKey, NULL);
                        //-------------------------------------------------------//
         }
	| direct_declarator {$$ = $1;if($1->exprType==2){ funcName=$1->nodeKey; funcType = $1->nodeType;

                            }
                        //------------------3AC---------------------------------//
                        $$->place = pair<string, sEntry*>($$->nodeKey, NULL);
                        //-------------------------------------------------------//
          }
	;

direct_declarator
	: IDENTIFIER{
                    $$=terminal($1);$$->exprType=1;$$->nodeKey=string($1);$$->nodeType=typeName; char* a =new char();
                strcpy(a,typeName.c_str()); $$->size = getSize(a);
                        //------------------3AC---------------------------------//
                        $$->place = pair<string, sEntry*>($$->nodeKey, NULL);
                        //-------------------------------------------------------//
			   }
	| '(' declarator ')' {$$ = $2;
                           if($2->exprType==1){ $$->exprType=1;
                                          $$->nodeKey=$2->nodeKey;
                                        //------------------3AC---------------------------------//
                                         $$->place = pair<string, sEntry*>($$->nodeKey, NULL);
                                       //-------------------------------------------------------//
                                          $$->nodeType=$2->nodeType;}
                           }
	| direct_declarator '[' ']' {$$ = nonTerminalSquareB("direct_declarator", $1);
                      if($1->exprType==1){ $$->exprType=1;
                                          $$->nodeKey=$1->nodeKey;
                                          $$->nodeType=$1->nodeType+string("*");}
                          char* a = new char();
                          strcpy(a,($$->nodeType).c_str());
                          $$->size = getSize(a);
                          strcpy(a,($1->nodeType).c_str());
                          $$->exprType=15;
                          $$->iVal=getSize(a);
                                  //------------------3AC---------------------------------//
                                   $$->place = pair<string, sEntry*>($$->nodeKey, NULL);
                                 //-------------------------------------------------------//
                               }
	| direct_declarator '[' '*' ']' {$$ = nonTerminalFourChild("direct_declarator", $1, NULL, NULL, NULL, $3);
          if($1->exprType==1){ $$->exprType=1;
                                          $$->nodeKey=$1->nodeKey;
                                          $$->nodeType=$1->nodeType+string("*");}

                          char* a = new char();
                          strcpy(a,($$->nodeType).c_str());
                          $$->size = getSize(a);
                        //------------------3AC---------------------------------//
                        $$->place = pair<string, sEntry*>($$->nodeKey, NULL);
                        //-------------------------------------------------------//
                            }
	| direct_declarator '[' STATIC type_qualifier_list assignment_expression ']'{
				temp = terminal($3);
				$$ = nonTerminalFourChild("direct_declarator", $1, temp, $4, $5, NULL);
           if($1->exprType==1){ $$->exprType=1;
                                          $$->nodeKey=$1->nodeKey;
                                          $$->nodeType=$1->nodeType+string("*");}

                 if($5->iVal){ $$->size =  $1->size*$5->iVal; }
                 else { char* a = new char();
                        strcpy(a,($$->nodeType).c_str());
                        $$->size = getSize(a); }
                        //------------------3AC---------------------------------//
                        $$->place = pair<string, sEntry*>($$->nodeKey, NULL);
                        //-------------------------------------------------------//
                          }
	| direct_declarator '[' STATIC assignment_expression ']' {
				temp = terminal($3);
				$$ = nonTerminalFourChild("direct_declarator", $1, temp, $4, NULL, NULL);
        if($1->exprType==1){ $$->exprType=1;
                                          $$->nodeKey=$1->nodeKey;
                                          $$->nodeType=$1->nodeType+string("*");}
                 if($4->iVal){ $$->size = $1->size *$4->iVal; }
                 else { char* a = new char();
                        strcpy(a,($$->nodeType).c_str());
                        $$->size = getSize(a); }
                        //------------------3AC---------------------------------//
                        $$->place = pair<string, sEntry*>($$->nodeKey, NULL);
                        //-------------------------------------------------------//

                          }
	| direct_declarator '[' type_qualifier_list '*' ']' {$$ = nonTerminalFourChild("direct_declarator", $1, $3, NULL, NULL, $4);
          if($1->exprType==1){ $$->exprType=1;
                                          $$->nodeKey=$1->nodeKey;
                                          $$->nodeType=$1->nodeType+string("*");}
                          char* a = new char();
                          strcpy(a,($$->nodeType).c_str());
                          $$->size = getSize(a);
                        //------------------3AC---------------------------------//
                        $$->place = pair<string, sEntry*>($$->nodeKey, NULL);
                        //-------------------------------------------------------//

         }
	| direct_declarator '[' type_qualifier_list STATIC assignment_expression ']' {

                          temp = terminal($4);
				$$ = nonTerminalFourChild("direct_declarator", $1, $3, temp, $5, NULL);
          if($1->exprType==1){ $$->exprType=1;
                                          $$->nodeKey=$1->nodeKey;
                                          $$->nodeType=$1->nodeType+string("*");}
                 if($5->iVal){ $$->size = $1->size * $5->iVal; }
                 else { char* a = new char();
                        strcpy(a,($$->nodeType).c_str());
                        $$->size = getSize(a); }
                        //------------------3AC---------------------------------//
                        $$->place = pair<string, sEntry*>($$->nodeKey, NULL);
                        //-------------------------------------------------------//

}
	| direct_declarator '[' type_qualifier_list assignment_expression ']'{$$ = nonTerminalFourChild("direct_declarator", $1, $3, $4, NULL, NULL);
          if($1->exprType==1){ $$->exprType=1;
                                          $$->nodeKey=$1->nodeKey;
                                          $$->nodeType=$1->nodeType+string("*");}
                 if($4->iVal){ $$->size = $1->size *$4->iVal; }
                 else { char* a = new char();
                        strcpy(a,($$->nodeType).c_str());
                        $$->size = getSize(a); }
                        //------------------3AC---------------------------------//
                        $$->place = pair<string, sEntry*>($$->nodeKey, NULL);
                        //-------------------------------------------------------//

}
	| direct_declarator '[' type_qualifier_list ']' {$$ = nonTerminal("direct_declarator", NULL, $1, $3);
          if($1->exprType==1){ $$->exprType=1;
                               $$->nodeKey=$1->nodeKey;
                                $$->nodeType=$1->nodeType+string("*");
                         char* a = new char();
                        strcpy(a,($$->nodeType).c_str());
                        $$->size = getSize(a);
           }
                        //------------------3AC---------------------------------//
                        $$->place = pair<string, sEntry*>($$->nodeKey, NULL);
                        //-------------------------------------------------------//

         }
	| direct_declarator '[' assignment_expression ']' {$$ = nonTerminal("direct_declarator", NULL, $1, $3);
         if($1->exprType==1){ $$->exprType=1;
                            $$->nodeKey=$1->nodeKey;
                            $$->nodeType=$1->nodeType+string("*");}
                 if($3->iVal){ $$->size = $1->size * $3->iVal; }
                 else { char* a = new char();
                        strcpy(a,($$->nodeType).c_str());
                        $$->size = getSize(a); }
                        //------------------3AC---------------------------------//
                        $$->place = pair<string, sEntry*>($$->nodeKey, NULL);
                        //-------------------------------------------------------//

        }
	| direct_declarator '(' E3 parameter_type_list ')' M
         {
         $$ = nonTerminal("direct_declarator", NULL, $1, $4);
          if($1->exprType==1){ $$->nodeKey=$1->nodeKey;
                           $$->exprType=2;
                           $$->nodeType=$1->nodeType;
                           insertFuncArguments($1->nodeKey,funcArguments);
                           funcArguments=string("");
                         char* a = new char();
                        strcpy(a,($$->nodeType).c_str());
                        $$->size = getSize(a);
                           }
                        //------------------3AC---------------------------------//
                        $$->place = pair<string, sEntry*>($$->nodeKey, NULL);
                        backPatch($4->nextlist, $6);
                        if( !(($$->nodeKey == "odd" && tempodd == 0) || ($$->nodeKey == "even" && tempeven == 0)) ){string em =  "func " + $$->nodeKey+ " begin:";
                        emit(pair<string , sEntry*>(em, NULL), pair<string , sEntry*>("", NULL),pair<string , sEntry*>("", NULL),pair<string , sEntry*>("", NULL),-2);}
                        if($$->nodeKey == "odd" ){
                           tempodd = 1;
                        }
                        if($$->nodeKey == "even" ){
                           tempeven = 1;
                        }
                        //-------------------------------------------------------//
               }
	| direct_declarator '(' E3 ')'
         {
          $$ = nonTerminalRoundB("direct_declarator", $1);
          if($1->exprType==1){
                          $$->nodeKey=$1->nodeKey;
                          insertFuncArguments($1->nodeKey,string(""));
                          $$->exprType=2;
                          funcArguments = string("");
                          }
                       $$->nodeType=$1->nodeType;
                         char* a = new char();
                        strcpy(a,($$->nodeType).c_str());
                        $$->size = getSize(a);
                        //------------------3AC---------------------------------//
                        $$->place = pair<string, sEntry*>($$->nodeKey, NULL);
                        string em =  "func " + $$->nodeKey+ " begin:";
                        emit(pair<string , sEntry*>(em, NULL), pair<string , sEntry*>("", NULL),pair<string , sEntry*>("", NULL),pair<string , sEntry*>("", NULL),-2);
                        //-------------------------------------------------------//
                     }
	| direct_declarator '(' E3 identifier_list ')' {$$ = nonTerminal("direct_declarator", NULL, $1, $4);
                         char* a = new char();
                        strcpy(a,($$->nodeType).c_str());
                        $$->size = getSize(a);
                        //------------------3AC---------------------------------//
                        $$->place = pair<string, sEntry*>($$->nodeKey, NULL);
                        string em =  "func " + $$->nodeKey+ " begin:";
                        emit(pair<string , sEntry*>(em, NULL), pair<string , sEntry*>("", NULL),pair<string , sEntry*>("", NULL),pair<string , sEntry*>("", NULL),-2);
                        //-------------------------------------------------------//
          }
	;

E3
   : %empty                 {   typeName =string("");
                          funcArguments = string("");
                           paramTable();  }
    ;

pointer
	: '*' type_qualifier_list pointer {$$=nonTerminal("*",NULL,$2,$3);$$->nodeType=string("*")+$3->nodeType;}
	| '*' type_qualifier_list  {$$=nonTerminal("*",NULL,$2,NULL);$$->nodeType=string("*");}
	| '*' pointer   {$$=nonTerminal("*",NULL,$2,NULL);$$->nodeType=string("*")+$2->nodeType;}
	| '*'          {$$=terminal("*");$$->nodeType=string("*");}
	;


type_qualifier_list
	: type_qualifier {$$=$1;}
	| type_qualifier_list type_qualifier {$$=nonTerminal("type_qualifier_list",NULL,$1,$2);}
	;


parameter_type_list
	: parameter_list ',' ELLIPSIS {
                                        funcArguments = funcArguments+string(",...");
					temp = terminal($3);
					$$=nonTerminal("parameter_type_list",NULL,$1,temp);
                                        $$->nextlist=$1->nextlist;
				      }
	| parameter_list {$$=$1;}
	;

parameter_list
	: parameter_declaration {$$=$1;}
	| parameter_list ',' M  parameter_declaration {$$=nonTerminal("parameter_list",NULL,$1,$4);
                                                      //----------------3AC--------------//
                                                       backPatch($1->nextlist,$3);
                                                       $$->nextlist=$4->nextlist;
                                                      //---------------------------------//
                                                      }
	;

parameter_declaration
	: declaration_specifiers declarator {typeName=string("");
          //paramTable();
         if($2->exprType==1){ char *t=new char();
                     strcpy(t,($2->nodeType).c_str());
                     char *key =new char();
                     strcpy(key,($2->nodeKey).c_str());
                  if(scopeLookup($2->nodeKey)){ yyerror("Error: redeclaration of %s",key);}
                   else {  insertSymbol(*curr,key,t,$2->size,0,1);}
                if(funcArguments==string(""))funcArguments=($2->nodeType);
               else funcArguments= funcArguments+string(",")+($2->nodeType);
                     }


         $$=nonTerminal("parameter_declaration",NULL,$1,$2);}
	| declaration_specifiers abstract_declarator {typeName=string("");$$=nonTerminal("parameter_declaration",NULL,$1,$2);}
	| declaration_specifiers {typeName=string("");$$=$1;}
	;

identifier_list
	: IDENTIFIER                  {
					$$=terminal($1);
				      }
	| identifier_list ',' IDENTIFIER {
					temp = terminal($3);
					$$=nonTerminal("identifier_list",NULL,$1,temp);
				      }
	;

type_name
	: specifier_qualifier_list abstract_declarator {$$=nonTerminal("type_name",NULL,$1,$2);}
	| specifier_qualifier_list {$$=$1;}
	;

abstract_declarator
	: pointer direct_abstract_declarator {$$=nonTerminal("abstract_declarator",NULL,$1,$2);}
	| pointer {$$=$1;}
	| direct_abstract_declarator {$$=$1;}
	;

direct_abstract_declarator
	: '(' abstract_declarator ')'  {$$ = $2;}
	| '[' ']'  {$$ = terminal("[ ]");}
	| '[' '*' ']' {$$ = terminal("[ * ]");}
	| '[' STATIC type_qualifier_list assignment_expression ']' {
							             temp = terminal($2);
								     $$ = nonTerminal2("direct_abstract_declarator", temp, $3, $4);
								   }
	| '[' STATIC assignment_expression ']'                     {
							             temp = terminal($2);
								     $$ = nonTerminal2("direct_abstract_declarator", temp, $3, NULL);
								   }
	| '[' type_qualifier_list STATIC assignment_expression ']'{
							             temp = terminal($3);
								     $$ = nonTerminal2("direct_abstract_declarator", $2, temp, $4);
								   }
	| '[' type_qualifier_list assignment_expression ']' {$$ = nonTerminal("direct_abstract_declarator", NULL, $2, $3);}
	| '[' type_qualifier_list ']' {$$ = $2;}
	| '[' assignment_expression ']'{$$ = $2;}
	| direct_abstract_declarator '[' ']' {$$ = nonTerminal("direct_abstract_declarator" , "[ ]", $1,NULL);}
	| direct_abstract_declarator '[' '*' ']' {$$ = nonTerminal("direct_abstract_declarator", "\[ \* \]", $1, NULL);}
	| direct_abstract_declarator '[' STATIC type_qualifier_list assignment_expression ']'{
				temp = terminal($3);
				$$ = nonTerminalFourChild("direct_abstract_declarator", $1, temp, $4, $5, NULL);
                          }
	| direct_abstract_declarator '[' STATIC assignment_expression ']'{
				temp = terminal($3);
				$$ = nonTerminalFourChild("direct_abstract_declarator", $1, temp, $4, NULL, NULL);
                          }
	| direct_abstract_declarator '[' type_qualifier_list assignment_expression ']' {$$ = nonTerminal2("direct_abstract_declarator", $1, $3, $4);}
	| direct_abstract_declarator '[' type_qualifier_list STATIC assignment_expression ']'{
				temp = terminal($4);
				$$ = nonTerminalFourChild("direct_abstract_declarator", $1, $3, temp,  $5, NULL);
                          }
	| direct_abstract_declarator '[' type_qualifier_list ']' {$$ = nonTerminal("direct_abstract_declarator",NULL, $1, $3);}
	| direct_abstract_declarator '[' assignment_expression ']' {$$ = nonTerminal("direct_abstract_declarator",NULL, $1, $3);}
	| '(' ')'  {$$ = terminal("( )");}
	| '(' parameter_type_list ')' {$$ = $2;}
	| direct_abstract_declarator '(' ')'{$$ = nonTerminal("direct_abstract_declarator","( )", $1,NULL);}
	| direct_abstract_declarator '(' parameter_type_list ')' {$$ = nonTerminal("direct_abstract_declarator", NULL, $1, $3);}
	;

initializer
	: '{' initializer_list '}' {$$ = $2; $$->nodeType = $2->nodeType+string("*");
                                   }
	| '{' initializer_list ',' '}' {$$ = nonTerminal("initializer", $3, $2 ,NULL); $$->nodeType = $2->nodeType+string("*"); $$->exprType =$2->exprType;
                                     //--------------3AC--------------------//
                                        $$->place = $2->place;
                                        $$->nextlist = $2->nextlist;
                                     //-------------------------------------//
                                        }
	| assignment_expression {$$ = $1;}
	;

initializer_list
	: designation M initializer {
           $$ = nonTerminal("initializer_list", NULL, $1 ,$3);
           $$->nodeType = $3->nodeType;
           char* a =validAssign($1->nodeType,$3->nodeType);
               if(a){
                    if(!strcmp(a,"true")){ ; }
                    if(!strcmp(a,"warning")){
                         yyerror("Warning: Assignment with incompatible pointer type");
                         }
                    }
                else{ yyerror("Error: Incompatible types when assigning type \'%s\' to \'%s\' ",($1->nodeType).c_str(),($3->nodeType).c_str()); }
           $$->exprType = 1;
                                     //--------------3AC--------------------//
                                        $$->place = $3->place;
                                        backPatch($1->nextlist, $2);
                                        $$->nextlist = $3->nextlist;
                                     //-------------------------------------//
        }
	| initializer {$$ = $1;$$->exprType=1;}
	| initializer_list ',' M designation initializer {
          $$ = nonTerminal2("initializer_list", $1, $4 ,$5);
          $$->nodeType = $1->nodeType;
           char* a =validAssign($4->nodeType,$5->nodeType);
               if(a){
                    if(!strcmp(a,"true")){ ; }
                    if(!strcmp(a,"warning")){ ;
                         yyerror("Warning: Assignment with incompatible pointer type");
                         }
                     }
                else{ yyerror("Error: Incompatible types when assigning type \'%s\' to \'%s\' ",($4->nodeType).c_str(),($5->nodeType).c_str()); }
            a =validAssign($1->nodeType,$5->nodeType);
               if(a){
                    if(!strcmp(a,"true")){ ; }
                    if(!strcmp(a,"warning")){ ;
                         yyerror("Warning: Assignment with incompatible pointer type");
                         }
                     }
                else{ yyerror("Error: Incompatible types when initializing type \'%s\' to \'%s\' ",($1->nodeType).c_str(),($5->nodeType).c_str()); }

            $$->exprType =$1->exprType+1;
                                     //--------------3AC--------------------//
                                        backPatch($1->nextlist, $3);
                                        $$->nextlist = $5->nextlist;
                                     //-------------------------------------//
          }
	| initializer_list ',' M  initializer {
          $$ = nonTerminal("initializer_list", NULL, $1 ,$4);
          $$->nodeType = $1->nodeType;
           char* a =validAssign($1->nodeType,$4->nodeType);
               if(a){
                    if(!strcmp(a,"true")){ ; }
                    if(!strcmp(a,"warning")){ ;
                         yyerror("Warning: Assignment with incompatible pointer type");
                         }
                     }
                else{ yyerror("Error: Incompatible types when initializing type \'%s\' to \'%s\' ",($1->nodeType).c_str(),($4->nodeType).c_str()); }
           $$->exprType = $1->exprType+1;
                                     //--------------3AC--------------------//
                                        backPatch($1->nextlist, $3);
                                        $$->nextlist = $4->nextlist;
                                     //-------------------------------------//
        }
	;

designation
	: designator_list '='  {
           $$ = nonTerminal("designation", "=", $1 ,NULL);
           $$->nodeType = $1->nodeType=1;
           //--------3AC-------------//
              $$->place= $1->place;
              $$->nextlist=$1->nextlist;
           //--------------------------//
           }
	;

designator_list
	: designator  {$$ = $1;}
	| designator_list designator  {$$ = nonTerminal("designator_list", NULL, $1 ,$2); $$->nodeType = $2->nodeType;}
	;

designator
	: '[' constant_expression ']'  {$$ = $2;}
	| '.' IDENTIFIER   {
				temp = terminal($2);
				$$ = nonTerminal("designator", $1, NULL, temp);
			   }
	;

static_assert_declaration
	: STATIC_ASSERT '(' constant_expression ',' STRING_LITERAL ')' ';' {
				temp = terminal($1);
				temp1 = terminal($5);
				$$ = nonTerminal2("static_assert_declaration", temp, $3, temp1);
			   }
	;

statement
        : labeled_statement  {$$ = $1;}
        | compound_statement  {$$ = $1;}
        | expression_statement  {$$ = $1;}
        | selection_statement  {$$ = $1;}
        | iteration_statement  {$$ = $1;}
        | jump_statement  {$$ = $1;}
        ;
M5
  : CASE constant_expression ':' {
                                  $$=$2;
                                //-----------3AC--------------------//
                                 qid t = getTmpSym("bool");
                                 int k = emit(pair<string, sEntry*>("EQ_OP", lookup("\=\=")),pair<string, sEntry*>("", NULL), $2->place, t, -1);
                                 int k1 = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("IF", lookup("if")), t, pair<string, sEntry*>("", NULL ),0);
                                 int k2 = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL ),0);
                                 $$->caselist.push_back(k);
                                 $$->truelist.push_back(k1);
                                 $$->falselist.push_back(k2);
                               //-----------------------------------//


   }
  ;

labeled_statement
        : IDENTIFIER ':' M statement {
                                temp = terminal($1);
                                $$ = nonTerminal("labeled_statement", NULL, temp, $4);
                                //===========3AC======================//
                                 if(!gotoIndexStorage($1, $3)){
                                     yyerror("ERROR:\'%s\' is already defined", $1);

                                }  $$->nextlist = $4->nextlist;
                                   $$->caselist = $4->caselist;
                                   $$->continuelist = $4->continuelist;
                                   $$->breaklist = $4->breaklist;
                                //=====================================//

                           }
        | M5 M statement {
                                temp = terminal("case");
                                $$ = nonTerminal2("labeled_statement", temp, $1, $3);
                                //-----------3AC--------------------//
                                  backPatch($1->truelist, $2);
                                  $3->nextlist.merge($1->falselist);
                                  $$->breaklist = $3->breaklist;
                                  $$->nextlist = $3->nextlist;
                                  $$->caselist = $1->caselist;
                                  $$->continuelist=$3->continuelist;
                               //-----------------------------------//
                           }
        | DEFAULT ':' statement {
                                temp = terminal($1);
                                $$ = nonTerminal("labeled_statement", NULL, temp, $3);
                               //---------3AC-----------------------//
                                 $$->breaklist= $3->breaklist;
                                 $$->nextlist = $3->nextlist;
                                 $$->continuelist=$3->continuelist;
                               //----------------------------------//
                           }
        ;

compound_statement
	: '{' '}'   {isFunc=0;$$ = terminal("{ }"); $$->rVal = -5;}
	| E1  block_item_list '}'  {if(blockSym){ string s($1);
                                    s=s+string(".csv");
                                    string u($1);
                                    //printSymTables(curr,s);
                                    //updateSymTable(u); blockSym--;
                                 } $$ = $2;
                               }
	;
E1
    :  '{'       { if(isFunc==0) {symNumber++;
                        symFileName = /*string("symTableFunc")+to_string(funcSym)*/funcName+string("Block")+to_string(symNumber);
                        //scope=S_BLOCK;
                        //makeSymTable(symFileName,scope,string("12345"));
                        char * y=new char();
                        strcpy(y,symFileName.c_str());
                        $$ = y;
                        //blockSym++;
                        }
                       isFunc=0;
              }

    ;

block_item_list
	: block_item  {$$ = $1;}
	| block_item_list M block_item  {$$ = nonTerminal("block_item_list", NULL, $1, $3);
                                      //---------------3AC--------------------//
                                         backPatch($1->nextlist, $2);
                                         $$->nextlist = $3->nextlist;
                                         $1->caselist.merge($3->caselist);
                                         $$->caselist = $1->caselist;
                                         $1->continuelist.merge($3->continuelist);
                                         $1->breaklist.merge($3->breaklist);
                                         $$->continuelist = $1->continuelist;
                                         $$->breaklist = $1->breaklist;
                                      //----------------------------------------//
                                      }
	;

block_item
	: declaration {$$ = $1;}
	| statement {$$ = $1;}
	;

expression_statement
	: ';' {$$ = terminal(";");}

	| expression ';' {$$ =  $1 ;}
	;

M4
  :  IF '(' expression ')' {
                        if($3->truelist.begin()==$3->truelist.end()){
                            int k = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("IF", lookup("if")), $3->place, pair<string, sEntry*>("", NULL ),0);
                            int k1 = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL ),0);
                            $3->truelist.push_back(k);
                            $3->falselist.push_back(k1);

                        }
                        $$ = $3;
  }
  ;

GOTO_emit
   : %empty {

                           $$ = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL ),0);
   }
   ;

selection_statement
        : M4 M statement GOTO_emit ELSE M statement {
                                                           $$ = nonTerminal2("IF (expr) stmt ELSE stmt", $1, $3, $7);
                                                          //----------3AC---------------------//
                                                            backPatch($1->truelist, $2);
                                                            backPatch($1->falselist, $6);
                                                            $3->nextlist.push_back($4);
                                                            $3->nextlist.merge($7->nextlist);
                                                            $$->nextlist=$3->nextlist;
                                                            $3->breaklist.merge($7->breaklist);
                                                            $$->breaklist = $3->breaklist;
                                                            $3->continuelist.merge($7->continuelist);
                                                            $$->continuelist = $3->continuelist;
                                                         //-----------------------------------//
                                                         }
        | M4 M statement {
                                           $$ = nonTerminal2("IF (expr) stmt", NULL, $1, $3);
                                           //---------------3AC-------------------//
                                               backPatch($1->truelist, $2);
                                               $3->nextlist.merge($1->falselist);
                                               $$->nextlist= $3->nextlist;
                                               $$->continuelist = $3->continuelist;
                                               $$->breaklist = $3->breaklist;
                                           //------------------------------------//

                                         }
        | SWITCH '(' expression ')' statement{
                                           $$ = nonTerminal2("SWITCH (expr) stmt", NULL, $3, $5);
                                           //--------------3AC---------------------------//
                                              setListId1($5->caselist, $3->place);
                                              $5->nextlist.merge($5->breaklist);
                                              $$->nextlist= $5->nextlist;
                                              $$->continuelist= $5->continuelist;
                                          //---------------------------------------------//
                                         }
        ;


M6
  :   expression  {
                        if($1->truelist.begin()==$1->truelist.end()){
                            int k = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("IF", lookup("if")), $1->place, pair<string, sEntry*>("", NULL ),0);
                            int k1 = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL ),0);
                            $1->truelist.push_back(k);
                            $1->falselist.push_back(k1);

                        }
                        $$ = $1;
  }
  ;


M7
  :   expression_statement  {
                        if($1->truelist.begin()==$1->truelist.end()){
                            int k = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("IF", lookup("if")), $1->place, pair<string, sEntry*>("", NULL ),0);
                            int k1 = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL ),0);
                            $1->truelist.push_back(k);
                            $1->falselist.push_back(k1);

                        }
                        $$ = $1;
  }
  ;

iteration_statement
        : WHILE '(' M M6 ')' M statement GOTO_emit {
                                           $$ = nonTerminal2("WHILE (expr) stmt", NULL, $4, $7);
                                           //-----------3AC------------------//
                                             backPatch($4->truelist, $6);
                                             $7->continuelist.push_back($8);
                                             backPatch($7->continuelist, $3);
                                             backPatch($7->nextlist, $3);
                                             $$->nextlist = $4->falselist;
                                             $$->nextlist.merge($7->breaklist);
                                           //--------------------------------//

                                         }
        | DO M  statement  WHILE '(' M  M6 ')' ';'{
                                                     $$ = nonTerminal2("DO stmt WHILE (expr)", NULL, $3, $7);
                                                   //--------3AC-------------------------//
                                                      backPatch($7->truelist, $2);
                                                      backPatch($3->continuelist, $6);
                                                      backPatch($3->nextlist, $6);
                                                      $7->falselist.merge($3->breaklist);
                                                      $$->nextlist = $7->falselist;
                                                   //-----------------------------------//
                                                   }
        | FOR '(' expression_statement M M7 ')' M statement GOTO_emit  {
                                           $$ = nonTerminal2("FOR (expr_stmt expr_stmt) stmt", $3, $5, $8);
                                           //-------------3AC-------------------//
                                             backPatch($3->nextlist, $4);
                                             backPatch($5->truelist, $7);
                                             $5->falselist.merge($8->breaklist);
                                             $$->nextlist = $5->falselist;
                                             $8->nextlist.merge($8->continuelist);
                                             $8->nextlist.push_back($9);
                                             backPatch($8->nextlist, $4 );
                                          //------------------------------------//
                                         }
        | FOR '(' expression_statement M M7 M expression GOTO_emit ')' M statement GOTO_emit {
                                           $$ = nonTerminalFiveChild("FOR (expr_stmt expr_stmt expr) stmt", NULL, $3, $5, $7, $11);
                                           //-------------3AC-------------------//
                                             backPatch($3->nextlist, $4);
                                             backPatch($5->truelist, $10);
                                             $5->falselist.merge($11->breaklist);
                                             $$->nextlist = $5->falselist;
                                             $11->nextlist.merge($11->continuelist);
                                             $11->nextlist.push_back($12);
                                             backPatch($11->nextlist, $6 );
                                             $7->nextlist.push_back($8);
                                             backPatch($7->nextlist, $4);
                                          //------------------------------------//
                                         }
        | FOR '(' declaration M M7 ')' M statement GOTO_emit  {
                                           $$ = nonTerminal2("FOR ( decl expr_stm ) stmt", $3, $5, $8);
                                           //-------------3AC-------------------//
                                             backPatch($3->nextlist, $4);
                                             backPatch($5->truelist, $7);
                                             $5->falselist.merge($8->breaklist);
                                             $$->nextlist = $5->falselist;
                                             $8->nextlist.merge($8->continuelist);
                                             $8->nextlist.push_back($9);
                                             backPatch($8->nextlist, $4 );
                                          //------------------------------------//
                                         }
        | FOR '(' declaration M M7 M expression GOTO_emit ')' M  statement GOTO_emit {
                                           $$ = nonTerminalFiveChild("FOR ( decl expr_stmt expr ) stmt", NULL, $3, $5, $7, $11);
                                           //-------------3AC-------------------//
                                             backPatch($3->nextlist, $4);
                                             backPatch($5->truelist, $10);
                                             $5->falselist.merge($11->breaklist);
                                             $$->nextlist = $5->falselist;
                                             $11->nextlist.merge($11->continuelist);
                                             $11->nextlist.push_back($12);
                                             backPatch($11->nextlist, $6 );
                                             $7->nextlist.push_back($8);
                                             backPatch($7->nextlist, $4);
                                          //------------------------------------//
                                         }
        ;

jump_statement
        : GOTO IDENTIFIER ';' {
                                temp = terminal($1);
                                temp1 = terminal($2);
                                $$ = nonTerminal("jump_statement", NULL, temp, temp1);
                                //-----------3AC---------------------//
                                 int k = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL ),0);
                                 gotoIndexPatchListStorage($2, k);
                                //-----------------------------------//
                              }
        | CONTINUE ';'        {
                                $$ = terminal("continue");
                                //-----------3AC---------------------//
                                 int k = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL ),0);
                                 $$->continuelist.push_back(k);
                               //-----------------------------------//
                              }
        | BREAK ';'           {
                                $$ = terminal("break");
                                //-----------3AC---------------------//
                                 int k = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL ),0);
                                 $$->breaklist.push_back(k);
                               //-----------------------------------//

                              }
        | RETURN ';'          {
                                $$ = terminal("return");
                              //------------3AC----------------//

                                  emit(pair<string, sEntry*>("RETURN", lookup("return")),pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL ),-1);
                              //------------------------------//
                              }
        | RETURN expression ';' {
                                  temp = terminal("return");
                                    $$ = nonTerminal("jump_statement", NULL, temp, $2);
                              //------------3AC----------------//

                                  emit(pair<string, sEntry*>("RETURN", lookup("return")), $2->place, pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL ),-1);
                              //------------------------------//
                                }
        ;


translation_unit
	: external_declaration  {$$ = $1;}
	| translation_unit M external_declaration  {$$ = nonTerminal("translation_unit", NULL, $1, $3);
                                                   //----------3Ac----------------//
                                                      backPatch($1->nextlist, $2);
                                                      $$->nextlist = $3->nextlist;
                                                   //------------------------------//
                                                   }
	;

external_declaration
	: function_definition  {typeName=string("");$$ = $1;}
	| declaration  {typeName=string("");$$ = $1;}
	;

function_definition
	: declaration_specifiers declarator E2 declaration_list compound_statement
         {      typeName=string("");
                string s($3);
                string u = s+string(".csv");
                printSymTables(curr,u);
                symNumber=0;
               updateSymTable(s);
                $$ = nonTerminalFourChild("function_definition", $1, $2, $4, $5, NULL);
               //--------------------3AC--------------------------------//
                        if($5->rVal != -5){ string em =  "func end";
                        emit(pair<string , sEntry*>(em, NULL), pair<string , sEntry*>("", NULL),pair<string , sEntry*>("", NULL),pair<string , sEntry*>("", NULL),-3);}
               //------------------------------------------------------//
         }
	| declaration_specifiers declarator E2 compound_statement  {
              typeName=string("");
              string s($3);string u =s+string(".csv");
              printSymTables(curr,u);
              symNumber=0;
              updateSymTable(s);
              $$ = nonTerminal2("function_definition", $1, $2, $4);
               //--------------------3AC--------------------------------//
                if($4->rVal != -5){string em =  "func end";
                emit(pair<string , sEntry*>(em, NULL), pair<string , sEntry*>("", NULL),pair<string , sEntry*>("", NULL),pair<string , sEntry*>("", NULL),-3); }
               //------------------------------------------------------//
             }
	;

E2
    : %empty                { typeName=string("");scope = S_FUNC;
                                         isFunc = 1;
                                         funcSym++;
                                         symFileName = funcName;//string("symTableFunc")+to_string(funcSym);
                                         makeSymTable(symFileName,scope,funcType);
                                         char* y= new char();
                                         strcpy(y,symFileName.c_str());
                                         $$ = y;
       }
    ;

declaration_list
	: declaration {$$ = $1;}
	| declaration_list M declaration {$$ = nonTerminal("declaration_list", NULL, $1, $3);
                           //--------3AC--------------//
                             backPatch($1->nextlist, $2);
                             $$->nextlist = $3->nextlist;
                          //--------------------------//
          }
	;

%%

void helpMessage(){
  printf("Specify an input file with -i flag\n");
  printf("Specify an output file with -o flag\n");
  return;
}

extern FILE *yyin;

int main(int argc,char **argv){
  if(argc==1){
    helpMessage();
    return 0;
  }
  tempodd =0;
  tempeven =0; 
  yyin=NULL;
  int fileflag = 0;
  // command line options
  int argCount;
  for(argc--, argv++; argc>0; argc-=argCount, argv += argCount){
    argCount = 1;
    if(!strcmp(*argv, "-h")){
      helpMessage();
      return 0;
    }
    else if(!strcmp(*argv, "-o")){
      if (argc > 1){
        digraph =fopen(*(argv+1),"w");
        fileflag = 1;
      }
      else {
        helpMessage();
        return 0;
      }
    }
    else if(!strcmp(*argv, "-i")){
      if (argc > 1){
        yyin =fopen(*(argv+1),"r");
        strncpy(filename,*(argv+1),1024);
      }
      else {
        helpMessage();
        return 0;
      }
    }

}
  if(yyin == NULL) {
    helpMessage();
    return 0;
  }
  char ch;
  funcName = string("GST");
  duplicate = fopen("duplicate.txt","w");
  while( ( ch = fgetc(yyin) ) != EOF ){
        fputc(ch, duplicate);
  }
  fclose(duplicate);
  fclose(yyin);
  yyin=fopen(filename,"r");
  // default output file
  if(fileflag == 0)
  digraph =fopen("digraph.gv","w");
  currArguments = string("");
  stInitialize();
  graphInitialization();
  yyparse();
  char* gotoError = backPatchGoto();
 if(gotoError)
    yyerror("ERROR: '\%s'\ label used but not defined\n", gotoError);

graphEnd();
  display3ac();
  resetRegister();
  generateCode();
  printCode();
  symFileName = "GST.csv";
  printSymTables(curr,symFileName);
  printFuncArguments();
  return 0;
}
void yyerror(char *s,...){
  va_list args;
  char buffer[MAX_STR_LEN];

va_start(args,s);
  vsnprintf(buffer,MAX_STR_LEN-1,s,args);
  va_end(args);


int count = 1;
  if(s=="syntax error") count = 2;
  fprintf(stderr,"%s : %d :: %s\n",filename,yylineno,buffer);
  duplicate=fopen("duplicate.txt","r");
  if ( duplicate != NULL )
  {
    char line[256]; /* or other suitable maximum line size */
    while (fgets(line, sizeof line, duplicate) != NULL) /* read a line */
    {
        if (count == yylineno)
        {
            fprintf(stderr,"\t%s\n",line);
            break;
        }
        else
        {
            count++;
        }
    }
    fclose(duplicate);
}
else
{
    //file doesn't exist
}

}

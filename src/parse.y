%{
#include <iostream>
#include <cstring>
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
#include "nodes.h"
#include "symTable.h"
#include "typeCheck.h"
FILE *digraph;
FILE *duplicate;
node *temp,*temp1,*temp2;
char filename[1000];
string typeName="";
extern int yylineno;
string symFileName;
string funcName;
string funcType;
string funcArguments;
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
%type <str> assignment_operator E1 E2 E3

%start translation_unit 

%left <str> ',' '^' '|' ';' '{' '}' '[' ']' '(' ')' '+' '-' '%' '/' '*' '.' '>' '<' SIZEOF
%right <str> '&' '=' '!' '~' ':' '?'

%type <ptr> multiplicative_expression additive_expression cast_expression primary_expression expression assignment_expression postfix_expression unary_expression shift_expression relational_expression equality_expression and_expression exclusive_or_expression inclusive_or_expression logical_or_expression logical_and_expression conditional_expression constant_expression
%type <ptr> constant string generic_selection enumeration_constant
%type <ptr> generic_assoc_list generic_association type_name argument_expression_list initializer_list
%type <ptr> unary_operator
%type <ptr> declaration declaration_specifiers
%type <ptr> init_declarator_list static_assert_declaration storage_class_specifier type_specifier function_specifier type_qualifier alignment_specifier
%type <ptr> init_declarator declarator initializer atomic_type_specifier struct_or_union_specifier enum_specifier struct_or_union struct_declaration_list
%type <ptr> struct_declaration specifier_qualifier_list struct_declarator_list struct_declarator enumerator_list enumerator enumerator_constant pointer
%type <ptr> direct_declarator type_qualifier_list parameter_type_list identifier_list parameter_list parameter_declaration
%type <ptr> abstract_declarator direct_abstract_declarator designation designator_list designator labeled_statement compound_statement expression_statement declaration_list
%type <ptr> selection_statement iteration_statement jump_statement block_item_list block_item external_declaration translation_unit function_definition statement jump_statement_error


%%

primary_expression
  : IDENTIFIER                    {$$=terminal($1);
				    char* a = primaryExpr($1);
				    if (a) {string as(a);
                                         $$->isInit = lookup($1)->is_init;
                                         $$->nodeType=as;
                                         string key($1);
                                         $$->nodeKey = key;
                                         $$->exprType = 3; }
				    else{ yyerror("Error: %s is not declared in this scope", $1);
                                      $$->nodeType = string("");}
				  }
  | constant                      {$$=$1; }
  | string                        {$$=$1; }
  | '(' expression ')'            {$$=$2; }
  | generic_selection             {$$=$1; }
  ;

constant
  : I_CONSTANT                    {$$=terminal($1->str); 
				   char * a = constant($1->nType);
                                   $$->isInit=1;
                                   string as(a);
				   $$->nodeType=as;			
				   }
  | F_CONSTANT                    {$$=terminal($1->str);
                                   char * a = constant($1->nType);
                                   $$->isInit =1;
                                   string as(a);
                                   $$->nodeType=as;
                                   }
  | ENUMERATION_CONSTANT           {$$=terminal($1);
                              $$->isInit=1;
                             $$->nodeType=string("ENUMERATION_CONSTANT");}
  ;
enumeration_constant    /* before it has been defined as such */
  : IDENTIFIER                    {$$=terminal($1);}
  ;

string
  : STRING_LITERAL                {$$=terminal($1); $$->nodeType = string("char*"); $$->isInit =1; }
  | FUNC_NAME                     {$$=terminal($1); $$->nodeType = string(); $$->isInit=1;}
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
  | DEFAULT ':' assignment_expression        {temp = terminal("DEFAULT"); $$ = nonTerminal2("generic_association", temp, $3, NULL);} 
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
	  }
	  else {
		  yyerror("Error: Invalid Function call");
	  }

  }
  | postfix_expression '(' argument_expression_list ')'   {$$ = nonTerminal("postfix_expression", NULL, $1, $3); 
          if($3->isInit==1) $$->isInit=1;
	  char* s = postfixExpr($1->nodeType, 3);
	  if(s){
		  string as(s); 
		  $$->nodeType =as;
	  }
	  else {
		  yyerror("Error: Invalid Function call");
	  }
} 
  | postfix_expression '.' IDENTIFIER       {
                                                temp = terminal($3);
                                                $$ = nonTerminal("postfix_expression.IDENTIFIER",NULL, $1, temp);
                             

                                            }    
  | postfix_expression PTR_OP IDENTIFIER    {
                                                temp=terminal($3);
                                                $$ = nonTerminal($2,NULL, $1, temp);
                                            }
  | postfix_expression INC_OP               {

                                               $$=  nonTerminal($2, NULL,$1, NULL);
         if($1->isInit==1) $$->isInit=1;
	  char* s = postfixExpr($1->nodeType, 6);
	  if(s){
		  string as(s); 
		  $$->nodeType =as;
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
          } 
  | argument_expression_list ',' assignment_expression
	    {
             $$ = nonTerminal("argument_expression_list",NULL, $1, $3);
	     char* a =  argumentExpr($1->nodeType, $3->nodeType, 2);
		string as(a);
		$$->nodeType = as;
		if($1->isInit == 1 && $3->isInit==1) $$->isInit=1;

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
	  }
	  else {
		  yyerror("Error: Increment not defined for this type");
	  }

  } 

  | DEC_OP unary_expression       {
       	  $$=  nonTerminal($1, NULL,NULL, $2); 
	  if($2->isInit == 1 ) $$->isInit=1;
	  char* s = postfixExpr($2->nodeType, 7);
	  if(s){
		  string as(s); 
		  $$->nodeType =as;
	  }
	  else {
		  yyerror("Error: Decrement not defined for this type");
	  }

  }
  | unary_operator cast_expression { 
		$$ = nonTerminal("unary_expression", NULL, $1, $2);
		if( $2->isInit==1) $$->isInit=1;
		char* a= unaryExpr($1->name, $2->nodeType, 1);
		if(a){
		    string as(a);
		    $$->nodeType= as;
		}
		else{
		    yyerror("Error: Type inconsistent with operator %s", $1->name.c_str());
		}
 	}
  | SIZEOF unary_expression       {
                                $$=  nonTerminal($1, NULL,NULL, $2);
				$$->nodeType = string("int");
				$$->isInit=1;

                                   }
  | SIZEOF '(' type_name ')'   {
                                   $$=  nonTerminal($1, NULL,NULL, $3);
				   $$->nodeType = string("int");
				   $$->isInit=1;
                                   }
  | ALIGNOF '(' type_name ')'   {
	  $$=  nonTerminal($1, NULL,NULL, $3);
	  $$->nodeType = string("int");
	  $$->isInit=1;
                                   }
  ;

unary_operator
  : '&'      { $$ = terminal("&");}
  | '*'      { $$ = terminal("*");}
  | '+'      { $$ = terminal("+");}
  | '-'      { $$ = terminal("-");}
  | '~'      { $$ = terminal("~");}
  | '!'      { $$ = terminal("!");}
  ;
      
cast_expression
        : unary_expression        {$$ = $1;}
        | '(' type_name ')' cast_expression 
		{
			$$ = nonTerminal("cast_expression", NULL, $2, $4);
			$$->nodeType = $2->nodeType;
			if($4->isInit==1) $$->isInit=1;
		}
        ;

multiplicative_expression
        : cast_expression                                     {$$=$1;}
        | multiplicative_expression '*' cast_expression       {
            char* a=multilplicativeExpr($1->nodeType, $3->nodeType, '*');
           if(a){ if(strcmp(a,"int")==0){
               $$=nonTerminal("* int",NULL,$1,$3);
               $$->nodeType = string("long long");
	    }
	    else if (strcmp(a, "float")==0){
               $$=nonTerminal("* float",NULL,$1,$3);
               $$->nodeType = string("long double");
            } }
            else{
                $$=nonTerminal("*",NULL,$1,$3);
		yyerror("Error: Incompatible type for * operator");
            }
	    if($1->isInit==1 && $3->isInit==1) $$->isInit=1;
        }
        | multiplicative_expression '/' cast_expression       {
            char* a=multilplicativeExpr($1->nodeType, $3->nodeType, '/');
           if(a){ if(!strcmp(a,"int")){
               $$=nonTerminal("/ int",NULL,$1,$3);
               $$->nodeType = string("long long");
	    }
	    else if (!strcmp(a,"float")){
               $$=nonTerminal("/ float",NULL,$1,$3);
               $$->nodeType = string("long double");
            } }
            else{
               $$=nonTerminal("/",NULL,$1,$3);
		yyerror("Error: Incompatible type for / operator");
            }
	    if($1->isInit==1 && $3->isInit==1) $$->isInit=1;
}
        | multiplicative_expression '%' cast_expression       {
            $$=nonTerminal("%",NULL,$1,$3);
            char* a=multilplicativeExpr($1->nodeType, $3->nodeType, '/');
            if(a){
		$$->nodeType= string("long long");
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
                char *a = additiveExpr($1->nodeType,$3->nodeType,'+');
                 char *q=new char();
                 if(a){string as(a);
                 string p = string("+ ")+as;
                 strcpy(q,p.c_str());}
                 else q = "+";
                 $$=nonTerminal(q,NULL,$1,$3);
                 if(a){ string as(a);
                 if(!strcmp(a,"int")) $$->nodeType=string("long long");
                 else if(!strcmp(a,"float")) $$->nodeType=string("long double");
                 else $$->nodeType=as; }
                 else {
                       yyerror("Error: Incompatible type for + operator");
                      } 
		 if($1->isInit==1 && $3->isInit==1) $$->isInit=1;
                 }
        | additive_expression '-' multiplicative_expression   {
                 char *a = additiveExpr($1->nodeType,$3->nodeType,'-');
		 char *q = new char();
		 if(a){ string as(a);
                         string p =string("- ")+as;
                         strcpy(q,p.c_str());
                      }
		  $$=nonTerminal(q,NULL,$1,$3);
	          if(a){ string as(a);
                   if(!strcmp(a,"int")) $$->nodeType=string("long long");
                   else if(!strcmp(a,"float")) $$->nodeType=string("long double");
			 else $$->nodeType=as; }
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
                 if(a) { if(!strcmp(a,"bool")) $$->nodeType = string("bool");
                    else if(!strcmp(a,"Bool")){
                       $$->nodeType = string("bool");
                       yyerror("Warning: comparison between pointer and integer");}
                    }else {
                         yyerror("Error: invalid operands to binary <");
                    }
                  if($1->isInit==1 && $3->isInit==3) $$->isInit=1; 
        
      }
  | relational_expression '>' shift_expression   
 {                $$ = nonTerminal(">", NULL, $1, $3);
                  char* a=relationalExpr($1->nodeType,$3->nodeType,">");                 if(a){ if(!strcmp(a,"bool")) $$->nodeType = string("bool");
                    else if(!strcmp(a,"Bool")){
                       $$->nodeType = string("bool");
                       yyerror("Warning: comparison between pointer and integer");}
                    } else {
                         yyerror("Error: invalid operands to binary >");
                    }
                  if($1->isInit==1 && $3->isInit==3) $$->isInit=1;

  }
  | relational_expression LE_OP shift_expression  
   {
                                  $$ = nonTerminal2("<=", $1,NULL, $3);
                    char* a=relationalExpr($1->nodeType,$3->nodeType,"<=");               if(a){if(!strcmp(a,"bool")) $$->nodeType = string("bool");
                    else if(!strcmp(a,"Bool")){
                       $$->nodeType = string("bool");
                       yyerror("Warning: comparison between pointer and integer");}
                    }else {
                         yyerror("Error: invalid operands to binary <=");
                    }
                  if($1->isInit==1 && $3->isInit==3) $$->isInit=1;
      }
  | relational_expression GE_OP shift_expression
    {
                       $$ = nonTerminal2(">=", $1,NULL, $3);
                  char* a=relationalExpr($1->nodeType,$3->nodeType,">=");            if(a){  if(!strcmp(a,"bool")) $$->nodeType = string("bool");
                 else if(!strcmp(a,"Bool")){
                 $$->nodeType = string("bool");
              yyerror("Warning: comparison between pointer and integer");}
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
               }
               else {
                 yyerror("Error:Invalid operands to the binary |");
               }
                 if($1->isInit==1 && $3->isInit==3) $$->isInit=1;

      }
  ;

logical_and_expression
  : inclusive_or_expression { $$ = $1;}
  | logical_and_expression AND_OP inclusive_or_expression  {
                          $$ = nonTerminal2("&&", $1,NULL, $3);       
                        $$->nodeType == string("bool");
                 if($1->isInit==1 && $3->isInit==3) $$->isInit=1;
                                                           }
  ;

logical_or_expression
  : logical_and_expression  { $$ = $1;}
  | logical_or_expression OR_OP logical_and_expression  {
                                $$ = nonTerminal2("||", $1,NULL, $3);
                 if($1->isInit==1 && $3->isInit==3) $$->isInit=1;
                        $$->nodeType == string("bool");
                                                        }
  ;

conditional_expression
  : logical_or_expression  { $$ = $1;}
  | logical_or_expression '?' expression ':' conditional_expression  {
            $$ = nonTerminal2("conditional_expression", $1, $3, $5);
            char* a = conditionalExpr($3->nodeType,$5->nodeType);
            if(a){
                 string as(a);
                 $$->nodeType = as;
                 }
            else
                {
                 yyerror("Error:Type mismatch in conditional expression");
                }
           if($1->isInit==1 && $3->isInit==3 && $5->isInit) $$->isInit=1;
    
          }
  ;

assignment_expression
  : conditional_expression  { $$ = $1;}
  | unary_expression assignment_operator assignment_expression  
             { $$ = nonTerminal2($2, $1,NULL, $3);
              

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
  | expression ',' assignment_expression   { $$ = nonTerminal("expression",NULL, $1, $3);}
  ;

constant_expression 
  : conditional_expression  { $$ = $1;}
  ;

declaration
  : declaration_specifiers ';'  { typeName=string(""); $$ = $1;}
  | declaration_specifiers init_declarator_list ';'  { typeName=string(""); $$ = nonTerminal("declaration", NULL, $1, $2);}
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
  | init_declarator_list ',' init_declarator  { $$ = nonTerminal("init_declaration_list",NULL, $1, $3);}
  ;

init_declarator
  : declarator '=' initializer  { 
                    if($1->exprType==1){ char *t=new char();
                      strcpy(t,($$->nodeType).c_str()); 
                      char *key =new char();
                      strcpy(key,($1->nodeKey).c_str());
                if(lookup($1->nodeKey)){ yyerror("Error : redeclaration of %s",key); } 
                else { insertSymbol(*curr,key,t,0,0,1); }
                } 
                $$ = nonTerminal("=", NULL, $1, $3);
               }
  | declarator     {                                                                           if($1->exprType==1){ char *t=new char();
                     strcpy(t,($1->nodeType).c_str());
                     char *key =new char();
                     strcpy(key,($1->nodeKey).c_str());
                  if(lookup($1->nodeKey)){ yyerror("Error: redeclaration of %s",key);}
                   else {  insertSymbol(*curr,key,t,0,0,0);}
                     } 
                   $$ = $1;
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
  | struct_or_union_specifier  {$$ = $1;yyerror("Error : Not implemented struct or union yet");}
  | enum_specifier  {$$ =$1;yyerror("Error : not implemented Enum specifier");}
  | TYPEDEF_NAME    {  if(typeName==string(""))typeName = string($1);
                   else typeName = typeName+string(" ")+string($1);
                  $$ = terminal($1);
              }
  ;

struct_or_union_specifier
  : struct_or_union '{' struct_declaration_list '}' {$$ = nonTerminal("struct_or_union_specifier", NULL, $1, $3);}
  | struct_or_union IDENTIFIER '{' struct_declaration_list '}'  {
                                                                  $$ = nonTerminal("struct_or_union_specifier", $2, $1, $4);
                                                                }
  | struct_or_union IDENTIFIER   {
                                    $$ = nonTerminal("struct_or_union_specifier", $2,$1, NULL);
                                  }
  ;

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
  : specifier_qualifier_list ';'  {$$ = $1;}
  | specifier_qualifier_list struct_declarator_list ';' {$$ = nonTerminal("struct_declaration", NULL, $1, $2);}
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
	| declarator ':' constant_expression  {$$ = nonTerminal("struct_declarator", NULL, $1, $3);}
	| declarator {$$ = $1;}
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
         }
	| direct_declarator {$$ = $1;if($1->exprType==2){ funcName=$1->nodeKey; funcType = $1->nodeType; } }
	;

direct_declarator
	: IDENTIFIER{ 
                    $$=terminal($1);$$->exprType=1;$$->nodeKey=string($1);$$->nodeType=typeName;
			   }
	| '(' declarator ')' {$$ = $2;
                           if($2->exprType==1){ $$->exprType=1;
                                          $$->nodeKey=$2->nodeKey;
                                          $$->nodeType=$2->nodeType;}
                           }
	| direct_declarator '[' ']' {$$ = nonTerminalSquareB("direct_declarator", $1);
                      if($1->exprType==1){ $$->exprType=1;
                                          $$->nodeKey=$1->nodeKey;
                                          $$->nodeType=$1->nodeType+string("*");}
                               } 
	| direct_declarator '[' '*' ']' {$$ = nonTerminalFourChild("direct_declarator", $1, NULL, NULL, NULL, $3);
          if($1->exprType==1){ $$->exprType=1;
                                          $$->nodeKey=$1->nodeKey;
                                          $$->nodeType=$1->nodeType+string("*");}

                            }
	| direct_declarator '[' STATIC type_qualifier_list assignment_expression ']'{ 
				temp = terminal($3);
				$$ = nonTerminalFourChild("direct_declarator", $1, temp, $4, $5, NULL);
           if($1->exprType==1){ $$->exprType=1;
                                          $$->nodeKey=$1->nodeKey;
                                          $$->nodeType=$1->nodeType+string("*");}
             
                          }
	| direct_declarator '[' STATIC assignment_expression ']' { 
				temp = terminal($3);
				$$ = nonTerminalFourChild("direct_declarator", $1, temp, $4, NULL, NULL);
        if($1->exprType==1){ $$->exprType=1;
                                          $$->nodeKey=$1->nodeKey;
                                          $$->nodeType=$1->nodeType+string("*");}

                          }
	| direct_declarator '[' type_qualifier_list '*' ']' {$$ = nonTerminalFourChild("direct_declarator", $1, $3, NULL, NULL, $4);
          if($1->exprType==1){ $$->exprType=1;
                                          $$->nodeKey=$1->nodeKey;
                                          $$->nodeType=$1->nodeType+string("*");}
   
         }
	| direct_declarator '[' type_qualifier_list STATIC assignment_expression ']' { 
				
                          temp = terminal($4);
				$$ = nonTerminalFourChild("direct_declarator", $1, $3, temp, $5, NULL);
          if($1->exprType==1){ $$->exprType=1;
                                          $$->nodeKey=$1->nodeKey;
                                          $$->nodeType=$1->nodeType+string("*");}
                          
}
	| direct_declarator '[' type_qualifier_list assignment_expression ']'{$$ = nonTerminalFourChild("direct_declarator", $1, $3, $4, NULL, NULL);
          if($1->exprType==1){ $$->exprType=1;
                                          $$->nodeKey=$1->nodeKey;
                                          $$->nodeType=$1->nodeType+string("*");}

}
	| direct_declarator '[' type_qualifier_list ']' {$$ = nonTerminal("direct_declarator", NULL, $1, $3);
          if($1->exprType==1){ $$->exprType=1;
                               $$->nodeKey=$1->nodeKey;
                                $$->nodeType=$1->nodeType+string("*");}

         }
	| direct_declarator '[' assignment_expression ']' {$$ = nonTerminal("direct_declarator", NULL, $1, $3);
         if($1->exprType==1){ $$->exprType=1;
                            $$->nodeKey=$1->nodeKey;
                            $$->nodeType=$1->nodeType+string("*");}

        }
	| direct_declarator '(' E3 parameter_type_list ')'
         { 
         $$ = nonTerminal("direct_declarator", NULL, $1, $4);
          if($1->exprType==1){ $$->nodeKey=$1->nodeKey;
                           $$->exprType=2;
                           $$->nodeType=$1->nodeType;
                           insertFuncArguments($1->nodeKey,funcArguments);
                           funcArguments=string("");
                           }
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
                     } 
	| direct_declarator '(' E3 identifier_list ')' {$$ = nonTerminal("direct_declarator", NULL, $1, $4); }
	;

E3 
   : %empty                 {   typeName =string("");  
                          funcArguments = string("");  }
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
				      }
	| parameter_list {$$=$1;}
	;

parameter_list
	: parameter_declaration {$$=$1;}
	| parameter_list ',' parameter_declaration {$$=nonTerminal("parameter_list",NULL,$1,$3);}
	;

parameter_declaration
	: declaration_specifiers declarator {typeName=string("");
          paramTable();
         if($2->exprType==1){ char *t=new char();
                     strcpy(t,($2->nodeType).c_str());
                     char *key =new char();
                     strcpy(key,($2->nodeKey).c_str());
                  if(lookup($2->nodeKey)){ yyerror("Error: redeclaration of %s",key);}
                   else {  insertSymbol(*curr,key,t,0,0,1);}
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
	: '{' initializer_list '}' {$$ = $2;}
	| '{' initializer_list ',' '}' {$$ = nonTerminal("initializer", $3, $2 ,NULL);}
	| assignment_expression {$$ = $1;}
	;

initializer_list
	: designation initializer {$$ = nonTerminal("initializer_list", NULL, $1 ,$2);}
	| initializer {$$ = $1;}
	| initializer_list ',' designation initializer {$$ = nonTerminal("initializer_list", $2, $1 ,$3);}
	| initializer_list ',' initializer {$$ = nonTerminal("initializer_list", NULL, $1 ,$3);}
	;

designation
	: designator_list '='  {$$ = nonTerminal("designation", "=", $1 ,NULL);}
	;

designator_list
	: designator  {$$ = $1;}
	| designator_list designator  {$$ = nonTerminal("designator_list", NULL, $1 ,$2);}
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

labeled_statement
        : IDENTIFIER ':' statement {
                                temp = terminal($1);
                                $$ = nonTerminal("labeled_statement", NULL, temp, $3);
                           }
        | CASE constant_expression ':' statement {
                                temp = terminal($1);
                                $$ = nonTerminal2("labeled_statement", temp, $2, $4);
                           }
        | DEFAULT ':' statement {
                                temp = terminal($1);
                                $$ = nonTerminal("labeled_statement", NULL, temp, $3);
                           }
        ;

compound_statement
	: '{' '}'   {isFunc=0;$$ = terminal("{ }");} 
	| E1  block_item_list '}' {if(blockSym){ printSymTables(curr,$1);    updateSymTable(); blockSym--; } $$ = $2;}
	;
E1 
    :  '{'       { if(isFunc==0) {symNumber++;
                        symFileName = /*string("symTableFunc")+to_string(funcSym)*/funcName+string("Block")+to_string(symNumber);
                        scope=S_BLOCK;
                        makeSymTable(symFileName,scope,string("12345"));
                        char * y=new char();
                        strcpy(y,symFileName.c_str());
                        $$ = strcat(y,".csv");
                        blockSym++;
                        }
                       isFunc=0;
              } 
   
    ;

block_item_list
	: block_item  {$$ = $1;}
	| block_item_list block_item  {$$ = nonTerminal("block_item_list", NULL, $1, $2);}
	;

block_item
	: declaration {$$ = $1;}
	| statement {$$ = $1;}
	;

expression_statement
	: ';' {$$ = terminal(";");}

	| expression ';' {$$ =  $1 ;}
	;

selection_statement
        : IF '(' expression ')' statement ELSE statement {
                                                           $$ = nonTerminal2("IF (expr) stmt ELSE stmt", $3, $5, $7);
                                                         }
        | IF '(' expression ')' statement {
                                           $$ = nonTerminal2("IF (expr) stmt", NULL, $3, $5);
                                         }
        | SWITCH '(' expression ')' statement{
                                           $$ = nonTerminal2("SWITCH (expr) stmt", NULL, $3, $5);
                                         }
        ;

iteration_statement
        : WHILE '(' expression ')' statement  {
                                           $$ = nonTerminal2("WHILE (expr) stmt", NULL, $3, $5);
                                         }
        | DO statement WHILE '(' expression ')' ';'{
                                                     $$ = nonTerminal2("DO stmt WHILE (expr)", NULL, $2, $5);
                                                   }
        | FOR '(' expression_statement expression_statement ')' statement  {
                                           $$ = nonTerminal2("FOR (expr_stmt expr_stmt) stmt", $3, $4, $6);
                                         }
        | FOR '(' expression_statement expression_statement expression ')' statement {
                                           $$ = nonTerminalFiveChild("FOR (expr_stmt expr_stmt expr) stmt", NULL, $3, $4, $5, $7);
                                         }
        | FOR '(' declaration expression_statement ')' statement  {
                                           $$ = nonTerminal2("FOR ( decl expr_stm ) stmt", $3, $4, $6);
                                         }
        | FOR '(' declaration expression_statement expression ')' statement  {
                                           $$ = nonTerminalFiveChild("FOR ( decl expr_stmt expr ) stmt", NULL, $3, $4, $5, $7);
                                         }
        ;

jump_statement
        : GOTO IDENTIFIER ';' {
                                temp = terminal($1);
                                temp1 = terminal($2);
                                $$ = nonTerminal("jump_statement", NULL, temp, temp1);
                              }
        | CONTINUE ';'        {
                                $$ = terminal("contiue");
                              }
        | BREAK ';'           {
                                $$ = terminal("break");
                              }
        | RETURN ';'          {
                                $$ = terminal("return");
                              }
        | RETURN expression ';' {
                                  temp = terminal("return");
                                    $$ = nonTerminal("jump_statement", NULL, temp, $2);
                                }
        ;


translation_unit
	: external_declaration  {$$ = $1;}
	| translation_unit external_declaration  {$$ = nonTerminal("translation_unit", NULL, $1, $2);}
	;

external_declaration
	: function_definition  {typeName=string("");$$ = $1;}
	| declaration  {typeName=string("");$$ = $1;}
	;

function_definition
	: declaration_specifiers declarator E2 declaration_list compound_statement {typeName=string("");printSymTables(curr,$3); symNumber=0; updateSymTable();$$ = nonTerminalFourChild("function_definition", $1, $2, $4, $5, NULL);}
	| declaration_specifiers declarator E2 compound_statement  {typeName=string(""); printSymTables(curr,$3);  symNumber=0;  updateSymTable();$$ = nonTerminal2("function_definition", $1, $2, $4);}
	;

E2 
    : %empty                { typeName=string("");scope = S_FUNC;
                                         isFunc = 1;
                                         funcSym++;
                                         symFileName = funcName;//string("symTableFunc")+to_string(funcSym);
                                         makeSymTable(symFileName,scope,funcType);
                                         char* y= new char();
                                         strcpy(y,symFileName.c_str());
                                         $$ = strcat(y,".csv");
       }
    ;

declaration_list
	: declaration {$$ = $1;}
	| declaration_list declaration {$$ = nonTerminal("declaration_list", NULL, $1, $2);}
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

  stInitialize();
  graphInitialization();
  yyparse();
  
  graphEnd();
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

%{
#include <iostream>
#include <string>
#include <stdio.h>
#include <stdlib.h>

using namespace std;

int yylex(void);
void yyerror(char *s);
#include "nodes.h"
FILE *digraph;
%}


/* Reference LexxAndYaccTutorial : by Tom Niemann*/
%union {
  int number;     /*integer value*/
  char *str; 
  node *ptr;     /*node pointer */
};

/* Grammar from quut.com/c/ANSI-C-grammar-y.html */
%token <str> IDENTIFIER I_CONSTANT F_CONSTANT STRING_LITERAL FUNCTION_NAME SIZEOF
%token <str> PTR_OP INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token <str> AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token <str> SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN 
%token <str> XOR_ASSIGN OR_ASSIGN
%token <str> TYPEDEF_NAME ENUMERATION_CONSTANT 
%token <str> TYPEDEF EXTERN STATIC AUTO REGISTER INLINE
%token <str> CONST RESTRICT VOLATILE 
%token <str> BOOL CHAR SHORT INT SIGNED UNSIGNED FLOAT DOUBLE VOID 
%token <str> COMPLEX IMAGINARY 
%token <str> STRUCT UNION ENUM ELLIPSIS LONG
%token <str> CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN
%token <str> ALIGNAS ALIGNOF ATOMIC GENERIC NORETURN STATIC_ASSERT THREAD_LOCAL
/* %start translation_unit */
%start additive_expression

%type <ptr> multiplicative_expression additive_expression cast_expression
%token <str> INTEGER
%left <str> '*' '/' '%' '+' '-'
/*%left <str> '+' '-'*/
%%

cast_expression
        : INTEGER                                               {$$=terminal($1);$$=nonTerminal("cast_expression",NULL,$$,NULL);}
        |
        ;

multiplicative_expression
        : cast_expression                                     {$$=nonTerminal("multiplicative_expression",NULL,$1,NULL);}
        | multiplicative_expression '*' cast_expression       {$$=nonTerminal("multiplicative_expression",$2,$1,$3);}
        | multiplicative_expression '/' cast_expression       {$$=nonTerminal("multiplicative_expression",$2,$1,$3);}
        | multiplicative_expression '%' cast_expression       {$$=nonTerminal("multiplicative_expression",$2,$1,$3);}
        ;

additive_expression
        : multiplicative_expression                           {$$=nonTerminal("additive_expression",NULL,$1,NULL);}
        | additive_expression '+' multiplicative_expression   {$$=nonTerminal("additive_expression",$2,$1,$3);}
        | additive_expression '-' multiplicative_expression   {$$=nonTerminal("additive_expression",$2,$1,$3);}
        ;

%%
extern FILE *yyin;
int main(int argc,char **argv){
  yyin =fopen(argv[1],"r");
  digraph =fopen("out/digraph.gv","w");
  graphInitialization();
  yyparse();
  graphEnd();
  return 0;
}
void yyerror(char *str){
  fprintf(stderr,"error:%s\n",str);
}

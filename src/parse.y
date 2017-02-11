%{
#include <iostream>
#include <cstring>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
using namespace std;

int yylex(void);
void yyerror(char *s);
#include "nodes.h"
FILE *digraph;
node *temp,*temp1,*temp2;
char filename[1000];
extern int yylineno;
%}


/* Reference LexxAndYaccTutorial : by Tom Niemann*/
%union {
  int number;     /*integer value*/
  char *str; 
  node *ptr;     /*node pointer */
};

/* Grammar from quut.com/c/ANSI-C-grammar-y.html */
%token <str> CHAR CONST CASE CONTINUE DEFAULT DO DOUBLE
%token <str> ELSE ENUM EXTERN FLOAT FOR IF INLINE INT LONG
%token <str> REGISTER RESTRICT RETURN SHORT SIGNED STATIC STRUCT SWITCH TYPEDEF UNION
%token <str> UNSIGNED VOID VOLATILE WHILE ALIGNAS ALIGNOF ATOMIC BOOL COMPLEX
%token <str> GENERIC IMAGINARY NORETURN STATIC_ASSERT THREAD_LOCAL FUNC_NAME
%token <str> AUTO BREAK GOTO TYPEDEF_NAME IDENTIFIER ENUMERATION_CONSTANT
%token <str> STRING_LITERAL I_CONSTANT F_CONSTANT
%left <str> PTR_OP
%token <str> INC_OP DEC_OP
%token <str> LEFT_OP RIGHT_OP
%left <str> LE_OP GE_OP EQ_OP NE_OP
%left <str> AND_OP OR_OP
%right <str> MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%right <str> SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN 
%right <str> XOR_ASSIGN OR_ASSIGN
%token <str> ELLIPSIS

%start translation_unit 

%left <str> ',' '^' '|' ';' '{' '}' '[' ']' '(' ')' '+' '-' '%' '/' '*' '.' '>' '<' SIZEOF
%right <str> '&' '=' '!' '~' ':' '?'

%type <ptr> multiplicative_expression additive_expression cast_expression primary_expression constant string expression generic_selection enumeration_constant
%type <ptr> generic_assoc_list generic_association type_name assignment_expression postfix_expression argument_expression_list initializer_list unary_expression
%type <ptr> unary_operator shift_expression relational_expression equality_expression and_expression exclusive_or_expression inclusive_or_expression
%type <ptr> logical_or_expression logical_and_expression conditional_expression assignment_operator declaration constant_expression declaration_specifiers
%type <ptr> init_declarator_list static_assert_declaration storage_class_specifier type_specifier function_specifier type_qualifier alignment_specifier 
%type <ptr> init_declarator declarator initializer atomic_type_specifier struct_or_union_specifier enum_specifier struct_or_union struct_declaration_list
%type <ptr> struct_declaration specifier_qualifier_list struct_declarator_list struct_declarator enumerator_list enumerator enumerator_constant pointer
%type <ptr> direct_declarator type_qualifier_list parameter_type_list identifier_list parameter_list parameter_declaration  
%type <ptr> abstract_declarator direct_abstract_declarator designation designator_list designator labeled_statement compound_statement expression_statement declaration_list
%type <ptr> selection_statement iteration_statement jump_statement block_item_list block_item external_declaration translation_unit function_definition statement jump_statement_error
%%

primary_expression
  : IDENTIFIER                    {$$=terminal($1);$$=nonTerminal("IDENTIFIER",NULL,$$,NULL);$$=nonTerminal("primary_expression",NULL,$$,NULL);}
  | constant                      {$$=nonTerminal("primary_exprssion",NULL,$1,NULL); }
  | string                        {$$=nonTerminal("primary_exprssion",NULL,$1,NULL); }
  | '(' expression ')'            {$$=nonTerminal("primary_exprssion",NULL,$2,NULL); }
  | generic_selection             {$$=nonTerminal("primary_exprssion",NULL,$1,NULL); }
  ;

constant
  : I_CONSTANT                    {$$=terminal($1);$$=nonTerminal("I_CONSTANT",NULL,$$,NULL);$$=nonTerminal("constant",NULL,$$,NULL);}
  | F_CONSTANT                    {$$=terminal($1);$$=nonTerminal("F_CONSTANT",NULL,$$,NULL);$$=nonTerminal("constant",NULL,$$,NULL);}
  | ENUMERATION_CONSTANT           {$$=terminal($1);$$=nonTerminal("ENUMERATION_CONSTANT",NULL,$$,NULL);$$=nonTerminal("constant",NULL,$$,NULL);}
  ;
enumeration_constant    /* before it has been defined as such */
  : IDENTIFIER                    {$$=terminal($1);$$=nonTerminal("IDENTIFIER",NULL,$$,NULL);$$=nonTerminal("enumeration_constant",NULL,$$,NULL);}
  ;

string
  : STRING_LITERAL                {$$=terminal($1);$$=nonTerminal("STRING_LITERAL",NULL,$$,NULL);$$=nonTerminal("string",NULL,$$,NULL);}
  | FUNC_NAME                     {temp=nonTerminal("FUNC_NAME",$1,NULL,NULL);  $$=nonTerminal("string",NULL,temp,NULL);}
  ;

generic_selection
  : GENERIC '(' assignment_expression ',' generic_assoc_list ')' {$$=terminal($1);$$=nonTerminal("GENERIC",NULL,$$,NULL);$$=nonTerminal2("generic_selection",$$,$3,$5);}
  ;
generic_assoc_list
  : generic_association                        {$$=nonTerminal("generic_assoc_list",NULL,$1,NULL);}
  | generic_assoc_list ',' generic_association  {$$=nonTerminal2("generic_assoc_list",NULL,$1,$3);}
  ;

generic_association
  : type_name ':' assignment_expression      {$$ = nonTerminal2("generic_association", $1, $3, NULL);}
  | DEFAULT ':' assignment_expression        {$$ = terminal("DEFAULT"); $$ = nonTerminal2("generic_association", $$, $3, NULL);} 
  ;
 
postfix_expression
  : primary_expression                       {$$ = nonTerminal("postfix_expression", NULL, $1, NULL);} 
  | postfix_expression '[' expression ']'    {$$ = nonTerminal("postfix_expression", NULL, $1, $3);} 
  | postfix_expression '(' ')'               {$$ = nonTerminal("postfix_expression", NULL, $1, NULL);} 
  | postfix_expression '(' argument_expression_list ')'   {$$ = nonTerminal("postfix_expression", NULL, $1, $3);} 
  | postfix_expression '.' IDENTIFIER       {
                                                temp=nonTerminal("IDENTIFIER",$3,NULL,NULL); 
                                                $$ = nonTerminal("postfix_expression", $2, $1, temp);
                                            }    
  | postfix_expression PTR_OP IDENTIFIER    {
                                                temp=terminal($2);
                                                temp=nonTerminal("PTR_OP",NULL,temp,NULL);
                                                temp1=terminal($3);
                                                $$=nonTerminal("IDENTIFIER",NULL,temp1,NULL);
                                                $$ = nonTerminal2("postfix_expression", $1, temp, temp1);
                                            }
  | postfix_expression INC_OP               {
                                                temp=terminal($2);
                                                temp=nonTerminal("INC_OP",NULL,temp,NULL);
                                                $$=  nonTerminal("postfix_expression", NULL,$1, temp); 
                                            } 
  | postfix_expression DEC_OP               {
                                                temp=terminal($2);
                                                temp=nonTerminal("INC_OP",NULL,temp,NULL);
                                                $$=  nonTerminal("postfix_expression",NULL, $1, temp); 
                                            } 
  | '(' type_name ')' '{' initializer_list '}' {
                                                  $$=  nonTerminal("postfix_expression", NULL, $2, $5);
                                               }
  | '(' type_name ')' '{' initializer_list ',' '}' {
                                                    temp=nonTerminal("initializer_list ,",$6,$5,NULL);
                                                    $$=nonTerminal("postfix_expression",NULL,$2,temp);
                                                   }
  ;

argument_expression_list
  : assignment_expression            {$$ = nonTerminal("argument_expression_list", NULL, $1, NULL);} 
  | argument_expression_list ',' assignment_expression    {$$ = nonTerminal("argument_expression_list", $2, $1, $3);} 
  ;

unary_expression
  : postfix_expression            {$$ = nonTerminal("unary_expression", NULL, $1, NULL);} 
  | INC_OP unary_expression       {
                                      temp=terminal($1);
                                      temp=nonTerminal("INC_OP",NULL,temp,NULL);
                                      $$=  nonTerminal("unary_expression", NULL, temp, $2); 
                                   } 

  | DEC_OP unary_expression       {
                                      temp=terminal($1);
                                      temp=nonTerminal("DEC_OP",NULL,temp,NULL);
                                      $$=  nonTerminal("unary_expression", NULL, temp, $2); 
                                   }
  | unary_operator cast_expression { $$ = nonTerminal("unary_expression", NULL, $1, $2);}
  | SIZEOF unary_expression       {
                                      temp=terminal($1);
                                      temp=nonTerminal("SIZEOF",NULL,temp,NULL);
                                      $$=  nonTerminal("unary_expression", NULL, temp, $2); 
                                   }
  | SIZEOF '(' type_name ')'   {
                                      temp=terminal($1);
                                      temp=nonTerminal("SIZEOF",NULL,temp,NULL);
                                      $$=  nonTerminal("unary_expression", NULL, temp, $3); 
                                   }
  | ALIGNOF '(' type_name ')'   {
                                      temp=terminal($1);
                                      temp=nonTerminal("ALIGNOF",NULL,temp,NULL);
                                      $$=  nonTerminal("unary_expression", NULL, temp, $3); 
                                   }
  ;

unary_operator
  : '&'      { $$ = nonTerminal("unary_operator", $1, NULL, NULL);}
  | '*'      { $$ = nonTerminal("unary_operator", $1, NULL, NULL);}
  | '+'      { $$ = nonTerminal("unary_operator", $1, NULL, NULL);}
  | '-'      { $$ = nonTerminal("unary_operator", $1, NULL, NULL);}
  | '~'      { $$ = nonTerminal("unary_operator", $1, NULL, NULL);}
  | '!'      { $$ = nonTerminal("unary_operator", $1, NULL, NULL);}
  ;
      
cast_expression
        : unary_expression        {$$ = nonTerminal("cast_expression", NULL, $1, NULL);}
        | '(' type_name ')' cast_expression {$$ = nonTerminal("cast_expression", NULL, $2, $4);}
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


shift_expression
  : additive_expression     {$$ = nonTerminal("shift_expression", NULL, $1, NULL);}
  | shift_expression LEFT_OP additive_expression {
                                                    temp = nonTerminal("LEFT_OP", $2, NULL, NULL);
                                                    $$ = nonTerminal2("shift_expression", $1, temp, $3);
                                                  }
  | shift_expression RIGHT_OP additive_expression {
                                                    temp = nonTerminal("RIGHT_OP", $2, NULL, NULL);
                                                    $$ = nonTerminal2("shift_expression", $1, temp, $3);
                                                  }
  ;

relational_expression
  : shift_expression     {$$ = nonTerminal("relational_expression", NULL, $1, NULL);}
  | relational_expression '<' shift_expression   {$$ = nonTerminal("relational_expression", $2, $1, $3);}
  | relational_expression '>' shift_expression   {$$ = nonTerminal("relational_expression", $2, $1, $3);}
  | relational_expression LE_OP shift_expression  {
                                                    temp = nonTerminal("LE_OP", $2, NULL, NULL);
                                                    $$ = nonTerminal2("relational_expression", $1, temp, $3);
                                                  }
  | relational_expression GE_OP shift_expression{
                                                    temp = nonTerminal("GE_OP", $2, NULL, NULL);
                                                    $$ = nonTerminal2("relational_expression", $1, temp, $3);
                                                  }
  ;

equality_expression
  : relational_expression   {$$ = nonTerminal("equality_expression", NULL, $1, NULL);}
  | equality_expression EQ_OP relational_expression {
                                                    temp = nonTerminal("EQ_OP", $2, NULL, NULL);
                                                    $$ = nonTerminal2("equality_expression", $1, temp, $3);
                                                  }
  | equality_expression NE_OP relational_expression {
                                                    temp = nonTerminal("NE_OP", $2, NULL, NULL);
                                                    $$ = nonTerminal2("equality_expression", $1, temp, $3);
                                                  }
  ;

and_expression
  : equality_expression  { $$ = nonTerminal("and_expression", NULL, $1, NULL);}
  | and_expression '&' equality_expression  {$$ = nonTerminal("and_expression", $2, $1, $3);}
  ;

exclusive_or_expression
  : and_expression   { $$ = nonTerminal("exclusive_or_expression", NULL, $1, NULL);}
  | exclusive_or_expression '^' and_expression  {$$ = nonTerminal("exclusive_or_expression", $2, $1, $3);}
  ;

inclusive_or_expression
  : exclusive_or_expression    { $$ = nonTerminal("inclusive_or_expression", NULL, $1, NULL);}
  | inclusive_or_expression '|' exclusive_or_expression  {$$ = nonTerminal("inclusive_or_expression", $2, $1, $3);}
  ;

logical_and_expression
  : inclusive_or_expression { $$ = nonTerminal("logical_and_expression", NULL, $1, NULL);}
  | logical_and_expression AND_OP inclusive_or_expression  {
                                                            temp = nonTerminal("AND_OP", $2, NULL, NULL);
                                                            $$ = nonTerminal2("logical_and_expression", $1, temp, $3);
                                                            }
  ;

logical_or_expression
  : logical_and_expression  { $$ = nonTerminal("logical_or_expression", NULL, $1, NULL);}
  | logical_or_expression OR_OP logical_and_expression  {
                                                            temp = nonTerminal("OR_OP", $2, NULL, NULL);
                                                            $$ = nonTerminal2("logical_or_expression", $1, temp, $3);
                                                            }
  ;

conditional_expression
  : logical_or_expression  { $$ = nonTerminal("conditional_expression", NULL, $1, NULL);}
  | logical_or_expression '?' expression ':' conditional_expression  {$$ = nonTerminal2("conditional_expression", $1, $3, $5);}
  ;

assignment_expression
  : conditional_expression  { $$ = nonTerminal("assignment_expression", NULL, $1, NULL);}
  | unary_expression assignment_operator assignment_expression  {$$ = nonTerminal2("assignment_expression", $1, $2, $3);}
  ;

assignment_operator
  : '='    { $$ = nonTerminal("assignment_operator", $1, NULL, NULL);}
  | MUL_ASSIGN  { 
                  temp = nonTerminal("MUL_ASSIGN", $1, NULL, NULL);
                  $$ = nonTerminal("assignment_operator", NULL, temp, NULL);
                }
  | DIV_ASSIGN  { 
                  temp = nonTerminal("DIV_ASSIGN", $1, NULL, NULL);
                  $$ = nonTerminal("assignment_operator", NULL, temp, NULL);
                }
  | MOD_ASSIGN  { 
                  temp = nonTerminal("MOD_ASSIGN", $1, NULL, NULL);
                  $$ = nonTerminal("assignment_operator", NULL, temp, NULL);
                }
  | ADD_ASSIGN  { 
                  temp = nonTerminal("ADD_ASSIGN", $1, NULL, NULL);
                  $$ = nonTerminal("assignment_operator", NULL, temp, NULL);
                }
  | SUB_ASSIGN  { 
                  temp = nonTerminal("SUB_ASSIGN", $1, NULL, NULL);
                  $$ = nonTerminal("assignment_operator", NULL, temp, NULL);
                }
  | LEFT_ASSIGN { 
                  temp = nonTerminal("LEFT_ASSIGN", $1, NULL, NULL);
                  $$ = nonTerminal("assignment_operator", NULL, temp, NULL);
                }
  | RIGHT_ASSIGN  { 
                  temp = nonTerminal("RIGHT_ASSIGN", $1, NULL, NULL);
                  $$ = nonTerminal("assignment_operator", NULL, temp, NULL);
                }
  | AND_ASSIGN  { 
                  temp = nonTerminal("AND_ASSIGN", $1, NULL, NULL);
                  $$ = nonTerminal("assignment_operator", NULL, temp, NULL);
                }
  | XOR_ASSIGN  { 
                  temp = nonTerminal("XOR_ASSIGN", $1, NULL, NULL);
                  $$ = nonTerminal("assignment_operator", NULL, temp, NULL);
                }
  | OR_ASSIGN    { 
                  temp = nonTerminal("OR_ASSIGN", $1, NULL, NULL);
                  $$ = nonTerminal("assignment_operator", NULL, temp, NULL);
                }
  ;

expression
  : assignment_expression    { $$ = nonTerminal("expression", NULL, $1, NULL);}
  | expression ',' assignment_expression   { $$ = nonTerminal("expression", $2, $1, $3);}
  ;

constant_expression 
  : conditional_expression  { $$ = nonTerminal("constant_expression", NULL, $1, NULL);}
  ;

declaration
  : declaration_specifiers ';'  { $$ = nonTerminal("declaration", NULL, $1, NULL);}
  | declaration_specifiers init_declarator_list ';'  { $$ = nonTerminal("declaration", NULL, $1, $2);}
  | static_assert_declaration   { $$ = nonTerminal("declaration", NULL, $1, NULL);}
  ;

declaration_specifiers
  : storage_class_specifier declaration_specifiers { $$ = nonTerminal("declaration_specifiers", NULL, $1, $2);}  
  | storage_class_specifier      { $$ = nonTerminal("declaration_specifiers", NULL, $1, NULL);}
  | type_specifier declaration_specifiers   { $$ = nonTerminal("declaration_specifiers", NULL, $1, $2);}
  | type_specifier              { $$ = nonTerminal("declaration_specifiers", NULL, $1, NULL);}
  | type_qualifier declaration_specifiers  { $$ = nonTerminal("declaration_specifiers", NULL, $1, $2);}
  | type_qualifier         { $$ = nonTerminal("declaration_specifiers", NULL, $1, NULL);}
  | function_specifier declaration_specifiers   { $$ = nonTerminal("declaration_specifiers", NULL, $1, $2);}
  | function_specifier  { $$ = nonTerminal("declaration_specifiers", NULL, $1, NULL);}
  | alignment_specifier declaration_specifiers { $$ = nonTerminal("declaration_specifiers", NULL, $1, $2);}
  | alignment_specifier  { $$ = nonTerminal("declaration_specifiers", NULL, $1, NULL);}
  ;

init_declarator_list
  : init_declarator    { $$ = nonTerminal("init_declaration_list", NULL, $1, NULL);}
  | init_declarator_list ',' init_declarator  { $$ = nonTerminal("init_declaration_list", $2, $1, $3);}
  ;

init_declarator
  : declarator '=' initializer  { $$ = nonTerminal("init_declarator", $2, $1, $3);}
  | declarator     { $$ = nonTerminal("init_declarator", NULL, $1, NULL);}
  ;

storage_class_specifier
  : TYPEDEF   { 
                  temp = nonTerminal("TYPEDEF", $1, NULL, NULL);
                  $$ = nonTerminal("storage_class_specifier", NULL, temp, NULL);
              }
  | EXTERN    { 
                  temp = nonTerminal("EXTERN", $1, NULL, NULL);
                  $$ = nonTerminal("storage_class_specifier", NULL, temp, NULL);
              }
  | STATIC    { 
                  temp = nonTerminal("STATIC", $1, NULL, NULL);
                  $$ = nonTerminal("storage_class_specifier", NULL, temp, NULL);
              }
  | THREAD_LOCAL { 
                  temp = nonTerminal("THREAD_LOCAL", $1, NULL, NULL);
                  $$ = nonTerminal("storage_class_specifier", NULL, temp, NULL);
              }
  | AUTO      { 
                  temp = nonTerminal("AUTO", $1, NULL, NULL);
                  $$ = nonTerminal("storage_class_specifier", NULL, temp, NULL);
              }
  | REGISTER  { 
                  temp = nonTerminal("REGISTER", $1, NULL, NULL);
                  $$ = nonTerminal("storage_class_specifier", NULL, temp, NULL);
              }
  ;

type_specifier
  : VOID     { 
                  temp = nonTerminal("VOID", $1, NULL, NULL);
                  $$ = nonTerminal("type_specifier", NULL, temp, NULL);
              }
  | CHAR     { 
                  temp = nonTerminal("CHAR", $1, NULL, NULL);
                  $$ = nonTerminal("type_specifier", NULL, temp, NULL);
              }
  | SHORT     { 
                  temp = nonTerminal("SHORT", $1, NULL, NULL);
                  $$ = nonTerminal("type_specifier", NULL, temp, NULL);
              }
  | INT       { 
                  temp = nonTerminal("INT", $1, NULL, NULL);
                  $$ = nonTerminal("type_specifier", NULL, temp, NULL);
              }
  | LONG      { 
                  temp = nonTerminal("LONG", $1, NULL, NULL);
                  $$ = nonTerminal("type_specifier", NULL, temp, NULL);
              }
  | FLOAT     { 
                  temp = nonTerminal("FLOAT", $1, NULL, NULL);
                  $$ = nonTerminal("type_specifier", NULL, temp, NULL);
              }
  | DOUBLE    { 
                  temp = nonTerminal("DOUBLE", $1, NULL, NULL);
                  $$ = nonTerminal("type_specifier", NULL, temp, NULL);
              }
  | SIGNED    { 
                  temp = nonTerminal("SIGNED", $1, NULL, NULL);
                  $$ = nonTerminal("type_specifier", NULL, temp, NULL);
              }
  | UNSIGNED  { 
                  temp = nonTerminal("UNSIGNED", $1, NULL, NULL);
                  $$ = nonTerminal("type_specifier", NULL, temp, NULL);
              }
  | BOOL      { 
                  temp = nonTerminal("BOOL", $1, NULL, NULL);
                  $$ = nonTerminal("type_specifier", NULL, temp, NULL);
              }
  | COMPLEX   { 
                  temp = nonTerminal("COMPLEX", $1, NULL, NULL);
                  $$ = nonTerminal("type_specifier", NULL, temp, NULL);
              }
  | IMAGINARY { 
                  temp = nonTerminal("IMAGINARY", $1, NULL, NULL);
                  $$ = nonTerminal("type_specifier", NULL, temp, NULL);
              }   
  | atomic_type_specifier  {$$ = nonTerminal("type_specifier", NULL, $1, NULL);}
  | struct_or_union_specifier  {$$ = nonTerminal("type_specifier", NULL, $1, NULL);}
  | enum_specifier  {$$ = nonTerminal("type_specifier", NULL, $1, NULL);}
  | TYPEDEF_NAME    { 
                  temp = nonTerminal("TYPEDEF_NAME", $1, NULL, NULL);
                  $$ = nonTerminal("type_specifier", NULL, temp, NULL);
              }
  ;

struct_or_union_specifier
  : struct_or_union '{' struct_declaration_list '}' {$$ = nonTerminal("struct_or_union_specifier", NULL, $1, $3);}
  | struct_or_union IDENTIFIER '{' struct_declaration_list '}'  {
                                                                  temp = nonTerminal("IDENTIFIER", $2, NULL, NULL );
                                                                  $$ = nonTerminal2("struct_or_union_specifier", $1, temp, $4);
                                                                }
  | struct_or_union IDENTIFIER   {
                                    temp = nonTerminal("IDENTIFIER", $2, NULL, NULL );
                                    $$ = nonTerminal2("struct_or_union_specifier", $1, temp, NULL);
                                  }
  ;

struct_or_union
  : STRUCT   { 
                  temp = nonTerminal("STRUCT", $1, NULL, NULL);
                  $$ = nonTerminal("struct_or_union", NULL, temp, NULL);
              }
  | UNION     { 
                  temp = nonTerminal("UNION", $1, NULL, NULL);
                  $$ = nonTerminal("struct_or_union", NULL, temp, NULL);
              }  
  ;

struct_declaration_list
  : struct_declaration   {$$ = nonTerminal("struct_declaration_list", NULL, $1, NULL);}
  | struct_declaration_list struct_declaration  {$$ = nonTerminal("struct_declaration_list", NULL, $1, $2);}
  ;

struct_declaration
  : specifier_qualifier_list ';'  {$$ = nonTerminal("struct_declaration", NULL, $1, NULL);}
  | specifier_qualifier_list struct_declarator_list ';' {$$ = nonTerminal("struct_declaration", NULL, $1, $2);}
  | static_assert_declaration  {$$ = nonTerminal("struct_declaration", NULL, $1, NULL);}
  ;

specifier_qualifier_list
	: type_specifier specifier_qualifier_list {$$ = nonTerminal("specifier_qualifier_list", NULL, $1, $2);}
	| type_specifier  {$$ = nonTerminal("specifier_qualifier_list", NULL, $1, NULL);}
	| type_qualifier specifier_qualifier_list  {$$ = nonTerminal("specifier_qualifier_list", NULL, $1, $2);}
	| type_qualifier  {$$ = nonTerminal("specifier_qualifier_list", NULL, $1, NULL);}
	;

struct_declarator_list
	: struct_declarator  {$$ = nonTerminal("struct_declarator_list", NULL, $1, NULL);}
	| struct_declarator_list ',' struct_declarator  {$$ = nonTerminal("struct_declarator_list", $2, $1, $3);}
	;

struct_declarator
	: ':' constant_expression {$$ = nonTerminal("struct_declarator", $1, NULL, $2);}
	| declarator ':' constant_expression  {$$ = nonTerminal("struct_declarator", $2, $1, $3);}
	| declarator {$$ = nonTerminal("struct_declarator", NULL, $1, NULL);}
	;

enum_specifier
	: ENUM '{' enumerator_list '}' {   
                                           temp=nonTerminal("ENUM",$1,NULL,NULL);
                                       	   $$ = nonTerminal("enum_specifier", NULL, temp, $3);
                                       }
	| ENUM '{' enumerator_list ',' '}' {    
                                                temp2=nonTerminal("ENUM",$1,NULL,NULL);
						temp = nonTerminal("enumerator_list ,", $4, $3, NULL);
						$$ = nonTerminal("enum_specifier", NULL, temp2, temp);
					   }
	| ENUM IDENTIFIER '{' enumerator_list '}'  {
                                                    temp2=nonTerminal("ENUM",$1,NULL,NULL);
					            temp1 = nonTerminal("IDENTIFIER", $2, NULL, NULL);
						    $$ = nonTerminal2("enum_specifier", temp2, temp1, $4);
                                                   }
	| ENUM IDENTIFIER '{' enumerator_list ',' '}' {
                                                        temp2=nonTerminal("ENUM",$1,NULL,NULL);
							temp1 = nonTerminal("IDENTIFIER", $2, NULL, NULL);
							temp = nonTerminal("enumerator_list ,", $5, $4, NULL);
							$$ = nonTerminal2("enum_specifier", temp2, temp1, temp);
                                                   }

	| ENUM IDENTIFIER                          {
                                                        temp2=nonTerminal("ENUM",$1,NULL,NULL);
							temp1 = nonTerminal("IDENTIFIER", $2, NULL, NULL);
							$$ = nonTerminal2("enum_specifier", temp2, temp1, NULL);
                                                   }

	;

enumerator_list
	: enumerator  {$$ = nonTerminal("enumerator_list", NULL, $1,  NULL);}
	| enumerator_list ',' enumerator {$$ = nonTerminal("enumerator_list", $2, $1,  $3);}
	;

enumerator	
	: enumeration_constant '=' constant_expression {$$ = nonTerminal("enumerator", $2, $1,  $3);}
	| enumeration_constant {$$ = nonTerminal("enumerator", NULL, $1,  NULL);}
	;

atomic_type_specifier
	: ATOMIC '(' type_name ')' {
					temp = nonTerminal("ATOMIC", $1, NULL, NULL);
					$$ = nonTerminal("atomic_type_specifier", NULL, temp, $3);
				   }
	;

type_qualifier
	: CONST {
		     temp = nonTerminal("CONST", $1, NULL, NULL);
		     $$ = nonTerminal("type_qualifier", NULL, temp, NULL);
		}
	| RESTRICT {
		     temp = nonTerminal("RESTRICT", $1, NULL, NULL);
		     $$ = nonTerminal("type_qualifier", NULL, temp, NULL);
		   }
	| VOLATILE {
		     temp = nonTerminal("VOLATILE", $1, NULL, NULL);
		     $$ = nonTerminal("type_qualifier", NULL, temp, NULL);
		   }
	| ATOMIC {
		     temp = nonTerminal("ATOMIC", $1, NULL, NULL);
		     $$ = nonTerminal("type_qualifier", NULL, temp, NULL);
		 }
	;

function_specifier
	: INLINE{
		     temp = nonTerminal("INLINE", $1, NULL, NULL);
		     $$ = nonTerminal("function_specifier", NULL, temp, NULL);
		}
	| NORETURN{
		     temp = nonTerminal("NORETURN", $1, NULL, NULL);
		     $$ = nonTerminal("function_specifier", NULL, temp, NULL);
		}
	;

alignment_specifier
	: ALIGNAS '(' type_name ')'{
				     temp = nonTerminal("ALIGNAS", $1, NULL, NULL);
				     $$ = nonTerminal("alignment_specifier", NULL, temp, $3);
				   }
	| ALIGNAS '(' constant_expression ')'{
					     temp = nonTerminal("ALIGNAS", $1, NULL, NULL);
					     $$ = nonTerminal("alignment_specifier", NULL, temp, $3);
					   }
	;

declarator
	: pointer direct_declarator {$$ = nonTerminal("declarator", NULL, $1, $2);}
	| direct_declarator {$$ = nonTerminal("declarator", NULL, $1, NULL);}
	;

direct_declarator
	: IDENTIFIER{
		     temp = nonTerminal("IDENTIFIER", $1, NULL, NULL);
		     $$ = nonTerminal("direct_declarator", NULL, temp, NULL);
		   }
	| '(' declarator ')' {$$ = nonTerminal("direct_declarator", NULL, $2, NULL);}
	| direct_declarator '[' ']' {$$ = nonTerminalSquareB("direct_declarator", $1);} 
	| direct_declarator '[' '*' ']' {$$ = nonTerminalFourChild("direct_declarator", $1, NULL, NULL, NULL, $3);}
	| direct_declarator '[' STATIC type_qualifier_list assignment_expression ']'{ 
				temp = nonTerminal("STATIC", $3, NULL,NULL);
				$$ = nonTerminalFourChild("direct_declarator", $1, temp, $4, $5, NULL);
                          }
	| direct_declarator '[' STATIC assignment_expression ']' { 
				temp = nonTerminal("STATIC", $3, NULL,NULL);
				$$ = nonTerminalFourChild("direct_declarator", $1, temp, $4, NULL, NULL);
                          }
	| direct_declarator '[' type_qualifier_list '*' ']' {$$ = nonTerminalFourChild("direct_declarator", $1, $3, NULL, NULL, $4);}
	| direct_declarator '[' type_qualifier_list STATIC assignment_expression ']' { 
				temp = nonTerminal("STATIC", $4, NULL,NULL);
				$$ = nonTerminalFourChild("direct_declarator", $1, $3, temp, $5, NULL);
                          }
	| direct_declarator '[' type_qualifier_list assignment_expression ']'{$$ = nonTerminalFourChild("direct_declarator", $1, $3, $4, NULL, NULL);}
	| direct_declarator '[' type_qualifier_list ']' {$$ = nonTerminal("direct_declarator", NULL, $1, $3);}
	| direct_declarator '[' assignment_expression ']' {$$ = nonTerminal("direct_declarator", NULL, $1, $3);}
	| direct_declarator '(' parameter_type_list ')' {$$ = nonTerminal("direct_declarator", NULL, $1, $3);}
	| direct_declarator '(' ')' {$$ = nonTerminalRoundB("direct_declarator", $1);} 
	| direct_declarator '(' identifier_list ')' {$$ = nonTerminal("direct_declarator", NULL, $1, $3);}
	;

pointer
	: '*' type_qualifier_list pointer {$$=nonTerminal("pointer",NULL,$2,$3);}
	| '*' type_qualifier_list  {$$=nonTerminal("pointer",NULL,$2,NULL);}
	| '*' pointer   {$$=nonTerminal("pointer",NULL,$2,NULL);}
	| '*'          {$$=nonTerminal("pointer",$1,NULL,NULL);}
	;


type_qualifier_list
	: type_qualifier {$$=nonTerminal("type_qualifier_list",NULL,$1,NULL);}
	| type_qualifier_list type_qualifier {$$=nonTerminal("type_qualifier_list",NULL,$1,$2);}
	;


parameter_type_list
	: parameter_list ',' ELLIPSIS {
					temp = nonTerminal("ELLIPSIS", $3, NULL, NULL);
					$$=nonTerminal("parameter_type_list",$2,$1,temp);
				      }
	| parameter_list {$$=nonTerminal("parameter_type_list",NULL,$1,NULL);}
	;

parameter_list
	: parameter_declaration {$$=nonTerminal("parameter_list",NULL,$1,NULL);}
	| parameter_list ',' parameter_declaration {$$=nonTerminal("parameter_list",$2,$1,$3);}
	;

parameter_declaration
	: declaration_specifiers declarator {$$=nonTerminal("parameter_declaration",NULL,$1,$2);}
	| declaration_specifiers abstract_declarator {$$=nonTerminal("parameter_declaration",NULL,$1,$2);}
	| declaration_specifiers {$$=nonTerminal("parameter_declaration",NULL,$1,NULL);}
	;

identifier_list
	: IDENTIFIER                  {
					temp = nonTerminal("IDENTIFIER", $1, NULL, NULL);
					$$=nonTerminal("identifier_list",NULL,NULL,temp);
				      }
	| identifier_list ',' IDENTIFIER {
					temp = nonTerminal("IDENTIFIER", $3, NULL, NULL);
					$$=nonTerminal("identifier_list",$2,$1,temp);
				      }
	;

type_name
	: specifier_qualifier_list abstract_declarator {$$=nonTerminal("type_name",NULL,$1,$2);}
	| specifier_qualifier_list {$$=nonTerminal("type_name",NULL,$1,NULL);}
	;

abstract_declarator
	: pointer direct_abstract_declarator {$$=nonTerminal("abstract_declarator",NULL,$1,$2);}
	| pointer {$$=nonTerminal("abstract_declarator",NULL,$1,NULL);}
	| direct_abstract_declarator {$$=nonTerminal("abstract_declarator",NULL,$1,NULL);}
	;

direct_abstract_declarator
	: '(' abstract_declarator ')'  {$$ = nonTerminal("direct_abstract_declarator", NULL, $2, NULL);}
	| '[' ']'  {$$ = nonTerminalSquareB("direct_abstract_declarator" ,NULL);}
	| '[' '*' ']' {$$ = nonTerminal("direct_abstract_declarator", $2, NULL, NULL);}
	| '[' STATIC type_qualifier_list assignment_expression ']' {
							             temp = nonTerminal("STATIC", $2, NULL, NULL);
								     $$ = nonTerminal2("direct_abstract_declarator", temp, $3, $4);
								   }
	| '[' STATIC assignment_expression ']'                     {
							             temp = nonTerminal("STATIC", $2, NULL, NULL);
								     $$ = nonTerminal2("direct_abstract_declarator", temp, $3, NULL);
								   }
	| '[' type_qualifier_list STATIC assignment_expression ']'{
							             temp = nonTerminal("STATIC", $3, NULL, NULL);
								     $$ = nonTerminal2("direct_abstract_declarator", $2, temp, $4);
								   }
	| '[' type_qualifier_list assignment_expression ']' {$$ = nonTerminal("direct_abstract_declarator", NULL, $2, $3);}
	| '[' type_qualifier_list ']' {$$ = nonTerminal("direct_abstract_declarator", NULL, $2, NULL);}
	| '[' assignment_expression ']'{$$ = nonTerminal("direct_abstract_declarator", NULL, $2, NULL);}
	| direct_abstract_declarator '[' ']' {$$ = nonTerminalSquareB("direct_abstract_declarator", $1);}
	| direct_abstract_declarator '[' '*' ']' {$$ = nonTerminal("direct_abstract_declarator", $3, $1, NULL);}
	| direct_abstract_declarator '[' STATIC type_qualifier_list assignment_expression ']'{ 
				temp = nonTerminal("STATIC", $3, NULL,NULL);
				$$ = nonTerminalFourChild("direct_abstract_declarator", $1, temp, $4, $5, NULL);
                          }
	| direct_abstract_declarator '[' STATIC assignment_expression ']'{ 
				temp = nonTerminal("STATIC", $3, NULL,NULL);
				$$ = nonTerminalFourChild("direct_abstract_declarator", $1, temp, $4, NULL, NULL);
                          }
	| direct_abstract_declarator '[' type_qualifier_list assignment_expression ']' {$$ = nonTerminal2("direct_abstract_declarator", $1, $3, $4);}
	| direct_abstract_declarator '[' type_qualifier_list STATIC assignment_expression ']'{ 
				temp = nonTerminal("STATIC", $4, NULL,NULL);
				$$ = nonTerminalFourChild("direct_abstract_declarator", $1, $3, temp,  $5, NULL);
                          }
	| direct_abstract_declarator '[' type_qualifier_list ']' {$$ = nonTerminal("direct_abstract_declarator",NULL, $1, $3);}
	| direct_abstract_declarator '[' assignment_expression ']' {$$ = nonTerminal("direct_abstract_declarator",NULL, $1, $3);}
	| '(' ')'  {$$ = nonTerminalRoundB("direct_abstract_declarator", NULL);}
	| '(' parameter_type_list ')' {$$ = nonTerminal("direct_abstract_declarator", NULL, $2, NULL);}
	| direct_abstract_declarator '(' ')'{$$ = nonTerminalRoundB("direct_abstract_declarator", $1);}
	| direct_abstract_declarator '(' parameter_type_list ')' {$$ = nonTerminal("direct_abstract_declarator", NULL, $1, $3);}
	;

initializer
	: '{' initializer_list '}' {$$ = nonTerminal("initializer", NULL, $2 ,NULL);}
	| '{' initializer_list ',' '}' {$$ = nonTerminal("initializer", $3, $2 ,NULL);}
	| assignment_expression {$$ = nonTerminal("initializer", NULL, $1 ,NULL);}
	;

initializer_list
	: designation initializer {$$ = nonTerminal("initializer_list", NULL, $1 ,$2);}
	| initializer {$$ = nonTerminal("initializer_list", NULL, $1 ,NULL);}
	| initializer_list ',' designation initializer {$$ = nonTerminal("initializer_list", $2, $1 ,$3);}
	| initializer_list ',' initializer {$$ = nonTerminal("initializer_list", $2, $1 ,$3);}
	;

designation
	: designator_list '='  {$$ = nonTerminal("designation", $2, $1 ,NULL);}
	;

designator_list
	: designator  {$$ = nonTerminal("designator_list", NULL, $1 ,NULL);}
	| designator_list designator  {$$ = nonTerminal("designator_list", NULL, $1 ,$2);}
	;

designator
	: '[' constant_expression ']'  {$$ = nonTerminal("designator", NULL, NULL ,$2);}
	| '.' IDENTIFIER   {
				temp = nonTerminal("IDENTIFIER", $2, NULL, NULL);
				$$ = nonTerminal("designator", $1, NULL, temp);
			   }
	;

static_assert_declaration
	: STATIC_ASSERT '(' constant_expression ',' STRING_LITERAL ')' ';' {
				temp = nonTerminal("STATIC_ASSERT", $1, NULL, NULL);
				temp1 = nonTerminal("STRING_LITERAL", $5, NULL, NULL);
				$$ = nonTerminal2("static_assert_declaration", temp, $3, temp1);
			   }
	;

statement
	: labeled_statement  {$$ = nonTerminal("statement", NULL, $1, NULL);}
	| compound_statement  {$$ = nonTerminal("statement", NULL, $1, NULL);}
	| expression_statement  {$$ = nonTerminal("statement", NULL, $1, NULL);}
	| selection_statement  {$$ = nonTerminal("statement", NULL, $1, NULL);}
	| iteration_statement  {$$ = nonTerminal("statement", NULL, $1, NULL);}
	| jump_statement  {$$ = nonTerminal("statement", NULL, $1, NULL);}
	;

labeled_statement
	: IDENTIFIER ':' statement {
				temp = nonTerminal("IDENTIFIER", $1, NULL, NULL);
				$$ = nonTerminal("labeled_statement", NULL, temp, $3);
			   }
	| CASE constant_expression ':' statement {
				temp = nonTerminal("CASE", $1, NULL, NULL);
				$$ = nonTerminal2("labeled_statement", temp, $2, $4);
			   }
	| DEFAULT ':' statement {
				temp = nonTerminal("DEFAULT", $1, NULL, NULL);
				$$ = nonTerminal("labeled_statement", NULL, temp, $3);
			   }
	;

compound_statement
	: '{' '}'   {$$ = nonTerminalCurlyB("compound_statement", NULL);} 
	| '{'  block_item_list '}' {$$ = nonTerminal("compound_statement", NULL , $2, NULL);}
	;

block_item_list
	: block_item  {$$ = nonTerminal("block_item_list", NULL, $1, NULL);}
	| block_item_list block_item  {$$ = nonTerminal("block_item_list", NULL, $1, $2);}
	;

block_item
	: declaration {$$ = nonTerminal("block_item", NULL, $1, NULL);}
	| statement {$$ = nonTerminal("block_item", NULL, $1, NULL);}
	;

expression_statement
	: ';' {$$ = nonTerminal("expression_statement", $1, NULL, NULL);}

	| expression ';' {$$ = nonTerminal("expression_statement",$2, $1, NULL);}
	;

selection_statement
	: IF '(' expression ')' statement ELSE statement {
							   temp = nonTerminal("IF", $1, NULL, NULL);
							   temp1 = nonTerminal("ELSE", $6, NULL, NULL);
                                                           $$ = nonTerminalFiveChild("selection_statement", temp, $3, $5, temp1, $7);
							 }
	| IF '(' expression ')' statement {
					   temp = nonTerminal("IF", $1, NULL, NULL);
                                           $$ = nonTerminalFiveChild("selection_statement", temp, $3, $5, NULL, NULL);
					 }
	| SWITCH '(' expression ')' statement{
					   temp = nonTerminal("SWITCH", $1, NULL, NULL);
                                           $$ = nonTerminalFiveChild("selection_statement", temp, $3, $5, NULL, NULL);
					 }
	;

iteration_statement
	: WHILE '(' expression ')' statement  {
					   temp = nonTerminal("WHILE", $1, NULL, NULL);
                                           $$ = nonTerminalFiveChild("iteration_statement", temp, $3, $5, NULL, NULL);
					 }
	| DO statement WHILE '(' expression ')' ';'{
							   temp = nonTerminal("DO", $1, NULL, NULL);
							   temp1 = nonTerminal("WHILE", $3, NULL, NULL);
                                                           $$ = nonTerminalFiveChild("iteration_statement", temp, $2, temp1, $5, NULL);
							 }
	| FOR '(' expression_statement expression_statement ')' statement  {
					   temp = nonTerminal("FOR", $1, NULL, NULL);
                                           $$ = nonTerminalFiveChild("iteration_statement", temp, $3, $4, $6, NULL);
					 }
	| FOR '(' expression_statement expression_statement expression ')' statement {
					   temp = nonTerminal("FOR", $1, NULL, NULL);
                                           $$ = nonTerminalFiveChild("iteration_statement", temp, $3, $4, $5, $7);
					 }
	| FOR '(' declaration expression_statement ')' statement  {
					   temp = nonTerminal("FOR", $1, NULL, NULL);
                                           $$ = nonTerminalFiveChild("iteration_statement", temp, $3, $4, $6, NULL);
					 }
	| FOR '(' declaration expression_statement expression ')' statement  {
					   temp = nonTerminal("FOR", $1, NULL, NULL);
                                           $$ = nonTerminalFiveChild("iteration_statement", temp, $3, $4, $5, $7);
					 }
	;

jump_statement
	: GOTO IDENTIFIER ';' {  
				temp = nonTerminal("GOTO", $1, NULL, NULL);
				temp1 = nonTerminal("IDENTIFIER", $2, NULL, NULL);
				$$ = nonTerminal("jump_statement", NULL, temp, temp1);
			      }
	| CONTINUE ';'	      {  
				temp = nonTerminal("CONTINUE", $1, NULL, NULL);
				$$ = nonTerminal("jump_statement", NULL, temp, NULL);
			      }
	| BREAK ';' 	      {  
				temp = nonTerminal("BREAK", $1, NULL, NULL);
				$$ = nonTerminal("jump_statement", NULL, temp, NULL);
			      }
	| RETURN ';' 	      {  
				temp = nonTerminal("RETURN", $1, NULL, NULL);
				$$ = nonTerminal("jump_statement", NULL, temp, NULL);
			      }
	| RETURN expression ';' {  
				    temp = nonTerminal("RETURN", $1, NULL, NULL);
				    $$ = nonTerminal("jump_statement", NULL, temp, $2);
			        }
	;

translation_unit
	: external_declaration  {$$ = nonTerminal("translation_unit", NULL, $1, NULL);}
	| translation_unit external_declaration  {$$ = nonTerminal("translation_unit", NULL, $1, $2);}
	;

external_declaration
	: function_definition  {$$ = nonTerminal("external_declaration", NULL, $1, NULL);}
	| declaration  {$$ = nonTerminal("external_declaration", NULL, $1, NULL);}
	;

function_definition
	: declaration_specifiers declarator declaration_list compound_statement {$$ = nonTerminalFourChild("function_definition", $1, $2, $3, $4, NULL);}
	| declaration_specifiers declarator compound_statement  {$$ = nonTerminal2("function_definition", $1, $2, $3);}
	;

declaration_list
	: declaration {$$ = nonTerminal("declaration_list", NULL, $1, NULL);}
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
      if (argc > 1)
      digraph =fopen(*(argv+1),"w");
      else {
        helpMessage();
        return 0;
      }
    }
    else if(!strcmp(*argv, "-i")){
      if (argc > 1){
        yyin =fopen(*(argv+1),"r");
        strncpy(filename,*(argv+1),1024);
        fileflag = 1;
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
  // default output file
  if(fileflag == 0)
  digraph =fopen("digraph.gv","w");

  graphInitialization();
  yyparse();
  
  graphEnd();
  return 0;
}
void yyerror(char *str){
  fprintf(stderr,"In %s at line no. %d :%s\n",filename,yylineno,str);
}

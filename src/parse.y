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
#include "symTable.h"
FILE *digraph;
FILE *duplicate;
node *temp,*temp1,*temp2;
char filename[1000];
extern int yylineno;
string symFileName;
%}


/* Reference LexxAndYaccTutorial : by Tom Niemann*/
%union {
  float f;
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
  : IDENTIFIER                    {$$=terminal($1);}
  | constant                      {$$=$1; }
  | string                        {$$=$1; }
  | '(' expression ')'            {$$=nonTerminal("primary_exprssion",NULL,$2,NULL); }
  | generic_selection             {$$=$1; }
  ;

constant
  : I_CONSTANT                    {$$=terminal($1);}
  | F_CONSTANT                    {$$=terminal($1);}
  | ENUMERATION_CONSTANT           {$$=terminal($1);}
  ;
enumeration_constant    /* before it has been defined as such */
  : IDENTIFIER                    {$$=terminal($1);}
  ;

string
  : STRING_LITERAL                {$$=terminal($1);}
  | FUNC_NAME                     {$$=terminal($1);}
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
  | postfix_expression '[' expression ']'    {$$ = nonTerminal("postfix_expression", NULL, $1, $3);} 
  | postfix_expression '(' ')'               {$$ = $1;} 
  | postfix_expression '(' argument_expression_list ')'   {$$ = nonTerminal("postfix_expression", NULL, $1, $3);} 
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
                                            } 
  | postfix_expression DEC_OP               {
                                                $$=  nonTerminal($2,NULL, $1,NULL); 
                                            } 
  | '(' type_name ')' '{' initializer_list '}' {
                                                  $$=  nonTerminal("postfix_expression", NULL, $2, $5);
                                               }
  | '(' type_name ')' '{' initializer_list ',' '}' {
                                                    $$=nonTerminalFourChild("postfix_expression",$2,$5,NULL,NULL,$6);
                                                   }
  ;

argument_expression_list
  : assignment_expression            {$$ = $1;} 
  | argument_expression_list ',' assignment_expression    {$$ = nonTerminal("argument_expression_list",NULL, $1, $3);} 
  ;

unary_expression
  : postfix_expression            {$$ = $1;} 
  | INC_OP unary_expression       {
                                      $$=  nonTerminal($1, NULL, NULL, $2); 
                                   } 

  | DEC_OP unary_expression       {
                                      $$=  nonTerminal($1, NULL, NULL, $2); 
                                   }
  | unary_operator cast_expression { $$ = nonTerminal("unary_expression", NULL, $1, $2);}
  | SIZEOF unary_expression       {
                                      $$=  nonTerminal($1, NULL, NULL, $2); 
                                   }
  | SIZEOF '(' type_name ')'   {
                                      $$=  nonTerminal($1, NULL, NULL, $3); 
                                   }
  | ALIGNOF '(' type_name ')'   {
                                      $$=  nonTerminal($1, NULL, NULL, $3); 
                                   }
  ;

unary_operator
  : '&'      { $$ = terminal("&");}
  | '*'      { $$ =  terminal("*");}
  | '+'      { $$ =  terminal("+");}
  | '-'      { $$ =  terminal("-");}
  | '~'      { $$ =  terminal("~");}
  | '!'      { $$ = terminal("!");}
  ;
      
cast_expression
        : unary_expression        {$$ = $1;}
        | '(' type_name ')' cast_expression {$$ = nonTerminal("cast_expression", NULL, $2, $4);}
        ;

multiplicative_expression
        : cast_expression                                     {$$=$1;}
        | multiplicative_expression '*' cast_expression       {$$=nonTerminal("*",NULL,$1,$3);}
        | multiplicative_expression '/' cast_expression       {$$=nonTerminal("/",NULL,$1,$3);}
        | multiplicative_expression '%' cast_expression       {$$=nonTerminal("%",NULL,$1,$3);}
        ;

additive_expression
        : multiplicative_expression                           {$$=$1;}
        | additive_expression '+' multiplicative_expression   {$$=nonTerminal("+",NULL,$1,$3);}
        | additive_expression '-' multiplicative_expression   {$$=nonTerminal("-",NULL,$1,$3);}
        ;


shift_expression
  : additive_expression     {$$ = $1;}
  | shift_expression LEFT_OP additive_expression {
                                                    $$ = nonTerminal2($2, $1,NULL, $3);
                                                  }
  | shift_expression RIGHT_OP additive_expression {
                                                    $$ = nonTerminal2($2, $1,NULL, $3);
                                                  }
  ;

relational_expression
  : shift_expression     {$$ = $1;}
  | relational_expression '<' shift_expression   {$$ = nonTerminal($2, NULL, $1, $3);}
  | relational_expression '>' shift_expression   {$$ = nonTerminal( $2,NULL, $1, $3);}
  | relational_expression LE_OP shift_expression  {
                                                    $$ = nonTerminal2($2, $1,NULL, $3);
                                                  }
  | relational_expression GE_OP shift_expression{
                                                    $$ = nonTerminal2($2, $1,NULL, $3);
                                                  }
  ;

equality_expression
  : relational_expression   {$$ = $1;}
  | equality_expression EQ_OP relational_expression {
                                                    $$ = nonTerminal2($2, $1,NULL, $3);
                                                  }
  | equality_expression NE_OP relational_expression {
                                                    $$ = nonTerminal2($2, $1,NULL, $3);
                                                  }
  ;

and_expression
  : equality_expression  { $$ = $1;}
  | and_expression '&' equality_expression  {$$ = nonTerminal($2, NULL, $1, $3);}
  ;

exclusive_or_expression
  : and_expression   { $$ = $1;}
  | exclusive_or_expression '^' and_expression  {$$ = nonTerminal( $2,NULL, $1, $3);}
  ;

inclusive_or_expression
  : exclusive_or_expression    { $$ = $1;}
  | inclusive_or_expression '|' exclusive_or_expression  {$$ = nonTerminal( $2,NULL, $1, $3);}
  ;

logical_and_expression
  : inclusive_or_expression { $$ = $1;}
  | logical_and_expression AND_OP inclusive_or_expression  {
                                                            $$ = nonTerminal2($2, $1,NULL, $3);
                                                            }
  ;

logical_or_expression
  : logical_and_expression  { $$ = $1;}
  | logical_or_expression OR_OP logical_and_expression  {
                                                            $$ = nonTerminal2($2, $1,NULL, $3);
                                                            }
  ;

conditional_expression
  : logical_or_expression  { $$ = $1;}
  | logical_or_expression '?' expression ':' conditional_expression  {$$ = nonTerminal2("conditional_expression", $1, $3, $5);}
  ;

assignment_expression
  : conditional_expression  { $$ = $1;}
  | unary_expression assignment_operator assignment_expression  {$$ = nonTerminal2("assignment_expression", $1, $2, $3);}
  ;

assignment_operator
  : '='    { $$ = terminal($1);}
  | MUL_ASSIGN  { 
                  $$ = terminal($1);
                }
  | DIV_ASSIGN  { 
                  $$ = terminal($1);
                }
  | MOD_ASSIGN  { 
                  $$ = terminal($1);
                }
  | ADD_ASSIGN  { 
                  $$ = terminal($1);
                }
  | SUB_ASSIGN  { 
                  $$ = terminal($1);
                }
  | LEFT_ASSIGN { 
                  $$ = terminal($1);
                }
  | RIGHT_ASSIGN  { 
                  $$ = terminal($1);
                }
  | AND_ASSIGN  { 
                  $$ = terminal($1);
                }
  | XOR_ASSIGN  { 
                  $$ = terminal($1);
                }
  | OR_ASSIGN    { 
                  $$ = terminal($1);
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
  : declaration_specifiers ';'  { $$ = $1;}
  | declaration_specifiers init_declarator_list ';'  { $$ = nonTerminal("declaration", NULL, $1, $2);}
  | static_assert_declaration   { $$ = $1;}
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
  | init_declarator_list ',' init_declarator  { $$ = nonTerminal("init_declaration_list", NULL, $1, $3);}
  ;

init_declarator
  : declarator '=' initializer  { $$ = nonTerminal( $2,NULL, $1, $3);}
  | declarator     { $$ = $1;}
  ;

storage_class_specifier
  : TYPEDEF   { 
                  $$=terminal($1);
              }
  | EXTERN    { 
                  $$=terminal($1);
              }
  | STATIC    { 
                  $$=terminal($1);
              }
  | THREAD_LOCAL { 
                  $$=terminal($1);
              }
  | AUTO      { 
                  $$=terminal($1);
              }
  | REGISTER  { 
                  $$=terminal($1);
              }
  ;

type_specifier
  : VOID     { 
                  $$=terminal($1);
              }
  | CHAR     { 
                  $$=terminal($1);
              }
  | SHORT     { 
                  $$=terminal($1);
              }
  | INT       { 
                  $$=terminal($1);
              }
  | LONG      { 
                  $$=terminal($1);
              }
  | FLOAT     { 
                  $$=terminal($1);
              }
  | DOUBLE    { 
                  $$=terminal($1);
              }
  | SIGNED    { 
                  $$=terminal($1);
              }
  | UNSIGNED  { 
                  $$=terminal($1);
              }
  | BOOL      { 
                  $$=terminal($1);
              }
  | COMPLEX   { 
                  $$=terminal($1);
              }
  | IMAGINARY { 
                  $$=terminal($1);
              }   
  | atomic_type_specifier  {$$ = $1;}
  | struct_or_union_specifier  {$$ = $1;}
  | enum_specifier  {$$ = $1;}
  | TYPEDEF_NAME    { 
                  $$=terminal($1);
              }
  ;

struct_or_union_specifier
  : struct_or_union '{' struct_declaration_list '}' {$$ = nonTerminal("struct_or_union_specifier", NULL, $1, $3);}
  | struct_or_union IDENTIFIER '{' struct_declaration_list '}'  {
                                                                  $$ = nonTerminal("struct_or_union_specifier",$2,$1, $4);
                                                                }
  | struct_or_union IDENTIFIER   {
                                    $$ = nonTerminal("struct_or_union_specifier",$2, $1 ,NULL);
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
	| struct_declarator_list ',' struct_declarator  {$$ = nonTerminal("struct_declarator_list", NULL, $1, $3);}
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
						$$ = nonTerminal1("enum_specifier", $1, $3, $4);
					   }
	| ENUM IDENTIFIER '{' enumerator_list '}'  {
						    $$ = nonTerminal3("enum_specifier",$1,$2, $4,NULL);
                                                   }
	| ENUM IDENTIFIER '{' enumerator_list ',' '}' {
						    $$ = nonTerminal3("enum_specifier",$1,$2, $4,$5);
                                                   }

	| ENUM IDENTIFIER                          {
						    $$ = nonTerminal3("enum_specifier",$1,$2,NULL,NULL);
                                                   }

	;

enumerator_list
	: enumerator  {$$ = $1;}
	| enumerator_list ',' enumerator {$$ = nonTerminal("enumerator_list", NULL, $1,  $3);}
	;

enumerator	
	: enumeration_constant '=' constant_expression {$$ = nonTerminal($2,NULL, $1,  $3);}
	| enumeration_constant {$$ = $1;}
	;

atomic_type_specifier
	: ATOMIC '(' type_name ')' {
					$$ = nonTerminal("atomic_type_specifier", $1, NULL, $3);
				   }
	;

type_qualifier
	: CONST {
                     $$ = terminal($1);
		}
	| RESTRICT {
                     $$ = terminal($1);
		   }
	| VOLATILE {
                     $$ = terminal($1);
		   }
	| ATOMIC {
                     $$ = terminal($1);
		 }
	;

function_specifier
	: INLINE{
                     $$ = terminal($1);
		}
	| NORETURN{
                     $$ = terminal($1);
		}
	;

alignment_specifier
	: ALIGNAS '(' type_name ')'{
				     $$ = nonTerminal("alignment_specifier",$1,NULL, $3);
				   }
	| ALIGNAS '(' constant_expression ')'{
				     $$ = nonTerminal("alignment_specifier",$1,NULL, $3);
					   }
	;

declarator
	: pointer direct_declarator {$$ = nonTerminal("declarator", NULL, $1, $2);}
	| direct_declarator {$$ = $1;}
	;

direct_declarator
	: IDENTIFIER{
                     $$=terminal($1);
		   }
	| '(' declarator ')' {$$ = $2;}
	| direct_declarator '[' ']' {$$ = nonTerminalSquareB("direct_declarator", $1);} 
	| direct_declarator '[' '*' ']' {$$ = nonTerminalFourChild("direct_declarator", $1, NULL, NULL, NULL, $3);}
	| direct_declarator '[' STATIC type_qualifier_list assignment_expression ']'{ 
				temp = terminal($3);
				$$ = nonTerminalFourChild("direct_declarator", $1, temp, $4, $5, NULL);
                          }
	| direct_declarator '[' STATIC assignment_expression ']' { 
				temp = terminal($3);
				$$ = nonTerminalFourChild("direct_declarator", $1, temp, $4, NULL, NULL);
                          }
	| direct_declarator '[' type_qualifier_list '*' ']' {$$ = nonTerminalFourChild("direct_declarator", $1, $3, NULL, NULL, $4);}
	| direct_declarator '[' type_qualifier_list STATIC assignment_expression ']' { 
				temp = terminal($4);
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
	: '*' type_qualifier_list pointer {$$=nonTerminal($1,NULL,$2,$3);}
	| '*' type_qualifier_list  {$$=nonTerminal($1,NULL,$2,NULL);}
	| '*' pointer   {$$=nonTerminal($1,NULL,$2,NULL);}
	| '*'          {$$=terminal($1);}
	;


type_qualifier_list
	: type_qualifier {$$=$1;}
	| type_qualifier_list type_qualifier {$$=nonTerminal("type_qualifier_list",NULL,$1,$2);}
	;


parameter_type_list
	: parameter_list ',' ELLIPSIS {
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
	: declaration_specifiers declarator {$$=nonTerminal("parameter_declaration",NULL,$1,$2);}
	| declaration_specifiers abstract_declarator {$$=nonTerminal("parameter_declaration",NULL,$1,$2);}
	| declaration_specifiers {$$=$1;}
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
	| direct_abstract_declarator '[' ']' {$$ = nonTerminal("direct_abstract_declarator","[ ]",$1,NULL);}
	| direct_abstract_declarator '[' '*' ']' {$$ = nonTerminal("direct_abstract_declarator", "[ * ]", $1, NULL);}
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
	| direct_abstract_declarator '(' ')'{$$ = nonTerminal("direct_abstract_declarator","( )",$1,NULL);}
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
	| initializer_list ',' designation initializer {$$ = nonTerminal2("initializer_list", $1, $3 ,$4);}
	| initializer_list ',' initializer {$$ = nonTerminal("initializer_list", NULL, $1 ,$3);}
	;

designation
	: designator_list '='  {$$ = nonTerminal("designation", $2, $1 ,NULL);}
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
	: '{' '}'   {$$ = terminal("{ }");} 
	| '{'  block_item_list '}' {$$ = $2;}
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

	| expression ';' {$$ = $1;}
	;

selection_statement
	: IF '(' expression ')' statement ELSE statement {
                                                           $$ = nonTerminalFiveChild("IF (expr) stmt ELSE stmt", NULL, $3, $5, NULL, $7);
							 }
	| IF '(' expression ')' statement {
                                           $$ = nonTerminalFiveChild("IF (expr) stmt", NULL, $3, $5, NULL, NULL);
					 }
	| SWITCH '(' expression ')' statement{
                                           $$ = nonTerminalFiveChild("SWITCH (expr) stmt", NULL, $3, $5, NULL, NULL);
					 }
	;

iteration_statement
	: WHILE '(' expression ')' statement  {
                                           $$ = nonTerminalFiveChild("WHILE (expr) stmt", NULL, $3, $5, NULL, NULL);
					 }
	| DO statement WHILE '(' expression ')' ';'{
                                                     $$ = nonTerminalFiveChild("DO stmt WHILE (expr)", NULL, $2, NULL, $5, NULL);
					           }
	| FOR '(' expression_statement expression_statement ')' statement  {
                                           $$ = nonTerminalFiveChild("FOR (expr_stmt expr_stmt) stmt", NULL, $3, $4, $6, NULL);
					 }
	| FOR '(' expression_statement expression_statement expression ')' statement {
                                           $$ = nonTerminalFiveChild("FOR (expr_stmt expr_stmt expr) stmt", NULL, $3, $4, $5, $7);
					 }
	| FOR '(' declaration expression_statement ')' statement  {
                                           $$ = nonTerminalFiveChild("FOR ( decl expr_stm ) stmt", NULL, $3, $4, $6, NULL);
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
	| CONTINUE ';'	      {  
				$$ = terminal($1);
			      }
	| BREAK ';' 	      {  
				$$ = terminal($1);
			      }
	| RETURN ';' 	      {  
				$$ = terminal($1);
			      }
	| RETURN expression ';' {  
				    temp = terminal($1);
				    $$ = nonTerminal("jump_statement", NULL, temp, $2);
			        }
	;

translation_unit
	: external_declaration  {$$ = $1;}
	| translation_unit external_declaration  {$$ = nonTerminal("translation_unit", NULL, $1, $2);}
	;

external_declaration
	: function_definition  {$$ = $1;}
	| declaration  {$$ = $1;}
	;

function_definition
	: declaration_specifiers declarator declaration_list compound_statement {$$ = nonTerminalFourChild("function_definition", $1, $2, $3, $4, NULL);}
	| declaration_specifiers declarator compound_statement  {$$ = nonTerminal2("function_definition", $1, $2, $3);}
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
  return 0;
}
void yyerror(char *str){
  
  int count = 1;
  if(str=="syntax error") count = 2;
  fprintf(stderr,"In %s at line no. %d :%s\n",filename,yylineno,str);
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

%{
#include <stdlib.h>
#include <stdio.h>
#include "./src/nodes.h"
#include "parse.tab.h"
void yyerror (char *);
%}
%e 1019
%p 2807
%n 371
%a 1213
%o 1117

O   [0-7]
D   [0-9]
NZ  [1-9]
L   [a-zA-Z_]
A   [a-zA-Z_0-9]
H   [a-fA-F0-9]
HP  (0[xX])    
E   ([Ee][+-]?{D}+)
P   ([Pp][+-]?{D}+)
FS  (f|F|l|L)
IS  (((u|U)(l|L|ll|LL)?)|((l|L|ll|LL)(u|U)?))
CP  (u|U|L)
SP  (u8|u|U|L)
ES  (\\(['\?\\abfnrtv]|[0-7]{1,3}|x[a-fA-F0-9]+))
WS  [ \t\v\n\f]
%%

"auto"					{ yylval.str=strdup(yytext); return(AUTO); }
"break"					{ yylval.str=strdup(yytext);return(BREAK); }
"case"					{ yylval.str=strdup(yytext);return(CASE); }
"char"					{ yylval.str=strdup(yytext);return(CHAR); }
"const"					{ yylval.str=strdup(yytext);return(CONST); }
"continue"				{ yylval.str=strdup(yytext);return(CONTINUE); }
"default"				{ yylval.str=strdup(yytext);return(DEFAULT); }
"do"					{ yylval.str=strdup(yytext);return(DO); }
"double"				{ yylval.str=strdup(yytext);return(DOUBLE); }
"else"					{ yylval.str=strdup(yytext);return(ELSE); }
"enum"					{ yylval.str=strdup(yytext);return(ENUM); }
"extern"				{ yylval.str=strdup(yytext);return(EXTERN); }
"float"					{ yylval.str=strdup(yytext);return(FLOAT); }
"for"					{ yylval.str=strdup(yytext);return(FOR); }
"goto"					{ yylval.str=strdup(yytext);return(GOTO); }
"if"					{ yylval.str=strdup(yytext);return(IF); }
"inline"				{ yylval.str=strdup(yytext);return(INLINE); }
"int"					{ yylval.str=strdup(yytext);return(INT); }
"long"					{ yylval.str=strdup(yytext);return(LONG); }
"register"				{ yylval.str=strdup(yytext);return(REGISTER); }
"restrict"				{ yylval.str=strdup(yytext);return(RESTRICT); }
"return"				{ yylval.str=strdup(yytext);return(RETURN); }
"short"					{ yylval.str=strdup(yytext);return(SHORT); }
"signed"				{ yylval.str=strdup(yytext);return(SIGNED); }
"sizeof"				{ yylval.str=strdup(yytext);return(SIZEOF); }
"static"				{ yylval.str=strdup(yytext);return(STATIC); }
"struct"				{ yylval.str=strdup(yytext);return(STRUCT); }
"switch"				{ yylval.str=strdup(yytext);return(SWITCH); }
"typedef"				{ yylval.str=strdup(yytext);return(TYPEDEF); }
"union"					{ yylval.str=strdup(yytext);return(UNION); }
"unsigned"				{ yylval.str=strdup(yytext);return(UNSIGNED); }
"void"					{ yylval.str=strdup(yytext);return(VOID); }
"volatile"				{ yylval.str=strdup(yytext);return(VOLATILE); }
"while"					{ yylval.str=strdup(yytext);return(WHILE); }
"_Alignas"                              { yylval.str=strdup(yytext);return ALIGNAS; }
"_Alignof"                              { yylval.str=strdup(yytext);return ALIGNOF; }
"_Atomic"                               { yylval.str=strdup(yytext);return ATOMIC; }
"_Bool"                                 { yylval.str=strdup(yytext);return BOOL; }
"_Complex"                              { yylval.str=strdup(yytext);return COMPLEX; }
"_Generic"                              { yylval.str=strdup(yytext);return GENERIC; }
"_Imaginary"                            { yylval.str=strdup(yytext);return IMAGINARY; }
"_Noreturn"                             { yylval.str=strdup(yytext);return NORETURN; }
"_Static_assert"                        { yylval.str=strdup(yytext);return STATIC_ASSERT; }
"_Thread_local"                         { yylval.str=strdup(yytext);return THREAD_LOCAL; }
"__func__"                              { yylval.str=strdup(yytext);return FUNCTION_NAME; }

{NZ}{D}*      { 
 			  yylval.str = strdup(yytext);
			  return INTEGER;
			} 

"*"        {
			yylval.str = strdup(yytext);
			 return '*';
		   }
"+"        {
 				yylval.str = strdup(yytext);
 				 return '+'; 
 			} 
"-"        {
			yylval.str = strdup(yytext);
			 return '-'; 
			}
"/"        {
			yylval.str = strdup(yytext);
			 return '/'; 
			 	 	}

%%

int yywrap(void) {
  return 1;
}

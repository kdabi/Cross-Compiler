%{
#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include "nodes.h"
#include "parse.tab.h"
void yyerror (char *,...);
void get_int_info();
void get_real_info();
extern int sym_type(const char *);
#define sym_type(identifier) IDENTIFIER
static int returnType(void);
static void startComment(void);
%}
%e 1019
%p 2807
%n 371
%a 1213
%o 1117
%option yylineno

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
"/*"                    {startComment();/*consuming all the characters of comment */}
"//".*                  {/* Consume the comment */}

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
"__func__"                              { yylval.str=strdup(yytext);return FUNC_NAME; }


{L}{A}*                                 { return returnType(); }

{HP}{H}+{IS}?                           {sscanf(yytext+2,"%llx",&yylval.num->iVal);get_int_info();yylval.num->str = strdup(yytext);
                                        return I_CONSTANT;}
{NZ}{D}*{IS}?                           {sscanf(yytext,"%lld",&yylval.num->iVal);get_int_info(); yylval.num->str = strdup(yytext);return I_CONSTANT;}
"0"{O}*{IS}?                            {sscanf(yytext,"%lld",&yylval.num->iVal);get_int_info(); yylval.num->str = strdup(yytext); return I_CONSTANT;}
{CP}?"'"([^'\\\n]|{ES})+"'"             {get_int_info(); yylval.num->str = strdup(yytext); ;return I_CONSTANT;}

{D}+{E}{FS}?                            {yylval.num->str = strdup(yytext);get_real_info(); return F_CONSTANT;}
{D}*"."{D}+{E}?{FS}?                    {yylval.num->str = strdup(yytext);get_real_info(); return F_CONSTANT;}
{D}+"."{E}?{FS}?                        {yylval.num->str = strdup(yytext);get_real_info(); return F_CONSTANT;}
{HP}{H}+{P}{FS}?                        {yylval.num->str = strdup(yytext);get_real_info(); return F_CONSTANT;}
{HP}{H}*"."{H}+{P}{FS}?                 {yylval.num->str = strdup(yytext);get_real_info(); return F_CONSTANT;}
{HP}{H}+"."{P}{FS}?                     {yylval.num->str = strdup(yytext);get_real_info(); return F_CONSTANT;}

({SP}?\"([^"\\\n]|{ES})*\"{WS}*)+       {yylval.str=strdup(yytext); return STRING_LITERAL;} 

"..."					{ yylval.str=strdup(yytext);return ELLIPSIS; }
">>="					{ yylval.str=strdup(yytext);return RIGHT_ASSIGN; }
"<<="					{ yylval.str=strdup(yytext);return LEFT_ASSIGN; }
"+="					{ yylval.str=strdup(yytext);return ADD_ASSIGN; }
"-="					{ yylval.str=strdup(yytext);return SUB_ASSIGN; }
"*="					{ yylval.str=strdup(yytext);return MUL_ASSIGN; }
"/="					{ yylval.str=strdup(yytext);return DIV_ASSIGN; }
"%="					{ yylval.str=strdup(yytext);return MOD_ASSIGN; }
"&="					{ yylval.str=strdup(yytext);return AND_ASSIGN; }
"^="					{ yylval.str=strdup(yytext);return XOR_ASSIGN; }
"|="					{ yylval.str=strdup(yytext);return OR_ASSIGN; }
">>"					{ yylval.str=strdup(yytext);return RIGHT_OP; }
"<<"					{ yylval.str=strdup(yytext);return LEFT_OP; }
"++"					{ yylval.str=strdup(yytext);return INC_OP; }
"--"					{ yylval.str=strdup(yytext);return DEC_OP; }
"->"					{ yylval.str=strdup(yytext);return PTR_OP; }
"&&"					{ yylval.str=strdup(yytext);return AND_OP; }
"||"					{ yylval.str=strdup(yytext);return OR_OP; }
"<="					{ yylval.str=strdup(yytext);return LE_OP; }
">="					{ yylval.str=strdup(yytext);return GE_OP; }
"=="					{ yylval.str=strdup(yytext);return EQ_OP; }
"!="					{ yylval.str=strdup(yytext);return NE_OP; }
";"					{ yylval.str=strdup(yytext);return ';'; }
("{"|"<%")				{ yylval.str=strdup(yytext);return '{'; }
("}"|"%>")				{ yylval.str=strdup(yytext);return '}'; }
","					{ yylval.str=strdup(yytext);return ','; }
":"					{ yylval.str=strdup(yytext);return ':'; }
"="					{ yylval.str=strdup(yytext);return '='; }
"("					{ yylval.str=strdup(yytext);return '('; }
")"					{ yylval.str=strdup(yytext);return ')'; }
("["|"<:")				{ yylval.str=strdup(yytext);return '['; }
("]"|":>")				{ yylval.str=strdup(yytext);return ']'; }
"."					{ yylval.str=strdup(yytext);return '.'; }
"&"					{ yylval.str=strdup(yytext);return '&'; }
"!"					{ yylval.str=strdup(yytext);return '!'; }
"~"					{ yylval.str=strdup(yytext);return '~'; }
"-"					{ yylval.str=strdup(yytext);return '-'; }
"+"					{ yylval.str=strdup(yytext);return '+'; }
"*"					{ yylval.str=strdup(yytext);return '*'; }
"/"					{ yylval.str=strdup(yytext);return '/'; }
"%"					{ yylval.str=strdup(yytext);return '%'; }
"<"					{ yylval.str=strdup(yytext);return '<'; }
">"					{ yylval.str=strdup(yytext);return '>'; }
"^"					{ yylval.str=strdup(yytext);return '^'; }
"|"					{ yylval.str=strdup(yytext);return '|'; }
"?"					{ yylval.str=strdup(yytext);return '?'; }
\n                                    {}
" "                                        {}
{WS}                                       {}
.                                  {yyerror("Undefined pattern");}
({SP}?\"([^"\\\n]|{ES})*)        { yyerror("Incomplete String");} 
%%

int yywrap(void) {
  return 1;
} 
void get_int_info(){
   int i;
   yylval.num->nType = yylval.num->is_unsigned=1;
   for(i=yyleng-1;;i--){
       if(yytext[i]=='u'||yytext[i]=='U')
                yylval.num->is_unsigned =1;
       else if (yytext[i]=='l'||yytext[i] == 'L')
                yylval.num->nType++;
       else
             break;

   }


}
void get_real_info(){
   int i=yyleng-1;
   sscanf(yytext,"Lf",&yylval.num->rVal);
       if(yytext[i]=='f'||yytext[i]=='F')
                yylval.num->nType =N_FLOAT;
       else if (yytext[i]=='l'||yytext[i] == 'L')
                yylval.num->nType = N_LONGDOUBLE;
       else
               yylval.num->nType =N_DOUBLE;




}

static void startComment(void)
{
    int c;

    while ((c = yyinput()) != EOF){
        if (c == '*')
        {
            while ((c = yyinput()) == '*') ;


            if (c == '/')
                return;

            if (c == -1)
                break;
        }
    }
    yyerror("unterminated comment");
}
static int returnType(void)
{
 yylval.str = strdup(yytext);
{       string m =returnSymType(yytext);
        if(m=="TYPEDEF_NAME")
             return TYPEDEF_NAME;
        else if(m=="ENUMERATION_CONSTANT")
             return ENUMERATION_CONSTANT;
        else
            return IDENTIFIER;

}
   
}

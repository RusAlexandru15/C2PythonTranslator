%{
#include "y.tab.h"
%}

%%

[-+*/]    {yylval.svalue=strdup(yytext); return OP;} //operatori

"+="      {yylval.svalue=strdup(yytext); return SHORTOP;}
"-="      {yylval.svalue=strdup(yytext); return SHORTOP;}
"/="      {yylval.svalue=strdup(yytext); return SHORTOP;}
"*="      {yylval.svalue=strdup(yytext); return SHORTOP;}

[<>]     {yylval.svalue=strdup(yytext); return IFOP;}
"=="     {yylval.svalue=strdup(yytext); return IFOP;}
"!="     {yylval.svalue=strdup(yytext); return IFOP;}
"<="     {yylval.svalue=strdup(yytext); return IFOP;}
">="     {yylval.svalue=strdup(yytext); return IFOP;}


"++"     { return SHORTPLUS;}
"--"     { return SHORTMINUS;}

[()]          return *yytext; 
"{"             return OPENBRACE;
"}"             return CLOSEBRACE;

"&&"      { return ANDOP;}
"||"      { return OROP;}
"else if" {return ELIF;}
"if"      { return IF;}
"else"    {return ELSE;}
"while"   {return WHILE;}

"for"    {return FOR;}
"printf" {yylval.svalue=strdup("print"); return PRINT; }

[,"]       return *yytext;

"int"         ;
"float"       ;
"long"        ;
"double"      ;
"%d"          ;
"%g"          ;
"%s"          ;

"//"[a-zA-Z ]+  {yylval.svalue=strdup(yytext+2); return COMLINE;} //comentariu

[0-9]+     {yylval.svalue=strdup(yytext); return NUM;} //numere
[a-zA-Z]+  {yylval.svalue =strdup(yytext); return VAR; } //variabile

[ \t]      ;
\n         ;

.          return *yytext;

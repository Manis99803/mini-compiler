%{
#include"y.tab.h"
#include<stdio.h>
#include<string.h>
int LineNo=1;
int scopeCount = -1;


%}
identifier [a-zA-Z][_a-zA-Z0-9]*
number [0-9]+|([0-9]*\.[0-9]+)
%%
\/\/(.*)		{}
\/\*(.*\n)*.*\*\/ 	{}
"#include<stdio.h>"     {}
"while" {return WHILE; }
"if" {return IF;}
"main"	{ return MAIN;}
"int"|"char"|"float" {	strcpy(yylval.var,yytext); return TYPE;}
{identifier} {strcpy(yylval.var,yytext);return VAR;}
{number} {strcpy(yylval.var,yytext);return NUM;}
\<|\>|\>=|\<=|==|!= {strcpy(yylval.var,yytext);return RELOP;}
"{"	{ scopeCount++; return '{';}
"}"	{ scopeCount--; return '}';}
[ \t] ;
\n LineNo++;
. return *yytext;
%%

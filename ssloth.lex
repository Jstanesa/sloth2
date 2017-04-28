/*John Stanesa Sloth lexer
*/
%{
#include <stdio.h>
#include <string.h>
#include "compiler.tab.h"
%}
%option noyywrap
openBracket "["
closeBracket "]"
openCurly "{"
closeCurly "}"
float "float"
array "array"
start "begin"
end "end"
if "if"
then "then"
else "else"
while "while"
do "do"
print "print"
input "input"

digit [0-9]
alpha [a-zA-Z]

identifier [a-zA-Z_][a-zA-Z0-9_]*
value [0-9]*\.?[0-9]+

comment %.*\n
whitespace [ \t\n]
plus "+"
minus "-"
slash "/"
star "*"
lessEqual <=
greatEqual >=
less <
great >
equal ==
not !
notEqual !=
and "&&"
or "||"
endLine ;
assignment :=
openParen "("
closeParen ")"
comma ","
undefined .
%%
{comment}
{whitespace}
{plus} return 102;
{minus} return 103;
{slash} return 104;
{star} return 105;
{less} return 106;
{great} return 107;
{lessEqual} return 108;
{greatEqual} return 109;
{equal} return 110;
{notEqual} return 111;
{and} return 112;
{or} return 113;
{not} return 114;
{endLine} return 115;
{assignment} return 116;
{openParen} return 117;
{closeParen} return 118;
{start} return 119;
{end} return 120;
{if} return 121;
{then} return 122;
{else} return 123;
{while} return 124;
{do} return 125;
{print} return 126;
{input} return 127;
{openBracket} return 128;
{closeBracket} return 129;
{openCurly} return 130;
{closeCurly} return 131;
{float} return 132;
{array} return 133;
{comma} return 134;
{identifier} {strcpy(yylval.str,yytext); return 100;}
{value} {yylval.val =atof(yytext); return 101;}
{undefined} printf("Error: character not defined\n"); return 0;
%%
/*
main(int argc, char *argv[])
{
    if(argc<2){
	printf("Error: you must pass a file to be lexed\n");
	return 0;
    }
    stdin = fopen(argv[1], "r");
    if(stdin==NULL){
	printf("Error: file does not exist\n");
	return 0;
    }
    //while(yylex()!=0);
    int token=1;
    while(token!=0){
	token=yylex();
	if(token>10)
	    printf("%d\n",token);
    }
}
*/

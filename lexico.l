%{
    #include <stdio.h>
    #include "y.tab.h"
    #include <string.h>
    #include <stdlib.h> 
    #include <stdarg.h>
    #include "alpha.h"

    extern int yyerror (char *msg);
%}

%%

[ \t\n]                   ;
[0-9]+                    { yylval.iValue = atoi(yytext); return INT;}            
"program"                 { return(PROGRAM);}
"type"                    { yylval.sValue = strdup(yytext); return (TYPE); }
"var"                     { return(VAR); }
"add"                     { return(ADD); }
"mul"                     { return(MUL); }
"rel"                     { return(REL); }
"int"                     { return(INT); }
"float"                   { return(FLOAT); }
"char"                    { return(CHAR); }
"string"                  { return(STRING); }
"bool"                    { return(BOOL); }
"if"                      { return(IF); }
"else"                    { return(ELSE); }
"then"                    { return(THEN); }
"while"                   { return(WHILE); }
"begin"                   { return(B_BEGIN); }
"end"                     { return(B_END); }
"switch"                  { return(SWITCH); }
"case"                    { return(CASE); }
"for"                     { return(FOR); }
"void"                    { return(VOID); }
"static"                  { return(STATIC); }
"const"                   { return(CONST); }
"default"                 { return(DEFAULT); }
"break"                   { return(BREAK); }
"continue"                { return(CONTINUE); }
"exit"                    { return(EXIT); }
"return"                  { return(RETURN); }
"print"                   { return(PRINT); }
"scan"                    { return(SCAN); }
"malloc"                  { return(MALLOC); }
"free"                    { return(FREE); }
"inttostr"                { return(INTTOSTR); }
"strtoint"                { return(STRTOINT); }
"floattostr"              { return(FLOATTOSTR); }
"strtofloat"              { return(STRTOFLOAT); }
"inttofloat"              { return(INTTOFLOAT); }
"floattoint"              { return(FLOATTOINT); }
"include"                 { return(INCLUDE); }
"assing"                  { return(ASSING); }
"read"                    { return(READ); }
"write"                   { return(WRITE); }
","                       { return(VIRGULA);}
"+"                       { return(SUM); }
"-"                       { return(SUB); }
"/"                       { return(DIV); }
"*"                       { return(MULT); }
"="                       { return(IQUAL); }
":="                      { return(ASSIGN); }
"+="                      { return(SUMIQ); }
"-="                      { return(SUBIQ); }
"++"                      { return(SUMS); }
"--"                      { return(SUBS); }
"=="                      { return(IQUALS); }
"!="                      { return(DIFS); }
">"                       { return(BIG); }
"<"                       { return(SMA); }
">="                      { return(BIGS); }
"<="                      { return(SMAS); }
"!"                       { return(NOT); }
"&&"                      { return(AND); }
"||"                      { return(OR); }
"("                       { return(PARL); }
")"                       { return(PARR); }
"{"                       { return(KEYL); }
"}"                       { return(KEYR); }
";"                       { return(SEMI); }
"["                       { return(BRAL); } 
"]"                       { return(BRAR); }
[a-zA-Z][a-zA-Z0-9]*      { yylval.sValue = strdup(yytext); return ID;}
.                         { yyerror("invalid character");}


%%

#ifndef yywrap
    int yywrap (void) {
        return 1;
    }
#endif


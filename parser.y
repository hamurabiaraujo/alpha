%{
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h> 
#include <stdarg.h>
#include <math.h>
//#include "alpha.h"

int yylex(void);
int yyerror(char* yaccProvidedMessage); 
FILE *file;
extern int yylineno;     //i declare yylineno from the lexical analyzer
extern char *yytext;
extern FILE *yyin; 

%}

// TODO: criar novos tipos

// TODO: criar regras de precedência


%union {
	int    iValue; 	/* integer value */
    char   sIndex; /* symbol table index */
	char * sValue;  /* string value */
//    nodo    nod;
};

%token <sValue> ID TYPE STRING
%token <sIndex> CHAR
%token <iValue> INT
%token <fValue> FLOAT
%token <ident> 
    PROGRAM 
    ADD 
    MUL 
    REL 
    VAR 
    BOOL 
    THEN 
    ASSING 
    READ 
    WRITE
%token IF ELSE WHILE B_BEGIN B_END SWITCH CASE FOR FUNC
%token STATIC CONST DEFAULT BREAK CONTINUE EXIT RETURN VOID NUM
%token PRINT SCAN MALLOC FREE INCLUDE
%token INTTOSTR STRTOINT FLOATTOSTR STRTOFLOAT INTTOFLOAT FLOATTOINT 
%token <ident> 
    IQUAL 
    ASSIGN 
    SUMIQ 
    SUBIQ 
    SUMS 
    SUBS 
    NOT 
    AND 
    OR 
    PARL 
    PARR 
    KEYL 
    KEYR 
    SEMI 
    BRAL 
    BRAR 
    VIRGULA
    POW
    PERC
%left BIGS SMAS IQUALS DIFS BIG SMA
%left SUM SUB
%left MULT DIV
%left PARR OR AND POW ID SCAN FUNC
%left INTTOSTR STRTOINT FLOATTOSTR STRTOFLOAT INTTOFLOAT FLOATTOINT
%left VOID STRING CHAR INT FLOAT
%right PARL VIRGULA MENUN
%right NOT RETURN
%nonassoc UMINUS 
%nonassoc IFX B_END FUNCX
%nonassoc ELSE 

%start prog
//%type <nod>
//    elem
//    elemlist
%type <sValue>
    stm 
    stmlist 
    expr 
    decls 
    decl 
    ids 
    call 
    args  
    tipo
    scan
    base_expr
    return
    function
    subprograms
    if
    while
    print

%%

prog : PROGRAM subprograms B_BEGIN decls stmlist B_END {
        
        printf("\nAplicação gerada com sucesso!\n");
        
    }
    ;

subprograms :  {}
            | function subprograms {fprintf(file, "{\n\t%s",$2);}
            ;

function : tipo ID PARL decls PARR B_BEGIN stmlist B_END {
        fprintf(file,"%s %s ( %s ) { \n\t %s\n", $1,$2,$4,$7);
    }
    ;

decls :  decl {}
       | decl SEMI decls {}
       ;

decl : tipo ids {fprintf(file,"%s \n",$2);}
     ;

ids :  ID             {$$ = $1;}
     | ID VIRGULA ids {fprintf(file,",");}
     ;

stmlist : stm                   {}
        | stmlist SEMI stm      {}
        ;

stm : while {}
    | if {}
    | print {}
    | scan {} 
    | call {}
    | return {}
    | break {}
    | switch {}
    | case {}
    ;

case : CASE ID expr BREAK {}
    ;

switch : SWITCH ID {}

break : BREAK {fprintf(file,"\n\tbreak;");}
    ;

while : WHILE expr B_BEGIN stmlist B_END {}
    ;

return : RETURN expr {fprintf(file,"\n\treturn (%s); \n }", $2); }
    ;     

if : IF PARL expr PARR B_BEGIN stmlist B_END {fprintf(file,"\n\tif (%s) {%s;\n} ; \n",$3,$6);}
    | IF PARL expr PARR B_BEGIN stmlist B_END ELSE B_BEGIN stmlist B_END {fprintf(file,"\n\tif (%s) {\n%s;\n} else {\n%s\n}; \n",$3,$6,$10);}
    ;

print : PRINT PARL expr PARR {fprintf(file,"\n\tprintf (%s); \n",$3);}
    ;

scan : SCAN PARL ID VIRGULA expr PARR {
    //fprintf(file,"\tscanf("d",&%s);\n",$5);
    
    if ( atoi($3) == atoi("i")) 
        fprintf(file,"\tscanf('%%d',&%s);\n",$5);
    else if ( atoi($3) == atoi("s")) 
        fprintf(file,"\tscanf('%%s',&%s);\n",$5);
    else if ( atoi($3) == atoi("c")) 
        fprintf(file,"\tscanf('%%c',&%s);\n",$5);
    else if ( atoi($3) == atoi("f")) 
        fprintf(file,"\tscanf('%%f',&%s);\n",$5);    
    else yyerror; 
    }
    ;
    
tipo : VOID {fprintf(file,"\nvoid "); }
     | STRING {fprintf(file,"\nstring "); }
     | CHAR {fprintf(file,"\nchar "); }
     | INT { fprintf(file,"\nint ");}
     | FLOAT {fprintf(file,"\nfloat "); }
     | BOOL {fprintf(file,"\nbool "); }
     ;

call : ID PARL args PARR {fprintf(file,"(%s) \n", $3);}
       ;

args :   expr {fprintf(file,"%s; \n", $1);}
       | expr VIRGULA expr {fprintf(file,",");};

base_expr : ID  {}
          | call {}
          | literal {}
          ;

literal : INT
       ;

expr :  base_expr  {}
      | PARL expr PARR {fprintf(file,"%s",$2);}
      | expr SUM base_expr {fprintf(file,"%s+",$1);}
      | expr SUB base_expr {fprintf(file,"%s-",$1);}
      | expr MULT base_expr {fprintf(file,"%s*",$1);}
      | expr DIV base_expr {fprintf(file,"%s/",$1);}
      | expr DIFS base_expr {fprintf(file,"%s != ",$1);} 
      | expr IQUALS base_expr {fprintf(file,"%s == ",$1);}
      | expr AND base_expr {fprintf(file,"%s &&",$1);}
      | expr OR base_expr {fprintf(file,"%s || ",$1);}
      | expr POW base_expr { }      
      ;

%%


int main (int argc, char *argv[]) {
    file = fopen("saida.c","w");
	return yyparse( );
}

int yyerror (char *msg) {
	fprintf (stderr, "Linha %d: %s\n", yylineno, yytext);
	return 0;
}

%{
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h> 
#include <stdarg.h>
#include <math.h>
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

%%

prog : PROGRAM subprograms B_BEGIN decls stmlist B_END {

        printf("\nAplicação encerrada\n");
        
    }
    ;

subprograms :  {}
            | function subprograms {}
            ;

function : tipo ID PARL decls PARR B_BEGIN stmlist B_END {
        fprintf(file,"%s %s ( %s ) { \n\t %s\n", $1,$2,$4,$7);
    }
    ;

decls :  decl {$$ = $1;}
       | decl SEMI decls {fprintf(file,"%s; \n",$1);}
       ;

decl : tipo ids {fprintf(file,"\t%s \n",$1);}
     ;

ids :  ID             {$$ = $1;}
     | ID VIRGULA ids {fprintf(file,",");}
     ;

stmlist : stm                   {}
        | stmlist SEMI stm      {}
        ;

stm :  scan {} 
     | call {}
     | return {}
     | if {}
     ;

return : RETURN expr {
        fprintf(file,"\n\treturn %s; \n",$2);
    }
    ;     

if : IF PARL expr PARR B_BEGIN stmlist B_END {fprintf(file,"\n\tif (%s) {%s;\n} ; \n",$3,$6);};

scan : SCAN PARL expr PARR {fprintf(file,"\tscanf(%s);\n",$3); }
    ;
    
tipo : VOID {fprintf(file,"\nvoid "); }
     | STRING {fprintf(file,"\nstring "); }
     | CHAR {fprintf(file,"\nchar "); }
     | INT { fprintf(file,"\nint ");}
     | FLOAT {fprintf(file,"\nfloat "); }
     | BOOL {fprintf(file,"\nbool "); }
     ;

call : ID PARL args PARR {}
       ;

args :   expr {fprintf(file,"%s; \n", $1);}
       | expr VIRGULA expr {fprintf(file,",");};

base_expr : ID  {}
          | call {$$ = $1;}
          | literal {}
          ;

literal: INT
       ;

expr :  base_expr  {}
      | PARL expr PARR {}
      | expr SUM base_expr {}
      | expr SUB base_expr {}
      | expr MULT base_expr {}
      | expr DIV base_expr {}
      | expr DIFS base_expr {} 
      | expr IQUALS base_expr {}
      | expr AND base_expr {}
      | expr OR base_expr { }
      | base_expr POW expr {}      
      ;

%%


int main (void) {
    file = fopen("saida.c","w");
	return yyparse( );
}

int yyerror (char *msg) {
	fprintf (stderr, "Linha %d: %s\n", yylineno, yytext);
	return 0;
}

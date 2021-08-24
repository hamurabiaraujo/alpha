%{
#include <stdio.h>
#include <string.h>

int yylex(void);
int yyerror(char *s);
extern int yylineno;
extern char * yytext;

%}

%union {
	int    iValue; 	/* integer value */
	char   cValue; 	/* char value */
	char * sValue;  /* string value */
	};

%token <sValue> ID
%token <iValue> NUMBER
%token INT FLOAT STRING PROGRAM TYPE ADD MUL REL VAR BOOL THEN ASSING READ WRITE 
%token IF ELSE WHILE DO B_BEGIN B_END CASE FOR 
%token VOID STATIC CONST DEFAULT BREAK CONTINUE EXIT QUIT RETURN 
%token PRINTF SCANF MALOC FREE INCLUDE
%token INTTOSTR STRTOINT FLOATTOSTR STRTOFLOAT INTTOFLOAT FLOATTOINT 
%token SUM SUB DIV MULT IQUAL ASSIGN SUMIQ SUBIQ SUMS SUBS IQUALS DIFS BIG SMA BIGS SMAS NOT AND OR PARL PARR KEYL KEYR SEMI BRAL BRAR

%start prog

%type <sValue> stm

%%
prog : stmlist {} 
	 ;

stm : ID ASSIGN ID             {printf("%s := %s\n",$1,$3);}
    | WHILE ID DO stm			{printf("%s := %s\n",$2,$4);}
	| B_BEGIN stmlist B_END	    {}
	
    | IF ID THEN stm {
        int size = 12 + strlen($2) + strlen($4);
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "if (%s) {\n\t %s\n}", $2, $4);
        free($4);
        $$ = s;
	  };

	| IF ID THEN stm ELSE stm {
        int size = 22 + strlen($2) + strlen($4) + strlen($6);
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "if (%s) {\n\t %s\n }else{\n\t %s}", $2, $4, $6);
        free($4);
        free($6);
        $$ = s;
	  };
      
    | CASE ID stm              {printf("%s := %s\n",$2,$3);}
    | FOR ID stm            	{printf("%s := %s\n",$2,$3);}
    | INTTOSTR ID stm          {printf("%s := %s\n",$2,$3);}
    | STRTOINT ID stm          {printf("%s := %s\n",$2,$3);}
    | FLOATTOSTR ID stm        {printf("%s := %s\n",$2,$3);}
    | STRTOFLOAT ID stm        {printf("%s := %s\n",$2,$3);}
    | INTTOFLOAT ID stm        {printf("%s := %s\n",$2,$3);}
    | FLOATTOINT ID stm        {printf("%s := %s\n",$2,$3);}
    | PRINTF stm               {printf("%s\n",$2);}
    | SCANF stm                {printf("%s\n",$2);}
    | RETURN ID                {printf("%s\n",$2);}
    | MALOC stm                {printf("%s\n",$2);}
    | FREE stm                 {printf("%s\n",$2);}
    | QUIT stm                 {printf("%s\n",$2);}
    | BREAK stm                {printf("%s\n",$2);}
    | CONTINUE stm             {printf("%s\n",$2);}
    | EXIT stm                 {printf("%s\n",$2);}
	;
	
stmlist : stm					{}
		| stmlist SEMI stm		{}
	    ;
%%

int main (void) {
	return yyparse ( );
}

int yyerror (char *msg) {
	fprintf (stderr, "%d: %s at '%s'\n", yylineno, msg, yytext);
	return 0;
}

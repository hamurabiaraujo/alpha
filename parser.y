%{
#include <stdio.h>
#include <string.h>

int yylex(void);
int yyerror(char *s);
extern int yylineno;
extern char * yytext;

%}

// TODO: criar novos tipos

// TODO: criar regras de precedência

%union {
	int    iValue; 	/* integer value */
	char   cValue; 	/* char value */
	char * sValue;  /* string value */
	};

%token <sValue> ID TYPE
%token <iValue> NUMBER
%token INT FLOAT STRING PROGRAM ADD MUL REL VAR BOOL THEN ASSING READ WRITE 
%token IF ELSE WHILE DO B_BEGIN B_END SWIT CASE FOR 
%token VOID STATIC CONST DEFAULT BREAK CONTINUE EXIT RETURN 
%token PRINT SCAN MALLOC FREE INCLUDE
%token INTTOSTR STRTOINT FLOATTOSTR STRTOFLOAT INTTOFLOAT FLOATTOINT 
%token SUM SUB DIV MULT IQUAL ASSIGN SUMIQ SUBIQ SUMS SUBS IQUALS DIFS BIG SMA BIGS SMAS NOT AND OR PARL PARR KEYL KEYR SEMI BRAL BRAR VIRGULA

%start prog

%type <sValue> stm stmlist expr decls decl ids


%%
prog : decls stmlist {
        printf("%s \n%s", $1, $2);
        printf("\nAplicação encerrada");
        free($1);
        free($2);
    };


decls :  decl       {$$ = $1;}
       | decl decls {
           int size = strlen($1) + strlen($2) + 2;
           char * s = malloc(sizeof(char) * size);
           sprintf(s, "%s\n%s", $1, $2);
           free($1);
           free($2);
           $$ = s;
       };

decl : TYPE ids {
           int size = strlen($1) + strlen($2) + 2;
           char * s = malloc(sizeof(char) * size);
           sprintf(s, "%s %s", $1, $2);
           free($2);
           $$ = s;
      };

ids :  ID           {$$ = $1;}
     | ID VIRGULA ids {
           int size = strlen($1) + strlen($3) + 3;
           char * s = malloc(sizeof(char) * size);
           sprintf(s, "%s, %s", $1, $3);
           free($3);
           $$ = s;
      };

stm : ID ASSIGN expr {
        int size = strlen($1) + strlen($3) + 5;
        char * s = malloc(sizeof(char) * size);
        sprintf(s,"%s = %s%c\n",$1,$3, 59);
        free($3);
        $$ = s;
    }

    | WHILE ID DO stm {
        int size = 16 + strlen($2) + strlen($4);
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "while (%s) {\n\t %s\n}", $2, $4);
        free($4);
        $$ = s;
    }

	| B_BEGIN stmlist B_END	{
        int size = strlen($2)+7;
        char * s = malloc(sizeof(char) * size);
        sprintf(s,"\n{ \n%s \n}", $2);
        free($2);
        $$ = s;
    }
	
    | IF ID THEN stm { 
        int size = 13 + strlen($2) + strlen($4);
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "if (%s) {\n\t %s\n}", $2, $4);
        free($4);
        $$ = s;
    }

	| IF ID THEN stm ELSE stm {
        int size = 24 + strlen($2) + strlen($4) + strlen($6);
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "if (%s) {\n\t %s\n }else{\n\t %s}", $2, $4, $6);
        free($4);
        free($6);
        $$ = s;
    }

    | SWIT ID stm {
        int size = 15 + strlen($2) + strlen($3);
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "switch (%s) {\n\t %s\n}", $2, $3);
        free($3);
        $$ = s;
    }
      
    | CASE stm {
        int size = 11 + strlen($2);
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "case {\n\t %s\n}", $2);
        free($2);
        $$ = s;
    }

    | BREAK {
        int size = 7;
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "break; /n");
        $$ = s;
    }

    | DEFAULT {
        int size = 9;
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "default; /n");
        $$ = s;
    }

    | FOR ID stm {
        int size = 11 + strlen($2) + strlen($3);
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "for (%s) {\n\t %s\n}", $2, $3);
        free($3);
        $$ = s;
    }
    
    | STRTOINT ID stm          {printf("%s := %s\n",$2,$3);}
    | FLOATTOSTR ID stm        {printf("%s := %s\n",$2,$3);}
    | STRTOFLOAT ID stm        {printf("%s := %s\n",$2,$3);}
    | INTTOFLOAT ID stm        {printf("%s := %s\n",$2,$3);}
    | FLOATTOINT ID stm        {printf("%s := %s\n",$2,$3);}
    | PRINT stm {
        int size = 12 + strlen($2);
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "printf (\n %s\n)", $2);
        free($2);
        $$ = s;
    }
    | SCAN stm {
        int size = 12 + strlen($2);
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "scanf (\n %s\n)", $2);
        free($2);
        $$ = s;
    }
    | RETURN ID {
        int size = 10 + strlen($2);
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "return \n %s\n", $2);
        free($2);
        $$ = s;
    }
    | MALLOC stm {
        int size = 10 + strlen($2);
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "malloc ( %s )\n", $2);
        free($2);
        $$ = s;
    }
    | FREE stm {
        int size = 9 + strlen($2);
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "free ( %s )\n", $2);
        free($2);
        $$ = s;
    }

    | CONTINUE {
        int size = 10;
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "continue; /n");
        $$ = s;
    }

    | EXIT {
        int size = 9;
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "exit(0); /n");
        $$ = s;
    }
	
stmlist : stm					{$$ = $1;}
		| stmlist SEMI stm		{
            int size = strlen($1) + strlen($3) + 2;
            char * s = malloc(sizeof(char) * size);
            sprintf(s, "%s;%s", $1,$3);
            free($1);
            free($3);
            $$ = s;
        };

expr : ID           {$$ = $1;}
    | ID SUM expr {
        int size = strlen($1) + strlen($3) + 4;
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "%s + %s", $1,$3);
        free($3);
        $$ = s;
    }
    | ID SUB expr {
        int size = strlen($1) + strlen($3) + 4;
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "%s - %s", $1,$3);
        free($3);
        $$ = s;
    }
    | ID MULT expr {
        int size = strlen($1) + strlen($3) + 4;
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "%s * %s", $1,$3);
        free($3);
        $$ = s;
    }
    | ID DIV expr {
        int size = strlen($1) + strlen($3) + 4;
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "%s / %s", $1,$3);
        free($3);
        $$ = s;
    };
%%

int main (void) {
	return yyparse ( );
}

int yyerror (char *msg) {
	fprintf (stderr, "%d: %s at '%s'\n", yylineno, msg, yytext);
	return 0;
}

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
    float  fValue;  /* float value */
	char   cValue; 	/* char value */
	char * sValue;  /* string value */
};

%left '+' '-' 
%left '*' '/'

%token <sValue> ID TYPE
%token <iValue> INT
%token <fValue> FLOAT
%token STRING PROGRAM ADD MUL REL VAR BOOL THEN ASSING READ WRITE 
%token IF ELSE WHILE B_BEGIN B_END SWITCH CASE FOR 
%token VOID STATIC CONST DEFAULT BREAK CONTINUE EXIT RETURN 
%token PRINT SCAN MALLOC FREE INCLUDE
%token INTTOSTR STRTOINT FLOATTOSTR STRTOFLOAT INTTOFLOAT FLOATTOINT 
%token SUM SUB DIV MULT IQUAL ASSIGN SUMIQ SUBIQ SUMS SUBS IQUALS DIFS BIG SMA BIGS SMAS NOT AND OR PARL PARR KEYL KEYR SEMI BRAL BRAR VIRGULA

%start prog

%type <sValue> stm stmlist expr decls decl ids bloco invoker args opera

%%
prog : decls bloco {
        printf("%s \n%s", $1, $2);
        printf("\nAplicação encerrada");
        free($1);
        free($2);
    };


decls :  decl       {$$ = $1;}
       | decl decls {
           int size = 1 + strlen($1) + strlen($2);
           char * s = malloc(sizeof(char) * size);
           sprintf(s, "%s\n%s", $1, $2);
           free($1);
           free($2);
           $$ = s;
       };

decl : TYPE ids {
           int size = 1 + strlen($1) + strlen($2);
           char * s = malloc(sizeof(char) * size);
           sprintf(s, "%s %s", $1, $2);
           free($1);
           free($2);
           $$ = s;
    }

    | INT ids { }
    | FLOAT ids { }


ids :  ID           {$$ = $1;}
     | ID VIRGULA ids {
           int size = 2 + strlen($1) + strlen($3) + 3;
           char * s = malloc(sizeof(char) * size);
           sprintf(s, "%s, %s", $1, $3);
           free($3);
           $$ = s;
      };

stm : ID ASSIGN expr {
        int size = 4 + strlen($1) + strlen($3) + 5;
        char * s = malloc(sizeof(char) * size);
        sprintf(s,"%s = %s%c\n",$1,$3, 59);
        free($3);
        $$ = s;
    }

    | WHILE expr B_BEGIN bloco B_END { 
        int size = 16 + strlen($2) + strlen($4);
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "while (%s) {\n\t %s\n}", $2, $4);
        free($4);
        $$ = s;
    }
	
    | IF expr THEN bloco { 
        int size = 13 + strlen($2) + strlen($4);
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "if (%s) {\n\t %s\n}", $2, $4);
        free($4);
        $$ = s;
    }

	| IF expr THEN bloco ELSE bloco {
        int size = 24 + strlen($2) + strlen($4) + strlen($6);
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "if (%s) {\n\t %s\n }else{\n\t %s}", $2, $4, $6);
        free($4);
        free($6);
        $$ = s;
    }

    | SWITCH ID stm {
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
        int size = 8;
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "break; \n");
        $$ = s;
    }

    | DEFAULT {
        int size = 10;
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "default; \n");
        $$ = s;
    }

    | FOR expr stm {
        int size = 14 + strlen($2) + strlen($3);
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "for (%s) {\n\t %s\n}", $2, $3);
        free($3);
        $$ = s;
    }
    
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

bloco : { }
        | stmlist {$$ = $1;};
	
stmlist : stm					{$$ = $1;}
		| stmlist SEMI stm		{
            int size = 1 + strlen($1) + strlen($3) + 2;
            char * s = malloc(sizeof(char) * size);
            sprintf(s, "%s;%s", $1,$3);
            free($1);
            free($3);
            $$ = s;
        };

expr : ID {$$ = $1;}
    | opera {$$ = $1;}
    | opera IQUALS opera {
        int size = 4 + strlen($1) + strlen($3) + 5;
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "%s == %s", $1,$3);
        free($3);
        $$ = s;
    }
    | opera DIFS opera {
        int size = 4 + strlen($1) + strlen($3) + 5;
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "%s != %s", $1,$3);
        free($3);
        $$ = s;
    }
    | invoker {
        $$ = $1;
    };

invoker : ID PARL args PARR {
    int size = 3 + strlen($1) + strlen($3);
    char * s = malloc(sizeof(char) * size);
    sprintf(s, "%s (%s)", $1,$3);
    free($3);
    $$ = s;
};

args : ID {
        $$ = $1;
    };

opera : ID SUM expr {
        int size = 3 + strlen($1) + strlen($3) + 4;
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "%s + %s", $1,$3);
        free($3);
        $$ = s;
    }
    | ID SUB expr {
        int size = 3 - strlen($1) + strlen($3) + 4;
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "%s - %s", $1,$3);
        free($3);
        $$ = s;
    }
    | ID MULT expr {
        int size = 3 + strlen($1) + strlen($3) + 4;
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "%s * %s", $1,$3);
        free($3);
        $$ = s;
    }
    | ID DIV expr {
        int size = 3 + strlen($1) + strlen($3) + 4;
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "%s / %s", $1,$3);
        free($3);
        $$ = s;
    };
%%

// int main (int argc, char *argv[]) {
//     FILE *fp;

//     if((fp=fopen(argv[1],"w"))==NULL){
//         printf("Erro ao abrir o arquivo");
//     }
//     else
//     {
// 	    return yyparse ( );
//     }

//     fclose(fp);
// }

int main (void) {
	return yyparse ( );
}

int yyerror (char *msg) {
	fprintf (stderr, "%4d: %s na linha '%s'\n", ++yylineno, msg, yytext);
	return 0;
}

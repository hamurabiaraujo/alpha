%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h> 
#include <stdarg.h>
#include "alpha.h"

nodeType *opr(int oper, int nops, ...); 
nodeType *id(int i); 
nodeType *con(int value); 
void freeNode(nodeType *p); 
int ex(nodeType *p);

int yylex(void);
int yyerror(char *s);
int sym[26]; /* symbol table */ 

extern int yylineno;
extern char * yytext;

%}

// TODO: criar novos tipos

// TODO: criar regras de precedência


%union {
	int    iValue; 	/* integer value */
    //float  fValue;  /* float value */
	//char   cValue; 	/* char value */
    char   sIndex; /* symbol table index */
	char * sValue;  /* string value */
    //nodeType *nPtr; /* node pointer */ 
};

%token <sValue> ID TYPE
%token <iValue> INT
%token <fValue> FLOAT
%token STRING PROGRAM ADD MUL REL VAR BOOL THEN ASSING READ WRITE 
%token IF ELSE WHILE B_BEGIN B_END SWITCH CASE FOR 
%token VOID STATIC CONST DEFAULT BREAK CONTINUE EXIT RETURN 
%token PRINT SCAN MALLOC FREE INCLUDE
%token INTTOSTR STRTOINT FLOATTOSTR STRTOFLOAT INTTOFLOAT FLOATTOINT 
%token IQUAL ASSIGN SUMIQ SUBIQ SUMS SUBS NOT AND OR PARL PARR KEYL KEYR SEMI BRAL BRAR VIRGULA

%left BIGS SMAS IQUALS DIFS BIG SMA
%left '+' '-' 
%left '*' '/'
%left SUM SUB
%left MULT DIV
%nonassoc UMINUS 
%nonassoc IFX
%nonassoc ELSE 

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

stm : expr { $$ = $1; } 
    
    | ID ASSIGN expr {
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
    
    | PRINT PARL stm PARR {
        int size = 12 + strlen($3);
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "printf (\n %s\n)", $3);
        free($3);
        $$ = s; 

        //$$ = opr(PRINT, 1, $3); 
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

#define SIZEOF_NODETYPE ((char *)&p->con - (char *)p)  

nodeType *con(int value) {     
    nodeType *p;     
    size_t nodeSize;      
    
    /* allocate node */     
    nodeSize = SIZEOF_NODETYPE + sizeof(conNodeType);     
    
    if ((p = malloc(nodeSize)) == NULL)         
        yyerror("out of memory");      
        
    /* copy information */     
    p->type = typeCon;     
    p->con.value = value;      
    return p; 
}  

nodeType *id(int i) {     
    nodeType *p;     
    size_t nodeSize;      
    /* allocate node */     
    nodeSize = SIZEOF_NODETYPE + sizeof(idNodeType);
    if ((p = malloc(nodeSize)) == NULL)    
         yyerror("out of memory");      
    
    /* copy information */     
    p->type = typeId;     
    p->id.i = i;      
    return p; 
}  

nodeType *opr(int oper, int nops, ...) {     
    va_list ap;     
    nodeType *p;     
    size_t nodeSize;     
    int i;      
    
    /* allocate node */     
    nodeSize = SIZEOF_NODETYPE + sizeof(oprNodeType) +         
    (nops - 1) * sizeof(nodeType*);     
    
    if ((p = malloc(nodeSize)) == NULL)     
        yyerror("out of memory");      
    
    /* copy information */     
    p->type = typeOpr;     
    p->opr.oper = oper;     
    p->opr.nops = nops;     
    va_start(ap, nops);     
    for (i = 0; i < nops; i++)         
        p->opr.op[i] = va_arg(ap, nodeType*);     
    
    va_end(ap);     
    return p; 
}

void freeNode(nodeType *p) {     
    int i;      
    if (!p) return;     
    if (p->type == typeOpr) {         
        for (i = 0; i < p->opr.nops; i++)             
            freeNode(p->opr.op[i]);     
    }     
    free (p); 
}

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

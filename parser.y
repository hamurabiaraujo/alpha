%{
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h> 
#include <stdarg.h>
#include <math.h>
#include "alpha.h"
//#define YYSTYPE STRING
//#include "lex.yy.c"

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

void Expected (char *s) {
    printf("\n Esperado: %s \n",s);
}



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
    bloco 
    invoker 
    args 
    opera 
    import
    importlist
    arq
    funcion
    tipo

%%

prog : importlist PROGRAM B_BEGIN decls bloco B_END {
        
        printf("\nAplicação encerrada");
        free($1);
        free($4);
        free($5);
    };

funcion : tipo FUNC ID PARL ID PARR bloco %prec FUNCX{
        int size = 10 + strlen($1) + strlen($3) + strlen($5) + strlen($7);
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "%s %s(%s) {\n\t %s ;\n}\n",$1,$3,$5,$7);
        free($1);
        free($3);
        free($5);
        free($7);
        $$ = s;
    }

import : INCLUDE arq {
        int size = 10 + strlen($2);
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "#include %s\n", $2);
        free($2);
        $$ = s;
    };

importlist : {}
    | importlist SEMI import {
        int size = 2 + strlen($1) + strlen($3);
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "%s;\n%s", $1,$3);
        free($1);
        free($3);
        $$ = s;
    };

arq : ID {$$ = $1;};

/*
prog : decls bloco {
        printf("%s \n%s", $1, $2);
        printf("\nAplicação encerrada");
        free($1);
        free($2);
    };
    */

decls :  decl {$$ = $1;}
       | decl decls {
           int size = 1 + strlen($1) + strlen($2);
           char * s = malloc(sizeof(char) * size);
           sprintf(s, "%s\n%s", $1, $2);
           free($1);
           free($2);
           $$ = s;
       };
       
tipo : VOID { 
            int size = 5;
            char * s = malloc(sizeof(char) * size);
            sprintf(s, "void ");
            return 0;
    }
    | STRING { 
            int size = 7;
            char * s = malloc(sizeof(char) * size);
            sprintf(s, "string ");
            return 0;
    }
    | CHAR { 
            int size = 5;
            char * s = malloc(sizeof(char) * size);
            sprintf(s, "char ");
            return 0;
    }
    | INT { 
            int size = 4;
            char * s = malloc(sizeof(char) * size);
            sprintf(s, "int ");
            return 0;
    }
    | FLOAT { 
            int size = 56;
            char * s = malloc(sizeof(char) * size);
            sprintf(s, "float ");
            return 0;
    }
    | BOOL { 
            int size = 5;
            char * s = malloc(sizeof(char) * size);
            sprintf(s, "bool ");
            return 0;
    };

decl :  tipo ids { 
            int size = 1 + strlen($2);
            char * s = malloc(sizeof(char) * size);
            sprintf(s, "%s %s", $1,$2);
            free($2);
            $$ = s;
    };


ids :  ID           {$$ = $1;}
     | ID VIRGULA ids {
           int size = 2 + strlen($1) + strlen($3) + 3;
           char * s = malloc(sizeof(char) * size);
           sprintf(s, "%s, %s", $1, $3);
           free($3);
           $$ = s;
      };

stm : expr { $$ = $1; } 
    | funcion {$$ = $1;}
    | ID ASSIGN expr {
        int size = 9 + strlen($1) + strlen($3);
        char * s = malloc(sizeof(char) * size);
        sprintf(s,"%s = %s;%c\n",$1,$3, 59);
        free($3);
        $$ = s;
    }

    | B_BEGIN bloco %prec B_END{
        int size = 7 + strlen($2);
        char * s = malloc(sizeof(char) * size);
        sprintf(s,"{ \n\t %s; \n}",$2);
        free($2);
        $$ = s;
    }

    | WHILE expr B_BEGIN bloco %prec B_END { 
        int size = 17 + strlen($2) + strlen($4);
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "while (%s) {\n\t %s;\n}", $2, $4);
        free($4);
        $$ = s;
    }
	
    | IF expr bloco %prec IFX{ 
        int size = 14 + strlen($2) + strlen($3);
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "if (%s) {\n\t %s;\n}", $2, $3);
        free($3);
        $$ = s;
    }

	| IF expr bloco ELSE bloco %prec IFX{
        int size = 26 + strlen($2) + strlen($3) + strlen($5);
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "if (%s) {\n\t %s;\n }else{\n\t %s;}", $2, $3, $5);
        free($3);
        free($5);
        $$ = s;
    }

    | SWITCH ID stm {
        int size = 16 + strlen($2) + strlen($3);
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "switch (%s) {\n\t %s;\n}", $2, $3);
        free($3);
        $$ = s;
    }
      
    | CASE stm {
        int size = 12 + strlen($2);
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "case {\n\t %s;\n}", $2);
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
        int size = 15 + strlen($2) + strlen($3);
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "for (%s) {\n\t %s;\n}", $2, $3);
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

    | SCAN PARL stm PARR {
        int size = 12 + strlen($3);
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "scanf (\n %s\n)", $3);
        free($3);
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
            int size = 1 + strlen($1) + strlen($3);
            char * s = malloc(sizeof(char) * size);
            sprintf(s, "%s;%s", $1,$3);
            free($1);
            free($3);
            $$ = s;
        };

expr :  opera {$$ = $1;}
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

opera : expr AND expr {
        int size = 4 + strlen($1) + strlen($3);
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "%s && %s", $1,$3);
        free($3);
        $$ = s;
    }
    | expr OR expr {
        int size = 4 + strlen($1) + strlen($3);
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "%s || %s", $1,$3);
        free($3);
        $$ = s;
    }
    | expr IQUALS expr {
        int size = 4 + strlen($1) + strlen($3);
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "%s == %s", $1,$3);
        free($3);
        $$ = s;
    }
    | expr POW expr {
        int size = 8 + strlen($1) + strlen($3) ;
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "powf(%s, %s)", $1,$3);
        free($3);
        $$ = s;
    }
    | expr DIFS expr {
        int size = 4 + strlen($1) + strlen($3) + 5;
        char * s = malloc(sizeof(char) * size);
        sprintf(s, "%s != %s", $1,$3);
        free($3);
        $$ = s;
    } 
    | ID SUM expr { 
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

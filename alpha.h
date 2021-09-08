typedef struct _atrib {
	char * nome;
	char * valor;
	struct _atrib *next;
} *atrib;

typedef union _conteudo {
	char  *texto;
	struct _nodo *filho;
} *conteudo;

typedef struct _nodo {
	char *tagname;
	atrib atributos;
	conteudo cont;
	struct _nodo *next;
} *nodo;

atrib insereatrib(atrib lst, char *nome, char *valor);
nodo inserenodo(char * tagname, atrib atributos,conteudo cont,nodo irmao);
void shownodo(nodo nod);
void showatrib(atrib nod);
nodo conc(nodo lst, nodo last);
char *strtrim(char *s);

int conta(char* line);

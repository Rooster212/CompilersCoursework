%{
#ifdef PRINT
#define	TOKEN(t) printf("Token: " #t "\n");
#define	ID_TOKEN(t) printf("ID Token: " #t "\n", yytext);
#define	CHARCONST_TOKEN(t) printf("Character Constant Token: " #t "\n", yytext);
#define	FLOAT_TOKEN(t) printf("Float %d Token: " #t "\n", atof(yytext));
#define	INTEGER_TOKEN(t) printf("Integer %d Token: " #t "\n", atoi(yytext));
#else
#define	TOKEN(t) return (t);
#define	ID_TOKEN(t) yylval.iVal = installId(yytext, 0);return(t);
#define	CHARCONST_TOKEN(t) yylval.iVal = installId(yytext, 1);return(t);
#define	INTEGER_TOKEN(t) yylval.iVal = installId(yytext,2);return(t);
#define	FLOAT_TOKEN(t) yylval.iVal = installId(yytext,3);return(t);

#include <strings.h>
extern SYMTABNODEPTR symTab[SYMTABSIZE];
extern int currentSymTabSize;

#endif

%}
delim           [ \t\n\r]
ws              {delim}+
digit           [0-9]
number          {digit}+
letter       	[A-Za-z]
integer_spl		{number}
float_spl		{number}\.{number}
label			{{letter}|{digit}}+
identifier		{letter}({letter}|{digit})*
character_const	\'{letter}\'
%%
"."             TOKEN(FULLSTOP);
":"             TOKEN(COLON);
","             TOKEN(COMMA);
"->"            TOKEN(ASSIGN);
"("             TOKEN(BRA);
")"             TOKEN(KET);
"="             TOKEN(EQUALS);
"<>"            TOKEN(NOTEQUAL);
"<"             TOKEN(LESSTHAN);
">"             TOKEN(GREATERTHAN);
"<="            TOKEN(LESSTHANEQUAL);
">="            TOKEN(GREATERTHANEQUAL);
"+"             TOKEN(PLUS);
"-"             TOKEN(MINUS);
"*"             TOKEN(TIMES);
"/"             TOKEN(DIVIDE);
"'"             TOKEN(APOSTROPHE);
";"             TOKEN(SEMICOLON);
ENDP            TOKEN(ENDP);
DECLARATIONS    TOKEN(DECLARATIONS);
CODE            TOKEN(CODE);
OF              TOKEN(OF_SPL);
TYPE            TOKEN(TYPE_SPL);
CHARACTER       TOKEN(CHARACTER_SPL);
INTEGER         TOKEN(INTEGER_SPL);
REAL            TOKEN(REAL_SPL);
IF              TOKEN(IF);
THEN            TOKEN(THEN);
ENDIF           TOKEN(ENDIF);
ELSE            TOKEN(ELSE);
DO              TOKEN(DO);
WHILE           TOKEN(WHILE);
ENDDO           TOKEN(ENDDO);
ENDWHILE        TOKEN(ENDWHILE);
FOR             TOKEN(FOR);
IS              TOKEN(IS);
BY              TOKEN(BY);
TO              TOKEN(TO);
ENDFOR          TOKEN(ENDFOR);
WRITE		    TOKEN(WRITE);	
NEWLINE         TOKEN(NEWLINE);
READ            TOKEN(READ);
NOT             TOKEN(NOT);
AND             TOKEN(AND);
OR              TOKEN(OR);
{identifier}	ID_TOKEN(ID_SPL);
{character_const} CHARCONST_TOKEN(CHARACTER_CONSTANT);
{float_spl}			FLOAT_TOKEN(FLOAT_NUM);
{integer_spl}		INTEGER_TOKEN(INTEGER_NUM);
{ws}            ; /* Do Nothing */
.				printf("Error: Unexpected symbol in lexical analyser: %s (%d)\n",yytext,yytext[0]);
%%

/* Here is the code for the library of symbol table routines */

/* code for a simple symbol table, which is an array of pointers to
   structs, each of which contains an identifier.
*/

#ifndef PRINT

SYMTABNODEPTR newSymTabNode()
{
    return ((SYMTABNODEPTR)malloc(sizeof(SYMTABNODE)));
}

int installId(char *id, int type) 
{
    extern SYMTABNODEPTR symTab[SYMTABSIZE]; 
    extern int currentSymTabSize;
    int index;

    index = lookup(id);
    if (index >= 0)
    {
		symTab[index]->uses++;
        return (index);
    }
    else if (currentSymTabSize >= SYMTABSIZE)
	{
          /* SYMTAB is full */
          return (NOTHING) ;
	}
    else
    {
       symTab[currentSymTabSize] = newSymTabNode();
       /* Recommended code for preventing buffer overrun on bounded strings */
       strncpy(symTab[currentSymTabSize]->identifier,id,IDLENGTH);
       symTab[currentSymTabSize]->identifier[IDLENGTH-1] = '\0';
	   symTab[currentSymTabSize]->type = type;
	   symTab[currentSymTabSize]->uses = 0;
	   symTab[currentSymTabSize]->reservedKeyword = checkKeywords(id);
       return(currentSymTabSize++);
    }
}
/* Look up an identifier in the symbol table, if its there return
   its index.  If its not there, put it in the end position,
   as long as the table isn't full, and return its index.
*/
int lookup(char *s)
{
    extern SYMTABNODEPTR symTab[SYMTABSIZE];
    extern int currentSymTabSize;
    int i;

    for(i=0; i<currentSymTabSize; i++)
    {
        if(strncmp(s,symTab[i]->identifier,IDLENGTH) == 0)
        {
            return (i);
        }
    }
    return (-1);    
}

int checkKeywords(char *s)
{
	int reservedWordsLength = 32;
	int i;
	for(i=0;i<reservedWordsLength;i++)
	{
		if (strcmp(ReservedWords[i],s) == 0)
		{
			return 1;
		}
	}
	return 0;
}

#endif

%{

extern int yydebug;
#if YYDEBUG == 1
yydebug = 1;
#endif

#include <stdio.h>
#include <stdlib.h>

/* These constants are used later in the code */
#define SYMTABSIZE     50
#define IDLENGTH       15
#define NOTHING        -1
#define INDENTOFFSET    2

enum ParseTreeNodeType { APOSTROPHE, DECLARATION_BLOCK, DECLARATION, TYPE, STATEMENT_LIST, STATEMENT, 
		ASSIGNMENT_STATEMENT, IF_STATEMENT, DO_STATEMENT, WHILE_STATEMENT, FOR_STATEMENT, FOR_CONDITION, WRITE_NEWLINE, DECLARATION_LIST,
		FOR_EXPRESSION, WRITE_STATEMENT, READ_STATEMENT, OUTPUT_LIST, CONDITIONAL, CONDITIONAL_STATEMENT, COMPARATOR, CHARACTER_CONSTANT_VALUE,
		EXPRESSION, EXPRESSION_PLUS, EXPRESSION_MINUS, TERM, TERM_TIMES, TERM_DIVIDE,VALUE, VALUE_CONSTANT, VALUE_BRACKETS, CONSTANT, NUMBER_CONSTANT_POSITIVE, NUMBER_CONSTANT_NEGATIVE, PROGRAM, BLOCK,TARGET_NUMBER_INT,TARGET_NUMBER_FLOAT } ;

char *NodeName[] = { "APOSTROPHE","DECLARATION_BLOCK","DECLARATION","TYPE"," STATEMENT_LIST","STATEMENT",
		"ASSIGNMENT_STATEMENT","IF_STATEMENT", "DO_STATEMENT","WHILE_STATEMENT","FOR_STATEMENT", "FOR_CONDITION", "WRITE_NEWLINE", "DECLARATION_LIST",
		"FOR_EXPRESSION","WRITE_STATEMENT","READ_STATEMENT","OUTPUT_LIST","CONDITIONAL","CONDITIONAL_STATEMENT","COMPARATOR", "CHARACTER_CONSTANT_VALUE",
		"EXPRESSION", "EXPRESSION_PLUS", "EXPRESSION_MINUS","TERM",  "TERM_TIMES", "TERM_DIVIDE","VALUE", "VALUE_CONSTANT","VALUE_BRACKETS", "CONSTANT","NUMBER_CONSTANT_POSITIVE","NUMBER_CONSTANT_NEGATIVE","PROGRAM","BLOCK","TARGET_NUMBER_INT","TARGET_NUMBER_FLOAT" };

char *ReservedWords[] = { "auto", "break", "case", "char", "const", "continue", 					"default", "do", "double", "else", "entry", "enum",
		"extern", "float", "for", "goto", "int", "long", "register", "return",
		"short", "signed", "sizeof", "static", "struct", "switch", "typedef",
		"union", "unsigned", "void", "volatile", "while" };

#ifndef TRUE
#define TRUE 1
#endif

#ifndef FALSE
#define FALSE 0
#endif

#ifndef NULL
#define NULL 0
#endif

/* ------------- parse tree definition --------------------------- */

struct treeNode {
    int  item;
    int  nodeIdentifier;
    struct treeNode *first;
    struct treeNode *second;
    struct treeNode *third;
  };

typedef  struct treeNode TREE_NODE;
typedef  TREE_NODE        *TERNARY_TREE;

/* --------------- forward declarations --------------------------- */

TERNARY_TREE create_node(int,int,TERNARY_TREE,TERNARY_TREE,TERNARY_TREE);
void printTree(TERNARY_TREE, int);
void printId(int, int);
void printCode(TERNARY_TREE, int);
void declareType(TERNARY_TREE, char	);
void printSymbolTable();
void populateSymbolTable(TERNARY_TREE);

/* ------------- folding method declarations ---------------------- */

void foldConstants(TERNARY_TREE);
float foldFloatExpression(TERNARY_TREE);
int foldIntExpression(TERNARY_TREE);

/* ------------- symbol table definition -------------------------- */

struct symTabNode {
    char identifier[IDLENGTH];
	char type;
	int uses;
	int reservedKeyword;
};

enum typeEnum { TYPE_ID, TYPE_CHAR, TYPE_INT, TYPE_FLOAT };

typedef  struct symTabNode SYMTABNODE;
typedef  SYMTABNODE        *SYMTABNODEPTR;

SYMTABNODEPTR  symTab[SYMTABSIZE]; 

int currentSymTabSize = 0;
char lastType = '\0';
int printWriteStatement = 0;
int isNegative = 0;
int numberOfDeclaredForLoops = 0;

/****************/
/* Warnings     */
/****************/
int usageOfReservedWords = 0;
int unusedVariables = 0;
int programIdentifierError = 0;
%}

/****************/
/* Start symbol */
/****************/
%start  program

/**********************/
/* Action value types */
/**********************/

%union {
    int iVal;
    TERNARY_TREE  tVal;
}

/* We can declare types of tree nodes */
%token ASSIGN BRA BY CODE COLON COMMA DECLARATIONS DO ELSE ENDDO ENDFOR 
		ENDIF ENDP ENDWHILE FOR FULLSTOP IF
		IS KET NEWLINE OF_SPL READ EQUALS NOTEQUAL LESSTHAN GREATERTHAN LESSTHANEQUAL GREATERTHANEQUAL SEMICOLON THEN TO TYPE_SPL WHILE WRITE CHARACTER_SPL INTEGER_SPL REAL_SPL AND OR
/* These are the types of lexical tokens -> iVal */
%token<iVal> ID_SPL CHARACTER_CONSTANT FLOAT_NUM INTEGER_NUM 
%token<iVal> TIMES DIVIDE PLUS MINUS NOT
/* Some tokens do not return a value */
/* Whereas Rules return a tVal type (Tree) */
%type<tVal> program block declaration_block declaration type statement_list statement assignment_statement 
			if_statement do_statement while_statement for_statement for_condition write_statement read_statement 
			output_list conditional conditional_statement comparator expression term value constant target_number number_constant

%%
/* ----------------------- grammar rules --------------------------- */

program      : ID_SPL COLON block ENDP ID_SPL FULLSTOP
			{
				TERNARY_TREE ParseTree;
                ParseTree = create_node($1, PROGRAM, $3, NULL, NULL) ;
#ifdef DEBUG
				printTree(ParseTree, 0);
				printSymbolTable();
#else
				populateSymbolTable(ParseTree);
				if($1 != $5)
				{
					programIdentifierError++;
				}
				printCode(ParseTree, 0);
#endif
			}
            ;

block       : DECLARATIONS declaration_block CODE statement_list
				{
					$$ = create_node(NOTHING, BLOCK, $2, $4, NULL);
				}
				| CODE statement_list
				{
					$$ = create_node(NOTHING, BLOCK, $2, NULL, NULL);
				}
			;

declaration_block : declaration OF_SPL TYPE_SPL type SEMICOLON	
				{
					$$ = create_node(NOTHING, DECLARATION_BLOCK, $1, $4, NULL);
				}
				| declaration OF_SPL TYPE_SPL type SEMICOLON declaration_block
				{
					$$ = create_node(NOTHING, DECLARATION_BLOCK, $1, $4, $6);
				}
			;
declaration : ID_SPL 
				{
					$$ = create_node($1, DECLARATION, NULL, NULL, NULL);
				}
				| ID_SPL COMMA declaration
				{
					$$ = create_node($1, DECLARATION_LIST, $3, NULL, NULL);
				}
				;

type : CHARACTER_SPL
				{
					$$ = create_node(CHARACTER_SPL, TYPE, NULL, NULL, NULL);
				}
			| INTEGER_SPL
			{
				$$ = create_node(INTEGER_SPL, TYPE, NULL, NULL, NULL);
			}
			| REAL_SPL
			{
				$$ = create_node(REAL_SPL, TYPE, NULL, NULL, NULL);
			}
			;

statement_list : statement
			{
				$$ = create_node(NOTHING, STATEMENT_LIST, $1, NULL, NULL);
			}
			| statement SEMICOLON statement_list
			{
				$$ = create_node(NOTHING, STATEMENT_LIST, $1, $3, NULL);
			}
			;

statement : assignment_statement
			{
				$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL);
			}
			|if_statement 
			{
				$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL);
			}
			| do_statement
			{
				$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL);
			}
			| while_statement 
			{
				$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL);
			}
			| for_statement 
			{
				$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL);
			}
			| write_statement 
			{
				$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL);
			}
			| read_statement
			{
				$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL);
			}
			;

assignment_statement : expression ASSIGN ID_SPL
			{
				$$ = create_node($3, ASSIGNMENT_STATEMENT, $1, NULL, NULL);
			}
			;

if_statement : IF conditional THEN statement_list ELSE statement_list ENDIF 
			{
				$$ = create_node(NOTHING, IF_STATEMENT, $2, $4, $6);
			}
			| IF conditional THEN statement_list ENDIF
			{
				$$ = create_node(NOTHING, IF_STATEMENT, $2, $4, NULL);
			}
			;
			
do_statement : DO statement_list WHILE conditional ENDDO
			{
				$$ = create_node(NOTHING, DO_STATEMENT, $2, $4, NULL);
			}
			;

while_statement : WHILE conditional DO statement_list ENDWHILE
			{
				$$ = create_node(NOTHING, WHILE_STATEMENT, $2, $4, NULL);
			}
			;

for_statement : FOR for_condition DO statement_list ENDFOR
			{
				$$ = create_node(NOTHING, FOR_STATEMENT, $2, $4, NULL);
			}
			;

for_condition : ID_SPL IS expression BY expression TO expression 
			{
				$$ = create_node($1, FOR_CONDITION, $3, $5, $7);
			}
			;

write_statement : WRITE BRA output_list KET 
			{
				$$ = create_node(NOTHING, WRITE_STATEMENT, $3, NULL, NULL);
			}
			| NEWLINE
			{
				$$ = create_node(NOTHING, WRITE_NEWLINE, NULL, NULL, NULL);
			}
			;
read_statement : READ BRA ID_SPL KET
			{
				$$ = create_node($3, READ_STATEMENT, NULL, NULL, NULL);
			}
			;

output_list : value 
			{
				$$ = create_node(NOTHING, OUTPUT_LIST, $1, NULL, NULL);
			}
			| value COMMA output_list
			{
				$$ = create_node(NOTHING, OUTPUT_LIST, $1, $3, NULL);
			};

conditional : conditional_statement 
			{
				$$ = create_node(NOTHING, CONDITIONAL, $1, NULL, NULL);
			}
			| conditional_statement AND conditional
			{
				$$ = create_node(AND, CONDITIONAL, $1, $3, NULL);
			}
			| conditional_statement OR conditional
			{
				$$ = create_node(OR, CONDITIONAL, $1, $3, NULL);
			};	

conditional_statement : expression comparator expression
			{
				$$ = create_node(NOTHING, CONDITIONAL_STATEMENT, $1, $2, $3);
			}
			| NOT conditional_statement
			{
				$$ = create_node($1, CONDITIONAL_STATEMENT, $2, NULL, NULL);
			};

comparator : EQUALS 
			{
				$$ = create_node(EQUALS, COMPARATOR, NULL, NULL, NULL);
			}
			| NOTEQUAL 
			{
				$$ = create_node(NOTEQUAL, COMPARATOR, NULL, NULL, NULL);
			}
			| LESSTHAN 
			{
				$$ = create_node(LESSTHAN, COMPARATOR, NULL, NULL, NULL);
			}
			| GREATERTHAN 
			{
				$$ = create_node(GREATERTHAN, COMPARATOR, NULL, NULL, NULL);
			}
			| LESSTHANEQUAL
			{
				$$ = create_node(LESSTHANEQUAL, COMPARATOR, NULL, NULL, NULL);
			}
			| GREATERTHANEQUAL
			{
				$$ = create_node(GREATERTHANEQUAL, COMPARATOR, NULL, NULL, NULL);
			}
		;
expression : term 
			{
				$$ = create_node(NOTHING, EXPRESSION, $1, NULL, NULL);
			}
			| term PLUS expression
			{
				$$ = create_node($2, EXPRESSION_PLUS, $1, $3, NULL);
			}
			| term MINUS expression
			{
				$$ = create_node($2, EXPRESSION_MINUS, $1, $3, NULL);
			}
			;
term : value 
			{
				$$ = create_node(NOTHING, TERM, $1, NULL, NULL);
			}
			| value TIMES term 
			{
				$$ = create_node($2, TERM_TIMES, $1, $3, NULL);
			}
			| value DIVIDE term
			{
				$$ = create_node($2, TERM_DIVIDE, $1, $3, NULL);
			};

value : ID_SPL
			{
				$$ = create_node($1, VALUE, NULL, NULL, NULL);
			}
			| constant 
			{
				$$ = create_node(NOTHING, VALUE_CONSTANT, $1, NULL, NULL);
			}
			| BRA expression KET
			{
				$$ = create_node(NOTHING, VALUE_BRACKETS, $2, NULL, NULL);
			}
			;

constant : number_constant 
			{
				$$ = create_node(NOTHING, CONSTANT, $1, NULL, NULL);
			}
			| CHARACTER_CONSTANT
			{
				$$ = create_node($1, CHARACTER_CONSTANT_VALUE, NULL, NULL, NULL);
			}
			;

number_constant : target_number 
			{
				$$ = create_node(NOTHING, NUMBER_CONSTANT_POSITIVE, $1, NULL, NULL);
			}
			| MINUS target_number
			{
				$$ = create_node(NOTHING, NUMBER_CONSTANT_NEGATIVE, $2, NULL, NULL);
			}
			;
			
target_number : INTEGER_NUM 
			{
				$$ = create_node($1, TARGET_NUMBER_INT, NULL, NULL, NULL);
			}
			| FLOAT_NUM
			{
				$$ = create_node($1, TARGET_NUMBER_FLOAT, NULL, NULL, NULL);
			}
			;
%%

/* Code for routines for managing the Parse Tree */

TERNARY_TREE create_node(int ival, int case_identifier, TERNARY_TREE p1,
			 TERNARY_TREE  p2, TERNARY_TREE  p3)
{
    TERNARY_TREE t;
    t = (TERNARY_TREE)malloc(sizeof(TREE_NODE));
    t->item = ival;
    t->nodeIdentifier = case_identifier;
    t->first = p1;
    t->second = p2;
    t->third = p3;
    return (t);
}

#ifdef DEBUG
void printTree(TERNARY_TREE t, int indent)
{
	int i;
	if(t == NULL) return;
	// do the indenting
	for(i=indent;i;i--)printf(" ");
	printf("Node identifier %s\n", NodeName[t->nodeIdentifier]);
	/* Val printing */
	if (t->item != NOTHING){
		for(i=indent;i;i--)printf(" ");
		if(t->nodeIdentifier == TARGET_NUMBER_INT)
		{
			printf(" Integer: %d ", t->item);
			symTab[t->item]->type = 'i';
		}
		else if(t->nodeIdentifier == TARGET_NUMBER_FLOAT)
		{
			printf(" Float: %d ", t->item);
			symTab[t->item]->type = 'f';
		}
		else if(t->nodeIdentifier == ID_SPL)
		{
			printf(" ID_SPL: %s\n", symTab[t->item]->identifier);
			symTab[t->item]->type = 'd';
		}
		else if(t->nodeIdentifier == CHARACTER_CONSTANT_VALUE)
		{
			printf(" Char Constant: %c\n", symTab[t->item]->identifier);
			symTab[t->item]->type = 'c';
		}
		else if(t->nodeIdentifier == VALUE){
			printf(" Value identifier: %s\n", symTab[t->item]->identifier);
			symTab[t->item]->type = 's';
		}
		else if(t->nodeIdentifier == DECLARATION)
		{
			printf(" ID_SPL: %s\n", symTab[t->item]->identifier);
			symTab[t->item]->type = 's';
		}
		else if(t->nodeIdentifier == PROGRAM)
		{
			printf(" Program Name [ID_SPL]: %s\n", symTab[t->item]->identifier);
			symTab[t->item]->type = 'd';
		}
		
	}
	printId(t -> item,indent); // so we take a pointer from t and get the item
	
	// now we have to recurse down the tree
	printTree(t -> first,indent+2);
	printTree(t -> second,indent+2);
	printTree(t -> third,indent+2);
};
void printId(int s, int indent)
{
	if(s == NOTHING) return;
	int j;
	for(j=indent;j;j--)printf(" ");
	printf("Identifier %s\n", symTab[s]);
};

void printSymbolTable()
{
	int i;
	printf("\n\nSYMBOL TABLE\n");
	printf("--------------------------------------------------------\n");
	for(i=0;i<currentSymTabSize;i++)
	{
		if(symTab[i] != NULL && symTab[i]->identifier != NULL)
		{
			printf("%s",symTab[i]->identifier);
			switch(symTab[i]->type)
			{
				case 'd':
					printf("	         TYPE: ID_SPL\n");
					break;
				case 'c':
					printf("		 TYPE: CHAR_CONST\n");
					break;
				case 's':
					printf("		 TYPE: IDENTIFIER\n");
					break;
				case 'f':
					printf("		 TYPE: FLOAT\n");
					break;
				case 'i':
					printf("		 TYPE: INTEGER\n");
					break;
				default:
					printf("		 TYPE: unknown (%s)\n",symTab[i]->type);
					break;
			}
			printf("			USES: %d\n",symTab[i]->uses);
			printf("			RESERVED: %d\n",symTab[i]->reservedKeyword);
			printf("--------------------------------------------------------\n");
		}
	}
};
#endif

void populateSymbolTable(TERNARY_TREE t)
{
	if (t == NULL) return;
	if (t->item != NOTHING){
		if(t->nodeIdentifier == TARGET_NUMBER_INT)
		{
			symTab[t->item]->type = 'i';
		}
		else if(t->nodeIdentifier == TARGET_NUMBER_FLOAT)
		{
			symTab[t->item]->type = 'f';
		}
		else if(t->nodeIdentifier == ID_SPL)
		{
			symTab[t->item]->type = 'd';
		}
		else if(t->nodeIdentifier == CHARACTER_CONSTANT_VALUE)
		{
			symTab[t->item]->type = 'c';
		}
		else if(t->nodeIdentifier == VALUE){
			symTab[t->item]->type = 's';
		}
		else if(t->nodeIdentifier == DECLARATION)
		{
			symTab[t->item]->type = 's';
		}
		else if(t->nodeIdentifier == PROGRAM)
		{
			symTab[t->item]->type = 'd';
		}
	}
	// now we have to recurse down the tree
	populateSymbolTable(t -> first);
	populateSymbolTable(t -> second);
	populateSymbolTable(t -> third);
}

void printWarnings()
{
	// work out numbers
	int i;
	for(i=0;i<currentSymTabSize;i++)
	{	
		// if we have an identifier
		if(symTab[i]->type == 's')
		{
			if(symTab[i]->uses == 0) 
				unusedVariables++;
		}
		if(symTab[i]->reservedKeyword == 1) usageOfReservedWords++;
	}
	
	/* Print out warnings */
	if(usageOfReservedWords > 0)
	{
		printf("\n");
		printf("/* WARNING: there was usage of C reserved keywords in your program. They have been prefixed with an underscore to avoid errors. This occurred %d times. */\n",usageOfReservedWords);
	}
	if(unusedVariables > 0)
	{
		printf("\n");
		printf("/* WARNING: There were %d unused variables in your program. */\n",unusedVariables);
	}
	if(programIdentifierError > 0)
	{
		printf("\n");
		printf("/* WARNING: Your program identifiers do not match (beginning and end). */\n");
	}
}

void foldConstants(TERNARY_TREE t)
{
	switch(t->nodeIdentifier)
	{
		case EXPRESSION_MINUS:
			break;
		case EXPRESSION_PLUS:
			break;
		default:
			foldConstants(t->first);
			foldConstants(t->second);
			foldConstants(t->third);
			break;
	}
}

float foldFloatExpression(TERNARY_TREE t)
{
	
}

int foldIntExpression(TERNARY_TREE t)
{

}

void printCode(TERNARY_TREE t, int indent)
{
	int i;
	if(t == NULL) return;
	for(i=indent;i;i--)printf(" ");
	switch(t->nodeIdentifier)
	{
		case PROGRAM:
			printf("#include <stdio.h>\n\n");
			printf("/* ");
			printf("%s",symTab[t->item]); /* Program identifier */
			printf(" */\n\n");
			printf("int main(void) {\n");
			printCode(t->first,indent+3);
			printf("return 0;\n");
			printf("}\n");
			printf("/* End Program %s */",symTab[t->item]);
			printWarnings();
			break;
		case APOSTROPHE:
			break;
		case DECLARATION_LIST:
			if(symTab[t->item]->reservedKeyword == 1)
				printf("_");
			printf("%s,",symTab[t->item]);
			symTab[t->item]->type = lastType;
			printCode(t->first,indent);
			printCode(t->second,indent);
			printCode(t->third,indent); 
			break;
		case DECLARATION:
			/* we can put the semicolon and new line in here */
			if(symTab[t->item]->reservedKeyword == 1)
				printf("_");
			printf("%s;\n",symTab[t->item]);
			symTab[t->item]->type = lastType;
			break;
		case DECLARATION_BLOCK:
			printCode(t->second,indent);
			printCode(t->first,indent);
			printCode(t->third,indent);
			break;
		case TYPE:
			switch(t->item)
			{
				case CHARACTER_SPL:
					lastType ='c';
					printf("char ");
					break;
				case REAL_SPL:
					lastType ='f';
					printf("float ");
					break;
				case INTEGER_SPL:
					lastType ='i';
					printf("int ");
					break;
			}
			break;
		case STATEMENT_LIST: 
			printCode(t->first,indent);
			printCode(t->second,indent);
			printCode(t->third,indent);
			break;
		/*case STATEMENT:
			break;*/
		case ASSIGNMENT_STATEMENT:
			if(symTab[t->item]->reservedKeyword == 1)
				printf("_");
			printf("%s = ",symTab[t->item]->identifier);
			printCode(t->first,0);
			printf(";\n");
			break;
		case IF_STATEMENT:
			printf("if (");
			printCode(t->first,0);
			printf(")\n");
			printf("{\n");
			printCode(t->second,indent+3);
			printf("}\n");
			if(t->third != NULL)
			{
				printf("else\n{\n");
				printCode(t->third,indent+3);
				printf("}\n");
			}
			break;
		case DO_STATEMENT:
			printf("do {\n");
			printCode(t->first,indent+3);
			printf("} while (");
			printCode(t->second,0);
			printf(");\n");
			break;
		case WHILE_STATEMENT:
			printf("while (");
			printCode(t->first,0);
			printf(")\n{\n");
			printCode(t->second,indent+3);
			printf("}");
			break;
		case FOR_STATEMENT:
			printf("register int _by");
			printf("%d",numberOfDeclaredForLoops);
			printf(";\n");
			printf("for(");
			printCode(t->first,0);
			printf("){\n");
			printCode(t->second,indent+3);
			printf("}\n");
			break;
		case FOR_CONDITION:
			// Using Brian's solution for the for loop - its tricky but it should work. Requires runtime comparisons either way
			if(symTab[t->item]->reservedKeyword == 1)
				printf("_");
			printf("%s",symTab[t->item]->identifier);
			printf(" = ");
			printCode(t->first,0);
			printf("; ");
			printf("_by");
			if(symTab[t->item]->reservedKeyword == 1)
				printf("_");
			printf("%d",numberOfDeclaredForLoops);
			printf(" = ");
			printCode(t->second,0);
			printf(",((");
			if(symTab[t->item]->reservedKeyword == 1)
				printf("_");
			printf("%s",symTab[t->item]->identifier);
			printf("-(");
			printCode(t->third,0);
			printf(")) * ((_by");
			printf("%d",numberOfDeclaredForLoops);
			printf(" > 0) - (_by");
			printf("%d",numberOfDeclaredForLoops);
			printf(" < 0))) <= 0;");
			if(symTab[t->item]->reservedKeyword == 1)
				printf("_");
			printf("%s",symTab[t->item]->identifier);
			printf(" += _by");
			printf("%d",numberOfDeclaredForLoops);
			numberOfDeclaredForLoops++;
			/*
			 * The way the for loop works
			register int _by0;
			 // this is an example
			 
			 FOR integer IS -1 BY -1 TO -5 DO
			=
			for(integer = -1; _by0 = -1,((integer-(-5)) * ((_by0 > 0) - (_by0 < 0))) <= 0;integer += _by0)
			{
				<code>
			}
			
			 * Essentially, you are normalising to use less than 0
			 * Then, you need to find the sign of it
			 * This is achieved using the less than/greater than
			 * then this is multiplied by the number to give it either
			 * a positive or negative sign which will be applied to the 
			 * variable by multiplying it
			 *
			*/
			break;
		case WRITE_STATEMENT:
			printCode(t->first,0);
			break;
		case WRITE_NEWLINE:
			// do indent
			for(i=indent;i;i--)printf(" ");
			printf("printf(\"\\n\");\n");
			break;
		case READ_STATEMENT:
			for(i=indent;i;i--)printf(" ");
			printf("scanf(\"");
			switch(symTab[t->item]->type)
			{
				case 'c':
					printf("%%c");
					break;
				case 'i':
					printf("%%d");
					break;
				case 'f':
					printf("%%f"); 
					break;
			}
			printf("\",");
			if(symTab[t->item]->reservedKeyword == 1)
				printf("&_");
			else
				printf("&");
			printf("%s", symTab[t->item]);
			printf(");\n");
			break;
		case OUTPUT_LIST:
			if (t->first != NULL && t->first->nodeIdentifier == VALUE)
			{
				printf("printf(\"");
				switch(symTab[t->first->item]->type)
				{
					case 'c':
						printf("%%c");
						break;
					case 'i':
						printf("%%d");
						break;
					case 'f':
						printf("%%f"); 
						break;
				}
				printf("\",");
				printCode(t->first,0);
				printCode(t->second,0);
				printf(");\n"); // end printf 
			}
			else if (t->first != NULL && t->first->nodeIdentifier == VALUE_CONSTANT)
			{
				printWriteStatement = 1;
				printCode(t->first,0);
				printCode(t->second,0);
				printWriteStatement = 0;
			}
			else // we have an expression
			{
				printf("printf(\"%%f\",");
				printCode(t->first,0);
				printCode(t->second,0);
				printf(");\n"); // end printf 
			}
			break;
		case CONDITIONAL:
			printCode(t->first,0);
			if(t->item == AND)
			{
				printf(" && ");
				printCode(t->second,0);
			}
			else if (t->item == OR)
			{
				printf(" || ");
				printCode(t->second,0);
			}
			break;
		case CONDITIONAL_STATEMENT:
			if(t->item != NOTHING)
			{
				printf("!(");
				printCode(t->first,0);
				printf(")");
			}
			else
			{
				printCode(t->first,0);
				printCode(t->second,0);
				printCode(t->third,0);
			}
			break;
		case COMPARATOR:
			switch(t->item)
			{
				case EQUALS:
					printf("==");
					break;
				case NOTEQUAL:
					printf("!=");
					break;
				case LESSTHAN:
					printf("<");
					break;
				case GREATERTHAN:
					printf(">");
					break;
				case LESSTHANEQUAL:
					printf("<=");
					break;
				case GREATERTHANEQUAL:
					printf(">=");
					break;
			}
			break;
		case CHARACTER_CONSTANT_VALUE:
			if (printWriteStatement == 1)
			{
				printf("printf(\"%%c\",");
			}
			printf("%s",symTab[t->item]->identifier);
			if (printWriteStatement == 1)
			{
				printf(");\n");
			}
			break;
		case EXPRESSION:
			printCode(t->first,0);
			break;
		case EXPRESSION_PLUS:
			printCode(t->first,0);
			printf("+");
			printCode(t->second,0);
			break;
		case EXPRESSION_MINUS:
			printCode(t->first,0);
			printf("-");
			printCode(t->second,0);
			break;
		case TERM:
			printCode(t->first,0);
			break;
		case TERM_TIMES:
			printCode(t->first,0);
			printf(" * ");
			printCode(t->second,0);
			break;
		case TERM_DIVIDE:
			printCode(t->first,0);
			printf(" / ");
			printCode(t->second,0);
			break;
		case VALUE:
			if(symTab[t->item]->reservedKeyword == 1)
				printf("_");
			printf("%s",symTab[t->item]->identifier);
			break;
		case VALUE_CONSTANT:
			printCode(t->first,0);
			break;
		case VALUE_BRACKETS:
			printf("(");
			printCode(t->first,0);
			printf(")");
			break;
		case NUMBER_CONSTANT_POSITIVE:
			if (printWriteStatement == 1)
			{
				if(t->first->nodeIdentifier == TARGET_NUMBER_FLOAT)
					printf("printf(\"%%f\",");
				else
					printf("printf(\"%%d\",");
			}
			printCode(t->first,0);	
			if (printWriteStatement == 1)
				printf(");\n");
			break;
		case NUMBER_CONSTANT_NEGATIVE:
			if (printWriteStatement == 1)
			{
				if(t->first->nodeIdentifier == TARGET_NUMBER_FLOAT)
					printf("printf(\"%%f\",");
				else
					printf("printf(\"%%d\",");
			}
			isNegative = 1;
			printCode(t->first,0);
			if (printWriteStatement == 1)
				printf(");\n");
			break;
		case TARGET_NUMBER_INT:
			if (isNegative == 1)
			{
				printf("(-");
			}
			/* we have to write this as a string as it has been stored in the symbol table */
			printf("%s",symTab[t->item]);
			if (isNegative == 1)
			{
				printf(")"); // we surround the negative with brackets so it doesn't break other things
			}
			isNegative = 0;
			break;
		case TARGET_NUMBER_FLOAT:
			if (isNegative == 1)
			{
				printf("(-");
			}
			/* we have to write this as a string as it has been stored in the symbol table */
			printf("%s",symTab[t->item]);
			if (isNegative == 1)
			{
				printf(")");
			}
			isNegative = 0;
			break;
		case ID_SPL:
			if(symTab[t->item]->reservedKeyword == 1)
				printf("_");
			printf("%s",symTab[t->item]->identifier);
			break;
		default: // this catches all the other cases that we have removed as they only need to recurse more
			printCode(t->first,0);
			printCode(t->second,0);
			printCode(t->third,0);
			break;
	}
}
#include "lex.yy.c"

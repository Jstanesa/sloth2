%{
#include <assert.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#define ID_SIZE 100
#define MAX_CHILDREN 3
#define STATEMENT 201
#define ARRAY 202
#define ARRAYINST 203
#define FUNCTIONDECL 204
#define FUNCTIONCALL 205
#define MAIN 206

int varCount = 0;
int loopCount = 0;
//file to be printed to
FILE *fp;

struct entry{
    char *key;
    float value;
    int count;
};
int yywrap( );
void yyerror(const char* str);

struct Node* make_node(int type, double value, char* id);
void attach_node(struct Node* parent, struct Node* child);
void addVar(struct entry table[1000],char *var,float value);
void eval_stmt(struct Node* node,struct entry hashtable[1000]);
float eval_expr(struct Node* node,struct entry hashtable[1000]);
float getVar(struct entry hashtable[1000],char *name);
int floatToInt(float a);

struct Node* tree;
/* a tree node definition */
struct Node {
  /* the type of the node */
  int type;

  /* the value of the node if it can have one */
  double value;

  /* the id of the node (used for identifiers only) */
  char id[ID_SIZE];

  /* at most three children nodes */
  int num_children;
  struct Node* children[MAX_CHILDREN];
};

%}
%token ENDLINE 115
%token ASSIGNMENT 116
%token START 119
%token END 120
%token IF 121
%token THEN 122
%token ELSE 123
%token WHILE 124
%token DO 125
%token PRINT 126
%token INPUT 127
%token FLOAT 132
%token ARRAYTYPE 133

%token <str> IDENTIFIER 100
%type <node> identifier
%token <val> VALUE 101

%right THEN
%right ELSE

%left OR 113
%left AND 112
%left LESS 106 LESSEQUAL 108 GREAT 107 GREATEQUAL 109 EQUAL 110 NOTEQUAL 111
%left PLUS 102 MINUS 103
%left STAR 105 SLASH 104
%right NOT 114
%right OPENPAREN 117
%left CLOSEPAREN 118
%right OPENBRACKET 128
%left CLOSEBRACKET 129
%right OPENCURLY 130
%left CLOSECURLY 131
%left COMMA 134
%union{
    double val;
    struct Node* node;
    char str[100];
}


%type <node> type
%type <node> exprs
%type <node> args
%type <node> arrayStmt
%type <node> assignmentStmt
%type <node> ifStmt
%type <node> whileStmt
%type <node> ifElseStmt
%type <node> printStmt
%type <node> stmtSeq
%type <node> expr
%type <node> stmt
%type <node> stmts
%type <node> main
%type <node> functionStmt
%type <node> functions
%type <node> functionCall
/* give us more detailed errors */
%error-verbose

%%

program: main{
       tree = $1;
       }
       |main functions {
    /*tree = make_node(0,0,"");
      */
   tree = $1;
   attach_node($1,$2);
}
main: stmts{
    //$$=$1;
    $$=make_node(MAIN,0,"");
    attach_node($$,$1);
    }
functions: functionStmt {
         $$=$1;
         }
         |functions functionStmt{
         $$=$1;
         attach_node($$,$2);
         }
stmt: assignmentStmt {
	$$=$1;
      }
    | ifStmt {
	$$=$1;
    }
    | ifElseStmt {
	$$=$1;
    }
    | whileStmt {
	$$=$1;
    }
    | printStmt {
	//$$=make_node(STATEMENT,0,"");
	//attach_node($$,$1);
	$$=$1;
    }
    | stmtSeq {
	$$=$1;
    }
    | arrayStmt{
    $$=$1;
    }
    |functionCall{
    $$=$1;
    }/*
    |functionStmt{
    $$=$1;
    }*/

assignmentStmt: identifier ASSIGNMENT expr ENDLINE {
		    $$=make_node(ASSIGNMENT,0,"");
		    //struct Node* temp = make_node(IDENTIFIER,0,$1);
		    //attach_node($$,temp);
		    attach_node($$,$1);
		    attach_node($$,$3);
		}
ifElseStmt: IF expr THEN stmt ELSE stmt {
		$$=make_node(IF,0,"");
		attach_node($$,$2);
		attach_node($$,$4);
		attach_node($$,$6);
	    }
ifStmt: IF expr THEN stmt {
	    $$=make_node(IF,0,"");
	    attach_node($$,$2);
	    attach_node($$,$4);
	}
whileStmt: WHILE expr DO stmt {
	       $$=make_node(WHILE,0,"");
	       attach_node($$,$2);
	       attach_node($$,$4);
	   }
printStmt: PRINT expr ENDLINE {
	       $$=make_node(PRINT,0,"");
	       attach_node($$,$2);
	   }
arrayStmt: IDENTIFIER OPENBRACKET expr CLOSEBRACKET ENDLINE{
            $$=make_node(ARRAYINST,0,$1);
            attach_node($$,$3);
        }
functionStmt: IDENTIFIER OPENPAREN args CLOSEPAREN OPENCURLY stmts CLOSECURLY{
            $$=make_node(FUNCTIONDECL,0,$1);
            attach_node($$,$3);
            attach_node($$,$6);
            }
functionCall:IDENTIFIER OPENPAREN exprs CLOSEPAREN ENDLINE{
            $$=make_node(FUNCTIONCALL,0,$1);
            attach_node($$,$3);
            }
args: type IDENTIFIER{
    $$=make_node(IDENTIFIER,0,$2);
    attach_node($$,$1);
    } | type IDENTIFIER COMMA args{
    $$=make_node(IDENTIFIER,0,$2);
    attach_node($$,$1);
    attach_node($$,$4);
    }|{$$=NULL;}
type: FLOAT{
    $$=make_node(FLOAT,0,"");
    }|ARRAYTYPE{
    $$=make_node(ARRAYTYPE,0,"");
    }
stmtSeq: START stmts END {
	     $$=$2;
	 }
stmts: stmt {	
	$$=make_node(STATEMENT,0,"");
	attach_node($$,$1);
       }
    | stmt stmts {
	$$=make_node(STATEMENT,0,"");
	attach_node($$,$1);
	attach_node($$,$2);
    }

exprs: expr{
     $$=$1;
     }
     |expr COMMA exprs{
     $$=$1;
     attach_node($$,$3);
     }
/* an expression uses + or - or neither */
expr: NOT expr{
	$$=make_node(NOT,0,"");
	attach_node($$,$2);
      }
    | expr PLUS expr {
      $$ = make_node(PLUS,0,"");
      attach_node($$,$1);
      attach_node($$,$3);
      }
    | expr MINUS expr {
      $$ = make_node(MINUS,0,"");
      attach_node($$,$1);
      attach_node($$,$3);
      }
    | expr STAR expr {
      $$ = make_node(STAR,0,"");
      attach_node($$,$1);
      attach_node($$,$3);
      }
    | expr SLASH expr {
      $$ = make_node(SLASH,0,"");
      attach_node($$,$1);
      attach_node($$,$3);
      }
    | expr LESS expr {
      $$ = make_node(LESS,0,"");
      attach_node($$,$1);
      attach_node($$,$3);
      }
    | expr LESSEQUAL expr {
      $$ = make_node(LESSEQUAL,0,"");
      attach_node($$,$1);
      attach_node($$,$3);
      }
    | expr GREAT expr {
      $$ = make_node(GREAT,0,"");
      attach_node($$,$1);
      attach_node($$,$3);
      }
    | expr GREATEQUAL expr {
      $$ = make_node(GREATEQUAL,0,"");
      attach_node($$,$1);
      attach_node($$,$3);
      }
    | expr EQUAL expr {
      $$ = make_node(EQUAL,0,"");
      attach_node($$,$1);
      attach_node($$,$3);
      }
    | expr NOTEQUAL expr {
      $$ = make_node(NOTEQUAL,0,"");
      attach_node($$,$1);
      attach_node($$,$3);
      }
    | expr AND expr {
      $$ = make_node(AND,0,"");
      attach_node($$,$1);
      attach_node($$,$3);
      }
    | expr OR expr {
      $$ = make_node(OR,0,"");
      attach_node($$,$1);
      attach_node($$,$3);
      }
    | OPENPAREN expr CLOSEPAREN {
      $$=$2;
      }
    | identifier {
	$$=$1;
    }
    | VALUE {
	$$=make_node(VALUE,$1,"");	
    }
    | INPUT {
	$$=make_node(INPUT,0,"");
    }

identifier: IDENTIFIER OPENBRACKET expr CLOSEBRACKET{
          $$=make_node(IDENTIFIER,0,$1);
          attach_node($$,$3);
          }
          | IDENTIFIER{
          $$=make_node(IDENTIFIER,0,$1);
          }

%%

void print_tree(struct Node* node, int tabs) {
  int i;

  /* base case */
  if(!node){
      printf("!node");
      return;
  }

  /* print leading tabs */
  for(i = 0; i < tabs; i++) {
    printf("    ");
  }

  switch(node->type) {
    case IDENTIFIER: printf("IDENTIFIER: %s\n", node->id); break;
    case VALUE: printf("VALUE: %lf\n", node->value); break;
    case PLUS: printf("PLUS:\n"); break;
    case MINUS: printf("MINUS:\n"); break;
    case SLASH: printf("DIVIDE:\n"); break;
    case STAR: printf("TIMES:\n"); break;
    case LESS: printf("LESS THAN:\n"); break;
    case GREAT: printf("GREATER:\n"); break;
    case LESSEQUAL: printf("LESS EQUAL:\n"); break;
    case GREATEQUAL: printf("GREATER EQUAL:\n"); break;
    case EQUAL: printf("EQUALS:\n"); break;
    case NOTEQUAL: printf("NOT EQUALS:\n"); break;
    case AND: printf("AND:\n"); break;
    case OR: printf("OR:\n"); break;
    case NOT: printf("NOT:\n"); break;
    case ASSIGNMENT: printf("ASSIGN:\n"); break;
    case IF: printf("IF:\n"); break;
    case WHILE: printf("WHILE:\n"); break;
    case PRINT: printf("PRINT:\n"); break;
    case INPUT: printf("INPUT:\n"); break;
    case STATEMENT: printf("STATEMENT:\n"); break;
    case ARRAY: printf("ARRAY:\n"); break;
    case ARRAYINST: printf("ARRAYINST: %s\n",node->id); break;
    case FUNCTIONDECL: printf("FUNCTIONDECL: %s\n",node->id); break;
    case FUNCTIONCALL: printf("FUNCTIONCALL: %s\n",node->id); break;
    case MAIN: printf("MAIN:\n"); break;
    case ARRAYTYPE: printf("ARRAYTYPE:\n");break;
    case FLOAT: printf("FLOAT:\n");break;
    default:
      printf("Error, %d not a valid node type.\n", node->type);
      exit(1);
  }

  /* print all children nodes underneath */
  for(i = 0; i < node->num_children; i++) {
    print_tree(node->children[i], tabs + 1);
  }
}



/* creates a new node and returns it */
struct Node* make_node(int type, double value, char* id) {
  int i;

  /* allocate space */
  struct Node* node = malloc(sizeof(struct Node));

  /* set properties */
  node->type = type;
  node->value = value;
  strcpy(node->id, id);
  node->num_children = 0;
  for(i = 0; i < MAX_CHILDREN; i++) {
    node->children[i] = NULL;
  }

  /* return new node */
  return node;
}

/* attach an existing node onto a parent */
void attach_node(struct Node* parent, struct Node* child) {
  /* connect it */
  parent->children[parent->num_children] = child;
  parent->num_children++;
  assert(parent->num_children <= MAX_CHILDREN);
}

int yywrap( ) {
  return 1;
}

void yyerror(const char* str) {
  fprintf(stderr, "Compiler error: '%s'.\n", str);
}

void eval_stmt(struct Node* node,struct entry hashtable[1000]){
    int i;
    if(!node){
	printf("Base case");
	return;
    }
    
    switch(node->type) {
    case MAIN:{
    break;
    }
    case FUNCTIONCALL:
    {
    fprintf(fp,"#FUNCTIONCALL\n");
    fprintf(fp,"call _%s\n",node->id);
    break;
    }
    case FUNCTIONDECL:
    {
    fprintf(fp,"#FUNCTIONDECL\n");
    fprintf(fp,"_%s:\n",node->id);
    eval_stmt(node->children[1],hashtable);
    fprintf(fp,"ret\n");
    break;
    }
    case ARRAYINST:
        fprintf(fp,"#ARRAYINST\n");
        addVar(hashtable,node->id,0);
        eval_expr(node->children[0],hashtable);//after this, the size of the array should be in xmm7
        //four bytes per float
        fprintf(fp,"movl $%d, %%eax\n", floatToInt(.5));
        fprintf(fp,"subq $4, %%rsp\n");
        fprintf(fp,"movl %%eax, (%%rsp)\n");
        fprintf(fp,"movss (%%rsp), %%xmm6\n");
        fprintf(fp,"addq $4, %%rsp\n");
        fprintf(fp,"addss %%xmm6, %%xmm7\n");
        fprintf(fp,"cvttss2si %%xmm7, %%edi\n");
        fprintf(fp,"imul $4, %%edi\n");
        //INSERT move amount of bytes into rdi register using CVTTSS2SI
        fprintf(fp,"call malloc\n");//after this, rax should hold pointer to array
        fprintf(fp,"movq %%rax, .var%s(%%rip)\n",node->id);//hopefully moves pointer to array variable
        break;
	case ASSIGNMENT:
          fprintf(fp,"#ASSIGNMENT\n");
          //printf("left child:%s\n",node->children[0]->id);
          if(node->children[0]->num_children==0){
		    addVar(hashtable,node->children[0]->id,eval_expr(node->children[1],hashtable));
            fprintf(fp,"movss %%xmm7, .var%s(%%rip)\n",node->children[0]->id);
		  }else{
          //use same code, but add (size of float * array index) to variable address 
          eval_expr(node->children[0]->children[0],hashtable);//index should be in xmm7
          fprintf(fp,"subq $4, %%rsp\n");
          fprintf(fp,"movss %%xmm7, (%%rsp)\n");
          eval_expr(node->children[1],hashtable);//value should be in xmm7
          fprintf(fp,"lea .var%s(%%rip), %%rax\n",node->children[0]->id);
          fprintf(fp,"cvttss2si (%%rsp), %%rdi\n");
          fprintf(fp,"addq $4, %%rsp\n");
          fprintf(fp,"imul $32, %%rdi\n");
          fprintf(fp,"lea (%%rax,%%rdi,1), %%rax\n");
          fprintf(fp,"movq %%xmm7, (%%rax)\n");
          }
          break;
	case IF:
    {//scope operator for temporary IF counter
        fprintf(fp,"#IF\n");
        int thisLoopNumber = loopCount;
        loopCount++;
        eval_expr(node->children[0],hashtable);
        fprintf(fp,"movl $0, %%eax\n");
        fprintf(fp,"subq $4, %%rsp\n"); 
        fprintf(fp,"movl %%eax, (%%rsp)\n");
        fprintf(fp,"movss (%%rsp), %%xmm0\n");
        fprintf(fp,"addq $4, %%rsp\n");
        fprintf(fp,"ucomiss %%xmm0, %%xmm7\n");
        fprintf(fp,"je .if%d\n",thisLoopNumber);
        eval_stmt(node->children[1],hashtable);
        if(node->num_children>2)
            fprintf(fp,"jmp .ifEnd%d\n",thisLoopNumber);
        fprintf(fp,".if%d:\n",thisLoopNumber);
        if(node->num_children>2){
            eval_stmt(node->children[2],hashtable);
            fprintf(fp,".ifEnd%d:\n",thisLoopNumber);
        }
        /*
		if((int)eval_expr(node->children[0],hashtable)){
			eval_stmt(node->children[1],hashtable);
		    } else if (node->num_children>2){//check for else
			eval_stmt(node->children[2],hashtable);
		    }*/
		break;
    }
	case WHILE:
        {
        fprintf(fp,"#WHILE\n");
        int thisLoopNumber = loopCount;
        loopCount++;
        fprintf(fp,".while%d:\n",thisLoopNumber);
        eval_expr(node->children[0],hashtable);
        fprintf(fp,"movl $0, %%eax\n");
        fprintf(fp,"subq $4, %%rsp\n");
        fprintf(fp,"movl %%eax, (%%rsp)\n");
        fprintf(fp,"movss (%%rsp), %%xmm0\n");
        fprintf(fp,"addq $4, %%rsp\n");
        fprintf(fp,"ucomiss %%xmm0, %%xmm7\n");
        fprintf(fp,"je .whileEnd%d\n",thisLoopNumber);
		eval_stmt(node->children[1],hashtable);
        fprintf(fp,"jmp .while%d\n",thisLoopNumber);
        fprintf(fp,".whileEnd%d:\n",thisLoopNumber);
		/* while((int)eval_expr(node->children[0],hashtable)){
		     eval_stmt(node->children[1],hashtable);
		    }*/
        }
		 break;
	case PRINT:
        fprintf(fp,"#PRINT\n");
        printf("%f\n",eval_expr(node->children[0],hashtable));
        fprintf(fp,"movss %%xmm7, %%xmm0\n");
        fprintf(fp,"cvtps2pd %%xmm0, %%xmm0\n");
        fprintf(fp,"movq $doubleformatstr, %%rdi\n");
        fprintf(fp,"movl $1, %%eax\n");
        fprintf(fp,"call printf\n");
        break;
	case STATEMENT:
	    for (i=0;i<node->num_children;i++){
		eval_stmt(node->children[i],hashtable);
	    }
	    break;
	default:
	    printf("Error, %d not a valid node type.\n", node->type);
	    exit(1);
    }
}

float eval_expr(struct Node* node,struct entry hashtable[1000]){
    float input;
    switch(node->type){
	case ARRAY:
        fprintf(fp,"#ARRAY\n");
        break;
    case INPUT: 
	    scanf("%f",&input);
        fprintf(fp,"#INPUT\n");
        fprintf(fp,"movq $inputstr, %%rdi #input\n");
        fprintf(fp,"movq $.input, %%rsi #input\n");
        fprintf(fp,"movl $0, %%eax #input\n");
        fprintf(fp,"call scanf #input\n");
        fprintf(fp,"movq .input(%%rip), %%xmm7 #input\n");
	    //printf("Inpute: %f",input);
	    return input;
	    break;
	case IDENTIFIER:
	    //printf("Node ID: %s",node->id);
        fprintf(fp,"#IDENTIFIER\n");
        if(node->num_children>0){
            eval_expr(node->children[0],hashtable);
            fprintf(fp,"cvttss2si  %%xmm7, %%rdi\n");
            fprintf(fp,"lea .var%s(%%rip), %%rax\n",node->id);
            fprintf(fp,"imul $32, %%rdi\n");
            fprintf(fp,"lea (%%rax,%%rdi,1), %%rax\n");
            fprintf(fp,"movss (%%rax), %%xmm7\n");
        }else{
        fprintf(fp,"movss .var%s(%%rip), %%xmm7\n",node->id);
        }
	    return getVar(hashtable,node->id);
	    break;
	case VALUE:
            fprintf(fp,"#VALUE\n");
            fprintf(fp,"movl $%d, %%eax\n", floatToInt(node->value));
            fprintf(fp,"subq $4, %%rsp\n");
            fprintf(fp,"movl %%eax, (%%rsp)\n");
            fprintf(fp,"movss (%%rsp), %%xmm7\n");
            fprintf(fp,"addq $4, %%rsp\n");
            return node->value;
            break;
	case PLUS:
            {
            fprintf(fp,"#PLUS\n");
            float firstArg = eval_expr(node->children[0],hashtable);
            //printf("firstArg: %f\n",firstArg);
            //fprintf(fp,"movss %%xmm7, %%xmm1\n");
            //fprintf(fp,"pushq %%xmm7\n");
            fprintf(fp,"subq $4, %%rsp\n");
            fprintf(fp,"movss %%xmm7, (%%rsp)\n");
            //fprintf(fp,"movl $%d, %%eax\n",firstArg);
            //fprintf(fp,
            float secondArg = eval_expr(node->children[1],hashtable); 
            //printf("secondArg: %f\n",secondArg);
            //fprintf(fp,"popq %%xmm1\n");
            fprintf(fp,"movss (%%rsp), %%xmm1\n");
            fprintf(fp,"addq $4, %%rsp\n");
            fprintf(fp,"movss %%xmm7, %%xmm0\n");
            fprintf(fp,"addss %%xmm1, %%xmm0\n");
            fprintf(fp,"movss %%xmm0, %%xmm7\n");
            printf("%f PLUS %f: %f\n",firstArg,secondArg,(firstArg + secondArg));
            return firstArg + secondArg;
		    //return (eval_expr(node->children[0],hashtable)+eval_expr(node->children[1],hashtable));
            /*read eax
            push watever
            eval_expr(090)
            read eax
            eax = stack + eax*/
            break;
            }
	case MINUS:
            {
            fprintf(fp,"#MINUS\n");
            float firstArg = eval_expr(node->children[0],hashtable);
            //printf("firstArg: %f\n",firstArg);
            //fprintf(fp,"movss %%xmm7, %%xmm1\n"); 
            fprintf(fp,"subq $4, %%rsp\n");
            fprintf(fp,"movss %%xmm7, (%%rsp)\n");
            float secondArg = eval_expr(node->children[1],hashtable); 
            //printf("secondArg: %f\n",secondArg);
            fprintf(fp,"movss (%%rsp), %%xmm1\n");
            fprintf(fp,"addq $4, %%rsp\n");
            fprintf(fp,"movss %%xmm7, %%xmm0\n");
            fprintf(fp,"subss %%xmm0, %%xmm1\n");
            fprintf(fp,"movss %%xmm1, %%xmm7\n");
            printf("%f MINUS %f: %f\n",firstArg,secondArg,(firstArg - secondArg));
            return firstArg - secondArg;
		    //return (eval_expr(node->children[0],hashtable)-eval_expr(node->children[1],hashtable));
		    break;
            }
	case SLASH:
            {
            fprintf(fp,"#SLASH\n");
            float firstArg = eval_expr(node->children[0],hashtable);
            //printf("firstArg: %f\n",firstArg);
            //fprintf(fp,"movss %%xmm7, %%xmm1\n");
            fprintf(fp,"subq $4, %%rsp\n");
            fprintf(fp,"movss %%xmm7, (%%rsp)\n");
            float secondArg = eval_expr(node->children[1],hashtable); 
            //printf("secondArg: %f\n",secondArg);
            fprintf(fp,"movss (%%rsp), %%xmm1\n");
            fprintf(fp,"addq $4, %%rsp\n");
            fprintf(fp,"movss %%xmm7, %%xmm0\n");
            fprintf(fp,"divss %%xmm0, %%xmm1\n");
            fprintf(fp,"movss %%xmm1, %%xmm7\n");
            printf("%f SLASH %f: %f\n",firstArg,secondArg,(firstArg / secondArg));
            return firstArg / secondArg;
		    //return (eval_expr(node->children[0],hashtable)/eval_expr(node->children[1],hashtable));
		    break;
            }
	case STAR:
            {
            fprintf(fp,"#STAR\n");
            float firstArg = eval_expr(node->children[0],hashtable);
            //printf("firstArg: %f\n",firstArg);
            //fprintf(fp,"movss %%xmm7, %%xmm1\n");
            fprintf(fp,"subq $4, %%rsp\n");
            fprintf(fp,"movss %%xmm7, (%%rsp)\n");
            float secondArg = eval_expr(node->children[1],hashtable); 
            //printf("secondArg: %f\n",secondArg);
            fprintf(fp,"movss (%%rsp), %%xmm1\n");
            fprintf(fp,"addq $4, %%rsp\n");
            fprintf(fp,"movss %%xmm7, %%xmm0\n");
            fprintf(fp,"mulss %%xmm1, %%xmm0\n");
            fprintf(fp,"movss %%xmm0, %%xmm7\n");
            printf("%f STAR %f: %f\n",firstArg,secondArg,(firstArg * secondArg));
            return firstArg * secondArg;
		    //return (eval_expr(node->children[0],hashtable)*eval_expr(node->children[1],hashtable));
		    break;
            }
	case LESS:
            {
            fprintf(fp,"#LESS\n");
            float firstArg = eval_expr(node->children[0],hashtable);
		    fprintf(fp,"subq $4, %%rsp\n");
            fprintf(fp,"movss %%xmm7, (%%rsp)\n");
            float secondArg = eval_expr(node->children[1],hashtable);
            fprintf(fp,"movss (%%rsp), %%xmm1\n");
            fprintf(fp,"addq $4, %%rsp\n");
            fprintf(fp,"movss %%xmm7, %%xmm0\n");
            fprintf(fp,"call LESS\n");

            if(firstArg<secondArg)
			    return 1;
		    else
			    return 0;
		    break;
            }
	case GREAT:
            {
            fprintf(fp,"#GREAT\n");
            float firstArg = eval_expr(node->children[0],hashtable);
            fprintf(fp,"subq $4, %%rsp\n");
            fprintf(fp,"movss %%xmm7, (%%rsp)\n");
            float secondArg = eval_expr(node->children[1],hashtable);
            fprintf(fp,"movss (%%rsp), %%xmm0\n");
            fprintf(fp,"addq $4, %%rsp\n");
            fprintf(fp,"movss %%xmm7, %%xmm1\n");
            fprintf(fp,"call LESS\n");
		    
            if(firstArg>secondArg)
			    return 1;
		    else
			    return 0;
		    break;
            }
	case LESSEQUAL:
            {
            fprintf(fp,"#LESSEQUAL\n");
            float firstArg = eval_expr(node->children[0],hashtable);
		    fprintf(fp,"subq $4, %%rsp\n");
            fprintf(fp,"movss %%xmm7, (%%rsp)\n");
            float secondArg = eval_expr(node->children[1],hashtable);
            fprintf(fp,"movss (%%rsp), %%xmm1\n");
            fprintf(fp,"addq $4, %%rsp\n");
            fprintf(fp,"movss %%xmm7, %%xmm0\n");
            fprintf(fp,"call LESSEQUAL\n");

            if(firstArg<=secondArg)
			    return 1;
		    else
			    return 0;
		    break;
            }
	case GREATEQUAL:
            {
            fprintf(fp,"#GREATEQUAL\n");
            float firstArg = eval_expr(node->children[0],hashtable);
		    fprintf(fp,"subq $4, %%rsp\n");
            fprintf(fp,"movss %%xmm7, (%%rsp)\n");
            float secondArg = eval_expr(node->children[1],hashtable);
            fprintf(fp,"movss (%%rsp), %%xmm0\n");
            fprintf(fp,"addq $4, %%rsp\n");
            fprintf(fp,"movss %%xmm7, %%xmm1\n");
            fprintf(fp,"call LESSEQUAL\n");

            if(firstArg>=secondArg)
			    return 1;
		    else
			    return 0;
		    break;
            }
	case EQUAL:
		    if (eval_expr(node->children[0],hashtable)==eval_expr(node->children[1],hashtable))
			return 1;
		    else
			return 0;
		    break;
	case NOTEQUAL:
		    if(eval_expr(node->children[0],hashtable)!=eval_expr(node->children[1],hashtable))
			return 1;
		    else
			return 0;
		    break;
	case AND:
		    if(eval_expr(node->children[0],hashtable)&&eval_expr(node->children[1],hashtable))
			return 1;
		    else
			return 0;
		    break;
	case OR:
		    if(eval_expr(node->children[0],hashtable)||eval_expr(node->children[1],hashtable))
			return 1;
		    else
			return 0;
		    break;
	case NOT:if((int)eval_expr(node->children[0],hashtable)==0)
			return 1;
		    else
			return 0;
		    break;
	default:
	      printf("Error, %d not a valid node type/expression.\n",node->type);
	      exit(1);
    }
}


int hash_function(struct entry table[1000],char *varName){
    int hash=((varName[0]*26)+varName[1]+varName[2])%1000;
    while ((table[hash].key!=NULL)&&(strcmp(table[hash].key,varName))){
	    //printf("%d %d\n",table[hash].key!=NULL,table[hash].key!=varName);
	    //printf("Keys: Passed: \"%s\" Found: \"%s\"",varName,table[hash].key);
	    hash=((hash+1)%1000);
    }
    if(table[hash].key==NULL){
        varCount+=1;
        table[hash].count=varCount;
    }
    //printf("Hash: %d\n",hash);
    return hash;
}
void addVar(struct entry table[1000],char *var,float value){
    int index = hash_function(table,var);
    table[index].key=var;
    table[index].value=value;
    //printf("Var: %s added with Value: %f\n", var,value);
}
float getVar(struct entry table[1000],char *var){
    int index = hash_function(table,var);
    //printf("Var: %s, Value: %f\n",var,table[index].value);
    return table[index].value;
}
int main(int argc, char *argv[]) {
    if(argc<2){
	printf("error: pass sloth source");
	return 0;
    }
    FILE* orig_stdin=stdin;
    stdin = fopen(argv[1],"r");
    if(stdin==NULL){
	printf("Error: file does not exist\n");
	return 0;
    }
    yyparse();
    print_tree(tree,1);

    fclose(stdin);
    stdin=orig_stdin;

    struct entry hashtable[1000];//should've just used a global var
    int i;
    for (i=0;i<1000;i++){
	//printf("%d",i);
	hashtable[i].key=NULL;
	hashtable[i].value=0;
    //hashtable[i].count=0;
    }
    /* hashtable debugging
    addVar(hashtable,"x",1);
    addVar(hashtable,"y",2);
    addVar(hashtable,"a",3);
    addVar(hashtable,"b",4);
    addVar(hashtable,"temp",5);
    addVar(hashtable,"foo",6);
    addVar(hashtable,"bar",7);
    addVar(hashtable,"x",12);
    printf("%f\n",getVar(hashtable,"x"));
    printf("%f\n",getVar(hashtable,"y"));
    printf("%f\n",getVar(hashtable,"a"));
    printf("%f\n",getVar(hashtable,"b"));
    printf("%f\n",getVar(hashtable,"temp"));
    printf("%f\n",getVar(hashtable,"foo"));
    printf("%f\n",getVar(hashtable,"bar"));
    */

    fp = fopen("filename.s","w");
    //Initial compiled code file setup
    //write initial data sections 
    fprintf(fp,".file \"filename.sl\"\n");
    fprintf(fp,".text\n");
    fprintf(fp,".globl main\n");
    //fprintf(fp,".type main, @function\n");
    fprintf(fp,"\n"); //newline for readability
    fprintf(fp,"main:\n");
    fprintf(fp,"pushq %%rbp\nmovq %%rsp, %%rbp\n");
    fprintf(fp,"movl $0, %%eax\n");
    eval_stmt(tree,hashtable);
    fprintf(fp,"leave\n");
    //fprintf(fp,"popq %%rbp\n");
    fprintf(fp,"ret\n");
    
    //LESS procedure
    fprintf(fp,"LESS:\n");
        fprintf(fp,"ucomiss %%xmm0, %%xmm1\n");
        fprintf(fp,"jb .setOne\n");
        //setZero
        fprintf(fp,"movl $%d, %%eax\n", floatToInt(0.0));
        fprintf(fp,"subq $4, %%rsp\n");
        fprintf(fp,"movl %%eax, (%%rsp)\n");
        fprintf(fp,"movss (%%rsp), %%xmm7\n");
        fprintf(fp,"addq $4, %%rsp\n");
        fprintf(fp,"jmp .end\n");
        fprintf(fp,".setOne:\n");//setOne
        fprintf(fp,"movl $%d, %%eax\n", floatToInt(1.0));
        fprintf(fp,"subq $4, %%rsp\n");
        fprintf(fp,"movl %%eax, (%%rsp)\n");
        fprintf(fp,"movss (%%rsp), %%xmm7\n");
        fprintf(fp,"addq $4, %%rsp\n");
        fprintf(fp,".end:\n");
        fprintf(fp,"ret\n");
    
    //LESSEQUAL procedure
    fprintf(fp,"LESSEQUAL:\n");
        fprintf(fp,"ucomiss %%xmm0, %%xmm1\n");
        fprintf(fp,"jbe .setOne2\n");
        //setZero
        fprintf(fp,"movl $%d, %%eax\n", floatToInt(0.0));
        fprintf(fp,"subq $4, %%rsp\n");
        fprintf(fp,"movl %%eax, (%%rsp)\n");
        fprintf(fp,"movss (%%rsp), %%xmm7\n");
        fprintf(fp,"addq $4, %%rsp\n");
        fprintf(fp,"jmp .end2\n");
        fprintf(fp,".setOne2:\n");//setOne
        fprintf(fp,"movl $%d, %%eax\n", floatToInt(1.0));
        fprintf(fp,"subq $4, %%rsp\n");
        fprintf(fp,"movl %%eax, (%%rsp)\n");
        fprintf(fp,"movss (%%rsp), %%xmm7\n");
        fprintf(fp,"addq $4, %%rsp\n");
        fprintf(fp,".end2:\n");
        fprintf(fp,"ret\n");
    
    fprintf(fp,".size main, .-main\n");
    
    fprintf(fp,".data\n");
    fprintf(fp,"doubleformatstr: .string \"double: %%f\\n\"\n");
    fprintf(fp,"inputstr: .string \"%%f\"\n");
    for (i=0;i<1000;i++){
        if(hashtable[i].key!=NULL)
            fprintf(fp,".var%s:\n\t.long 0\n.long 0\n\t.align 4\n",hashtable[i].key);
    }
    fprintf(fp,".input:\n\t.long 0\n\t.align 4\n");
    fprintf(fp,".ident \"jstanesa sloth compiler\"\n");
    //Cleanup
    fclose(fp);
    return 0;
}

int floatToInt(float a){
    return (*(int*) &a);
}

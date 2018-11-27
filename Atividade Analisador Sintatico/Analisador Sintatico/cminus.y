/********************************************************************************/
/* File: cminus.y                                                               */
/* Lex specification for CMINUS                                                 */
/* References: Compiler discipline, teacher A.C Lorena, Unifesp - Brazil -2017  */
/* Douglas Diniz Landim - ddlandim@unifesp.br                                   */
/********************************************************************************/
%{
#define YYPARSER /* distinguishes Yacc output from other code files */
#include "globals.h"
#include "util.h"
#include "scan.h"
#include "parse.h" 

#define YYSTYPE TreeNode *
static char * savedName; /* for use in assignments */
static int savedLineNo;  /* ditto */
static TreeNode * savedTree; /* stores syntax tree for later return */
static int yylex(void);


%}

%token IF ELSE WHILE INT VOID RETURN
%token NUM ID
%token ASSIGN EQ NE LT LTE GT GTE PLUS MINUS TIMES OVER LPAREN RPAREN LBRACKET RBRACKET LKEYS RKEYS COMMA SEMI
%token ERROR ENDFILE

%% /* Grammar for CMINUS */

program            :   list_declaration
                       {
                          savedTree = $1;
                       }
                    ;
list_declaration    :   list_declaration declaration
                        {
                            YYSTYPE t = $1;
                            if(t != NULL)
                    {
                                while(t->sibling != NULL)
                                    t = t->sibling;
                                t->sibling = $2;
                                $$ = $1;
                            }
                            else
                                $$ = $2;
                        }
                    |   declaration
                        {
                           $$ = $1;
                        }
                    ;
declaration         :   var_declaration
                        {
                           $$ = $1;
                        }
                    |   fun_declaration
                        {
                           $$ = $1;
                        }
                    ;
var_declaration     :   specify_type ident SEMI
                        {
                            $$ = $1;
                            $$->child[0] = $2;
                            $2->nodekind = StmtK;
                            $2->kind.stmt = VariableK;
                        }
                    |   specify_type ident LBRACKET num RBRACKET SEMI
                        {
                            $$ = $1;
                            $$->child[0] = $2;
                            $2->nodekind = StmtK;
                            $2->kind.stmt = VectorK;
                            $2->attr.len = $4->attr.val;
                        }
                    ;
specify_type        :   INT
                        {
                            $$ = newExpNode(TypeK);
                            $$->type = IntegerK;
                            $$->attr.name = "Integer";
                        }

                    |   VOID
                        {
                            $$ = newExpNode(TypeK);
                            $$->type = VoidK;
                            $$->attr.name = "Void";
                        }
                    ;
fun_declaration     :   specify_type ident LPAREN params RPAREN compound_decl
                        {
                            $$ = $1;
                            $$->child[0] = $2;
                            $2->child[0] = $4;
                            $2->child[1] = $6;
                            $2->nodekind = StmtK;
                            $2->kind.stmt = FunctionK;
                        }
                    ;
params              :   param_list
                        {
                           $$ = $1;
                        }
                    |   VOID
                        {
            }
                   ;
param_list         :   param_list COMMA param
                       {
                           YYSTYPE t = $1;
                           if(t != NULL)
               {
                              while(t->sibling != NULL)
                                  t = t->sibling;
                              t->sibling = $3;
                              $$ = $1;
                            }
                            else
                              $$ = $3;
                        }
                    |   param
                        {
                            $$ = $1;
                        }
                    ;
param               :   specify_type ident
                        {
                           $$ = $1;
                           $$->child[0] = $2;
                        }
                    |   specify_type ident LBRACKET RBRACKET
                         {
                            $$ = $1;
                            $$->child[0] = $2;
                            $2->kind.exp = VectorK;
                         }
                    ;
compound_decl       :   LKEYS local_declarations statement_list RKEYS
                        {
                            YYSTYPE t = $2;
                            if(t != NULL)
                {
                               while(t->sibling != NULL)
                                  t = t->sibling;
                                t->sibling = $3;
                                $$ = $2;
                            }
                            else
                               $$ = $3;
                        }
                    |   LKEYS local_declarations RKEYS
                        {
                            $$ = $2;
                        }
                    |   LKEYS statement_list RKEYS
                        {
                            $$ = $2;
                        }
                    |   LKEYS RKEYS
                        {
              }
                    ;
local_declarations  :   local_declarations var_declaration
                        {
                            YYSTYPE t = $1;
                            if(t != NULL)
              {
                              while(t->sibling != NULL)
                                   t = t->sibling;
                              t->sibling = $2;
                              $$ = $1;
                            }
                            else
                               $$ = $2;
                        }
                   |    var_declaration
                        {
                            $$ = $1;
                        }
                   ;
statement_list     :   statement_list statement
                       {
                           YYSTYPE t = $1;
                           if(t != NULL)
               {
                              while(t->sibling != NULL)
                                   t = t->sibling;
                              t->sibling = $2;
                              $$ = $1;
                           }
                           else
                             $$ = $2;
                       }
                    |   statement
                        {
                           $$ = $1;
                        }
                    ;
statement           :   expression_decl
                        {
                           $$ = $1;
                        }
                    |   compound_decl
                        {
                           $$ = $1;
                        }
                    |   selection_decl
                        {
                           $$ = $1;
                        }
                    |   iterator_decl
                        {
                           $$ = $1;
                        }
                    |   return_decl
                        {
                           $$ = $1;
                        }
                    ;
expression_decl     :   expression SEMI 
                        {
                           $$ = $1;
                        }
                    |   SEMI
                        {
            }
                    ;
selection_decl      :   IF LPAREN expression RPAREN statement 
                        {
                             $$ = newStmtNode(IfK);
                             $$->child[0] = $3;
                             $$->child[1] = $5;
                        }
                    |   IF LPAREN expression RPAREN statement ELSE statement
                        {
               
                             $$ = newStmtNode(IfK);
                             $$->child[0] = $3;
                             $$->child[1] = $5;
                             $$->child[2] = $7;
                        }
                    ;
iterator_decl       :   WHILE LPAREN expression RPAREN statement
                        {
                             $$ = newStmtNode(WhileK);
                             $$->child[0] = $3;
                             $$->child[1] = $5;
                        }
                   ;
return_decl        :   RETURN SEMI
                       {
                            $$ = newStmtNode(ReturnK);
                       }
                   |   RETURN expression SEMI
                       {
                            $$ = newStmtNode(ReturnK);
                            $$->child[0] = $2;
                       }
                   ;
expression         :   var ASSIGN expression
                       {
                            $$ = newStmtNode(AssignK);
                            $$->child[0] = $1;
                            $$->child[1] = $3;
                       }
                   |   simple_expression
                       {
                            $$ = $1;
                       }
                   ;
var                :   ident
                       {
                            $$ = $1;
                       }
                   |   ident LBRACKET expression RBRACKET
                       {
                            $$ = $1;
                            $$->child[0] = $3;
                            $$->kind.exp = VectorIdK;
                       }
                    ;
simple_expression   : sum_expression relational sum_expression
                       {
                            $$ = $2;
                            $$->child[0] = $1;
                            $$->child[1] = $3;
                       }
                    |  sum_expression
                       {
                            $$ = $1;
                       }
                    ;
relational          :  EQ
                       {
                            $$ = newExpNode(OpK);
                            $$->attr.op = EQ;                            
                       }
                    |  NE
                       {
                            $$ = newExpNode(OpK);
                            $$->attr.op = NE;                            
                       }
                    |  LT
                       {
                            $$ = newExpNode(OpK);
                            $$->attr.op = LT;                            
                       }
                    |  LTE
                       {
                            $$ = newExpNode(OpK);
                            $$->attr.op = LTE;                            
                       }
                    |  GT
                       {
                            $$ = newExpNode(OpK);
                            $$->attr.op = GT;                            
                       }
                    |  GTE
                       {
                            $$ = newExpNode(OpK);
                            $$->attr.op = GTE;                            
                       }
                    ;
sum_expression      :  sum_expression sum term
                       {
                            $$ = $2;
                            $$->child[0] = $1;
                            $$->child[1] = $3;
                       }
                    |  term
                       {
                            $$ = $1;
                       }
                   ;
sum                :  PLUS
                      {
                            $$ = newExpNode(OpK);
                            $$->attr.op = PLUS;                            
                      }
                    | MINUS
                      {
                            $$ = newExpNode(OpK);
                            $$->attr.op = MINUS;                            
                      }
                   ;
term               :   term mult factor
                       {
                            $$ = $2;
                            $$->child[0] = $1;
                            $$->child[1] = $3;
                       }
                   |   factor
                       {
                            $$ = $1;
                       }
                   ;
mult               :   TIMES
                       {
                            $$ = newExpNode(OpK);
                            $$->attr.op = TIMES;                            
                       }
                   |   OVER
                       {
                            $$ = newExpNode(OpK);
                            $$->attr.op = OVER;                            
                       }
                   ;
factor             :   LPAREN expression RPAREN
                       {
                            $$ = $2;
                       }
                   |   var
                       {
                            $$ = $1;
                       }
                   |   activation
                       {
                            $$ = $1;
                       }
                   |   num
                       {
                            $$ = $1;
                       }
                   ;
activation         :   ident LPAREN arg_list RPAREN
                       {
                            $$ = $1;
                            $$->child[0] = $3;
                            $$->nodekind = StmtK;
                            $$->kind.stmt = CallK;
                       }
                   |   ident LPAREN RPAREN 
             {
                            $$ = $1;
                            $$->nodekind = StmtK;
                            $$->kind.stmt = CallK;
                       }
                       
                   ;
arg_list           :   arg_list COMMA expression
                       {
                            YYSTYPE t = $1;
                             if(t != NULL)
               {
                                while(t->sibling != NULL)
                                   t = t->sibling;
                                 t->sibling = $3;
                                 $$ = $1;
                             }
                             else
                                 $$ = $3;
                        }
                    |   expression
                        {
                             $$ = $1;
                        }
                    ;
ident               :   ID
                        {
                             $$ = newExpNode(IdK);
                             $$->attr.name = copyString(tokenString);
                        }
                    ;
num                 :   NUM
                        {
                             $$ = newExpNode(ConstK);
                             $$->attr.val = atoi(tokenString);
                        }
                    ;

%%

int yyerror(char* message){
    fprintf(listing,"Syntax error at line %d: %s\n",lineno,message);
    fprintf(listing,"Current token: ");
    printToken(yychar,tokenString);
    Error = TRUE;
    return 0;
}

/* yylex calls getToken to make Yacc/Bison output
 * compatible with ealier versions of the TINY scanner
 */
static int yylex(void)
{ return getToken(); }

TreeNode * parse(void)
{ yyparse();
  return savedTree;
}
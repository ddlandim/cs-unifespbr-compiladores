/********************************************************************************/ 
/* File: analyze.c                                                              */
/* Semantic analyzer implementation                                             */
/* References: Compiler discipline, teacher A.C Lorena, Unifesp - Brazil -2017  */
/* Douglas Diniz Landim - ddlandim@unifesp.br                                   */
/********************************************************************************/
 
#include "globals.h"
#include "symtab.h"
#include "analyze.h"

static void typeError(TreeNode * t, char * message)
{ fprintf(listing,"Type error in %s at line %d: %s\n",t->attr.name, t->lineno,message);
  Error = TRUE;
}

/* counter for variable memory locations */
static int location = 0;

/* Procedure traverse is a generic recursive 
 * syntax tree traversal routine:
 * it applies preProc in preorder and postProc 
 * in postorder to tree pointed to by t
 */
static void traverse( TreeNode * t,
               void (* preProc) (TreeNode *),
               void (* postProc) (TreeNode *) ){ 
  if (t != NULL){ 
  	preProc(t);{ 
	  		int i;
	        for (i=0; i < MAXCHILDREN; i++)
        		traverse(t->child[i],preProc,postProc);
    	}
    	postProc(t);
    	traverse(t->sibling,preProc,postProc);
  	}
}

/* nullProc is a do-nothing procedure to 
 * generate preorder-only or postorder-only
 * traversals from traverse
 */
static void nullProc(TreeNode * t)
{ 
	if (t==NULL) 
		return;
  	else 
		return;
}

/* Procedure insertNode inserts 
 * identifiers stored in t into 
 * the symbol table 
 */
static void insertNode( TreeNode * t)
{ 
	switch (t->nodekind){ 
    case StmtK:
      switch (t->kind.stmt){ 		
			 case VariableK:
          		if (st_lookup(t->attr.name, t->attr.scope) == -1 && st_lookup(t->attr.name, "global") == -1)
            		st_insert(t->attr.name,t->lineno,location++, t->attr.scope, "variable", "integer");
          		else
            		typeError(t,"Declaration Error: Already declared.");	
            break;
			 case FunctionK:
				if (st_lookup(t->attr.name, t->attr.scope) == -1 && st_lookup(t->attr.name, "global") == -1)
				{
					if(t->type == integerK)
                        st_insert(t->attr.name,t->lineno,location++, t->attr.scope,"function", "integer");
            		else
                        st_insert(t->attr.name,t->lineno,location++, t->attr.scope,"function", "void");
            	}
          		else
            		typeError(t,"Declaration Error: Already declared.");	
			break;
			case CallK:
				if (st_lookup(t->attr.name, t->attr.scope) == -1 && st_lookup(t->attr.name, "global") == -1)
            		typeError(t,"Call Error. It was not declared.");	
          		else
            		st_insert(t->attr.name,t->lineno,location++, t->attr.scope, "call", "-");
			case ReturnK:
          	break;
        	default:
          break;
      }
      break;
      case ExpK:
      switch (t->kind.exp)
      { 
		  case IdK:
			if (st_lookup(t->attr.name, t->attr.scope) == -1 && st_lookup(t->attr.name, "global") == -1)
				 typeError(t,"Declaration Error: it was not declared");
			else
            	st_insert(t->attr.name,t->lineno,0, t->attr.scope, "variable", "integer");	
	      break;
	      case VectorK:
	      	if (st_lookup(t->attr.name, t->attr.scope) == -1 && st_lookup(t->attr.name, "global") == -1)
				 typeError(t,"Declaration Error: it was not declared");
			else
            	st_insert(t->attr.name,t->lineno,0, t->attr.scope, "vector", "integer");	
		  break;
		  case VectorIdK:
		  	if (st_lookup(t->attr.name, t->attr.scope) == -1 && st_lookup(t->attr.name, "global") == -1)
				 typeError(t,"Declaration Error: it was not declared");
			else
            	st_insert(t->attr.name,t->lineno,0, t->attr.scope, "vector index", "integer");	
		  case TypeK:
          break;
        default:
        break;
      }
      break;
    default:
      break;
  }
}

void buildSymtab(TreeNode * syntaxTree)
{ 
   
  traverse(syntaxTree,insertNode,nullProc); 
  if(st_lookup("main", "global") == -1)
   {
   		printf("Declaration Error: main was not declared");
   		Error = TRUE; 
   }
	
  if (TraceAnalyze)
  { 
    fprintf(listing,"\n Elements of symbol table :\n\n");
    printSymTab(listing);
  }
}

static void checkNode(TreeNode * t)
{ switch (t->nodekind)
  { 
   case ExpK:
      switch (t->kind.exp)
      { 
        case OperationK:
        break;
        default:
        break;
      }
      break;
    case StmtK:
      switch (t->kind.stmt)
      { 
        case IfK:
          if (t->child[0]->type == integerK && t->child[1]->type == integerK)
           typeError(t->child[0],"Type Error: if test is not Boolean");
        break;
        case AssignK:
          if (t->child[0]->type == voidK || t->child[1]->type == voidK)
            typeError(t->child[0],"assignment of non-integer value");
		  else if(t->child[1]->kind.stmt == CallK)
		  {
		    if(strcmp(st_lookup_type(t->child[1]->attr.name, t->child[1]->attr.scope), "void"))
				typeError(t->child[1],"assignment of void return");
			}
        break;
        default:
        break;
      }
    break;
    default:
    break;
  }
}

void typeCheck(TreeNode * syntaxTree)
{ 
    traverse(syntaxTree,nullProc,checkNode);
}

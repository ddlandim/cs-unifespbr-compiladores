/********************************************************************************/
/* File: cminus.l                                                               */
/* Lex specification for CMINUS                                                 */
/* References: Compiler discipline, teacher A.C Lorena, Unifesp - Brazil -2017  */
/* Douglas Diniz Landim - ddlandim@unifesp.br                                   */
/********************************************************************************/

%{ 
#include "globals.h"
#include "util.h"
#include "scan.h" 
/* lexeme of identifier or reserved word */
char tokenString[MAXTOKENLEN+1];
static int yylex(void); 
%}

digit       [0-9]
number      {digit}+
letter      [a-zA-Z]
identifier  {letter}+
newline     \r?\n
whitespace  [ \t]+ 


%%

"else"          {return ELSE;}
"if"            {return IF;}
"int"           {return INT;}
"return"        {return RETURN;}
"void"          {return VOID;}
"while"         {return WHILE;}

"+"             {return PLUS;}
"-"             {return MINUS;}
"*"             {return TIMES;}
"/"             {return OVER;}

"<"             {return LT;}
"<="            {return LTE;}
">"             {return GT;}
">="            {return GTE;}

"=="            {return EQ;}
"!="            {return NE;}
"="             {return ASSIGN;}


";"             {return SEMI;}
","             {return COMMA;}

"("             {return LPAREN;}
")"             {return RPAREN;}
"["             {return LBRACKET;}
"]"             {return RBRACKET;}
"{"             {return LKEYS;}
"}"             {return RKEYS;}

{number}        {return NUM;}
{identifier}    {return ID;}
{newline}       {lineno++;}
{whitespace}    {/* skip whitespace */}
"/*"            { char meta1;
                  do{
                    meta1 = input();
                    if (meta1 == '\n') lineno++;
                    if(meta1 == '*'){
                      meta1 = input();
                      if(meta1 == '/') break;
                    }
                  }while (meta1 != EOF);
                }

.               {return ERROR;}
<<EOF>>         {return ENDFILE;}
%%

TokenType getToken(void)
{ static int firstTime = TRUE;
  TokenType currentToken;
  if (firstTime)
  { firstTime = FALSE;
    lineno++;
    yyin = source;
    yyout = listing;
  }
  currentToken = yylex();
  strncpy(tokenString,yytext,MAXTOKENLEN);
  if (TraceScan) {
    fprintf(listing,"\t%d: ",lineno);
    printToken(currentToken,tokenString);
  }
  return currentToken;
}
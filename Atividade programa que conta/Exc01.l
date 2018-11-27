/*
* Aluno: Douglas Diniz Landim RA: 76681
* Contador de tokens
* /
%{
int num_numbers = 0, num_ids = 0, num_symbols = 0;
%}

DIGIT [0-9]
Rwords ["asm"	"auto"	"break"	"case" "catch"	"char"	"class"	"const" "continue"	"default"	"delete"	"do" "double"	"else"	"enum"	"extern" "float"	"for"	"friend"	"goto" "if"	"inline"	"int"	"long" "new" "operator" "private"	"protected" "public"	"register" "return"	"short" "signed"	"sizeof" "static" "struct" "switch"	"template"	"this"	"throw" "try"	"typedef"	"union" "unsigned" "virtual"	"void"	"volatile"	"while"]
letter [a-zA-Z]
espaco [\t]+
newline \r?\n
symbols [.^({letter}|{DIGIT}|{espaco})]
%%

{espaco}
{newline} 
{letter}({DIGIT}|{letter})* ++num_ids;
[0-9]{DIGIT}* ++num_numbers;
{symbols}  ++num_symbols;


<<EOF>> return 0;

%%

int main(int argc, char *argv[])
{
 FILE *f_in;
 if (argc == 2)
 {
 if(f_in = fopen(argv[1],"r")) yyin = f_in;
 else perror(argv[0]);
 }
 else yyin = stdin;
 yylex();
	printf("# of numbers %d, # of symbols %d, # of ids %d\n",  num_numbers, num_symbols, num_ids);
 return(0);
 }

 
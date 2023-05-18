%{
#include <stdio.h>
#include<string>
#include<vector>
#include<string.h>
#include<stdlib.h>
    //extern int yylineno;
    //extern int yyparse();
    extern int yylex(void);
    extern int currLine;
    void yyerror (char const *s) {
        fprintf (stderr, "Error at line %d: %s\n", currLine, s);
    }
    //extern FILE* yyin;
    
    /*Phase 3 begin*/
char *identToken;
int  numberToken;
int  count_names = 0;

enum Type { Integer, Array };

struct Symbol {
  std::string name;
  Type type;
};

struct Function {
  std::string name;
  std::vector<Symbol> declarations;
};

std::vector<Function> symbol_table;

// remember that Bison is a bottom up parser: that it parses leaf nodes first before
// parsing the parent nodes. So control flow begins at the leaf grammar nodes
// and propagates up to the parents.
Function *get_function() {
  int last = symbol_table.size()-1;
  if (last < 0) {
    printf("***Error. Attempt to call get_function with an empty symbol table\n");
    printf("Create a 'Function' object using 'add_function_to_symbol_table' before\n");
    printf("calling 'find' or 'add_variable_to_symbol_table'");
    exit(1);
  }
  return &symbol_table[last];
}

// find a particular variable using the symbol table.
// grab the most recent function, and linear search to
// find the symbol you are looking for.
// you may want to extend "find" to handle different types of "Integer" vs "Array"
bool find(std::string &value) {
  Function *f = get_function();
  for(int i=0; i < f->declarations.size(); i++) {
    Symbol *s = &f->declarations[i];
    if (s->name == value) {
      return true;
    }
  }
  return false;
}

// when you see a function declaration inside the grammar, add
// the function name to the symbol table
void add_function_to_symbol_table(std::string &value) {
  Function f; 
  f.name = value; 
  symbol_table.push_back(f);
}

// when you see a symbol declaration inside the grammar, add
// the symbol name as well as some type information to the symbol table
void add_variable_to_symbol_table(std::string &value, Type t) {
  Symbol s;
  s.name = value;
  s.type = t;
  Function *f = get_function();
  f->declarations.push_back(s);
}

// a function to print out the symbol table to the screen
// largely for debugging purposes.
void print_symbol_table(void) {
  printf("symbol table:\n");
  printf("--------------------\n");
  for(int i=0; i<symbol_table.size(); i++) {
    printf("function: %s\n", symbol_table[i].name.c_str());
    for(int j=0; j<symbol_table[i].declarations.size(); j++) {
      printf("  locals: %s\n", symbol_table[i].declarations[j].name.c_str());
    }
  }
  printf("--------------------\n");
}

struct CodeNode {
    std::string code; // generated code as a string.
    std::string name;
};
    /*Phase 3 end*/
%}


%union {
  char *op_val;
  struct CodeNode *node;
  int int_val;
}

%define parse.error verbose
%token /*NUMBER IDENTIFIER*/ INTEGER ARRAY ACCESS_ARRAY ASSIGNMENT PERIOD ADDITION SUBTRACTION DIVISION MULTIPLICATION MOD LESS GREATER GREATER_OR_EQUAL LESSER_OR_EQUAL EQUAL DIFFERENT WHILE IF THEN ELSE PRINT READ FUNC_EXEC FUNCTION BEGIN_PARAMS END_PARAMS NOT AND OR TAB SEMICOLON LEFT_PAREN RIGHT_PAREN RETURN COMMA BREAK QUOTE
%token <op_val> NUMBER 
%token <op_val> IDENTIFIER
%type  <op_val> symbol 
%type  <op_val> function_ident
%type  <node>   functions
%type  <node>   function
%type  <node>   declarations
%type  <node>   declaration
%type  <node>   statements
%type  <node>   statement
%start prog_start
%locations

%%


prog_start: %empty 
{
}      
| functions 
{
}
;

functions: function 
{
}
| function functions 
{
}
;


function: FUNCTION IDENTIFIER BEGIN_PARAMS declarations END_PARAMS SEMICOLON statements 
{
}
;

statements: tabs statement 
{
}
| tabs statement statements 
{
}
;

statement: %empty 
| var expression PERIOD 
{
}
| var ASSIGNMENT expression PERIOD 
{
}
| ELSE SEMICOLON statements 
{
}
| IF bool_exp SEMICOLON statements 
{
}
| WHILE bool_exp SEMICOLON statements 
{
}
| READ var PERIOD 
{
}
| PRINT var PERIOD 
{
}
| BREAK PERIOD 
{
}
| RETURN expression PERIOD
{
}
| expression PERIOD 
{
}
| declaration PERIOD 
{
}
;

tabs: single_tab 
{
}
| tabs single_tab
{
}
;

single_tab: TAB 
{
}
;

bool_exp: negate expression comp expression 
{
}
;

negate: %empty 
{
}
| NOT 
{
}
;

declarations: %empty 
{
}
| declaration 
{
}
| declaration COMMA declarations 
{
}

declaration: IDENTIFIER array_declaration INTEGER 
{
}
;

array_declaration: %empty 
{
}
| ARRAY NUMBER 
{
}
;

comp: LESS 
{
}
| GREATER 
{
}
| GREATER_OR_EQUAL 
{
}
| LESSER_OR_EQUAL 
{
}
| EQUAL 
{
}
;

expression: multiplicative_expr 
{
}
| multiplicative_expr ADDITION multiplicative_expr 
{
}
| multiplicative_expr SUBTRACTION multiplicative_exp
{
}
;

multiplicative_expr: term 
{
}
| term MULTIPLICATION term 
{
}
| term DIVISION term 
{
}
| term MOD term 
{
}

term: var 
{
}
| INTEGER
| NUMBER 
{
}
| LEFT_PAREN expression RIGHT_PAREN 
{
}
| FUNC_EXEC IDENTIFIER BEGIN_PARAMS expressions END_PARAMS 
{
}

expressions: %empty 
{
}
| expression 
{
}
| expression COMMA expressions 
{
}

var: IDENTIFIER 
{
}
| IDENTIFIER ACCESS_ARRAY expression 
{
}
%%


int main(int argc, char **argv) {
	/*yyin = stdin;
	
	do {
	  printf("Ctrl + D to quit\n");
	  yyparse();
	} while(!feof(yyin));
	return 0;*/
	yyparse();
   	return 0;
}

%{
#include <stdio.h>
#include <stdlib.h>
#include "src/defs.h"
#include "y.tab.h"

extern yytext_stack_struct* yytext_stack;
void yyerror(const char *);
int id_or_keyword(char *s);
%}

%option noyywrap
%option yylineno
%option caseless

ADDOP_ADD \+
ADDOP_SUB -
RELOP_NE <>
RELOP_GE >=
RELOP_LE <=
RELOP_GT >
RELOP_LT <
MULDIVANDOP_MUL \*
MULDIVANDOP_DIV \/
MULDIVANDOP_DIV_E DIV
MULDIVANDOP_MOD MOD
MULDIVANDOP_AND AND
KEYWORD_OR_ID _?[a-zA-Z][a-zA-Z0-9_]*
RCONST_REAL ((([1-9][0-9]*)|0|e?)\.(([0-9]*[1-9][0-9]*)|0)([E][+-]?(([1-9][0-9]*)|0))?)
RCONST_INT (([1-9][0-9]*)|0|e?)E[+-]?[0-9]+
RCONST_HEX 0H(([1-9A-F][0-9A-F]*)|0|e?)\.(([0-9A-F]*[1-9A-F][0-9A-F]*)|0)
RCONST_BIN 0B((1[01]*)|0)\.(([01]*1[01]*)|0)
ICONST ((([1-9][0-9]*)|0))|(0H(([1-9A-F][0-9A-F]*)|0))|(0B((1[01]*)|0))
BCONST TRUE|FALSE
CCONST '((\\n)|(\\f)|(\\t)|(\\r)|(\\b)|(\\v)|[\x20-\x7E])'
STRING \"((\\n)|(\\f)|(\\t)|(\\r)|(\\b)|(\\v)|(\\\n)|[\x20-\x7E])*\"
COMMENT "{"[^}]*"}"
WHITESPACE [ \t\r]+
NEWLINE [\n]

%%
"("                 { return LPAREN; }
")"                 { return RPAREN; }
";"                 { return SEMI; }
"."                 { return DOT; }
","                 { return COMMA; }
"="                 { return EQU; }
":"                 { return COLON; }
"["                 { return LBRACK; }
"]"                 { return RBRACK; }
":="                { return ASSIGN; }
".."                { return DOTDOT; }
{BCONST}            {
                        push_yytext_stack(yytext);
                        yylval.string = strdup(yytext);
                        return BCONST; 
                    }
{CCONST}	        { 
                        push_yytext_stack(yytext);
                        yylval.string = strdup(yytext);
                        return CCONST;  
                    }
{ICONST}	        { 
                        push_yytext_stack(yytext);
                        yylval.string = strdup(yytext);
                        return ICONST; 
                    }
{RCONST_REAL}	    {   
                        push_yytext_stack(yytext);
                        yylval.string = strdup(yytext);
                        return RCONST_REAL; 
                    }
{RCONST_INT}	    { 
                        push_yytext_stack(yytext);
                        yylval.string = strdup(yytext);
                        return RCONST_INT; 
                    }
{RCONST_HEX}	    { 
                        push_yytext_stack(yytext);
                        yylval.string = strdup(yytext);
                        return RCONST_HEX; 
                    }
{RCONST_BIN}	    {
                        push_yytext_stack(yytext);
                        yylval.string = strdup(yytext);
                        return RCONST_BIN; 
                    }
{RELOP_NE}          { return RELOP_NE; }
{RELOP_LE}          { return RELOP_LE; }
{RELOP_GE}	        { return RELOP_GE; }
{RELOP_GT}	        { return RELOP_GT; }
{RELOP_LT}	        { return RELOP_LT; }
{ADDOP_ADD}	        { return ADDOP_ADD;  }
{ADDOP_SUB}	        { return ADDOP_SUB;  }
{MULDIVANDOP_MUL}	{ return MULDIVANDOP_MUL;  }
{MULDIVANDOP_DIV}	{ return MULDIVANDOP_DIV;  }
{MULDIVANDOP_DIV_E}	{ return MULDIVANDOP_DIV_E;  }
{MULDIVANDOP_MOD}	{ return MULDIVANDOP_MOD;  }
{MULDIVANDOP_AND}	{ return MULDIVANDOP_AND;  }
{KEYWORD_OR_ID}	    {
                        int val = id_or_keyword(yytext);
                        if(val==ID) {
                            push_yytext_stack(yytext);
                            yylval.string = strdup(yytext); 
                        }
                        return(val);
                    }
{STRING}	        {
                        push_yytext_stack(yytext);
                        yylval.string = strdup(yytext); 
                        return STRING; 
                    }
{COMMENT}           { }
{WHITESPACE}        { }
{NEWLINE}           { }
.                   { yyerror(&yytext[0]); }
<<EOF>>             { return 0; }

%%

#define N 31
static char *kid[N] = {"program", "const", "type", "array", "set", "of", "record", "var", "forward", "function", "procedure", "integer", "real", "boolean", "char", "begin", "end", "if", "then", "else", "while", "do", "for", "downto", "to", "with", "read", "write", "or", "not", "in"};

static int kval[N] = {T_PROGRAM, T_CONST, T_TYPE, T_ARRAY, T_SET, T_OF, T_RECORD, T_VAR, T_FORWARD, T_FUNCTION, T_PROCEDURE, T_INTEGER, T_REAL, T_BOOLEAN, T_CHAR, T_BEGIN, T_END, T_IF, T_THEN, T_ELSE, T_WHILE, T_DO, T_FOR, T_DOWNTO, T_TO, T_WITH, T_READ, T_WRITE, OROP, NOTOP, INOP};

int id_or_keyword(char *s) {  
    int i,k;

    for(i=0; (i < N) && (strcmp(s,kid[i]) != 0); i++);
    if(i < N)
        return kval[i];
    else
        return ID;
}

void yyerror (const char * msg) {
    fprintf(stderr, "SimplePascal error at line %d: %s\n", yylineno, msg);
    exit(1);
}
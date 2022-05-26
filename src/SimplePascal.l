%{
#include <stdio.h>
#include <stdlib.h>
#include "src/tree.h"
#include "y.tab.h"

extern yytexts_* yytexts;
void yyerror(const char *);
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
ID _?[a-zA-Z][a-zA-Z0-9_]*
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
"program"           { return T_PROGRAM; }
"const"             { return T_CONST; }
"type"              { return T_TYPE; }
"array"             { return T_ARRAY; }
"set"               { return T_SET; }
"of"                { return T_OF; }
"record"            { return T_RECORD; }
"var"               { return T_VAR; }
"forward"           { return T_FORWARD; }
"function"          { return T_FUNCTION; }
"procedure"         { return T_PROCEDURE; }
"integer"           { return T_INTEGER; }
"real"              { return T_REAL; }
"boolean"           { return T_BOOLEAN; }
"char"              { return T_CHAR; }
"begin"             { return T_BEGIN; }
"end"               { return T_END; }
"if"                { return T_IF; }
"then"              { return T_THEN; }
"else"              { return T_ELSE; }
"while"             { return T_WHILE; }
"do"                { return T_DO; }
"for"               { return T_FOR; }
"downto"            { return T_DOWNTO; }
"to"                { return T_TO; }
"with"              { return T_WITH; }
"read"              { return T_READ; }
"write"             { return T_WRITE; }
"or"                { return OROP; }
"not"               { return NOTOP; }
"in"                { return INOP; }
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
                        yytexts->yytext[yytexts->slots++]=strdup(yytext);
                        yylval.string = strdup(yytext);
                        return BCONST; 
                    }
{CCONST}	        { 
                        yytexts->yytext[yytexts->slots++]=strdup(yytext);
                        yylval.string = strdup(yytext);
                        return CCONST;  
                    }
{ICONST}	        { 
                        yytexts->yytext[yytexts->slots++]=strdup(yytext);
                        yylval.string = strdup(yytext);
                        return ICONST; 
                    }
{RCONST_REAL}	        { 
                        yytexts->yytext[yytexts->slots++]=strdup(yytext);
                        yylval.string = strdup(yytext);
                        return RCONST_REAL; 
                    }
{RCONST_INT}	        { 
                        yytexts->yytext[yytexts->slots++]=strdup(yytext);
                        yylval.string = strdup(yytext);
                        return RCONST_INT; 
                    }
{RCONST_HEX}	        { 
                        yytexts->yytext[yytexts->slots++]=strdup(yytext);
                        yylval.string = strdup(yytext);
                        return RCONST_HEX; 
                    }
{RCONST_BIN}	        { 
                        yytexts->yytext[yytexts->slots++]=strdup(yytext);
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
{ID}	            { 
                        yytexts->yytext[yytexts->slots++]=strdup(yytext); 
                        yylval.string = strdup(yytext);
                        return ID;  
                    }
{STRING}	        {
                        yytexts->yytext[yytexts->slots++]=strdup(yytext); 
                        yylval.string = strdup(yytext); 
                        return STRING; 
                    }
{COMMENT}           { }
{WHITESPACE}        { }
{NEWLINE}           { }
.                   { yyerror(&yytext[0]); }
<<EOF>>             { return 0; }

%%

void yyerror (const char * msg) {
    fprintf(stderr, "SimplePascal error at line %d: %s\n", yylineno, msg);
    exit(1);
}
%{
/* 符号常量的定义 */
enum {
    PROGRAM, CONST, VAR, ARRAY, OF, PROCEDURE, FUNCTION, t_BEGIN, END, IF, THEN, ELSE, FOR, TO, DO, REPEAT, UNTIL, WHILE, 
    ID, NUMBER, 
    RELOP, ADDOP, MULOP, ASSIGNOP, 
    DELIMITER,
    OTHERS
} TokenType;
%}

/* 正则表达式的定义 */
delim       [ \t\n]
ws          {delim}+
letter      [A-Za-z]
digit       [0-9]
id          {letter}({letter}|{digit})*
number      [+-]?{digit}+(\.{digit}+)?(E[+-]?{digit}+)?

%%

"+"         { return(ADDOP); }
"-"         { return(ADDOP); }
"or"        { return(ADDOP); }

"*"         { return(MULOP); }
"/"         { return(MULOP); }
"div"       { return(MULOP); }
"mod"       { return(MULOP); }
"and"       { return(MULOP); }

"program"   {return(PROGRAM);}
"const"     {return(CONST);}
"var"       {return(VAR);} 
"array"     {return(ARRAY);}
"of"        {return(OF);}
"procedure" {return(PROCEDURE);}
"function"  {return(FUNCTION);}
"begin"     {return(t_BEGIN);}
"end"       {return(END);}
"if"        {return(IF);}
"then"      {return(THEN);}
"else"      {return(ELSE);}
"for"       {return(FOR);}
"to"        {return(TO);}
"do"        {return(DO);}
"repeat"    {return(REPEAT);}
"until"     {return(UNTIL);}
"while"     {return(WHILE);}

{ws}        {  }
{id}        { return(ID); }
{number}    { return(NUMBER); }

"<"         { return(RELOP); }
"<="        { return(RELOP); }
"<>"        { return(RELOP); }
">"         { return(RELOP); }
">="        { return(RELOP); }
"="         { return(RELOP); }

":="        { return(ASSIGNOP); }

";"         { return(DELIMITER); }
":"         { return(DELIMITER); }
","         { return(DELIMITER); }
"."         { return(DELIMITER); }
"("         { return(DELIMITER); }
")"         { return(DELIMITER); }
"["         { return(DELIMITER); }
"]"         { return(DELIMITER); }

"#"         { return(OTHERS); }

%%

// 此函数必须写，不用动
int yywrap () {
    return 1;
}

void writeout(int c){
    // printf("c = %d   ", c);
    for (TokenType = PROGRAM; TokenType <= OTHERS; TokenType++) {
        if (c == TokenType) {
            // printf("c = TokenType = %d", TokenType);
            fprintf(yyout, "(%d, \"%s\")\n", c, yytext);break;
        }
    }

    // switch(c) {
    //     case CONST: fprintf(yyout, "(CONST, \"%s\")\n", yytext);break;
    //     case RELOP: fprintf(yyout, "(RELOP, \"%s\")\n", yytext);break;
    //     case WHILE: fprintf(yyout, "(WHILE, \"%s\")\n", yytext);break;
    //     case DO: fprintf(yyout, "(DO, \"%s\")\n", yytext);break;
    //     case NUMBER: fprintf(yyout, "(NUM, \"%s\")\n", yytext);break;
    //     case ID: fprintf(yyout, "(ID, \"%s\")\n", yytext);break;
    //     default:break;
    // }

    return;
}

int main (int argc, char ** argv){
    int c;
    if (argc>=2){
        if ((yyin = fopen(argv[1], "r")) == NULL){
            printf("Can't open file %s\n", argv[1]);
            return 1;
        }
        if (argc>=3){
            yyout=fopen(argv[2], "w");
        }
    }

    /* yyin和yyout是lex中定义的输入输出文件指针，它们指明了
     * lex生成的词法分析器从哪里获得输入和输出到哪里。
     * 默认：stdin，stdout。
     */
    while ((c = yylex()) != 0) {
        writeout(c);
    }

    if(argc>=2){
        fclose(yyin);
        if (argc>=3) fclose(yyout);
    }
    return 0;
}
#!/bin/bash

# yacc --version 
#   bison (GNU Bison) 3.8.2
# flex --version
#   flex 2.6.4 Apple(flex-34)
# cc --version
#   Apple clang version 13.1.6 (clang-1316.0.21.2)

# usage:
# ./compile.sh
# ./SimplePascal < input_file

yacc -d src/SimplePascal.y
flex src/SimplePascal.l
cc lex.yy.c y.tab.c src/tree.c -o SimplePascal
rm lex.yy.c y.tab.c y.tab.h
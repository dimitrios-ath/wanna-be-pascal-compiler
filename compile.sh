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

yacc -d SimplePascal.y
flex SimplePascal.l
cc lex.yy.c y.tab.c tree.c -o SimplePascal

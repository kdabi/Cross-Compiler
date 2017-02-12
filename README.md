CS335A Project : Compiler
=========================
This compiler is being built as a course project under
Prof. Amey Karkare.
Source Language         : C
Implementation Language : C++
Target Language         : x86-Assembly

Part 1: Lexer & Parser
----------------------
This part produces the parse tree of a C-program and reports
syntax-errors along with the line no. and line in which the
error was reported. To produce the parse tree for some program 
follow the steps:

- git clone https://bitbucket.org/cs335compilerproject/compiler
- cd compiler
- mkdir bin
- make 

This has prepared an executable '/bin/lexer' in ./bin directory.

To run a program use your own program or any of the programs 
available in ./test/ directory. 

A typical session could be like:

- ./bin/lexer -i inputfile -o outputfile

For example you may run:

- ./bin/lexer -i ./test/test1.c -o graph.gv

For any help or assistance you may use -h flag.

This gives you the .gv file with dot code for the graph. 
The default output file is *digraph.gv*

To view the graph, you may use xdot:

- xdot graph.gv

Remember to remove *#include* from the inputfile as this 
resolution is done by C-preprocessor and not parser.


References
----------
We have picked the grammar for C from:

- http://www.quut.com/c/ANSI-C-grammar-y.html
- http://www.quut.com/c/ANSI-C-grammar-l-2011.html

In order to incorporate the commandline options, we have used
code from our 'NachOS Assignment: CS330A'

Other references include:
- LEX & YACC TUTORIAL by Tom Niemann
- http://graphviz.org/

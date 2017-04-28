# sloth2
Compiled version of sloth (Simple Language Of Tiny Heft)
This compiler compiles to AT&T syntax x86-64 assembly.
I compiled this code with Ubuntu 14.04.5 and gcc 4.8.4 .
This compiler relies on operating system specific behavior, CPU specific behavior, and compiler specific behavior. It may not work on your machine.

This compiler adds functions and arrays to the sloth language.

Instructions:

Download and install the latest version of flex from http://flex.sourceforge.net/

Download and install the latest version of Bison from https://www.gnu.org/software/bison/

Run the following commands:

    flex ssloth.lex 
    bison compiler.y
    gcc compiler.tab.c lex.yy.c

Next, run the program with a sloth file as it's argument. This will create a file compiled to x86-64 Assembly cleverly named "filename.s". It will also print the parse tree. For example:

    ./a.out examples/fact.sl

Now, use gcc to compile your x86-64 file to binary:

    gcc filename.s -o filename
    
Finally, run your binary file:

    ./filename
    
Alternatively, you can use the makefile:

    make compiler
    make fact

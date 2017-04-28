compiler: lex.yy.c compiler.y
	flex ssloth.lex
	bison -d compiler.y
	gcc lex.yy.c compiler.tab.c

compare: a.out examples/compare.sl
	./a.out examples/compare.sl
	gcc filename.s -o filename
	-./filename

variables: a.out examples/variables.sl
	./a.out examples/variables.sl
	gcc filename.s -o filename
	-./filename

if: a.out examples/if.sl
	./a.out examples/if.sl
	gcc filename.s -o filename
	-./filename
fact: a.out examples/fact.sl
	./a.out examples/fact.sl
	gcc filename.s -o filename
	-./filename
while: a.out examples/while.sl
	./a.out examples/while.sl
	gcc filename.s -o filename
	-./filename

array: a.out examples/array.sl
	./a.out examples/array.sl
	gcc filename.s -o filename
	-./filename
array2: a.out examples/array2.sl
	./a.out examples/array2.sl
	gcc filename.s -o filename
	-./filename
functions: a.out examples/functions.sl	
	./a.out examples/functions.sl
	gcc filename.s -o filename
	-./filename

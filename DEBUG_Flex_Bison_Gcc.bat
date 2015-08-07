flex spl.l
bison spl.y
gcc spl.tab.c spl.c -o spl_debug.exe -lfl -D DEBUG
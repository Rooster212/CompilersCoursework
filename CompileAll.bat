flex spl.l
bison spl.y
gcc spl.tab.c spl.c -o spl.exe -lfl
spl.exe < a.SPL 1> a.c
spl.exe < b.SPL 1> b.c
spl.exe < c.SPL 1> c.c
spl.exe < d.SPL 1> d.c
spl.exe < e.SPL 1> e.c
gcc -o a.exe a.c
gcc -o b.exe b.c
gcc -o c.exe c.c
gcc -o d.exe d.c
gcc -o e.exe e.c
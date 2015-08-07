for %%x in (*.spl) do myspl.exe < %%x 1> %%x.c
for %%y in (*.c) do gcc -o %%y.exe %%y
#How to?
---
Terminal commands:
---
nasm -f elf64 printf.asm -o printf.o
---
gcc main.c printf.o -o say
---
s./say
---

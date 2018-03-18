#include <stdlib.h>
#include <stdio.h>

void oak_printf(char*, ...);

int main() {

    char* a = "edaaaaaaa";
    oak_printf("hello %s", a);



    return 0;
}

// nasm -f elf64 printf.asm -o printf.o
//  gcc main.c printf.o -o say
// ./say

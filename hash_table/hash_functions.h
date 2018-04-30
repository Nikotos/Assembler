#ifndef HASH_FUNCTIONS_H
#define HASH_FUNCTIONS_H

#include<iostream>
#include<cstring>


size_t hash_func_1(const char* data)
{
    return 1;
}


size_t hash_func_2(const char* data)
{
    return *data;
}

size_t hash_func_3(const char* data)
{
    return strlen(data);
}

size_t hash_func_4(const char* data)
{
    int sum = 0;
    int i = 0;
    while (data[i] != '\0')
    {
        sum += data[i];
        i++;
    }
    return sum;
}

size_t hash_func_5(const char* data)
{
    int sum = 0;
    int i = 0;
    while (data[i] != '\0')
    {
        sum += data[i];
        i++;
    }
    return (sum/strlen(data));
}


//TODO first candidate to been refactored using __asm__() - done
/*==============================================================================
 *
 *      Usual C realisation
 *      Here is a big probability that Compiler do his works best
 *      and automatically optimize and inline this function
 *
 /==============================================================================*/
size_t hash_func_6(const char* data)
{
    uint32_t hash = 0;
    for(int i = 0; data[i] != '\0'; i++)
    {
        hash = hash * 31 + data[i];
    }
    return hash;
}




/*==============================================================================
 *
 *      Optimized realisation, but with function call
 *
 *
 /==============================================================================*/
size_t hash_func_6_forced(const char* data)
{
   uint32_t hash = 0;

    __asm__ __volatile__                    \
    (                                       \
            ".intel_syntax noprefix\n\t"    \
            "xor eax, eax\n\t"              \
            "xor ebx, ebx\n\t"              \
            "shl eax, 0x5\n\t"              \
            "add eax, ebx\n\t"              \
            "mov ebx, eax\n\t"              \
            "add al, byte ptr[rsi]\n\t"     \
            "inc rsi\n\t"                   \
            "cmp byte ptr [rsi], 0\n\t"     \
            "jne $ - 0xF\n\t"               \
            "mov %0, eax\n\t"               \
            ".att_syntax prefix\n\t"        \
            :   "=r" (hash)                 \
            :   "S" (DATA)                  \
            :   "%eax"                      \
            );                              \

    return hash;
}




/*==============================================================================
 *  One more optimization, here we avoid calling hash function
 *  instead of it we use macros with assembly inline.
 *
 *  So, but it haven't got big influence at efficiency.
 *  In my opinion Here compiler doing his work good
 *  and makes hash function inline without our "dancing with tambourine"
 *
 *
 /==============================================================================*/
#define GNU_HASH_ASM(DATA)                  \
({                                          \
    uint32_t hash = 0;                      \
                                            \
    __asm__ __volatile__                    \
    (                                       \
            ".intel_syntax noprefix\n\t"    \
            "xor eax, eax\n\t"              \
            "xor ebx, ebx\n\t"              \
            "shl eax, 0x5\n\t"              \
            "add eax, ebx\n\t"              \
            "mov ebx, eax\n\t"              \
            "add al, byte ptr[rsi]\n\t"     \
            "inc rsi\n\t"                   \
            "cmp byte ptr [rsi], 0\n\t"     \
            "jne $ - 0xF\n\t"               \
            "mov %0, eax\n\t"               \
            ".att_syntax prefix\n\t"        \
            :   "=r" (hash)                 \
            :   "S" (DATA)                  \
            :   "%eax"                      \
            );                              \
        hash;                               \
})

#endif //HASH_FUNCTIONS_H

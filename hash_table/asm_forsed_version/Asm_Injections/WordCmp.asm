__asm__ __volatile__                            \
        (                                       \
                ".intel_syntax noprefix\n"      \
                "mov ch, byte ptr [rdi]\n"      \
                "cmpsb\n"                       \
                "jne $+0x7\n"                   \
                "cmp ch, 0x0\n"                 \
                "jne $-0x08\n"                  \
                "dec rsi\n"                     \
                "dec rdi\n"                     \
                "xor rax, rax\n"                \
                "xor rbx, rbx\n"                \
                "mov ah, byte ptr [rdi]\n"      \
                "mov bh, byte ptr [rsi]\n"      \
                "sub rax, rbx\n"                \
                "mov %0, eax\n"                 \
                ".att_syntax prefix\n"          \
                :   "=r" (result)               \
                :   "D" (WORD1), "S" (WORD2)    \
                :   "%rax", "%rbx", "%rcx"      \
                );                              \
        result;



int res = 1
__asm__ __voltile__
    (

                ".intel_syntax noprefix\n\t"    \
                ""
                "Exit:\n\t"                     \
                ".att_syntax prefix\n\t"        \
                :   "=r" (res)                  \
                :   "D" (WORD1), "S" (WORD2)    \
                :   "%rax", "%rbx", "%rcx"      \
                );





__asm__ __volatile__                            \
    (                                           \
                ".intel_syntax noprefix\n\t"    \
                "cmp byte [rsi], 0\n\t"         \
                "je $ + 0x5\n\t"                \
                "cmpsb\n\t"                     \
                "je $ - 0x6\n\t"                \
                                                \
                "xor rax, rax\n\t"              \
                "xor rbx, rbx\n\t"              \
                "mov al, [rdi - 1]\n\t"         \
                "mov bl, [rsi - 1]\n\t"         \
                "sub al, bl\n\t"                \
                "mov %0, eax"                   \
                ".att_syntax prefix\n\t"        \
                :   "=r" (res)                  \
                :   "D" (WORD1), "S" (WORD2)    \
                :   "%rax", "%rbx", "%rcx"      \
                )                               \

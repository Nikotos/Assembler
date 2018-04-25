SECTION .TEXT
	GLOBAL _LIST_BYPASS


_LIST_BYPASS:
list_bypass:
mov rsi, [rsi + 16]
mov rdx, rsi
mov rcx, rdi
  mismuch:
    cmp byte [rcx], 0
    je stop
    cmpsb
    je mismuch
  stop:
    xor eax, eax
    xor ebx, ebx
    mov al, byte [rcx - 1]
    mov bl, byte [rdx - 1]
    sub al, bl
  cmp al, 0x0
  je return
  cmp [rsi + 16], 0x0
  jne list_bypass
return:
  mov %0, rsi






/* Parent part of code*/
/*
while (current_node != nullptr)
    {
        if (THE_FASTEST_WORDCMP(word, current_node->word_.body_) == 0)
        {
            return current_node;
        }
        else if (current_node->next_node_ == nullptr)
        {
            current_node->next_node_ = new Node(word);
            return current_node->next_node_;
        }

        current_node = current_node->next_node_;
    }
*/


__asm__ __volatile__
    (
            ".intel_syntax noprefix\n\t"
            "mov rdx, rdi\n\t"
            "mov rcx, rsi\n\t"
            "list_bypass:\n\t"
                "mov rcx, [rcx + 16]\n\t"
                "mov rsi, [rcx]\n\t"
                "mov rdi, rdx\n\t"
            "mismuch:\n\t"
                "cmp byte ptr [rsi], 0x0\n\t"
                "je stop\n\t"
                "cmpsb\n\t"
                "je mismuch\n\t"
            "stop:\n\t"
                "xor eax, eax\n\t"
                "xor ebx, ebx\n\t"
                "mov al, byte ptr [rsi - 1]\n\t"
                "mov bl, byte ptr [rdi - 1]\n\t"
                "sub eax, ebx\n\t"
                "cmp al, 0x0\n\t"
                "je return\n\t"
                "mov rbx, 0x0\n\t"
                "cmp [rcx + 16], rbx\n\t"
                "jne list_bypass\n\t"
            "return:\n\t"
                "mov %0, rcx\n\t"
                "mov %1, eax\n\t"
            ".att_syntax prefix\n\t"
    :  "=r"(ret_node), "=r"(is_equal)
    :  "S"(this), "D"(word)
    :  "%rax", "%rbx", "%rcx", "%rdx"
    );

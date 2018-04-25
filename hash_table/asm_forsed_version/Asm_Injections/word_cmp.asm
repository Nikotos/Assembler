SECTION .TEXT
	GLOBAL _STRCMP

;===============================================================
;				More understandable version of "assembler injection"
;
;				This is an STRCMP
;
;================================================================
_STRCMP:
mismuch:
  cmp byte [rsi], 0
  je stop
  cmpsb
  je mismuch
stop:
  xor eax, eax
  xor ebx, ebx
  mov al, [rdi - 1]
  mov bl, [rsi - 1]
  sub al, bl

  ret

SECTION .TEXT
	GLOBAL _GNU_HASH

;===============================================================
;				More understandable version of "assembler injection"
;
;				This is an GNU hash
;
;================================================================
_GNU_HASH:
xor eax, eax
cycle:
	shl eax, 5
	add al, byte [rsi]
	inc rsi
  cmp byte [rsi], 0
  jne $ - 11
	ret

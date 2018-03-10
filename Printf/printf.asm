
SECTION .TEXT
	GLOBAL _start

SECTION .const
NUMBER equ 0xABC

_start:
	jmp main

	;!// int Main() {..............
	main:

		;-----------------------
		mov rax, rsp			; linking to my stack
		push rax
		;-----------------------
		mov esp, stack				;// local stack
		add esp, 1024


		mov ax, 3802
		push ax
			mov r10d, input1
			mov r11d, input1_len
			call Printf
		pop ax

		mov ax, 100
		push ax

		mov ax, 3802
		push ax

		mov rax, s1						;// way to transfer string
		push rax
		mov ax, s1_len				;// strlen
		push ax

		mov ax, 'I'
		push ax


		mov r10d, input2
		mov r11d, input2_len
		call Printf

		pop ax

		pop ax
		pop rax

		pop ax

		pop ax
		;-------------------
		pop rax						;unlinking my stack
		mov rsp, rax
		;------------------

		; return 0
		mov eax, 1            ; 'exit' system call
		mov ebx, 0            ; exit with error code 0
		int 80h
	;!// } END OF MAIN

	jmp bypassing_jump		;// bypssing jump to pass functions

		;!-------------------------------------------------------------------------------
		;! C printf() function
		;! @note - supports %u %x %o %b
		;!
		;! @input: args in stack frame input
		;!				 r10d - input string, r11d - len of string
		;! @destr	may destroy almost all (except rsp, rbp) SYSCALL, DONT BELIEVE ANYONE!!!
		;!---------------------------------------------------------------------------------
		Printf:
			push rbp
			mov ebp, esp
			mov r9d, 0									;// String index
			add ebp, 8 + 8

			parsing:
				xor rax, rax


				mov al, [r10d + r9d]

				cmp al, '%' 						; (if getchar() == '%') {call handler}
				jne pars_pass1
					add r9d, 1
					push r9
					push r10
					push r11
					push ax

					call print_handler		;// we work with stack  (ebp) in handler

					pop ax
					pop r11
					pop r10
					pop r9
				pars_pass1:


				cmp al, '%' 						; (if getchar() == '%') {call handler}
				je pars_pass2
					push r9								;// Actually, syscall destroys r9,
					push r10
					push r11
					mov [output_sym], al	;// I've spent 2 hours to understand it

					mov eax, 4						;// too lazy to coolect symbils to string
					mov ebx, 1
					mov ecx, output_sym
					mov edx, 1
					int 80h

					pop r11
					pop r10
					pop r9
					pars_pass2:

				add r9d, 1
				cmp r9d, r11d
				jne parsing

			call Print_space
			pop rbp
		ret

		;!---------------------------------------------------------------------------------
		;! output printf() handler
		;! switches between %u %x %o %b %c %s
		;!
		;! @input: args - stack frame input,
		;!								r9d - posision in input string
		;!								r10d - input file pointer
		;! @destr may destroy almost all (except rsp, rbp) SYSCALL, DONT BELIEVE ANYONE!!!
		;!----------------------------------------------------------------------------------
		print_handler:
			xor r13, r13
			mov al, [r10d + r9d]				; al = qualifier, switch(al)
			mov cl, 0

			cmp al, 'u'									;case 'u': // Unsigned integer
			jne hand_pass1
				push ax										;// push to save
				mov r13w, [ebp]							; r13w = arg
				call Print_Dec
				add ebp, 2
				pop ax
				mov cl, '1'								; // to print % without qualifiers
			hand_pass1:

			cmp al, 'b'									;case 'b': // Binary
			jne hand_pass2
				push ax
				mov r13w, [ebp]							; r13w = arg
				call Print_Binary
				add ebp, 2
				pop ax
				mov cl, '1'								; // to print % without qualifiers
			hand_pass2:

			cmp al, 'o'									;case 'o': // Octal
			jne hand_pass3
				push ax
				mov r13w, [ebp]							; r13w = arg
				call Print_Octal
				add ebp, 2
				pop ax
				mov cl, '1'								; // to print % without qualifiers
			hand_pass3:

			cmp al, 'x'									;case 'x': // Hex
			jne hand_pass4
				push ax
				mov r13w, [ebp]							; r13w = arg
				call Print_Hex
				add ebp, 2

				pop ax
				mov cl, '1'								; // to print % without qualifiers
			hand_pass4:

			cmp al, 'c'									;case 'c': // Char
			jne hand_pass5
				push ax
				mov r13w, [ebp]						; r13w = arg
				mov ax, r13w
				mov [output_sym], al

				mov r8d, output_sym
				mov edx, 1
				call print_to_console

				add ebp, 2
				pop ax
				mov cl, '1'								; // to print % without qualifiers
			hand_pass5:

			cmp al, 's'							;case 's': // String
			jne hand_pass6
				push ax
				xor rdx, rdx							;// to edx been nulled
				mov dx, [ebp]							; dx = strlen!! highest two bytes in stack!
				mov r8, [ebp + 2]
				call print_to_console

				add ebp, 10
				pop ax
				mov cl, '1'								; // to print % without qualifiers
			hand_pass6:

			cmp al, '%'							;case 's': // String
			jne hand_pass7
				push ax
				xor rdx, rdx							;// to edx been nulled
				mov edx, 1							; dx = strlen!! highest two bytes in stack!
				mov byte [output_sym], '%'
				mov r8, output_sym
				mov edx, 1
				call print_to_console

				pop ax
				mov cl, '1'								; // to print % without qualifiers
			hand_pass7:



			cmp cl, '1'
			je hand_pass8
				mov r8d, handler_warning
				mov edx, handler_warning_len
				call print_to_console

				mov eax, 1            ; 'exit' system call
				mov ebx, 0            ; exit with error code 0
				int 80h
			hand_pass8:

		ret

		;!--------------------------------------------------------------------------------
		;! Print in BINARY mode, preparing and calling func.
		;!
		;! @input r13d - Number
		;! @destr may destroy almost all (except rsp, rbp) SYSCALL, DONT BELIEVE ANYONE!!!
		;!--------------------------------------------------------------------------------
		Print_Binary:
			mov ebx, 10000000000000000b		; ebx = start_mask
			mov ecx, 16										; ecx = start_shift
			mov edx, -1										; edx = srtlen
			mov r14d, 1										; delta_i = 1
			mov r13d, r13d
			mov r8d, output_bin

			call config_cycle
			mov edx, 16
			call print_to_console
		ret

		;!-----------------------------------------------------------------------------------
		;! Print in HEX mode, preparing and calling func.
		;!
		;! @input r13d - Number
		;! @destr may destroy almost all (except rsp, rbp) SYSCALL, DONT BELIEVE ANYONE!!!
		;!----------------------------------------------------------------------------------
		Print_Hex:
			mov ebx, 11110000000000000000b		; ebx = start_mask
			mov ecx, 16												; ecx = start_shift
			mov edx, -1												; edx = srtlen // edx becaue for memory
			mov r14d, 4												; delta_i = 4
			mov r13d, r13d
			mov r8d, output_hex								; r8d = &output_hex

			call config_cycle
			mov edx, 4
			call print_to_console
		ret

		;!-----------------------------------------------------------------------------
		;! Print in Octal mode, preparing and calling func.
		;!
		;! @input r13d - Number
		;! @destr may destroy almost all (except rsp, rbp) SYSCALL, DONT BELIEVE ANYONE!!!
		;!--------------------------------------------------------------------------------
		Print_Octal:
			mov ebx, 111000000000000000b		; ebx = start_mask
			mov ecx, 15										; ecx = start_shift
			mov edx, -1										; edx = srtlen // edx becaue for memory
			mov r14d, 3										; delta_i = 3
			mov r13d, r13d
			mov r8d, output_oct						; r8d = &output_oct

			call config_cycle
			mov edx, 5
			call print_to_console
		ret


		;!----------------------------------------------------------------
		;! Fill output string with configured bits
		;!
		;! @input r13w - Number, r8d - output string, r14d - mode coef.
		;! @destr eax, ebx, ecx, edx, r15d
		;!--------------------------------------------------------------
		config_cycle:
			mov eax, r13d									; eax = NUMBER

			push cx												;// push becuse binary operations implemented onle with cl register
			mov ecx, r14d
			shr ebx, cl										;// fast division for mask
			pop cx

			sub ecx, r14d									; ecx = ecx - r14d
			add edx, 1

			and eax, ebx										; eax = NUMBER & mask
			shr eax, cl											;// fast division

			mov r15d, [dict + eax]					; output[i] = dict[eax]
			mov [r8d + edx], r15d

			cmp cx, 0
			jne config_cycle
		ret



		;!-----------------------------------------------------------------------------
		;! Print in Decimal mode, preparing and calling func.
		;!
		;! @input r13d - Number
		;
		;! @destr may destroy almost all (except rsp, rbp) SYSCALL, DONT BELIEVE ANYONE!!!
		;!--------------------------------------------------------------------------------
		Print_Dec:
			mov eax, r13d
			mov r12d, 0
			mov r11d, 100000

			cycle1:
				mov rdx, 0						; edx = 0
				mov ecx, 10
				div ecx								; dx = ax % 10, ax = ax//10, division

				mov r15, [dict + edx]	;// converting division remainders to ASCII
				push r15							;// collecting division remainders

				add r12d, 1
				cmp r12d, 6
			jne cycle1

			mov r12d, 0
			cycle2:
				pop r15
				mov [output_dec + r12d], r15d
				add r12d, 1
				cmp r12d, 6
			jne cycle2


			mov r8d, output_dec
			mov edx, 6
			call print_to_console
		ret

		;!-----------------------------------------------------------------------------
		;! Print output string to console using system call
		;!
		;! @input edx - strlen, r8d - output string pointer
		;! @destr may destroy almost all (except rsp, rbp) SYSCALL, DONT BELIEVE ANYONE!!!
		;!
		;!------------------------------------------------------------------------------
		print_to_console:									; syscall
			mov eax, 4
			mov ebx, 1
			mov ecx, r8d
			int 80h
		ret


		;!---------------------------------------------------------------------------------
		;! Print '/n'
		;!
		;! @input
		;! @destr may destroy almost all (except rsp, rbp) SYSCALL, DONT BELIEVE ANYONE!!!
		;!
		;!--------------------------------------------------------------------------------------
		Print_space:
			mov eax, 4
			mov ebx, 1
			mov ecx, space
			mov edx, space_size
			int 80h
		ret

	bypassing_jump:

	SECTION .bss
		stack resb 1024

	SECTION .data
		input1 db 'hello! %x hello!'
		input1_len equ $ - input1
		input2 db ',and %c %s %x %u%%!'
		input2_len equ $ - input2
		s1 db 'love'
		s1_len equ $ - s1
		dict dw '0123456789ABCDEFD'
		space db 0xD, 0xA
		space_size equ 2
		output_bin	times 16 db '0'				;//output string for binary numbers
		output_hex times 4 db '0'
		output_oct times 5 db '0'
		output_dec times 6 db '0'
		output_sym db '0'
		handler_warning db 'ERROR! QUALIFIER NOT DEFINED!!!'
		handler_warning_len equ $ - handler_warning

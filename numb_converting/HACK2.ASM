.model tiny



.code
org 100h
VIDEOSEG equ 0b800h
BORDER1 equ  '='
BORDER2 equ '|'
FILL_SYM equ ' '




Start:
;!//-------------------------------------------------
;!// Print in BINARY MODE
;!// Print(one_bit_from_number)
;!// @input ch - mask
;!//		  cl - binary shift
;!//-----------------------------------------------
jmp bypass1									;// bypassing jump
	Print_bit:
		push ax
		and al, ch
		shr al, cl
		add al, 48							; to convert to '0' or '1'
		mov es:[bx], al						; console[i][j] = symbol
		mov byte ptr es:[bx + 1], 5eh		; color = smth_interesting
		pop ax
		add bx, 2
		ret
bypass1:

;!//-------------------------------------------------
;!// Print in 8-MODE
;!// 
;!// @input ch - mask
;!//		cl - binary shift
;!//-----------------------------------------------
jmp bypass2									;// bypassing jump
Print_twobit:								;// print first two bits
		push ax
		and al, 11000000b
		shr al, 6
		add al, 48							; to convert to '0' or '1'
		mov es:[bx], al						; console[i][j] = symbol
		mov byte ptr es:[bx + 1], 3eh		; color = smth_interesting
		pop ax
		add bx, 2
		ret
bypass2:
jmp bypass3									;// bypassing jump
	Print_trebit:
		push ax
		and al, ch
		shr al, cl
		add al, 48							; to convert to '0' or '1'
		mov es:[bx], al						; console[i][j] = symbol
		mov byte ptr es:[bx + 1], 3eh		; color = smth_interesting
		pop ax
		add bx, 2
		ret
bypass3:

;!//-------------------------------------------------
;!// Print in HEX-MODE
;!// 
;!// @input ch - mask
;!// 		cl - binary shift
;!//-----------------------------------------------
jmp bypass4
	Print_hex:
		push ax
		and al, ch
		shr al, cl

		cmp al, 9
		jle passing1
		call correction						; // to print numbers above 9
		passing1:

		add al, 48							; //to convert to '0' or '1'
		mov es:[bx], al						; console[i][j] = symbol
		mov byte ptr es:[bx + 1], 2eh		; color = smth_interesting
		pop ax
		add bx, 2
		ret
bypass4:
jmp bypass5
	correction:
		add al, 7
		ret									; // #define(10,11,12,13,14,15) (A,B,C,D,E,F)
bypass5:

;!//-------------------------------------------------
;!// Print in 10-MODE
;!// 
;!// @input al - ASCII CODE
;!//-----------------------------------------------
jmp bypass6
	Print_ten:
		xor ah, ah
		mov ch, 10
		div ch								; al = al//10, ah = al % 10

		add ah, 48							;// to convert to numbers
		mov es:[bx], ah						; console[i][j] = al % 10
		mov byte ptr es:[bx + 1], 4eh		; color = smth_interesting
		add bx, -2
		add ah, -48							;// to set back for using 

		xor ah, ah				
		mov ch, 10							; al = (al//10) // 10, ah = (al//10) % 10
		div ch

		add ah, 48							;// to convert to numbers
		mov es:[bx], ah						; console[i][j] = (al//10) % 10
		mov byte ptr es:[bx + 1], 4eh		; color = smth_interesting
		add bx, -2
		add ah, -48							;// to set back for using 

		add al, 48
		mov es:[bx], al						; console[i][j] = (al//10) // 10
		mov byte ptr es:[bx + 1], 4eh		; color = smth_interesting
		add bx, -2
		ret
bypass6:

;!//position = top(ramka) 					// start_position
	mov ax, y								; sdvig = (80*y + x)*2 [or bx = ]
	mov cx, 80								; cx = num_of_pos_in_str
	mul cx
	add ax, x
	mov cx, 2
	mul cx
	mov bx, ax								; bx = sdvig


;!//remember start_position
	mov start_pos, bx   					; start_position = VIDEOSEG + (80*y + x)*2


;!//set memory_segment = VIDEOSEG
	mov ax, VIDEOSEG    					; memory_seg = VIDEOSEG
    mov es, ax


;!//position = right_top - 1_step_down		; position = [x + wide][y + 1]
mov bx, start_pos
mov ax, wide
mov cx, 2
mul cx
add bx, ax									


;Fill(ramka, color)
mov jump_count, 0								; j = 0
Fill:
		;!// prepare index for rows print
		add jump_count, 1 						; j++
		mov ax, wide						; ax = wide
		mov cx, -2
		mul cx
		add bx, ax							; bx = bx - wide + 80*2
		add bx, 80*2

		mov cx, bx							
		add cx, wide
		add cx, wide						; cx = bx + 2*wide

		Fill_line:

			mov ax, FILL_SYM
			mov es:[bx], ax  	            ; console[x + i][y] = 'symbol'

			mov byte ptr es:[bx + 1], 4eh 	; color = 'yellow' on 'red'
			add bx, 2						; i++

			cmp bx, cx	
			jne Fill_line					; do while (bx < cx)

		mov ax, fatness
		add ax, -2
		cmp ax, jump_count
		jne Fill

	

;!//iteration_end = right_top(ramka)
	mov bx, start_pos						; bx = start_pos
	mov ax, wide							; cx = VIDEOSEG + wide*2  //prepare iterator
	mov cx, 2								; int n = wide*2
	mul cx
	mov cx, bx                       
	add cx, ax


;!//Print(ramka.line) // top or bottom border
mov jump_count, 0
Print_line:	
		mov ax, BORDER1					
		add jump_count, 1						;flag1++

		mov es:[bx], ax    	            	; console[x + i][y] = 'symbol'
		mov byte ptr es:[bx + 1], 4eh   	; color = 'yellow' on 'red'
		add bx, 2							; i++

		cmp bx, cx	
		jne Print_line						;	do while (bx < cx)



;!//position = left_bottom(ramka)					
	mov bx, start_pos						; dop_sdvig = (80*fatness)*2 [or bx = ]
	mov ax, fatness							; ax = fatness - 1
	add ax, -1
	mov cx, 80								; cx = 80
	mul cx
	mov cx, 2
	mul cx
	add bx, ax								; bx += dop_sdvig


;!//iteration_end =  right_bottom(ramka) 
	mov ax, wide							; cx = VIDEOSEG + wide*2 //prepare iterator
	mov cx, 2								; int n = wide*2
	mul cx
	mov cx, bx                       
	add cx, ax


	mov ax, wide
	cmp jump_count, ax							; if (flag1 == wide){Print1}
	je Print_line


;!//position = left_top(ramka)
	mov bx, start_pos
	add bx, 80*2							; bx = start_pos + 80*2


;!//iteration_end = left_bottom(ramka)
	mov ax, fatness
	add ax, -2
	mov cx, 80*2
	mul cx
	mov cx, ax
	add cx, bx								; cx = bx + (fatness - 1)*80*2


;!//Print(ramka.border) // left or right border
mov jump_count, 0
Print_border:
		mov ax, BORDER2
		add jump_count, 1

		mov es:[bx], ax						; conslole[i][j] = 'BORDER2'
		mov byte ptr es:[bx + 1], 4eh		; color = 'yellow' on 'red
		add bx, 80*2

		cmp bx, cx
		jne Print_border 					; do while (bx < cx)


;!//posotiom = right_top(ramka)
	mov bx, start_pos
	add bx, wide
	add bx, wide
	add bx, -2
	add bx, 80*2							; bx = start_pos + wide*2 + 80*2


;!//itertion_end = right_bottom(ramka)
	mov ax, fatness
	add ax, -2
	mov cx, 80*2
	mul cx
	mov cx, ax
	add cx, bx								; cx = bx + (fatness - 1)*80*2


	mov ax, fatness
	add ax, -2
	cmp ax, jump_count
	je Print_border


;!//position = middle_top(ramka)
	mov bx, start_pos						; dop_sdvig = (80*(fatness/2)*2 [or bx = ]
	mov ax, 2								; ax = y_wideness
	mov cx, 80								; cx = num_of_pos_in_str
	mul cx
	add bx, ax								; bx += dop_sdvig // for phrase

	mov ax, indent
	mov cx, 2
	mul cx
	add bx, ax								; dop_sdvig += indent //отступ


	mov di, bx 								; dx = bx // to remember start position

;!//PRINT(symbol_many_ways) while (sym != 'Esc')
Cycle:
	;!//Read(key_pressed)
		mov ah, 00h							; al = getchar()
		int 16h

		cmp al, 27							; while(getchar() != 'Esc')
		je Bryak

		mov bx, di
	;!//Print(symbol_key_pressed)
		add bx, 4*2							; position = ~~ramka.middle
		mov es:[bx], al						; console[i][j] = 'key_pressed'
		mov byte ptr es:[bx + 1], 4eh			; color = 'yellow on red'
		add bx, 2

		mov bx, di
		add bx, 80*2 						; print('\n')

	;!//Print(binary)
		mov dh, 10000000b					; dh = mask_start
		mov dl, 7							; dl = shift_start

		Print_bits:
			mov ch, dh
			mov cl, dl
			call Print_bit					; Print_bit()

			shr dh, 1
			add dl, -1

			cmp dl, -1
			jne Print_bits

		mov bx, di
		add bx, 80*4 + 3*2 					; print('\n    ')

	;!//Print(first_two_bits)				;// print first 2 bits from 8
		call Print_twobit

	;!//Print(eightary)
		mov dh, 111000b						; dh = mask_start
		mov dl, 3							; dl = shift_start

		Print_trebits:
			mov ch, dh
			mov cl, dl
			call Print_trebit

			shr dh, 3
			add dl, -3
			cmp dl, -3
			jne Print_trebits
	
		mov bx, di
		add bx, 80*6 + 4*2							; print('\n     ')
		;!//Print(in_HEX_system)
			mov dh, 11110000b						; dh = mask_start
			mov dl, 4								; dl = shift_start

		Print_hexs:
			mov ch, dh
			mov cl, dl
			call Print_hex

			shr dh, 4
			add dl, -4
			cmp dl, -4
			jne Print_hexs
	

		mov bx, di
		add bx, 80*10 + 6*2						; print('\n   ')

		;!//Print_ten
			call Print_ten

		jmp Cycle								; do while (sym != 'Esc')
		Bryak:

;!//stop(programm)
	xor ah, ah						
	int 16h

	mov ax, 4c00h							; return(0)
	int 21h

	.data
	x dw 30									; lest top corner
	y dw 8
	wide dw 15               				; wideness of border
	fatness dw 8							; fatness of border
	indent dw 3
	start_pos dw 0
	jump_count dw 0
end Start																		

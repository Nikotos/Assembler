.model tiny

locals @@

.code
org 100h
VIDEOSEG equ 0b800h
BORDER1 equ  '='
BORDER2 equ '|'
FILL_SYM equ ' '
NUMB equ 3802


Start:
;!//-------------------------------------------------
;!// Print in BINARY MODE (and in EIGHT and in HEX)
;!// Print(one_bit_from_number)
;!// @input   dx - mask
;!//		  cl - binary shift
;!// @destr bx
;!//-----------------------------------------------
jmp bypass1									;// bypassing jump
Print_bit		proc
				push ax
				and ax, dx
				shr ax, cl

				cmp ax, 9
				jle passing1
				call correction						; // to print numbers above 9

				passing1:
				add ax, 48							; to convert to '0' or '1'
				mov es:[bx], ax						; console[i][j] = symbol
				mov byte ptr es:[bx + 1], 5eh		; color = smth_interesting
				add bx, 2
				pop ax
				ret
				endp
bypass1:

jmp bypass2									;// bypassing jump
correction		proc
				add ax, 7
				ret							; // #define(10,11,12,13,14,15) (A,B,C,D,E,F)
				endp
bypass2:

;!//-------------------------------------------------
;!// Print in 10-MODE
;!// 
;!// @input al - ASCII CODE
;!// @destr cx
;!//-----------------------------------------------
jmp bypass3										;// bypassing jump
Print_ten		proc
				push ax
					ciclec:
						xor dx, dx
						mov cx, 10
						div cx							; ax = ax//10, dx = ax % 10
					call outputs						; printf(dx)

					cmp ax, 0
					jne ciclec
				pop ax
				ret
				endp
bypass3:

;!//-------------------------------------------------
;!// print number from dx
;!// 
;!// @input dx - almost ASCII CODE
;!// @destr dx
;!//-----------------------------------------------
jmp bypass4									;// bypassing jump
outputs			proc
				add dx, 48							;// to convert to numbers
				mov es:[bx], dx						; console[i][j] =  dx
				mov byte ptr es:[bx + 1], 3eh		; color = smth_interesting
				add bx, -2
				ret
				endp
bypass4:

;!//-------------------------------------------------
;!// convert string from SI to number
;!// 
;!// @input si - string pointer
;!// 		di - multiplier for converting
;!// @output ax - number
;!// @destr si, cx, di
;!//-----------------------------------------------
jmp bypass5
convert			proc								
				mov cl, [si]						; cl = *si
				inc si								; si++

				cmp cl, 13							; if (cl == "Enter") break
				je @@break

				mul di
				add cx, -48 						;// to convert from ASCII to numbers
				add ax, cx

				jmp convert							; do while (cl != 'Enter')
				@@break:
				ret
				endp
bypass5:



;!//-------------------------------------------------
;!// choosing variant of converting
;!// 
;!// @input si - string pointer
;!// @destr cl, di
;!//-----------------------------------------------
jmp bypass6
switch				proc
					
					mov cl, [si - 1]
					
					cmp cl, 100
					jne @@pass1
					mov di, 10
					call convert
					ret
					@@pass1:

					cmp cl, 98
					jne @@pass2
					mov di, 2
					call convert
					ret
					@@pass2:

					cmp cl, 111
					jne @@pass3
					mov di, 8
					call convert
					ret
					@@pass3:

					ret
					endp
bypass6:


;!//-------------------------------------------------
;!// Fill border with color
;!// 
;!// @input bx - start position for drawing
;!// @destr ax, cx, bx
;!//-----------------------------------------------
jmp bypass7
Color_border 		proc

				;!//position = right_top - 1_step_down		; position = [x + wide][y + 1]
					mov bx, start_pos
					mov ax, wide
					mov cx, 2
					mul cx
					add bx, ax								

					mov jump_count, 0								; j = 0
					@@Fill:
						;!// prepare index for rows print
						add jump_count, 1 						; j++
						mov ax, wide							; ax = wide
						mov cx, -2
						mul cx
						add bx, ax							; bx = bx - wide + 80*2
						add bx, 80*2
						add bx, 2

						mov cx, bx							
						add cx, wide
						add cx, wide						; cx = bx + 2*wide
						add cx, -4

						Fill_line:

							mov ax, FILL_SYM

							mov es:[bx], ax  	            ; console[x + i][y] = 'symbol'
							mov byte ptr es:[bx + 1], 4eh 	; color = 'yellow' on 'red'
							add bx, 2						; i++

							cmp cx, bx
							jne Fill_line					; do while (bx < cx)

						add bx, 2							;// to save borders from destruction after refreshing
						mov ax, fatness
						add ax, -2
						cmp ax, jump_count
						jne @@Fill
					ret
					endp
bypass7:



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



call Color_border
	

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


	mov di, bx 								; start_pos = bx // to remember start position


;//Convert(number) while (number != 'q')
Cicl:
	;//Scanf("%s", &dx)

		xor ax, ax
		mov ah, 0ah
		mov dx, offset str_input			; dx = 'stdin'
		int 21h

		mov si, dx
		add si, 2

		mov cl, [si]						; if(cl == "q") break
		cmp cl, 113
		je Brexit_jump_helper

		add si, 1
		xor ax, ax
		xor cx, cx

	;//ax = auto_type_def(str_input)
		push di
		call switch
		pop di

	mov si, ax
	call Color_border						;// to refresh the table!
	mov ax, si

	;!//Print(DEG)
		mov bx, di
		add bx, 80*2 + 9*2
		call Print_ten

	;!//Print(binary)
		mov bx, di
		add bx, 80*6
		mov dx, 1000000000000000b				; dx = mask_start
		mov cl, 15								; cl = shift_start

		Print_bits:
			call Print_bit						; Print_bit()

			shr dx, 1
			add cl, -1

			cmp cl, -1
			jne Print_bits
		mov si, 98
		mov es:[bx], si							;// letter 'b'
		mov byte ptr es:[bx + 1], 5eh
	
	jmp bypass8
	Cicl_jump_helper:							;// helping jump
	jmp Cicl
	Brexit_jump_helper:
	jmp Brexit
	bypass8:


	;!//Print(first_one_bit)					;// print first 1 bits from 8
		mov bx, di
		add bx, 80*10 + 6*2

		mov dx, 1000000000000000b
		mov cl, 15
		call Print_bit

		;!//Print(eightary)
			mov dx, 111000000000b				; dx = mask_start
			mov cl, 9							; dl = shift_start

			Print_trebits:
				call Print_bit

				shr dx, 3
				add cl, -3
				cmp cl, -3
				jne Print_trebits
			mov si, 111
			mov es:[bx], si							;// letter 'o'
			mov byte ptr es:[bx + 1], 5eh

	

	;!//Print(in_HEX_system)
			mov bx, di							; //set position
			add bx, 80*14 + 6*2 				; print('\n    ')

			mov dx, 1111000000000000b			; dx = mask_start
			mov cl, 12							; cl = shift_start

		Print_hexs:
			call Print_bit

			shr dx, 4
			add cl, -4
			cmp cl, -4
			jne Print_hexs	
		mov si, 104
		mov es:[bx], si							;// letter 'h'
		mov byte ptr es:[bx + 1], 5eh		

		
	jmp Cicl_jump_helper	
	

;!//stop(programm)
	Brexit:
	mov ax, 4c00h							; return(0)
	int 21h

	.data
	x dw 25									; lest top corner
	y dw 8
	wide dw 25               				; wideness of border
	fatness dw 11							; fatness of border
	indent dw 4
	start_pos dw 0
	jump_count dw 0
	str_input db 20, ?, '$$$$$$$$$$$$$$$$$$$$'
end Start																		

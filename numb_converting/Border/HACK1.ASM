.model tiny


.code
org 100h
VIDEOSEG equ 0b800h
BORDER1 equ  '='
BORDER2 equ '|'
FILL_SYM equ ' '

Start:
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


;!//position = middle(ramka)
	mov bx, start_pos						; dop_sdvig = (80*(fatness/2)*2 [or bx = ]
	mov ax, fatness							; ax = y_wideness
	mov cx, 80								; cx = num_of_pos_in_str
	mul cx
	add bx, ax								; bx += dop_sdvig // for phrase

	mov ax, indent
	mov cx, 2
	mul cx
	add bx, ax								; dop_sdvig += indent //отступ


	mov si, offset phrase					; si = &phrase


;!//Print(ramka.phrase)
Print_phrase:									
		mov al, [si]						; al = *si
		inc si								; si++
	
		mov es:[bx], al    	            	; console[x + i][y] = 'symbol'
		mov byte ptr es:[bx + 1], 4eh   	; color = 'yellow on red'
		add bx, 2							; i++

		cmp al, '$'	
		jne Print_phrase					; do while (i < wide)


;!//stop(programm)
	xor ah, ah						
	int 16h

	mov ax, 4c00h							; return(0)
	int 21h

	.data
	x dw 30									; lest top corner
	y dw 8
	wide dw 20                 				; wideness of border
	fatness dw 10							; fatness of border
	phrase db 'hello world$'
	indent dw 3
	start_pos dw 0
	jump_count dw 0
end Start																		

.386
.model flat,stdcall
option casemap:none

include windows.inc

.data 
map_w equ 8
map_h equ 8
maps sbyte  'wwwwwwwwweeeeeewwdeeedewwbepebewweeeewwwwdebeweeweeeeweewwwwwwee',\
			'eeeeeeeeeeewwwwwwwwwpeewweebodewweeeeewwweewwwwwwwwweeeeeeeeeeee',\
			'wwwwwwwwweeweeewwebbodewwedeedewwedobbpwweeeweewwwwwwwwweeeeeeee',\
			'ewwwwweewwweewweweebeewwwpwbwewwwedbdedwwwweeeewewweewwweewwwwwe',\
			'wwwwwwwwwwwwwwww',\
			'wweeeeww',\
			'wweeeeww',\
			'wwpbdeww',\
			'wweeeeww',\
			'wwwwwwwwwwwwwwww',0


.code
DllEntry proc _hInstance,_dwReason,_dwReserved
	
	mov eax, 1
	ret

DllEntry endp

loadMap  proc C count:sdword, now:ptr sbyte
    push ebx
    
    xor eax, eax
    mov ax, map_w*map_h
    mul count
    mov ebx, eax

    mov ecx, 0
loadele:
    mov eax, 0
    mov al, maps[ebx]
	mov	edx, ecx
	add	edx, now
    mov [edx], al
    inc ebx
    inc ecx
    cmp ecx, map_w*map_h
    jne loadele

    pop ebx
    ret
loadMap     endp

;# get person position
getPerPos proc C now: ptr sbyte, posx: ptr sdword, posy: ptr sdword
    push ebx
            
    mov ebx, now
next_ele:   
    mov al, [ebx]
    cmp al, 112 ;# 112 is 'p'
    jz findPer
	cmp al, 116 ;# 116 is 't'
    jz findPer
    inc ebx
    jmp next_ele

findPer:    
    sub ebx, now
    mov eax, ebx
    mov bl, map_w
    div bl

    mov ebx, eax
	xor eax, eax
    mov al, bh
    mov edx, posy
    mov [edx], eax
    ;invoke printf, offset printInt, eax
    xor eax, eax
    mov al, bl
    mov edx, posx
    mov [edx], eax
    ;invoke printf, offset printInt, eax

    pop ebx
	ret
getPerPos   endp

isSuccess proc C now:ptr sbyte
	push ebx
	
	mov ebx, now
	mov ecx, 0
checkNext:
	mov al, [ebx]
	cmp al, 98
	jz notSuccess
	inc ebx
	inc ecx
	cmp ecx, map_w*map_h
	jl checkNext
	mov eax, 1
	jmp endCheck
notSuccess:
	mov eax, 0
endCheck:
	pop ebx
	ret
isSuccess   endp

moveUp proc C now:ptr sbyte
    local posX, posY:dword
	push ebx
	invoke getPerPos, now, addr posX, addr posY

	mov bl, map_w
	mov eax, posX
	sub eax, 1
	mul bl
	add eax, posY
	mov edx, now
	add edx, eax
	xor eax, eax
	mov al, [edx]


	cmp al, 119 ;# 119 is 'w'
	jz upEnd ;# up is p_w, end

	cmp al, 98  ;# 98 is 'b'
	jnz upnext1
		mov bl, map_w
		mov eax, posX
		sub eax, 2
		mul bl
		add eax, posY
		mov edx, now
		add edx, eax
		xor eax, eax
		mov al, [edx]
		cmp al, 119 ;# 119 is 'w'
		jz bEnd ;# up is p_b_w, end
		cmp al, 98  ;# 98 is 'b'
		jz bEnd ;# up is p_b_b, end
		cmp al, 111 ;# 111 is 'o'
		jz bEnd ;# up is p_b_o, end
		cmp al, 101 ;# 101 is 'e'
		jnz upnext01
			mov al, 98
			mov [edx], al
			add edx, map_w
			mov al, 112
			mov [edx], al
			add edx, map_w
			mov al, [edx]
			cmp al, 112
			jnz up_t_b_e0
			mov al, 101
			mov [edx], al
			jmp bEnd
up_t_b_e0:
			mov al, 100
			mov [edx], al
			jmp bEnd
upnext01:
		cmp al, 100 ;# 100 is 'd'
		jnz bEnd
			mov al, 111
			mov [edx], al
			add edx, map_w
			mov al, 112
			mov [edx], al
			add edx, map_w
			mov al, [edx]
			cmp al, 112
			jnz up_t_b_e1
			mov al, 101
			mov [edx], al
			jmp bEnd
up_t_b_e1:
			mov al, 100
			mov [edx], al
			jmp bEnd
bEnd:
	jmp upEnd

upnext1:
	cmp al, 101 ;# 101 is 'e'
	jnz upnext2
	mov al, 112
	mov [edx], al
	add edx, map_w
	mov al, [edx]
	cmp al, 112
	jnz up_t_e
	mov al, 101
	mov [edx], al
	jmp eEnd
up_t_e:
	mov al, 100
	mov [edx], al
	jmp eEnd
eEnd:
	jmp upEnd

upnext2:
	cmp al, 100 ;# 100 is 'd'
	jnz upnext3
	mov al, 116
	mov [edx], al
	add edx, map_w
	mov al, [edx]
	cmp al, 112
	jnz up_t_d
	mov al, 101
	mov [edx], al
	jmp dEnd
up_t_d:
	mov al, 100
	mov [edx], al
	jmp dEnd
dEnd:
	jmp upEnd

upnext3:
	cmp al, 111 ;# 111 is 'o'
	jnz upEnd
		mov bl, map_w ;# up is p_o
		mov eax, posX
		sub eax, 2
		mul bl
		add eax, posY
		mov edx, now
		add edx, eax
		xor eax, eax
		mov al, [edx]
		cmp al, 119 ;# 119 is 'w'
		jz oEnd ;# up is p_b_w, end
		cmp al, 98  ;# 98 is 'b'
		jz oEnd ;# up is p_b_b, end
		cmp al, 111 ;# 111 is 'o'
		jz oEnd ;# up is p_b_o, end
		cmp al, 101 ;# 101 is 'e'
		jnz upnext31
			mov al, 98
			mov [edx], al ;# up is p_o_e,
			add edx, map_w
			mov al, 116
			mov [edx], al
			add edx, map_w
			mov al, [edx]
			cmp al, 112
			jnz up_t_o_e0
			mov al, 101
			mov [edx], al
			jmp oEnd
up_t_o_e0:
			mov al ,100
			mov [edx], al
			jmp oEnd
upnext31:
		cmp al, 100 ;# 100 is 'd'
		jnz oEnd
			mov al, 111
			mov [edx], al ;# 111 is 'o'
			add edx, map_w
			mov al, 116
			mov [edx], al
			add edx, map_w
			mov al, [edx]
			cmp al, 112
			jnz up_t_o_e1
			mov al, 101
			mov [edx], al
			jmp oEnd
up_t_o_e1:
			mov al, 100
			mov [edx], al
			jmp oEnd
oEnd:
	jmp upEnd

upEnd:
	nop
	invoke isSuccess, now
	;mov ebx, eax
	;invoke printf, offset printInt, ebx 
	pop ebx
	ret
moveUp endp


moveDown proc C now:ptr sbyte
	local posX, posY:dword
	push ebx
	invoke getPerPos, now, addr posX, addr posY

	mov bl, map_w
	mov eax, posX
	add eax, 1
	mul bl
	add eax, posY
	mov edx, now
	add edx, eax
	xor eax, eax
	mov al, [edx]

	.IF al == 'w'
		jmp downEnd
	.ELSEIF al == 'b'
		mov bl, map_w
		mov eax, posX
		add eax, 2
		mul bl
		add eax, posY
		mov edx, now
		add edx, eax
		xor eax, eax
		mov al, [edx]

		.IF al == 'w'
			jmp downEnd
		.ELSEIF al == 'b'
			jmp downEnd
		.ELSEIF al == 'o'
			jmp downEnd
		.ELSEIF al == 'e'
			mov al, 98
			mov [edx], al
			sub edx, map_w
			mov al, 112
			mov [edx], al
			sub edx, map_w
			mov al, [edx]
			.IF al == 'p'
				mov al, 101
				mov [edx], al
				jmp downEnd
			.ELSEIF al == 't'
				mov al, 100
				mov [edx], al
				jmp downEnd
			.ELSE 
				jmp downEnd
			.ENDIF
		.ELSEIF al == 'd'
			mov al, 111
			mov [edx], al
			sub edx, map_w
			mov al, 112
			mov [edx], al
			sub edx, map_w
			mov al, [edx]
			.IF al == 'p'
				mov al, 101
				mov [edx], al
				jmp downEnd
			.ELSEIF al == 't'
				mov al, 100
				mov [edx], al
				jmp downEnd
			.ELSE 
				jmp downEnd
			.ENDIF
		.ELSE
			jmp downEnd
		.ENDIF
	.ELSEIF al == 'e'
		mov al, 112
		mov [edx], al
		sub edx, map_w
		mov al, [edx]
		.IF al == 'p'
			mov al, 101
			mov [edx], al
			jmp downEnd
		.ELSEIF al == 't'
			mov al, 100
			mov [edx], al
			jmp downEnd
		.ELSE 
			jmp downEnd
		.ENDIF
	.ELSEIF al == 'd'
		mov al, 116
		mov [edx], al
		sub edx, map_w
		mov al, [edx]
		.IF al == 'p'
			mov al, 101
			mov [edx], al
			jmp downEnd
		.ELSEIF al == 't'
			mov al, 100
			mov [edx], al
			jmp downEnd
		.ELSE 
			jmp downEnd
		.ENDIF
	.ELSEIF al == 'o'
		mov bl, map_w
		mov eax, posX
		add eax, 2
		mul bl
		add eax, posY
		mov edx, now
		add edx, eax
		xor eax, eax
		mov al, [edx]

		.IF al == 'w'
			jmp downEnd
		.ELSEIF al == 'b'
			jmp downEnd
		.ELSEIF al == 'o'
			jmp downEnd
		.ELSEIF al == 'e'
			mov al, 98
			mov [edx], al
			sub edx, map_w
			mov al, 116
			mov [edx], al
			sub edx, map_w
			mov al, [edx]
			.IF al == 'p'
				mov al, 101
				mov [edx], al
				jmp downEnd
			.ELSEIF al == 't'
				mov al, 100
				mov [edx], al
				jmp downEnd
			.ELSE 
				jmp downEnd
			.ENDIF
		.ELSEIF al == 'd'
			mov al, 111
			mov [edx], al
			sub edx, map_w
			mov al, 116
			mov [edx], al
			sub edx, map_w
			mov al, [edx]
			.IF al == 'p'
				mov al, 101
				mov [edx], al
				jmp downEnd
			.ELSEIF al == 't'
				mov al, 100
				mov [edx], al
				jmp downEnd
			.ELSE 
				jmp downEnd
			.ENDIF
		.ELSE
			jmp downEnd
		.ENDIF
	.ELSE
		jmp downEnd
	.ENDIF

downEnd:
	nop
	invoke isSuccess, now
	pop ebx
	ret
moveDown endp


moveLeft proc c now:ptr sbyte
	local posX, posY:dword
	push ebx
	invoke getPerPos, now, addr posX, addr posY

	mov bl, map_w
	mov eax, posX
	mul bl
	add eax, posY
	mov edx, now
	add edx, eax
	sub edx, 1
	xor eax, eax
	mov al, [edx]

	.IF al == 'w'
		jmp leftEnd
	.ELSEIF al == 'b'
		sub edx, 1
		mov al, [edx]

		.IF al == 'w'
			jmp leftEnd
		.ELSEIF al == 'b'
			jmp leftEnd
		.ELSEIF al == 'o'
			jmp leftEnd
		.ELSEIF al == 'e'
			mov al, 98
			mov [edx], al
			add edx, 1
			mov al, 112
			mov [edx], al
			add edx, 1
			mov al, [edx]
			.IF al == 'p'
				mov al, 101
				mov [edx], al
				jmp leftEnd
			.ELSEIF al == 't'
				mov al, 100
				mov [edx], al
				jmp leftEnd
			.ELSE 
				jmp leftEnd
			.ENDIF
		.ELSEIF al == 'd'
			mov al, 111
			mov [edx], al
			add edx, 1
			mov al, 112
			mov [edx], al
			add edx, 1
			mov al, [edx]
			.IF al == 'p'
				mov al, 101
				mov [edx], al
				jmp leftEnd
			.ELSEIF al == 't'
				mov al, 100
				mov [edx], al
				jmp leftEnd
			.ELSE 
				jmp leftEnd
			.ENDIF
		.ELSE
			jmp leftEnd
		.ENDIF
	.ELSEIF al == 'e'
		mov al, 112
		mov [edx], al
		add edx, 1
		mov al, [edx]
		.IF al == 'p'
			mov al, 101
			mov [edx], al
			jmp leftEnd
		.ELSEIF al == 't'
			mov al, 100
			mov [edx], al
			jmp leftEnd
		.ELSE
			jmp leftEnd
		.ENDIF
	.ELSEIF al == 'd'
		mov al, 116
		mov [edx], al
		add edx, 1
		mov al, [edx]
		.IF al == 'p'
			mov al, 101
			mov [edx], al
			jmp leftEnd
		.ELSEIF al == 't'
			mov al, 100
			mov [edx], al
			jmp leftEnd
		.ELSE
			jmp leftEnd
		.ENDIF
	.ELSEIF al == 'o'
		sub edx, 1
		mov al, [edx]

		.IF al == 'w'
			jmp leftEnd
		.ELSEIF al == 'b'
			jmp leftEnd
		.ELSEIF al == 'o'
			jmp leftEnd
		.ELSEIF al == 'e'
			mov al, 98
			mov [edx], al
			add edx, 1
			mov al, 116
			mov [edx], al
			add edx, 1
			mov al, [edx]
			.IF al == 'p'
				mov al, 101
				mov [edx], al
				jmp leftEnd
			.ELSEIF al == 't'
				mov al, 100
				mov [edx], al
				jmp leftEnd
			.ELSE 
				jmp leftEnd
			.ENDIF
		.ELSEIF al == 'd'
			mov al, 111
			mov [edx], al
			add edx, 1
			mov al, 116
			mov [edx], al
			add edx, 1
			mov al, [edx]
			.IF al == 'p'
				mov al, 101
				mov [edx], al
				jmp leftEnd
			.ELSEIF al == 't'
				mov al, 100
				mov [edx], al
				jmp leftEnd
			.ELSE 
				jmp leftEnd
			.ENDIF
		.ELSE
			jmp leftEnd
		.ENDIF
	.ELSE
		jmp leftEnd
	.ENDIF

leftEnd:
	nop
	invoke isSuccess, now
	pop ebx
	ret
moveLeft endp


moveRight proc c now:ptr sbyte
	local posX, posY:dword
	push ebx
	invoke getPerPos, now, addr posX, addr posY

	mov bl, map_w
	mov eax, posX
	mul bl
	add eax, posY
	mov edx, now
	add edx, eax
	add edx, 1
	xor eax, eax
	mov al, [edx]

	.IF al == 'w'
		jmp rightEnd
	.ELSEIF al == 'b'
		add edx, 1
		mov al, [edx]

		.IF al == 'w'
			jmp rightEnd
		.ELSEIF al == 'b'
			jmp rightEnd
		.ELSEIF al == 'o'
			jmp rightEnd
		.ELSEIF al == 'e'
			mov al, 98
			mov [edx], al
			sub edx, 1
			mov al, 112
			mov [edx], al
			sub edx, 1
			mov al, [edx]
			.IF al == 'p'
				mov al, 101
				mov [edx], al
				jmp rightEnd
			.ELSEIF al == 't'
				mov al, 100
				mov [edx], al
				jmp rightEnd
			.ELSE 
				jmp rightEnd
			.ENDIF
		.ELSEIF al == 'd'
			mov al, 111
			mov [edx], al
			sub edx, 1
			mov al, 112
			mov [edx], al
			sub edx, 1
			mov al, [edx]
			.IF al == 'p'
				mov al, 101
				mov [edx], al
				jmp rightEnd
			.ELSEIF al == 't'
				mov al, 100
				mov [edx], al
				jmp rightEnd
			.ELSE 
				jmp rightEnd
			.ENDIF
		.ELSE
			jmp rightEnd
		.ENDIF
	.ELSEIF al == 'e'
		mov al, 112
		mov [edx], al
		sub edx, 1
		mov al, [edx]
		.IF al == 'p'
			mov al, 101
			mov [edx], al
			jmp rightEnd
		.ELSEIF al == 't'
			mov al, 100
			mov [edx], al
			jmp rightEnd
		.ELSE
			jmp rightEnd
		.ENDIF
	.ELSEIF al == 'd'
		mov al, 116
		mov [edx], al
		sub edx, 1
		mov al, [edx]
		.IF al == 'p'
			mov al, 101
			mov [edx], al
			jmp rightEnd
		.ELSEIF al == 't'
			mov al, 100
			mov [edx], al
			jmp rightEnd
		.ELSE
			jmp rightEnd
		.ENDIF
	.ELSEIF al == 'o'
		add edx, 1
		mov al, [edx]

		.IF al == 'w'
			jmp rightEnd
		.ELSEIF al == 'b'
			jmp rightEnd
		.ELSEIF al == 'o'
			jmp rightEnd
		.ELSEIF al == 'e'
			mov al, 98
			mov [edx], al
			sub edx, 1
			mov al, 116
			mov [edx], al
			sub edx, 1
			mov al, [edx]
			.IF al == 'p'
				mov al, 101
				mov [edx], al
				jmp rightEnd
			.ELSEIF al == 't'
				mov al, 100
				mov [edx], al
				jmp rightEnd
			.ELSE 
				jmp rightEnd
			.ENDIF
		.ELSEIF al == 'd'
			mov al, 111
			mov [edx], al
			sub edx, 1
			mov al, 116
			mov [edx], al
			sub edx, 1
			mov al, [edx]
			.IF al == 'p'
				mov al, 101
				mov [edx], al
				jmp rightEnd
			.ELSEIF al == 't'
				mov al, 100
				mov [edx], al
				jmp rightEnd
			.ELSE 
				jmp rightEnd
			.ENDIF
		.ELSE
			jmp rightEnd
		.ENDIF
	.ELSE
		jmp rightEnd
	.ENDIF

rightEnd:
	nop
	invoke isSuccess, now
	pop ebx
	ret
moveRight endp


end DllEntry

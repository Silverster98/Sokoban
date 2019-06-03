.386
.model flat,stdcall
option casemap:none

include windows.inc
include kernel32.inc
includelib kernel32.lib

.data 
map_w equ 8
map_h equ 8
filename db '.\map.txt',0      	;# 保存map.txt路径
mapF sbyte 331 dup(0)          	;# 保存从map.txt中读取到的数据

.code
;# dll entry function
DllEntry proc _hInstance,_dwReason,_dwReserved
	
	mov eax, 1
	ret

DllEntry endp

;# load map function
;# @count is the number of level
;# @now is the map ptr that hold the level map
loadMap  proc C count:sdword, now:ptr sbyte
    local hFile:HANDLE
	push ebx
    
    invoke CreateFile, offset filename, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
	mov hFile, eax
	invoke ReadFile, hFile, addr mapF, 331, NULL, NULL       ;# 读取文件到mapF数组
	invoke CloseHandle, hFile

	mov eax, count             	;# 以下代码开始复制相应关卡到now数组
	mov bl, 66
	mul bl
	add eax, offset mapF
	mov ebx, eax
	xor eax, eax
	
	mov ecx, 0
copyChar:
	mov al, [ebx]
	mov edx, now
	add edx, ecx
	mov [edx], al
	inc ebx
    inc ecx
    cmp ecx, map_w*map_h
    jne copyChar              	;# 总共复制8*8个字符

	pop ebx
    ret
loadMap     endp

;# get person position
;# @now is the map
;# @posx is the person pos's x
;# @posy is the person pos's y
getPerPos proc C now: ptr sbyte, posx: ptr sdword, posy: ptr sdword
    push ebx
            
    mov ebx, now
next_ele:   
    mov al, [ebx]
    cmp al, 112 			  	;# 112 is 'p'
    jz findPer
	cmp al, 116 				;# 116 is 't'
    jz findPer
    inc ebx
    jmp next_ele

findPer:    					;# 以下代码是将找到的坐标转换为为二维坐标，然后将其赋值给posx,posy
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

;# judge is success
;# @now is the map
isSuccess proc C now:ptr sbyte
	push ebx
	
	mov ebx, now
	mov ecx, 0
checkNext:						;# 依次判断map中是否还有b字符，若无b字符则成功
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

;# move up function
;# @now is map
moveUp proc C now:ptr sbyte
    local posX, posY:dword
	push ebx
	invoke getPerPos, now, addr posX, addr posY	;# 首先获取当前人的位置，根据人的位置来做相关判断

	mov bl, map_w				;# 获取人上方元素
	mov eax, posX
	sub eax, 1
	mul bl
	add eax, posY
	mov edx, now
	add edx, eax
	xor eax, eax
	mov al, [edx]


	cmp al, 119 				;# 119 is 'w'
	jz upEnd 					;# 上方是墙终止

	cmp al, 98  				;# 98 is 'b'，上方是箱子
	jnz upnext1					;# 不为 'b' 进入下一个判断
		mov bl, map_w
		mov eax, posX
		sub eax, 2
		mul bl
		add eax, posY
		mov edx, now
		add edx, eax
		xor eax, eax
		mov al, [edx]
		cmp al, 119 			;# 当人上方是箱子时，再判断上上方的元素
		jz bEnd 				;# up is p_b_w, end
		cmp al, 98 
		jz bEnd 				;# up is p_b_b, end
		cmp al, 111 			;# 111 is 'o'
		jz bEnd 				;# up is p_b_o, end
		cmp al, 101 			;# 101 is 'e'
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
		cmp al, 100
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

upnext1:						;# 上方是 e 即是空地
	cmp al, 101 				;# 101 is 'e'
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

upnext2:						;# 上方是 d 即是目标点
	cmp al, 100 				;# 100 is 'd'
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

upnext3:						;# 上方是 o 即箱子和目标点
	cmp al, 111 				;# 111 is 'o'
	jnz upEnd
		mov bl, map_w
		mov eax, posX
		sub eax, 2
		mul bl
		add eax, posY
		mov edx, now
		add edx, eax
		xor eax, eax
		mov al, [edx]
		cmp al, 119
		jz oEnd
		cmp al, 98
		jz oEnd
		cmp al, 111
		jz oEnd
		cmp al, 101
		jnz upnext31
			mov al, 98
			mov [edx], al
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
		cmp al, 100
		jnz oEnd
			mov al, 111
			mov [edx], al
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
	invoke isSuccess, now		;# 调用判断是否成功函数来判断是否成功，成功则返回eax=1,未成功返回eax=0
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

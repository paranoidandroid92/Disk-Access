[BITS 16]
mov ax,0x07c0
mov ds,ax

mov ax,0x6000
mov ss,ax
mov sp,0


end:
	hlt
	jmp end

;prints string in [ds:si] to screen	
printStr:
	pusha;
	push di
	push es
	cld;inc si after lodsb
loadchr:
	lodsb;
	cmp al,0x00;
	je printStrFinish;
	cmp al,0x0A;
	je newline;
	mov ah,0x4e;
	mov di,[video_memory_index];
	mov es,[video_memory_base];
	mov [es:di],ax;
	inc di;
	inc di;
	mov [video_memory_index],di;
	jmp loadchr;
newline:
	push dx;
	push bx;
	push ax;
	mov bx,0x00A0;
	add [video_memory_index],bx;
	mov dx,0;
	mov ax,[video_memory_index];
	div bx;
	sub [video_memory_index],dx;
	pop ax;
	pop bx;
	pop dx;
	jmp loadchr;
printStrFinish:
	pop es
	pop di
	popa;
	ret;

video_memory_base dw 0xb800
video_memory_index dw 0x0000
times 510-($-$$) db 0x00
db 0x55
db 0xAA

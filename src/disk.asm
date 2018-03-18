[BITS 16]
mov ax,0x07c0
mov ds,ax

mov ax,0x6000
mov ss,ax
mov sp,0

mov [drive_index],dl



end:
	call check_bios_extension
	hlt
	jmp end

check_bios_extension:
	pusha
	mov ah,0x41
	mov dl,[drive_index]
	mov bx,0x55AA
	int 0x13
	jc ext_present
ext_present:
	mov si,ext_present_str
	jmp ext_end
ext_not_present:
	mov si,ext_not_present_str
	jmp ext_end
ext_end:
	call printStr
	popa
	ret
	


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

ext_present_str db 'Extension present',0x00
ext_not_present_str db 'Extension not present',0x00
video_memory_base dw 0xb800
video_memory_index dw 0x0000
drive_index db 0x00
times 510-($-$$) db 0x00
db 0x55
db 0xAA

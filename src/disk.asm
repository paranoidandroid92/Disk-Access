[BITS 16]
mov ax,0x07c0
mov ds,ax

mov ax,0x6000
mov ss,ax
mov sp,0

mov [drive_index],dl

call check_bios_extension
mov ax,0
mov es,ax
mov di,0x7e00 ; read first sector of disk at 0000:7e00
mov ax,0
mov bx,1
call read_sector
mov ax,0
mov es,ax
mov di,0x7e00 ; write a sector from 0000:7e00 to sector 1
mov ax,1
mov bx,1
call write_sector

end:
	hlt
	jmp end

check_bios_extension:
	pusha
	mov ah,0x41
	mov dl,[drive_index]
	mov bx,0x55AA
	int 0x13
	jc ext_not_present
ext_present:
	mov si,ext_present_str
	jmp ext_end
ext_not_present:
	mov si,ext_not_present_str
ext_end:
	call printStr
	popa
	ret

;es:di => location to transfer sectors
;ax    => number of first sector
;bx    => number of sectors to be read
read_sector:
	pusha
	mov [dap_num_of_secs],bx
	mov [dap_seg_addr],es
	mov [dap_off_addr],di
	mov [dap_start_sec],ax
	mov ah,0x42
	mov dl,[drive_index]
	mov si,disk_access_packet
	int 0x13
	jc read_fail
read_succesful:
	mov si,read_succesful_str
	jmp read_end
read_fail:
	mov si,read_fail_str
read_end:
	call printStr
	popa
	ret

;es:di => location to transfer sectors
;ax    => number of first sector
;bx    => number of sectors to be written
write_sector:
	pusha
	mov [dap_num_of_secs],bx
	mov [dap_seg_addr],es
	mov [dap_off_addr],di
	mov [dap_start_sec],ax
	mov ah,0x43
	mov dl,[drive_index]
	mov si,disk_access_packet
	int 0x13
	jc write_fail
write_succesful:
	mov si,write_succesful_str
	jmp write_end
write_fail:
	mov si,write_fail_str
write_end:
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


ext_present_str db 'Extension present', 0x0A, 0x00
ext_not_present_str db 'Extension not present', 0x0A, 0x00
read_succesful_str db 'Read succesful', 0x0A, 0x00
read_fail_str db 'Read failed', 0x0A, 0x00
write_succesful_str db 'Write succesful', 0x0A, 0x00
write_fail_str db 'Write failed', 0x0A, 0x00
video_memory_base dw 0xb800
video_memory_index dw 0
drive_index db 0
disk_access_packet:
	dap_size		db 0x10
					db 0
	dap_num_of_secs dw 0x0000
	dap_off_addr	dw 0
	dap_seg_addr	dw 0
	dap_start_sec	dq 0
times 510-($-$$) db 0x00
db 0x55
db 0xAA
times 1024-($-$$) db 0x00

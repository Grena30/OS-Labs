org 0x7c00  ; The BIOS loads the boot sector to memory address

jmp start

msg db "Virtual Box Floppy", 0
msg_len equ $-msg

start:
    mov ax, 1300h   	; BIOS video function to write a string
    mov al, 1       	; display the entire string and update cursor
    mov bl, 8       	; color attribute
    mov dh, 9       	; row
    mov dl, 3      	; column
    mov cx, msg_len 	; length of the message
    mov bp, msg     	; points to the message

    ; Display the string
    int 10h
    
; Padding to ensure the bootloader is 512 bytes
times 510-($-$$) db 0
dw 0xaa55 ; Boot signature

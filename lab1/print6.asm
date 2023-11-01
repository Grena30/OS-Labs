org 0x7c00  ; The BIOS loads the boot sector to memory address

jmp start

msg db "OSI Model", 0
msg_len equ $-msg

start:
    mov ah, 13h  	; BIOS video function to write a string
    mov al, 0    	; display the entire string
    mov bl, 2    	; color attribute
    mov dh, 0    	; row
    mov dl, 0    	; column
    mov cx, msg_len  	; length of the message
    mov bp, msg  	; points to the message

    ; Display the string
    int 10h
    
; Padding to ensure the bootloader is 512 bytes
times 510-($-$$) db 0
dw 0xaa55 ; Boot signature

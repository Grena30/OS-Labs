org 0x7c00  ; The BIOS loads the boot sector to memory address

msg db "Os", 0
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

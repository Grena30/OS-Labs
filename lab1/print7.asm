org 0x7c00  ; The BIOS loads the boot sector to memory address

jmp start

msg db "Virtual Box Floppy", 0
msg_len equ $-msg

start:
    mov ax, 1300h   	; BIOS video function to write a string
    mov al, 1       	; display the entire string and update cursor
    mov bl, 5       	; color attribute
    mov dh, 5       	; row
    mov dl, 11      	; column
    mov cx, msg_len 	; length of the message
    mov bp, msg     	; points to the message

    ; Display the string
    int 10h

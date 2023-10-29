org 0x7c00  ; The BIOS loads the boot sector to memory address

start:
    mov ah, 09h  ; BIOS video function to display a string
    mov al, 'Z'  ; character to be displayed
    mov bl, 9    ; color attribute
    mov cx, 3    ; character display counter
    int 10h      ; BIOS video interrupt


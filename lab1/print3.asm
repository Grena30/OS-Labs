org 0x7c00  ; The BIOS loads the boot sector to memory address

start:
    mov ah, 09h  ; BIOS video function to display a string
    mov al, 'C'  ; character to be displayed
    mov bl, 12   ; color attribute 
    int 10h      ; Call BIOS video interrupt

; Padding to ensure the bootloader is 512 bytes
times 510-($-$$) db 0
dw 0xaa55 ; Boot signature

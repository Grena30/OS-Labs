org 0x7c00  ; The BIOS loads the boot sector to memory address

start:
    mov ah, 0Ah  ; BIOS video function to write character
    mov al, 'M'  ; character to display
    mov cx, 2    ; character counter
    int 10h      ; Call BIOS interrupt
    
; Padding to ensure the bootloader is 512 bytes
times 510-($-$$) db 0
dw 0xaa55 ; Boot signature

;org 0x7c00  ; The BIOS loads the boot sector to memory address

start:
    mov ah, 0Eh  	; BIOS video function to display a character with teletype
    mov al, 'B'		; character to be displayed
    int 10h		; Call BIOS interrupt

; Padding to ensure the bootloader is 512 bytes
times 510-($-$$) db 0
dw 0xaa55 ; Boot signature

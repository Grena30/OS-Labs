org 0x7c00     ; Set the origin address to 0x7c00, where the bootloader typically loads.

start:
    mov ax, 0xb800   ; video memory segment for text mode.
    mov es, ax       ; Set the extra segment (es) register to the video memory segment.
    mov di, 0x414    ; offset within the video memory
    mov cx, 0        ; counter
    mov si, msg      ; pointer to the start of the string.

loop:
    mov al, [si]     ; character that si points to
    stosb            ; Store the character in video memory.

    mov al, 0x26     ; attribute
    stosb         

    inc si           ; increment si
    inc cx           ; increment cx

    cmp cx, 18       ; compare cx to the string length
    jl loop          ; loop again if cx < len(str)
    
msg db "Nested Virtual Box", 0


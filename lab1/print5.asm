org 0x7c00  ; The BIOS loads the boot sector to memory address

start:
    ; Display characters
    mov ah, 09h  ; BIOS video function to display a string
    mov al, 'Z'  ; character to be displayed
    mov bl, 10   ; color attribute
    mov cx, 4    ; character counter
    int 10h

    ; Set cursor position
    mov ah, 02h  ; BIOS function to set the cursor position
    mov bh, 0    ; page number
    mov dh, 0    ; row
    mov dl, 4    ; column
    int 10h

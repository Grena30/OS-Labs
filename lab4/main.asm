org 0x8000									; Offset - Specific place where Kernel's supposed to begin
dw 0x1234

jmp start


start:
    mov al, 0x3      ; Set video mode to 3 (text mode)
    mov ah, 0
    int 0x10          ; Call BIOS video interrupt

    mov bx, 0         ; Clear register BX
    mov si, buffer    ; Load the address of the buffer for user input

read_key:
    mov ah, 0         ; Set AH to 0 (read keyboard input)
    int 0x16          ; Call BIOS keyboard interrupt

    cmp ah, 0x0e      ; Compare with Backspace key press
    je input_backspace ; Jump to label if Backspace is pressed

    cmp ah, 0x1c      ; Compare with Enter key press
    je input_enter    ; Jump to label if Enter is pressed

    cmp al, 0x3
    je bootloader

    cmp al, 0x20      ; Compare with ASCII value less than space
    jge echo_char     ; Jump to label if printable character

    jmp read_key      ; Jump back to read more keyboard input

bootloader:
    jmp 0xffff:0000							; Jump to reset vector location (FFFF0)
    ret

input_backspace:
    cmp si, buffer    ; Compare buffer address with SI
    je read_key       ; If buffer is empty, do nothing
    dec si            ; Decrement SI to remove the last character
    mov byte [si], 0  ; Set the removed character to null

    mov ah, 0x03      ; Set video function to get cursor position
    mov bh, 0
    int 0x10          ; Call BIOS video interrupt

    cmp dl, 0         ; If cursor is at y=0
    jz prev_line      ; Jump to label to move cursor to previous line
    jmp prev_char     ; Else jump to label to move cursor to previous position

prev_char:
    mov ah, 0x02      ; Set video function to move cursor
    dec dl            ; Decrement column position
    int 0x10          ; Call BIOS video interrupt
    jmp overwrite_char ; Jump to label to overwrite the character

prev_line:
    mov ah, 0x02      ; Set video function to move cursor
    mov dl, 79        ; Set column to the last column
    dec dh            ; Decrement row position
    int 0x10          ; Call BIOS video interrupt

overwrite_char:
    mov ah, 0xa       ; Set video function to write character with attribute
    mov al, 0x20      ; Set space (20h in ASCII) as the character
    mov cx, 1         ; Set count to 1
    int 0x10          ; Call BIOS video interrupt
    jmp read_key      ; Jump back to read more keyboard input

input_enter:
    mov ah, 0x03      ; Set video function to get cursor position
    mov bh, 0
    int 0x10          ; Call BIOS video interrupt

    sub si, buffer    ; Subtract buffer address from SI
    jz write_newline  ; If buffer is empty, write a new line

    mov ah, 0x03      ; Set video function to get cursor position
    mov bh, 0
    int 0x10          ; Call BIOS video interrupt

    cmp dh, 24        ; Compare row position with the last row
    jl print_echo     ; If less than, jump to label to print the entered string

    mov ah, 0x06      ; Set video function to scroll screen down
    mov al, 1
    mov bh, 0x07      ; Set attribute to White on Black
    mov cx, 0         ; Set top-left corner of the screen
    mov dx, 0x184f    ; Set bottom-right corner of the screen
    int 0x10          ; Call BIOS video interrupt
    mov dh, 0x17      ; Move cursor 1 line above the target

print_echo:
    mov cx, si

    push dx
    push si
    push bp

    mov bp, reversed_buffer
    mov si, buffer
    mov dx, cx

    .loop:                  ; Loop until the end of the buffer
    cmp dx, 1
    je .exit_loop

    inc si
    dec dx

    jmp .loop

    .exit_loop:
    mov dx, cx

    .reverse_buffer:         ; Add to the reversed_buffer starting from the end
    mov al, [si]
    mov [bp], al

    inc bp
    dec si

    cmp dx, 0
    je .print_buffer

    dec dx

    jmp .reverse_buffer

    .print_buffer:
    pop bp
    pop si
    pop dx

    mov bh, 0                   ; Video page number.
    mov ax, 0
    mov es, ax                  ; ES:BP is the pointer to the buffer
    mov bp, reversed_buffer

    mov bl, 0x70                ; Attribute: Black on White
    mov cx, si                  ; String length
    inc dh                      ; y coordinate
    mov dl, 0                   ; x coordinate

    mov ax, 0x1301              ; Write mode: character only, cursor moved
    int 0x10

write_newline:
    cmp dh, 24                   ; If at the last line of the terminal...
    je scroll_down               ; Scroll screen down 1 line

    mov ah, 0x03                 ; Set video function to get cursor position
    mov bh, 0
    int 0x10                     ; Call BIOS video interrupt

    jmp move_down                ; Else, just move cursor downwards

scroll_down:
    mov ah, 0x06                 ; Set video function to scroll screen down
    mov al, 1
    mov bh, 0x07                 ; Set attribute to White on Black
    mov cx, 0                    ; Set top-left corner of the screen
    mov dx, 0x184f               ; Set bottom-right corner of the screen
    int 0x10                     ; Call BIOS video interrupt
    mov dh, 0x17                 ; Move cursor 1 line above target

move_down:
    mov ah, 0x02                 ; Set video function to move the cursor
    mov bh, 0
    inc dh                       ; Increment row position
    mov dl, 0                    ; Set column to the start of the line
    int 0x10                      ; Call BIOS video interrupt

    add si, buffer               ; Add buffer address to SI

clear_buffer:
    mov byte [si], 0             ; Set each byte in the buffer to 0
    inc si                       ; Increment SI
    cmp si, 0                    ; Compare SI with 0
    jne clear_buffer             ; If not zero, continue clearing the buffer

    mov si, buffer               ; Reset SI to the buffer address
    jmp read_key                 ; Jump back to read more keyboard input

echo_char:
    cmp al, 0x7f                 ; Compare with Delete key
    jge read_key                 ; If greater than or equal, jump to read_key

    cmp si, buffer + 255         ; Compare buffer address with SI + 255
    je read_key                  ; If at max size (255), ignore further inputs

    mov ah, 0xe                  ; Set video function to echo characters to the screen
    int 10h                      ; Call BIOS video interrupt

    cmp al, 0x61                 ; Compare with ASCII value of 'a'
    jl .add_char

    cmp al, 0x7A                 ; Compare with ASCII value of 'z'
    jg .add_char

    sub al, 0x20                 ; If between 'a' and 'z' change it to uppercase
    mov [si], al
    inc si
    jmp read_key

    .add_char:
    mov [si], al
    inc si
    jmp read_key

align 512, db 0
main_end:
    buffer: times 255 db 0x0
    reversed_buffer: times 255 db 0x0
times 510 - ($ - main_end) db 0
dw 0x4321

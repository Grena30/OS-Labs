org 0x7c00

mov ah, 0x01
mov cx, 0x2020
int 0x10

mov ax, 0x1300
mov bx, 0x0007
mov cx, 0x0010									; String length - 16
mov dx, 0x0000									; Row 0, Col 0
xor bp, bp
mov es, bp
mov bp, boot_msg
int 0x10

mov cl, 0x11									; Length - 17
mov dx, 0x0100									; Row 1, Col 0
mov bp, addr_prompt
int 0x10

mov cl, 0x05									; Length - 5
mov dx, 0x0200									; Row 2, Col 0
mov bp, track_input_text
int 0x10

inc cl											; Length - 6
inc dh											; Row 3, Col 0
mov bp, sector_input_text
int 0x10

mov cl, 0x04									; Length - 4
mov dx, 0x0400									; Row 4, Col 0
mov bp, head_input_text
int 0x10

boot_start:

mov si, 0x0002
read_track:
	mov dx, 0x0207								; Row 2, Col 7
	call read_prep

	cmp di, 0x004f								; Valid interval: [0-79]
	jg read_track

shl di, 8
mov [kernel_location], di

read_sector:
	mov dx, 0x0307								; Row 3, Col 7
	call read_prep
	
	cmp di, 0x0012								; Valid interval: [1-18]
	jg read_sector
	
	test di, di
	jz read_sector

add [kernel_location], di

dec si
read_side:
	mov dx, 0x0407
	call read_prep
	
	cmp di, 0x0001
	jg read_side
shl di, 8

; Try reading 1st sector
call kernel_sector_setup
int 0x13										; Read Sectors, Load to RAM

mov bx, 0x0004

cmp ah, 0
je check_kernel_start

; Display Disk read error ahead
call prep_kernel_msg
mov bp, disk_err_msg
int 0x10

jmp boot_start

check_kernel_start:
	cmp word [0x8000], 0x1234
	je kernel_start_found

location_err:
	mov bp, location_err_msg
	call prep_kernel_msg
	int 0x10

	jmp boot_start

kernel_start_found:
	call kernel_sector_setup

kernel_read_loop:

	cmp word[bx + 0x1fe], 0x4321
	je kernel_read_end
	inc cx
	cmp cl, 0x13
	jl inc_floppy_end
	
	mov cl, 0x01
	inc dx
	cmp dl, 0x02
	jl inc_floppy_end
	
	inc ch

inc_floppy_end:
	add bx, 0x0200
	test bx, bx
	jnz kernel_read_loop_skip

	inc bx
	mov es, bx
	dec bx

kernel_read_loop_skip:
	mov ah, 0x02
	int 0x13

	jmp kernel_read_loop

kernel_read_end:
	mov bx, 0x0002
	mov bp, kernel_load_msg
	call prep_kernel_msg
	int 0x10

	xor ax, ax
	int 0x16

	jmp 0x8000

prep_kernel_msg:
	mov ax, 0x1301								; Print the upcoming message string
	mov dx, 0x0a1a								; Row 10, Col 26
	mov cx, 0x001c								; String length - 28
	ret


kernel_sector_setup:
	mov ax, 0x0201
	mov cx, [kernel_location]
	mov dx, di
	mov bx, 0x8000   							; Write to RAM starting from 0:8000
	ret


read_prep:
	mov ah, 0x02
	int 0x10
	
	mov ax, 0x0a5f
	mov cx, si
	int 0x10

	call read_num
	ret

read_num:
	xor di, di
	xor bx, bx
	
read_num_loop:
	xor ax, ax
	int 0x16

	cmp ah, 0x0e
	je read_bksp
	cmp ah, 0x1c
	je read_enter
	
	push ax
	mov ax, di
	mov di, 0x0a
	mul di
	mov di, ax
	pop ax
	
	cmp bx, si									; Digit limit reached
	je read_num_loop
	
	sub al, 0x30
	cmp al, 0x09
	ja read_num_loop

	xor ah, ah
	add di, ax
	
	add al, 0x30
	mov ah, 0x0e								; Write char as TTY
	int 0x10

	inc bl
	jmp read_num_loop

read_bksp:
	cmp bl, 0
	jz read_num_loop
	dec bl

	mov ax, di
	xor dx, dx
	mov di, 0x0a
	div di
	mov di, ax

	mov ah, 0x03
	int 0x10

	dec ah
	dec dl
	int 0x10

	mov ax, 0x0a5f
	mov cx, 0x0001
	int 0x10
	jmp read_num_loop

read_enter:
	ret

kernel_location dw 0x0000
boot_msg db "Welcome to my OS"
addr_prompt db "Made by Gutu Dinu"
track_input_text db "TRACK"
head_input_text db "HEAD"
sector_input_text db "SECTOR"
disk_err_msg db 	"   Disk Error Encountered   "
location_err_msg db "     Incorrect Location     "
kernel_load_msg db 	"Program Successfully Loaded!"

times 510 - ($ - $$) db 0
dw 0xaa55
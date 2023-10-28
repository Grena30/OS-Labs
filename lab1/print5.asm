_start:
	; Display characters
	mov AH, 09h
	mov AL, 'Z'
	mov BL, 10
	mov CX, 4
	int 10h

	; Set cursor position
	mov AH, 02h
	mov BH, 0
	mov DH, 0
	mov DL, 4
	int 10h
	 

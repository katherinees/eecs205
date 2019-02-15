
; #########################################################################

;

;   blit.asm - Assembly file for EECS205 Assignment 3

;

;  Katherine Steiner

; #########################################################################


      .586

      .MODEL FLAT,STDCALL

      .STACK 4096

      option casemap :none  ; case sensitive


include stars.inc

include lines.inc

include trig.inc

include blit.inc



.DATA

    ;; If you need to, you can place global variables here



.CODE


DrawPixel PROC USES ebx ecx edx x:DWORD, y:DWORD, color:DWORD
	cmp x, 0
	jl nope
	cmp x, 640
	jge nope
	cmp y, 0
	jl nope
	cmp y, 480
	jge nope
	mov eax, y
	mov ebx, 640
	imul ebx
	add eax, x
	mov edx, color
	mov ebx, ScreenBitsPtr
	mov BYTE PTR [ebx + eax], dl
nope:
	ret             ; Don't delete this line!!!

DrawPixel ENDP




BasicBlit PROC USES ebx ecx edx edi esi ptrBitmap:PTR EECS205BITMAP , xcenter:DWORD, ycenter:DWORD
LOCAL end_row:DWORD, end_col:DWORD, trans_col:BYTE, row_start:DWORD, col_start:DWORD

 mov edx, ptrBitmap

 mov dl, (EECS205BITMAP PTR [edx]).bTransparent

 mov trans_col, dl

 mov eax, ptrBitmap

 mov eax, (EECS205BITMAP PTR [eax]).dwWidth

 sar eax, 1

 mov ebx, xcenter

 add ebx, eax

 mov end_row, ebx   ; end_row <- xcenter + width/2

 mov ebx, xcenter

 sub ebx, eax

 mov row_start, ebx ; row_start <- xcenter - width/2


 mov eax, ptrBitmap

 mov eax, (EECS205BITMAP PTR [eax]).dwHeight

 sar eax, 1

 mov ecx, ycenter

 add ecx, eax

 mov end_col, ecx   ; end_col <- ycenter + height/2

 mov ecx, ycenter

 sub ecx, eax

 mov col_start, ecx ; col_start <- ycenter - height/2


 mov esi, ptrBitmap

 mov esi, (EECS205BITMAP PTR [esi]).lpBytes ; esi has address of 1pBytes array

 xor eax, eax

 mov ebx, row_start

 mov ecx, col_start



 jmp col_comp

col_body:

 jmp row_comp

row_body:

 mov al, [esi]

 cmp al, trans_col

 je dont_draw

 invoke DrawPixel, ebx, ecx, eax

dont_draw:

 inc ebx

 inc esi

row_comp:

 cmp ebx, end_row

 jle row_body

 inc ecx

 mov ebx, row_start

 dec esi

col_comp:

 cmp ecx, end_col

 jle col_body






 ret    ; Don't delete this line!!!

BasicBlit ENDP





RotateBlit PROC USES eax ebx ecx edx edi esi lpBmp:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD, angle:FXPT
LOCAL cosa:FXPT, sina:FXPT, shiftX:DWORD, shiftY:DWORD, dstWidth:DWORD, dstHeight:DWORD, dstX:DWORD, dstY:DWORD, srcX:DWORD, srcY:DWORD, trans_col:BYTE

	invoke FixedCos, angle
	mov cosa, eax

	invoke FixedSin, angle
	mov sina, eax

	mov esi, lpBmp
	mov dl, (EECS205BITMAP PTR [esi]).bTransparent
	mov trans_col, dl

	; shiftX =
	;		(EECS205BITMAP PTR [esi]).dwWidth * cosa / 2
	;		-  (EECS205BITMAP PTR [esi]).dwHeight * sina / 2
	xor edx, edx
	mov eax, (EECS205BITMAP PTR [esi]).dwWidth
	shl eax, 16 ; eax <- width as FXPT
	mov ebx, cosa
	sar ebx, 1 ; ebx <- cosa/2 as FXPT
	imul ebx   ; [edx, eax] <- width * cosa/2 as FXPT
	mov shiftX, edx ; shiftX <- result as int
	xor edx, edx
	mov eax, (EECS205BITMAP PTR [esi]).dwHeight
	shl eax, 16 ; eax <- height as FXPT
	mov ecx, sina
	sar ecx, 1 ; ecx <- sina/2 as FXPT
	imul ecx ; [edx, eax] <- height * sina/2 as FXPT
	sub shiftX, edx

	; shiftY =
	;		(EECS205BITMAP PTR [esi]).dwHeight * cosa / 2
	;		+  (EECS205BITMAP PTR [esi]).dwWidth * sina / 2
	xor edx, edx
	mov eax, (EECS205BITMAP PTR [esi]).dwHeight
	shl eax, 16 ; eax <- height as FXPT
	mov ebx, cosa
	sar ebx, 1 ; ebx <- cosa/2 as FXPT
	imul ebx   ; [edx, eax] <- height * cosa/2 as FXPT
	mov shiftY, edx ; shiftY <- result as int
	xor edx, edx
	mov eax, (EECS205BITMAP PTR [esi]).dwWidth
	shl eax, 16 ; eax <- width as FXPT
	mov ecx, sina
	sar ecx, 1 ; ecx <- sina/2 as FXPT
	imul ecx   ; [edx, eax] <- width * sina/2 as FXPT
	add shiftY, edx ; result as integer

	; dstWidth =
	;		(EECS205BITMAP PTR [esi]).dwWidth
	;		+  (EECS205BITMAP PTR [esi]).dwHeight
	mov eax, (EECS205BITMAP PTR [esi]).dwWidth
	mov dstWidth, eax
	mov eax, (EECS205BITMAP PTR [esi]).dwHeight
	add dstWidth, eax

	; dstHeight = dstWidth
	mov eax, dstWidth
	mov dstHeight, eax

	; for(dstX = - dstWidth; dstX < dstWidth; dstX++)
	mov eax, dstWidth
	neg eax
	mov dstX, eax ; dstX <- -dstWidth
	jmp outer_cond
outer_body:
	;; inside the outer for loop starts here
	; for(dstY = -dstHeight; dstY < dstHeight; dstY++)
	mov eax, dstHeight
	neg eax
	mov dstY, eax ; dstY <- -dstHeight
	jmp inner_cond
inner_body:
	;; inside the inner for loop starts here
	; srcX = dstX*cosa + dstY*sina
	xor edx, edx
	mov eax, dstX
	shl eax, 16 ; eax <- dstX as FXPT
	mov ebx, cosa
	imul ebx ; [edx, eax] <- dstX*cosa as FXPT
	mov srcX, edx ; move result into srcX as integer
	xor edx, edx
	mov eax, dstY
	shl eax, 16 ; eax <- dstY as FXPT
	mov ebx, sina
	imul ebx ; [edx, eax] <- dstY*sina as FXPT
	add srcX, edx ; add result into srcX as interger

	; srcY = dstY*cosa � dstX*sina
	xor edx, edx
	mov eax, dstY
	shl eax, 16 ; eax <- dstY as FXPT
	mov ebx, cosa
	imul ebx ; [edx, eax] <- dstY*cosa as FXPT
	mov srcY, edx ; move result into srcY as integer
	xor edx, edx
	mov eax, dstX
	shl eax, 16 ; eax <- dstX as FXPT
	mov ebx, sina
	imul ebx ; [edx, eax] <- dstX*sina as FXPT
	sub srcY, edx ; sub result from srcY as integer

	; and now we do a bunch of IF statements
	; if srcX >= 0
	cmp srcX, 0
	jl dont_draw
	; && srcX < (EECS205BITMAP PTR [esi]).dwWidth
	mov eax, (EECS205BITMAP PTR [esi]).dwWidth
	cmp srcX, eax
	jge dont_draw
	; && srcY >= 0
	cmp srcY, 0
	jl dont_draw
	; && srcY < (EECS205BITMAP PTR [esi]).dwHeight
	mov eax, (EECS205BITMAP PTR [esi]).dwHeight
	cmp srcY, eax
	jge dont_draw
	; && (xcenter+dstX-shiftX) >= 0
	mov eax, xcenter
	add eax, dstX
	sub eax, shiftX
	cmp eax, 0
	jl dont_draw
	; && (xcenter+dstX-shiftX) < 639
	cmp eax, 639
	jge dont_draw
	; && (ycenter+dstY-shiftY) >= 0
	mov eax, ycenter
	add eax, dstY
	sub eax, shiftY
	cmp eax, 0
	jl dont_draw
	; (ycenter+dstY-shiftY) < 479
	cmp eax, 479
	jge dont_draw
	; bitmap pixel (srcX,srcY) is not transparent)
	xor edx, edx
	mov eax, (EECS205BITMAP PTR [esi]).dwWidth
	imul srcY
	add eax, srcX
	mov ebx, (EECS205BITMAP PTR [esi]).dwWidth
	sar ebx, 1
	sub eax, ebx
	add eax, lpBmp
	xor ebx, ebx
	mov bl, BYTE PTR [eax]
	cmp bl, trans_col
	je dont_draw
	; congrats u made it
	; DrawPixel(xcenter+dstX-shiftX, ycenter+dstY-shiftY, bitmap pixel)
	mov eax, xcenter
	add eax, dstX
	sub eax, shiftX
	mov ecx, ycenter
	add ecx, dstY
	sub ecx, shiftY
	invoke DrawPixel, eax, ecx, ebx
dont_draw:
	;; inside the inner for loop ends here
	inc dstY
inner_cond:
	mov eax, dstY
	cmp eax, dstHeight
	jl inner_body
	;; inside the outer for loop ends here
	inc dstX
outer_cond:
	mov eax, dstX
	cmp eax, dstWidth
	jl outer_body


  ret             ; Don't delete this line!!!

RotateBlit ENDP








END

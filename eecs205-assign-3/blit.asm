
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
 ret         	; Don't delete this line!!!

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






 ret	; Don't delete this line!!!

BasicBlit ENDP


RotateBlit PROC USES ebx ecx edx edi esi lpBmp:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD, angle:FXPT


	ret         	; Don't delete this line!!!

RotateBlit ENDP




END

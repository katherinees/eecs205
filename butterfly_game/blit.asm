
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


DrawPixel PROC USES eax ebx edx ecx x:DWORD, y:DWORD, color:DWORD

  cmp x, 0             ;; check x, y is within the range

  jl okay

  cmp x,639

  jg okay

  cmp y,0

  jl okay

  cmp y, 479

  jg okay


  mov ebx, y        

  mov eax, 640

  mov edx, 0

  mul ebx

  add eax, x

  add eax, ScreenBitsPtr

  mov ebx, color

  mov BYTE PTR [eax], bl


okay:

    ret             ; Don't delete this line!!!

DrawPixel ENDP



BasicBlit PROC USES eax ebx ecx edx edi esi ptrBitmap:PTR EECS205BITMAP , xcenter:DWORD, ycenter:DWORD

 LOCAL dwWidth:DWORD, dwHeight:DWORD, trans_color:BYTE, xstart:DWORD, ystart:DWORD


 mov edx, ptrBitmap

 mov al, (EECS205BITMAP PTR[edx]).bTransparent    ;; get bTransparent

 mov trans_color, al


 mov ecx, (EECS205BITMAP PTR[edx]).dwWidth        ;; get dwWidth

 mov dwWidth, ecx

 shr ecx, 1               ;; xstart = xcenter - dwWidth/2

 mov ebx, xcenter

 sub ebx, ecx

 mov xstart, ebx


 mov ecx, (EECS205BITMAP PTR[edx]).dwHeight   ;; get dwHeight

 mov dwHeight, ecx

 shr ecx, 1                 ;; ystart = ycenter-dwHeight/2

 mov ebx, ycenter

 sub ebx, ecx

 mov ystart, ebx


 mov edx, (EECS205BITMAP PTR[edx]).lpBytes  

 mov edi, 0                   

 mov ecx, ystart    

 jmp OUTER_EVAL


OUTER_LOOP:

  mov esi, 0      ;; init inner counter esi = 0

  mov ebx, xstart ;; ebx = xstart

  jmp INNER_EVAL


  INNER_LOOP:

    mov eax, edi              ;; lpBtyes[edi * dwWidth + esi]

    imul eax, dwWidth

    add eax, esi

    add eax, edx          ;; get the ptr of the current pixel with ebx &lpBtyes


    mov al, BYTE PTR[eax] ;; skip the pixel with matched transparency color

    cmp al, trans_color

    je DONE_DRAWING


    movzx eax, al

    INVOKE DrawPixel, ebx, ecx, eax


  DONE_DRAWING:

    inc esi           ;; inc inner counter

    inc ebx           ;; inc x to be the next drawing point


  INNER_EVAL:

    cmp esi, dwWidth

    jl INNER_LOOP


    inc edi

    inc ecx


OUTER_EVAL:

  cmp edi, dwHeight     ;; if edi < dwheight, the outer loop is not over

  jl OUTER_LOOP


    ret             ; Don't delete this line!!!

BasicBlit ENDP











RotateBlit PROC USES eax ebx ecx edx edi esi lpBmp:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD, angle:FXPT
  LOCAL cosa : FXPT, sina : FXPT, shiftX : DWORD, shiftY : DWORD, dstWidth : DWORD, dstHeight : DWORD, srcX : DWORD, srcY: DWORD, x : DWORD, y : DWORD

  INVOKE FixedCos, angle  ;;get cosa and sina
  mov cosa, eax

  INVOKE FixedSin, angle
  mov sina, eax

  mov esi, lpBmp                    ;; esi = &lpBmp
  mov edx, (EECS205BITMAP PTR[esi]).dwWidth
  mov edi, (EECS205BITMAP PTR[esi]).dwHeight

  mov ebx, cosa
  mov ecx, sina

  mov eax, (EECS205BITMAP PTR[esi]).dwWidth   ; shiftX = dwWidth * cosa/2 - dwHeight * sina/2
  sal eax, 16                                 ; eax <- width as FXPT
  sar ebx, 1                                  ; ebx <- cosa/2 as FXPT
  imul ebx					; [edx, eax] <- width * cosa/2 as FXPT
  mov shiftX, edx				; shiftX <- result as int
  mov eax, (EECS205BITMAP PTR[esi]).dwHeight
  sal eax, 16					; height as FXPT
  sar ecx, 1                        ;; sina/2
  imul ecx                          ;; edx = dwHeight * sinA/2
  sub shiftX, edx

  mov ebx, cosa
  mov ecx, sina
  mov edx, (EECS205BITMAP PTR[esi]).dwWidth 
  mov eax, (EECS205BITMAP PTR[esi]).dwHeight
  sal eax, 16
  sar ebx, 1
  imul ebx
  mov shiftY, edx
  mov eax, (EECS205BITMAP PTR[esi]).dwWidth
  sal eax, 16
  sar ecx, 1
  imul ecx
  add shiftY, edx

  mov edi, (EECS205BITMAP PTR[esi]).dwHeight   ;;get dstWidth and dstHeight
  add edi, (EECS205BITMAP PTR[esi]).dwWidth
  mov dstWidth, edi
  mov dstHeight, edi

  neg edi                
  jmp outer_cond

outer_body:

    mov ecx, dstHeight    
    neg ecx
    jmp inner_cond
    inner_body:
      mov ebx, edi         
      shl ebx, 16          
      mov eax, ebx
      imul cosa
      mov srcX, edx
      mov ebx, ecx
      shl ebx, 16
      mov eax, ebx
      imul sina
      add srcX, edx      
      mov ebx, ecx       
      shl ebx, 16
      mov eax, ebx
      imul cosa
      mov srcY, edx
      mov ebx, edi
      shl ebx, 16
      mov eax, ebx
      imul sina
      sub srcY, edx   ;; dstY* cosa - dstX*sina
	; check if we should draw or not
      mov eax, srcX
      cmp eax, 0         ;; srcX>= 0
      jl dont_draw
      cmp eax, (EECS205BITMAP PTR[esi]).dwWidth  ;; srcX< dwWidth
      jge dont_draw
      mov eax, srcY   ;; check srcY
      cmp eax, 0
      jl dont_draw
      cmp eax, (EECS205BITMAP PTR[esi]).dwHeight
      jge dont_draw
      mov eax, xcenter   ;;check x
      add eax, edi
      sub eax, shiftX
      cmp eax, 0
      jl dont_draw
      cmp eax, 639
      jge dont_draw
      mov x, eax
      mov eax, ycenter    ;; check y
      add eax, ecx
      sub eax, shiftY
      cmp eax, 0
      jl dont_draw
      cmp eax, 479
      jge dont_draw
      mov y, eax
      mov eax, srcY           ;; color btye = [lpBytes + x + y * dwWidth]
      imul (EECS205BITMAP PTR[esi]).dwWidth
      add eax, srcX
      add eax, (EECS205BITMAP PTR[esi]).lpBytes
      mov al, BYTE PTR [eax]
      cmp al, (EECS205BITMAP PTR[esi]).bTransparent  ;;skip the pixel if equal
      je dont_draw
      movzx eax, al
      INVOKE DrawPixel, x, y, eax
      dont_draw:
      inc ecx      ;; ecx++
    inner_cond:
      cmp ecx, dstHeight
      jl inner_body
      inc edi      ;;edi++
  outer_cond:

  cmp edi, dstWidth

  jl outer_body

  ret             ; Don't delete this line!!!

RotateBlit ENDP













END







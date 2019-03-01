
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


SCREEN_WIDTH = 640

SCREEN_HEIGHT = 480

    ;; If you need to, you can place global variables here


.CODE


DrawPixel PROC USES eax ebx edx ecx x:DWORD, y:DWORD, color:DWORD

  cmp x, 0             ;; check x, y is within the range

  jl finish

  cmp x,SCREEN_WIDTH-1

  jg finish

  cmp y,0

  jl finish

  cmp y, SCREEN_HEIGHT-1

  jg finish


  mov ebx, y                ;; write the color to the pixel

  mov eax, SCREEN_WIDTH

  mov edx, 0

  mul ebx

  add eax, x

  add eax, ScreenBitsPtr

  mov ebx, color

  mov BYTE PTR [eax], bl


finish:

    ret             ; Don't delete this line!!!

DrawPixel ENDP



BasicBlit PROC USES eax ebx ecx edx edi esi ptrBitmap:PTR EECS205BITMAP , xcenter:DWORD, ycenter:DWORD

  ; INVOKE DrawPixel, 0, 1, 30


 LOCAL dwWidth:DWORD, dwHeight:DWORD, bTransparent:BYTE, xstart:DWORD, ystart:DWORD


 mov edx, ptrBitmap

 mov al, (EECS205BITMAP PTR[edx]).bTransparent    ;; get bTransparent

 mov bTransparent, al


 mov eax, (EECS205BITMAP PTR[edx]).dwWidth        ;; get dwWidth

 mov dwWidth, eax

 shr eax, 1               ;; xstart = xcenter - dwWidth/2

 mov ebx, xcenter

 sub ebx, eax

 mov xstart, ebx


 mov eax, (EECS205BITMAP PTR[edx]).dwHeight   ;; get dwHeight

 mov dwHeight, eax

 shr eax, 1                 ;; ystart = ycenter-dwHeight/2

 mov ebx, ycenter

 sub ebx, eax

 mov ystart, ebx


 mov edx, (EECS205BITMAP PTR[edx]).lpBytes  ;; ebx = start of lpBtyes

 mov edi, 0                   ;; init outer counter edi = 0

 mov ecx, ystart              ;; ecx = ystart

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

    cmp al, bTransparent

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



;; keeps only the least significant bits

INT2FXPT PROC, a:DWORD

  mov eax, a

  sal eax, 16


  ret

INT2FXPT ENDP



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


  mov eax, (EECS205BITMAP PTR[esi]).dwWidth   ;; shiftX = dwWidth * cosa/2 - dwHeight * sina/2

  sal eax, 16                                 ;;convert to FXPT

  sar ebx, 1                                  ;; consa/2

  imul ebx

  mov shiftX, edx                 ;; only get the integer part of multiplication

  mov eax, (EECS205BITMAP PTR[esi]).dwHeight

  sal eax, 16

  sar ecx, 1                        ;; sina/2

  imul ecx                          ;; edx = dwHeight * sinA/2

  sub shiftX, edx


  mov ebx, cosa       ;;reasign ebx, ecx

  mov ecx, sina


  mov edx, (EECS205BITMAP PTR[esi]).dwWidth   ;;compute shiftY

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


  neg edi                ;;init the outer loop

  jmp OUTER_EVAL


  OUTER_LOOP:

    mov ecx, dstHeight    ;; init inner loop

    neg ecx

    jmp INNER_EVAL


    INNER_LOOP:

      mov ebx, edi         ;; compute srcX

      shl ebx, 16          ;; convert to FXPT

      mov eax, ebx

      imul cosa

      mov srcX, edx

      mov ebx, ecx

      shl ebx, 16

      mov eax, ebx

      imul sina

      add srcX, edx      ;; dstY* sina + dstX*consa


      mov ebx, ecx       ;; compute srcY

      shl ebx, 16

      mov eax, ebx

      imul cosa

      mov srcY, edx

      mov ebx, edi

      shl ebx, 16

      mov eax, ebx

      imul sina

      sub srcY, edx   ;; dstY* cosa - dstX*sina


      mov eax, srcX

      cmp eax, 0         ;; srcX>= 0

      jl NOT_DRAW

      cmp eax, (EECS205BITMAP PTR[esi]).dwWidth  ;; srcX< dwWidth

      jge NOT_DRAW


      mov eax, srcY   ;; check srcY

      cmp eax, 0

      jl NOT_DRAW

      cmp eax, (EECS205BITMAP PTR[esi]).dwHeight

      jge NOT_DRAW


      mov eax, xcenter   ;;check x

      add eax, edi

      sub eax, shiftX

      cmp eax, 0

      jl NOT_DRAW

      cmp eax, 639

      jge NOT_DRAW

      mov x, eax


      mov eax, ycenter    ;; check y

      add eax, ecx

      sub eax, shiftY

      cmp eax, 0

      jl NOT_DRAW

      cmp eax, 479

      jge NOT_DRAW

      mov y, eax


      mov eax, srcY           ;; color btye = [lpBytes + x + y * dwWidth]

      imul (EECS205BITMAP PTR[esi]).dwWidth

      add eax, srcX

      add eax, (EECS205BITMAP PTR[esi]).lpBytes

      mov al, BYTE PTR [eax]


      cmp al, (EECS205BITMAP PTR[esi]).bTransparent  ;;skip the pixel if equal

      je NOT_DRAW


      movzx eax, al

      INVOKE DrawPixel, x, y, eax


      NOT_DRAW:

        inc ecx      ;; ecx++


    INNER_EVAL:

      cmp ecx, dstHeight

      jl INNER_LOOP


    inc edi      ;;edi++

  OUTER_EVAL:

  cmp edi, dstWidth

  jl OUTER_LOOP


  ret             ; Don't delete this line!!!

RotateBlit ENDP



END







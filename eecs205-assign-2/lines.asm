; #########################################################################
;
;   lines.asm - Assembly file for EECS205 Assignment 2
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc

.DATA

	;; If you need to, you can place global variables here

.CODE


;; Don't forget to add the USES the directive here
;;   Place any registers that you modify (either explicitly or implicitly)
;;   into the USES list so that caller's values can be preserved

;;   For example, if your procedure uses only the eax and ebx registers
;;      DrawLine PROC USES eax ebx x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD
DrawLine PROC uses eax ebx ecx edx esi edi x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD
	;; Feel free to use local variables...declare them here
	;; For example:
	;; 	LOCAL foo:DWORD, bar:DWORD
  LOCAL delta_x:DWORD, delta_y:DWORD, inc_x:DWORD, inc_y:DWORD, error:DWORD

	;; Place your code here
  mov inc_x, 1           ;; inc_x <- 1 if x1-x0>0 ie x0<x1
  mov eax, x1
  sub eax, x0
  cmp eax, 0             ;; eax <- x1-x0
  jg x_already_pos
  neg eax
  neg inc_x              ;; inc_x <- -1 if x1-x0<=0 ie x0>=x1
x_already_pos:
  mov delta_x, eax       ;; delta_x <- |x1-x0|

  mov inc_y, 1           ;; inc_y <- 1 if y1-y0>0 ie y0<y1
  mov eax, y1
  sub eax, y0
  cmp eax, 0             ;; eax <- y1-y0
  jg y_already_pos
  neg eax
  neg inc_y              ;; inc_y <- -1 if y1-y0<=0 ie y0>=y1
y_already_pos:
  mov delta_y, eax       ;; delta_y <- |y1-y0|

  xor edx, edx
  mov eax, delta_x
  cmp eax, delta_y
  jle error_else
  mov edx, 2
  idiv edx                 ;; eax <- delta_x/2
  jmp error_continue
error_else:
  mov eax, delta_y
  neg eax
  mov edx, 2
  idiv edx                 ;; eax <- -delta_y/2
error_continue:          ;; eax <- error
  mov error, eax

  mov ebx, x0            ;; ebx <- current_x
  mov ecx, y0            ;; ecx <- current_y
  invoke DrawPixel, ebx, ecx, color
  jmp condition

body:
  invoke DrawPixel, ebx, ecx, color

  mov edx, error         ;; edx <- prev_error = error

  mov edi, delta_x
  neg edi                ;; edi <- -delta_x
  cmp edx, edi           ;; cmp prev_error, -delta_x
  jle nextif
  mov esi, error         ;; esi <- error
  sub esi, delta_y       ;; esi <- error - delta_y
  mov error, esi         ;; error <- error - delta_y
  add ebx, inc_x         ;; curr_x += inc_x
nextif:
  cmp edx, delta_y       ;; cmp prev_error, delta_y
  jge condition
  mov esi, error         ;; esi <- error
  add esi, delta_x       ;; esi <- error + delta_x
  mov error, esi         ;; error <- error + delta_x
  add ecx, inc_y         ;; curr_y += inc_y

condition:
  cmp ebx, x1
  jne body
  cmp ecx, y1
  jne body


	ret        	;;  Don't delete this line...you need it
DrawLine ENDP




END

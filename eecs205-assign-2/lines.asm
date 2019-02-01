; #########################################################################
;
;   lines.asm - Assembly file for EECS205 Assignment 2
;
;   Katherine Steiner
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
DrawLine PROC USES eax ebx ecx edx esi x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD
	;; Feel free to use local variables...declare them here
	;; For example:
	;; 	LOCAL foo:DWORD, bar:DWORD
    LOCAL delta_x:DWORD, delta_y:DWORD, inc_x:DWORD, inc_y:DWORD

	;; Place your code here

      mov eax, x1
      mov inc_x, 1
      sub eax, x0          ;; eax <- x1-x0
      cmp eax, 0
      jg x_already_pos     ;; jump if x1-x0 > 0 ie x0 < x1
      neg eax
      neg inc_x
x_already_pos:
      mov delta_x, eax

      mov eax, y1
      mov inc_y, 1
      sub eax, y0           ;; eax <- y1-y0
      cmp eax, 0
      jg y_already_pos      ;; jump if y1-y0 > 0 ie y0 < y1
      neg eax
      neg inc_y
y_already_pos:
      mov delta_y, eax

delta_setup:
      mov eax, delta_x
      xor edx, edx
      mov ebx, 2
      cmp eax, delta_y
      jle error_else        ;; jump if delta_x <= delta_y
      idiv ebx
      jmp error_continue
error_else:
      mov eax, delta_y
      idiv ebx
      neg eax

error_continue:             ;; at this point, eax <- error
      mov ebx, x0
      mov ecx, y0
      invoke DrawPixel, ebx, ecx, color

      jmp condition

body:
      invoke DrawPixel, ebx, ecx, color
      mov edx, eax          ;; edx <- prev_error

      mov esi, delta_x
      neg esi
      cmp edx, esi
      jle nextif            ;; jump if prev_error <= -delta_x
      sub eax, delta_y      ;; otherwise, error -= delta_y, curr_x += inc_x
      add ebx, inc_x

nextif:
      cmp edx, delta_y
      jge condition
      add eax, delta_x
      add ecx, inc_y

condition:
      cmp ebx, x1
      jne body
      cmp ecx, y1
      jne body
      ret

DrawLine ENDP

END

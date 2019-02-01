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
      sub eax, x0
      jge x_already_pos
      neg eax
x_already_pos:
      mov delta_x, eax

      mov eax, y1
      sub eax, y0
      jge y_already_pos
      neg eax
   y_already_pos:
      mov delta_y, eax

      mov eax, x0
      mov inc_x, 1
      cmp eax, x1
      jl inc_continue
      neg inc_x ; Negate ix iff x0>=x1

   inc_continue:
      mov eax, y0
      mov inc_y, 1
      cmp eax, y1
      jl delta_setup
      neg inc_y

   delta_setup:
      mov eax, delta_x
      xor edx, edx
      mov ebx, 2
      cmp eax, delta_y ; Actual comparison
      jle error_else
      idiv ebx
      jmp error_continue
   error_else:
      ;; else error=-delta_y/2
      mov eax, delta_y ; To correctly divide deltay
      idiv ebx
      neg eax

   error_continue:
      mov ebx, x0 ; ebx is curr_x
      mov ecx, y0 ; ecx is curr_y
      invoke DrawPixel, ebx, ecx, color

    ;; Now, the drawing loop.
    ;; First, the conditional
 condition:
      ;; while (curr_x!=x1 OR curr_y!=y1)
      cmp ebx, x1
      jne body ; Jump to body if curr_x!=x1
      cmp ecx, y1
      jne body ; Jump to body if curr_y!=y1
	ret

    ;; Loop body
 body:
      invoke DrawPixel, ebx, ecx, color

      ;; prev_error=error
      mov edx, eax ; edx is prev_error

      mov esi, delta_x ; So we can negate deltax
      neg esi
      cmp edx, esi
      jle nextif
      ;; error=error-delta_y
      ;; curr_x=curr_x+inc_x
      sub eax, delta_y
      add ebx, inc_x

   nextif:
      ;; if (prev_error<delta_y)
      cmp edx, delta_y
      jge condition ; If prev_error>=delta_y, jump back to the conditional early. Else...
      ;; error=error+delta_x
      ;; curr_y=curr_y=inc_y
      add eax, delta_x
      add ecx, inc_y
      jmp condition ; Jump back to the conditional
DrawLine ENDP

END

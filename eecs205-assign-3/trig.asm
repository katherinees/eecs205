; #########################################################################
;
;   trig.asm - Assembly file for EECS205 Assignment 3
;   Katherine Steiner
;
; #########################################################################

  	.586
  	.MODEL FLAT,STDCALL
  	.STACK 4096
  	option casemap :none  ; case sensitive

include trig.inc

.DATA

;;  These are some useful constants (fixed point values that correspond to important angles)
PI_HALF = 102943       	 ;;  PI / 2
PI =  205887             	;;  PI
TWO_PI = 411774            	;;  2 * PI
PI_INC_RECIP =  5340353    	 ;;  Use reciprocal to find the table entry for a given angle
                     	;;          	(It is easier to use than divison would be)


 ;; If you need to, you can place global variables here

.CODE

FixedSin PROC USES ebx ecx edx esi angle:FXPT
 mov ecx, 0  ; ecx = 0 if we don't need to multiply by -1 in the end
 xor edx, edx
 mov ebx, angle
comp:
 cmp ebx, 0
 jge cont1
 add ebx, TWO_PI  ; if ebx < 0, add 2pi
 jmp comp
cont1:
 cmp ebx, TWO_PI
 jl cont2
 sub ebx, TWO_PI  ; if ebx > 2pi, sub 2pi
 jmp comp
cont2:
 cmp ebx, PI  ; if ebx > pi, it's in quad 3 or 4
 jg quad34
 cmp ebx, PI_HALF
 jg quad2
quad1:
 mov eax, PI_INC_RECIP
 imul ebx
 shl edx, 1  ; round to int part, mul by 2 bc WORDs
 movzx eax, WORD PTR [SINTAB + edx]
 jmp finish
quad2:
 mov esi, ebx
 mov ebx, PI
 sub ebx, esi  ; sin(x) = sin(pi-x) for quad 2
 mov eax, PI_INC_RECIP
 imul ebx
 shl edx, 1
 movzx eax, WORD PTR [SINTAB + edx]
 jmp finish
quad34:
 mov ecx, 1
 sub ebx, PI
 jmp comp
finish:
 cmp ecx, 0
 je okay
 neg eax
okay:
 ret   ; Don't delete this line!!!
FixedSin ENDP

FixedCos PROC angle:FXPT


      	; Replace this with your own crazy code
 mov eax, angle
 add eax, PI_HALF
 invoke FixedSin, eax

 ret   ; Don't delete this line!!!
FixedCos ENDP
END

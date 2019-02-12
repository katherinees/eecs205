; #########################################################################
;
;   trig.asm - Assembly file for EECS205 Assignment 3
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include trig.inc

.DATA

;;  These are some useful constants (fixed point values that correspond to important angles)
PI_HALF = 102943           	;;  PI / 2
PI =  205887	                ;;  PI 
TWO_PI	= 411774                ;;  2 * PI 
PI_INC_RECIP =  5340353        	;;  Use reciprocal to find the table entry for a given angle
	                        ;;              (It is easier to use than divison would be)


	;; If you need to, you can place global variables here
	
.CODE

FixedSin PROC angle:FXPT

	xor eax, eax            ; Replace this with your own crazy code

	ret			; Don't delete this line!!!
FixedSin ENDP 
	
FixedCos PROC angle:FXPT

	mov eax, 10000h         ; Replace this with your own crazy code

	ret			; Don't delete this line!!!	
FixedCos ENDP	
END

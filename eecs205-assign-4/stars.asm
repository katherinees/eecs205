; #########################################################################
;
;   stars.asm - Assembly file for EECS205 Assignment 1
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive


include stars.inc

.DATA

	;; If you need to, you can place global variables here

.CODE

DrawStarField proc

	;; Place your code here

    DrawStar proto x:DWORD, y:DWORD
    
    INVOKE DrawStar, 040d, 030d
    INVOKE DrawStar, 080d, 060d
    INVOKE DrawStar, 120d, 090d
    INVOKE DrawStar, 160d, 120d
    INVOKE DrawStar, 200d, 150d
    INVOKE DrawStar, 240d, 180d
    INVOKE DrawStar, 280d, 210d
    INVOKE DrawStar, 280d, 270d
    INVOKE DrawStar, 360d, 210d
    INVOKE DrawStar, 360d, 270d
    INVOKE DrawStar, 400d, 300d
    INVOKE DrawStar, 440d, 330d
    INVOKE DrawStar, 480d, 360d
    INVOKE DrawStar, 520d, 390d
    INVOKE DrawStar, 560d, 420d
    INVOKE DrawStar, 600d, 450d

	ret  			; Careful! Don't remove this line
DrawStarField endp



END

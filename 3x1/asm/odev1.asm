STSG SEGMENT PARA STACK 'STSGM'
	DW 20 DUP (?)
STSG ENDS

DTSG SEGMENT PARA 'DTSGM'
    vize DW 77,85,64,96
    final DW 56,63,86,74
    obp DW 4 dup(0)  
DTSG ENDS

CDSG SEGMENT PARA 'CDSGM'
	ASSUME CS: CDSG, DS: DTSG, SS: STSG
	
	ANA PROC FAR

		PUSH DS
		XOR AX, AX
		PUSH AX

		MOV AX, DTSG
		MOV DS, AX
		
		;CODE	
		MOV CX, 4
        LEA SI, vize
        LEA DI, final
        LEA BX, obp
        L1:
            MOV AX, [SI]
            MOV DX, 4
            MUL DX
            MOV [BX], AX
            MOV DX, 6
            MOV AX, [DI]
            MUL DX
            ADD [BX], AX
            MOV AX, 5
            ADD [BX], AX
            MOV AX, [BX]
            PUSH BX
            MOV BX, 10
            DIV BX
            POP BX
            MOV [BX], AX
            ADD SI, 2
            ADD DI, 2
            ADD BX, 2
            LOOP L1
        MOV CX, 4
        LEA DI, obp
        
        L2:
            DEC CX
            MOV SI,DI
            MOV BX, CX
        
        L3:
            MOV AX,[SI]
            MOV DX,[SI+2]
            CMP AX,DX
            JAE dont

            MOV [SI],DX
            MOV [SI +2],AX

        dont:
            ADD SI,2
            DEC BX
            JNZ L3

            CMP CX,1
            JG L2

 
        MOV AX,ds
        MOV DS,AX

		RETF

    
	ANA ENDP


CDSG ENDS

	END ANA
ortaksg	SEGMENT PARA 'ortak'
		ORG 100h
		ASSUME DS:ortaksg, CS:ortaksg, SS:ortaksg
Basla: JMP MAIN
    n DW 50
    primeCount DW 0
    nonPrimeCount DW 0
    primeOddSum DW 15 dup(0) 
    nonPrimeOrEvenSum DW 15 dup(0) 
    sqrTemp DW 0
MAIN    PROC NEAR
	    XOR SI, SI
        MOV CX, n
        L1:
            MOV BX,CX
            PUSH CX
            L2:
                PUSH CX
                CALL hipotenus
                CMP AX, 2500
                JA skip
                MOV CX, 1
                sqrtloop:
                    INC CX
                    CALL sqrt
                    CMP AX,DX
                    JA sqrtloop
                    CMP AX,DX
                    JB skip
                    MOV sqrTemp,CX
                prime:
                    XOR DX,DX
                    MOV CX, 2
                    MOV AX, sqrTemp
                    DIV CX
                    CMP DX, 0
                    JE nonprime
                    MOV CX, 3
                    MOV AX, sqrTemp
                primeloop:
                    XOR DX,DX
                    DIV CX
                    CMP DX,0
                    JE nonprime
                    MOV AX, sqrTemp
                    ADD CX, 2
                    CMP AX, CX
                    JA primeloop
                CALL oddCheck
                CMP DX,0
                JE nonprime
                CALL primeLoad
                CMP CX,0
                JE atlaP
                duplicateP:
                    CMP [DI],AX
                    JE skip
                    ADD DI,2
                    LOOP duplicateP
                atlap:
                CALL primeAdd
                JMP skip
                nonprime:
                    CALL nonPrimeLoad
                    CMP CX,0
                    JE atla
                    duplicate:
                        CMP [DI],AX
                        JE skip
                        ADD DI, 2
                        LOOP duplicate
                    atla:
                    CALL nonPrimeAdd
                skip:
                POP CX
                LOOP L2
            POP CX
            LOOP L1
bitir:	RET

sqrt proc
        PUSH AX
        MOV AX,CX
        MUL CX
        MOV DX,AX
        POP AX
    ret
sqrt endp

primeAdd proc
        MOV AX, primeCount
        LEA DI, primeOddSum
        ADD DI, AX
        ADD DI, AX
        MOV DX, sqrTemp
        MOV [DI], DX
        INC AX
        MOV primeCount, AX
    ret
primeAdd endp


nonPrimeAdd proc
        MOV AX, nonPrimeCount
        LEA DI, nonPrimeOrEvenSum
        ADD DI, AX
        ADD DI, AX
        MOV DX, sqrTemp
        MOV [DI],DX
        INC AX
        MOV nonPrimeCount,AX
    ret
nonPrimeAdd endp

hipotenus proc
        MOV AX,CX 
        MUL CX 
        PUSH AX 
        MOV AX, BX
        MUL BX
        MOV DX,AX
        POP AX
        ADD AX,DX
    ret
hipotenus endp

primeLoad proc
        MOV CX, primeCount
        LEA DI, primeOddSum
        MOV AX, sqrTemp
    RET
primeLoad endp

nonPrimeLoad proc
        MOV CX, nonPrimeCount
        LEA DI, nonPrimeOrEvenSum
        MOV AX, sqrTemp
    RET
nonPrimeLoad endp

oddCheck proc
        POP CX
        PUSH CX
        ADD CX,DX
        MOV AX,CX
        XOR DX,DX
        MOV CX, 2
        DIV CX
    ret
oddCheck endp
MAIN    ENDP
ortaksg	ENDS
		    END Basla

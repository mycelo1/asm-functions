            push    EBX
            push    ESI
            push    EDI

    @@Start:

            mov     ESI,  InData
            mov     EDI,  OutData
            mov     EBX,  InDataSize

            shr     EBX,  1
            shl     EBX,  1
            jz      @@Done

    @@Loop:

            lodsw
            xchg    AL,   AH
            stosw

            sub     EBX,  2
            jnz     @@Loop

    @@Done:

            pop     EDI
            pop     ESI
            pop     EBX

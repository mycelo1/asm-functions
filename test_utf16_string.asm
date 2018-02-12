            push    EAX
            push    EBX
            push    ECX
            push    EDX
            push    ESI
            push    EDI

    @@Start:

            mov     ESI,    InData
            mov     EBX,    InDataSize

            shr     EBX,    1
            shl     EBX,    1
            jz      @@Done

            mov     ECX,    0
            mov     EDX,    0
    @@Loop:

            lodsw

            cmp     AL,     0
            je      @@IncL

            cmp     AH,     0
            je      @@IncH

    @@RetLoop:

            sub     EBX,    2
            jnz     @@Loop
            jmp     @@Done

    @@IncL:

            inc     ECX
            jmp     @@RetLoop

    @@IncH:

            inc     EDX
            jmp     @@RetLoop

    @@Done:

            mov     ESI,    [CountCL]
            mov     [ESI],  ECX

            mov     ESI,    [CountCH]
            mov     [ESI],  EDX

            pop     EDI
            pop     ESI
            pop     EDX
            pop     ECX
            pop     EBX
            pop     EAX

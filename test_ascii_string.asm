            push    EAX
            push    EBX
            push    ECX
            push    ESI
            push    EDI

    @@Start:

            mov     ESI,    InData
            mov     EBX,    InDataSize
            jz      @@Done

            mov     ECX,    0
    @@Loop:

            lodsb

            shr     AL,     7
            jnz     @@Inc

    @@RetLoop:

            sub     EBX,    1
            jnz     @@Loop
            jmp     @@Done

    @@Inc:

            inc     ECX
            jmp     @@RetLoop

    @@Done:

            mov     ESI,    [Count8bit]
            mov     [ESI],  ECX

            pop     EDI
            pop     ESI
            pop     ECX
            pop     EBX
            pop     EAX

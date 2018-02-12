            push    EBX
            push    ESI
            push    EDI

    @@Start:

            mov     ESI,  InData
            mov     EDI,  OutText
            mov     EBX,  InDataSize
            mov     ECX,  Key

            cmp     EBX,  0
            jz      @@Done

    @@Loop:

            lodsd
            xor     EAX,  ECX
            mov     ECX,  EAX
            stosd

            sub     EBX, 4
            jnz     @@Loop

    @@Done:

            pop     EDI
            pop     ESI
            pop     EBX

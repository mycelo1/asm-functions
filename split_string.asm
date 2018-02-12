            push    EBX
            push    ESI
            push    EDI

    @@Start:

            mov     ESI,  InText
            mov     EDI,  OutText
            mov     EDX,  EDI
            mov     EBX,  1

    @@LoopSegment:

            cmp     EBX,  Position
            jg      @@Done

    @@LoopChar:

            movsb
            mov     AL,   BYTE PTR [EDI - 1]
            cmp     AL,   Separator
            je      @@SeparatorFound
            cmp     AL,   0
            je      @@EndFound
            jmp     @@LoopChar

    @@SeparatorFound:

            cmp     EBX,  Position
            je      @@Keep
            inc     EBX
            mov     EDI,  EDX
            jmp     @@LoopSegmento

    @@EndFound:

            cmp     EBX,  Position
            je      @@Keep
            mov     EDI,  EDX
            jmp     @@Done

    @@Keep:

            dec     EDI
            jmp     @@Done

    @@Done:

            xor     AL,   AL
            stosb

            pop     EDI
            pop     ESI
            pop     EBX

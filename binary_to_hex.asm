            push    EBX
            push    ESI
            push    EDI

    @@Start:

            mov     ESI,  InData
            mov     EDI,  OutText
            mov     EBX,  InDataSize

    @@LoopByte:

            lodsb
            mov     AH,   AL

    @@LowerPart:

            shr     AL,   4
            cmp     AL,   $09
            jg      @@LowerGr9
            or      AL,   $30
            jmp     @@HigherPart

    @@LowerGr9:

            sub     AL,   $09
            or      AL,   $40

    @@HigherPart:

            and     AH,   $0F
            cmp     AH,   $09
            jg      @@HigherGr9
            or      AH,   $30
            jmp     @@Store

    @@HigherGr9:

            sub     AH,   $09
            or      AH,   $40

    @@Store:

            stosw
            dec     EBX
            cmp     EBX,  0
            jg      @@LoopByte

    @@Done:

            xor     AL,   AL
            stosb

            pop     EDI
            pop     ESI
            pop     EBX

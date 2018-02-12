            push    EBX
            push    ESI
            push    EDI

    @@Start:

            mov     EDI,  WrongChar
            mov     EAX,  0
            stosd

            mov     ESI,  InText
            mov     EDI,  OutData
            mov     EBX,  InTextSize
            xor     ECX,  ECX

    @@LoopWord:

            cmp     ECX,  EBX
            jge     @@Done

            lodsw

    @@HigherPart:

            inc     ECX
            cmp     AL,   $30
            jl      @@Error
            cmp     AL,   $39
            jg      @@HigherGr39
            jmp     @@StoreHigher

    @@HigherGr39:

            cmp     AL,   $41
            jl      @@Error
            cmp     AL,   $46
            jg      @@HigherGr46
            add     AL,   $09
            jmp     @@StoreHigher

    @@HigherGr46:

            cmp     AL,   $61
            jl      @@Error
            cmp     AL,   $66
            jg      @@Error
            add     AL,   $09

    @@StoreHigher:

            shl     AL,   4

    @@LowerPart:

            inc     ECX
            cmp     AH,   $30
            jl      @@Error
            cmp     AH,   $39
            jg      @@LowerGr39
            jmp     @@StoreLower

    @@LowerGr39:

            cmp     AH,   $41
            jl      @@Error
            cmp     AH,   $46
            jg      @@LowerGr46
            add     AH,   $09
            jmp     @@StoreLower

    @@LowerGr46:

            cmp     AH,   $61
            jl      @@Error
            cmp     AH,   $66
            jg      @@Error
            add     AH,   $09

    @@StoreLower:

            and     AH,   $0F
            or      AL,   AH
            stosb

            jmp     @@LoopWord

    @@Error:

            mov     EDI,  WrongChar
            mov     EAX,  ECX
            stosd

    @@Done:

            pop     EDI
            pop     ESI
            pop     EBX

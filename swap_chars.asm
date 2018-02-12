            push    EBX
            push    ESI
            push    EDI

    @@Start:

            mov     ESI,  InText
            mov     EDI,  OutText
            push    ESI

    @@LoopText:

            pop     ESI
            lodsb
            cmp     AL,   0
            je      @@Done
            mov     CL,   AL
            push    ESI
            mov     ESI,  Chars1
            mov     EBX,  0

    @@LoopChars1:

            lodsb
            cmp     AL,   0
            je      @@NotFound
            cmp     AL,   CL
            je      @@Subst
            inc     EBX
            jmp     @@LoopChars1

    @@NotFound:

            mov     AL,   CL
            stosb
            jmp     @@LoopText

    @@Subst:

            mov     ESI,  Chars2
            add     ESI,  EBX
            lodsb
            stosb
            jmp     @@LoopText

    @@Done:

            xor     AL,   AL
            stosb

            pop     EDI
            pop     ESI
            pop     EBX

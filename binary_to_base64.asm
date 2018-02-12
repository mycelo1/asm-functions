            push    EBX
            push    ESI
            push    EDI
            jmp     @@Start

    @@BASE64CODEC:

            db      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

    @@BASE64FILLER:

            db      '='

    @@Start:

            mov     ESI,  InBuffer
            mov     EDI,  OutBuffer
            mov     EAX,  InSize
            mov     ECX,  $03
            xor     EDX,  EDX
            div     ECX
            mov     qttGroups,  EAX
            mov     qttRemain,   EDX
            lea     ECX,  CS:[OFFSET @@BASE64CODEC]
            xor     EAX,  EAX
            xor     EBX,  EBX
            xor     EDX,  EDX
            cmp     qttGroups, 0
            jz      @@DoRemain

    @@Loop:

            lodsw
            mov     BL,   AL
            shr     BL,   2
            mov     DL,   BYTE PTR [ECX + EBX]
            mov     BH,   AH
            and     BH,   $0F
            rol     AX,   4
            and     AX,   $3F
            mov     DH,   BYTE PTR [ECX + EAX]
            mov     AX,   DX
            stosw
            lodsb
            mov     BL,   AL
            shr     BX,   6
            mov     DL,   BYTE PTR [ECX + EBX]
            and     AL,   $3F
            xor     AH,   AH
            mov     DH,   BYTE PTR [ECX + EAX]
            mov     AX,   DX
            stosw
            dec     qttGroups
            jnz     @@Loop

    @@DoRemain:

            cmp     qttRemain, 0
            jz      @@Done
            xor     EAX,  EAX
            xor     EBX,  EBX
            xor     EDX,  EDX
            lodsb
            shl     AX,   6
            mov     BL,   AH
            mov     DL,   BYTE PTR [ECX + EBX]
            dec     qttRemain
            jz      @@SaveOne
            shl     AX,   2
            and     AH,   $03
            lodsb
            shl     AX,   4
            mov     BL,   AH
            mov     DH,   BYTE PTR [ECX + EBX]
            shl     EDX,  16
            shr     AL,   2
            mov     BL,   AL
            mov     DL,   BYTE PTR [ECX + EBX]
            mov     DH,   @@BASE64FILLER
            jmp     @@Last4

    @@SaveOne:

            shr     AL,   2
            mov     BL,   AL
            mov     DH,   BYTE PTR [ECX + EBX]
            shl     EDX,  16
            mov     DH,   @@BASE64FILLER
            mov     DL,   @@BASE64FILLER

    @@Last4:

            mov     EAX,  EDX
            ror     EAX,  16
            stosd

    @@Done:

            pop     EDI
            pop     ESI
            pop     EBX

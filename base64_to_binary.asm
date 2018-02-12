            push    EBX
            push    ESI
            push    EDI
            jmp     @@Start

    @@BASE64CODEC:

            db  $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF // 000..009
            db  $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF // 010..019
            db  $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF // 020..029
            db  $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF // 030..039
            db  $FF, $FF, $FF, $3E, $FF, $FF, $FF, $3F, $34, $35 // 040..049
            db  $36, $37, $38, $39, $3A, $3B, $3C, $3D, $FF, $FF // 050..059
            db  $FF, $FF, $FF, $FF, $FF, $00, $01, $02, $03, $04 // 060..069
            db  $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E // 070..079
            db  $0F, $10, $11, $12, $13, $14, $15, $16, $17, $18 // 080..089
            db  $19, $FF, $FF, $FF, $FF, $FF, $FF, $1A, $1B, $1C // 090..099
            db  $1D, $1E, $1F, $20, $21, $22, $23, $24, $25, $26 // 100..109
            db  $27, $28, $29, $2A, $2B, $2C, $2D, $2E, $2F, $30 // 110..119
            db  $31, $32, $33, $FF, $FF, $FF, $FF, $FF, $FF, $FF // 128..129
            db  $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF // 130..139
            db  $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF // 140..149
            db  $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF // 150..159
            db  $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF // 160..169
            db  $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF // 170..179
            db  $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF // 180..189
            db  $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF // 190..199
            db  $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF // 200..209
            db  $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF // 210..219
            db  $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF // 220..229
            db  $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF // 230..239
            db  $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF // 240..249
            db  $FF, $FF, $FF, $FF, $FF, $FF                     // 250..255

    @@BASE64FILLER:

            db      '='

    @@Start:

            mov     ESI,  InBuffer
            mov     EDI,  OutBuffer
            mov     EAX,  InSize
            and     EAX,  $03
            cmp     EAX,  $00
            jz      @@DecodeStart
            jmp     @@Error

    @@DecodeStart:

            mov     EAX,  InSize
            shr     EAX,  2
            jz      @@Done
            lea     ECX,  CS:[OFFSET @@BASE64CODEC]
            xor     EBX,  EBX
            dec     EAX
            jz      @@Remaining
            push    EBP
            mov     EBP,  EAX

    @@LoopStart:

            lodsd
            mov     EDX,  EAX
            mov     BL,   DL
            mov     AH,   BYTE PTR [ECX + EBX]
            cmp     AH,   $FF
            jz      @@ErrorPop
            mov     BL,   DH
            mov     AL,   BYTE PTR [ECX + EBX]
            cmp     AL,   $FF
            jz      @@ErrorPop
            shl     AL,   2
            ror     AX,   6
            stosb
            shr     AX,   12
            shr     EDX,  16
            mov     BL,   DL
            mov     AH,   BYTE PTR [ECX + EBX]
            cmp     AH,   $FF
            jz      @@ErrorPop
            shl     AH,   2
            rol     AX,   4
            mov     BL,   DH
            mov     BL,   BYTE PTR [ECX + EBX]
            cmp     BL,   $FF
            jz      @@ErrorPop
            or      AH,   BL
            stosw
            dec     EBP
            jnz     @@LoopStart
            pop     EBP

    @@Remaining:

            lodsd
            mov     EDX,  EAX
            mov     BL,   DL
            mov     AH,   BYTE PTR [ECX + EBX]
            cmp     AH,   $FF
            jz      @@Error
            mov     BL,   DH
            mov     AL,   BYTE PTR [ECX + EBX]
            cmp     AL,   $FF
            jz      @@Error
            shl     AL,   2
            ror     AX,   6
            stosb
            shr     EDX,  16
            cmp     DL,   @@BASE64FILLER
            jz      @@Success
            shr     AX,   12
            mov     BL,   DL
            mov     AH,   BYTE PTR [ECX + EBX]
            cmp     AH,   $FF
            jz      @@Error
            shl     AH,   2
            rol     AX,   4
            stosb
            cmp     DH,   @@BASE64FILLER
            jz      @@Success
            mov     BL,   DH
            mov     BL,   BYTE PTR [ECX + EBX]
            cmp     BL,   $FF
            jz      @@Error
            or      AH,   BL
            mov     AL,   AH
            stosb

    @@Success:

            mov     Result, $01
            jmp     @@Done

    @@ErrorPop:

            pop     EBP

    @@Error:

            mov     Result, $00

    @@Done:

            pop     EDI
            pop     ESI
            pop     EBX

          push    EBX
          push    ESI
          push    EDI

  @@Start:

          mov     ESI,  Text
          mov     EBX,  0

  @@LoopText:

          cmp     EBX,  Size
          jge     @@Done

          inc     EBX
          lodsb
          cmp     AL,   $20
          jae     @@LoopText

  @@Subst:

          mov     EDI,  ESI
          dec     EDI
          mov     BYTE PTR [EDI], $20
          jmp     @@LoopText

  @@Done:

          pop     EDI
          pop     ESI
          pop     EBX

          push    EBX
          push    ESI
          push    EDI

  @@Start:

          mov     ESI,  Texto
          mov     EBX,  0

  @@LoopText:

          cmp     EBX,  Size
          jge     @@Done

          inc     EBX
          lodsb

  @@CmpLs20:

          cmp     AL,   $20
          jle     @@Subst

  @@CmpGr7E:

          cmp     AL,   $7E
          jle     @@LoopText

  @@Subst:

          mov     EDI,  ESI
          dec     EDI
          mov     BYTE PTR [EDI], $2E
          jmp     @@LoopText

  @@Done:

          pop     EDI
          pop     ESI
          pop     EBX

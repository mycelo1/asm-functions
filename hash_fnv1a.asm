          push    EBX
          push    ESI
          push    EDI

          mov     EBX,  Seed
          mov     ESI,  Data
          mov     ECX,  Size

          and     ECX,  ECX
          jz      @@Exit

  @@Loop:

          xor     EAX,  EAX
          lodsb
          xor     EAX,  EBX
          mov     EBX,  $01000193
          mul     EBX
          mov     EBX,  EAX

          dec     ECX
          jnz     @@Loop
          jmp     @@Exit

  @@Exit:

          mov     Result, EBX

          pop     EDI
          pop     ESI
          pop     EBX

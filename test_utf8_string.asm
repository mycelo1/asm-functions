            push    EAX
            push    EBX
            push    ECX
            push    EDX
            push    ESI
            push    EDI

            jmp     @@Start

    @@InvalidBytes:

            db $C0, $C1, $F5, $F6, $F7, $F8, $F9, $FA
            db $FB, $FC, $FD, $FE, $FF, $00

    @@Start:

            cld                    
            mov     ESI,    InData
            mov     EBX,    InDataSize
            jz      @@Done

            mov     EAX,    0       // AL = current byte
            mov     ECX,    0       // CL = saved leading byte, CH = trailing bytes count
            mov     EDX,    0       // DL = current leading byte

    @@Loop:

            lodsb                   // load next byte
            dec     EBX             // decrement remaining bytes counter

            // test if null byte

            cmp     AL,     0       // byte == 0 ?
            je      @@Error         // yes, finish with error

            // test if byte is ASCII 7BIT (<=127)

            cmp     AL,     $80     // compare with 128
            jb      @@CheckAsc      // if lower, check if last character is valid

            // test if byte is in the list of invalid bytes

            push    ECX             // save ECX in stack
            push    EDI             // save EDI in stack

            lea     EDI,    CS:[OFFSET @@InvalidBytes]
            mov     ECX,    14

            repne   scasb           // search byte AL in EDI
            mov     EDX,    ECX

            pop     EDI             // load EDI from stack
            pop     ECX             // load ECX from stack

            cmp     EDX,    0       // invalid character found ?
            jne     @@Error         // yes, finish with error

            // test if trailing byte (10xxxxxx)

            mov     AH,     AL      // save loaded byte in AH
            shr     AH,     6       // move 6 bits to the right
            cmp     AH,     $02     // test if == 00000010
            je      @@CheckCont     // is equal, check if trailing byte is valid

    @@LeadingByte3:

            // test if leading byte 11110xxx (1+3)

            mov     AH,     AL      // save loaded byte in AH
            shr     AH,     3       // move 3 bits to the right
            cmp     AH,     $1E     // test if == 00011110
            jne     @@LeadingByte2  // diferent, go to next test
            mov     DL,     3       // leading byte (1+3) bytes
            jmp     @@CheckLead     // check if last character is valid

    @@LeadingByte2:

            // test if leading byte 1110xxxx (1+2)

            shr     AH,     1       // move 1 more bit to the right
            cmp     AH,     $0E     // test if == 00001110
            jne     @@LeadingByte1  // diferent, go to next test
            mov     DL,     2       // leading byte (1+2) bytes
            jmp     @@CheckLead     // check if last character is valid

    @@LeadingByte1:

            // testar if leading byte 110xxxxx (1+1)

            shr     AH,     1       // move 1 more bit to the right
            cmp     AH,     $06     // test if == 00000110
            jne     @@LeadingByte0  // diferent, go to next test
            mov     DL,     1       // leading byte (1+1) bytes
            jmp     @@CheckLead     // check if last character is valid

    @@LeadingByte0:

            // testar se é leading byte 11xxxxxx (inválido)

            shr     AH,     1       // move 1 more bit to the right
            cmp     AH,     $03     // test if == 00000011
            jne     @@LoopEnd       // diferent, continue loop

    @@InvalidByte:

            // did not pass any test

            jmp     @@Error         // terminate program with error

    @@LoopEnd:

            cmp     EBX,    0       // remaining bytes count == 0 ?
            jne     @@Loop          // diferent, return to loop begining

            // end of data, check if there was a leading byte before

            cmp     CL,     0       // is there a loaded leading byte?
            je      @@Done          // no, terminate program

            // there was a leading byte, check if corresponds to the number of trailing bytes

            cmp     CH,     CL      // leading byte == # trailing bytes?
            jne     @@Error         // no, finish program with error
            jmp     @@Done          // terminate program

    @@CheckAsc:

            // ASCII received, check if there was a leading byte before

            cmp     CL,     0       // is there a loaded leading byte?
            je      @@LoopEnd       // no, continue on loop

            // there was a leading byte, check if corresponds to the number of trailing bytes

            cmp     CH,     CL      // leading byte == # trailing bytes?
            jne     @@Error         // no, finish program with error
            mov     ECX,    0       // zero control
            jmp     @@LoopEnd       // continue on loop

    @@CheckCont:

            // received a trailing byte, check if there was a leading byte before

            cmp     CL,     0       // is there a loaded leading byte?
            je      @@Error         // no, finish program with error
            inc     CH              // increment trailing bytes counter
            cmp     CH,     CL      // leading byte VS # trailing bytes
            ja      @@Error         // trailing bytes higher than expected, finish with error
            jmp     @@LoopEnd       // continue on loop

    @@CheckLead:

            // there was a leading byte, check if corresponds to the number of trailing bytes

            cmp     CL,     0       // is there a loaded leading byte?
            je      @@SaveLead      // no, save current leading byte
            cmp     CH,     CL      // leading byte == # trailing bytes?
            jne     @@Error         // diferent, finish program with error

    @@SaveLead:

            mov     ECX,    0       // zero control
            mov     CL,     DL      // save current leading byte in CL
            jmp     @@LoopEnd       // continue on loop

    @@Error:

            inc     DH              // flag error

    @@Done:

            shr     EDX,    8       // EDX := DH
            mov     ESI,    [Errors]
            mov     [ESI],  EDX

            pop     EDI
            pop     ESI
            pop     EDX
            pop     ECX
            pop     EBX
            pop     EAX

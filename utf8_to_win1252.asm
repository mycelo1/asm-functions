            push    EAX
            push    EBX
            push    ECX
            push    EDX
            push    ESI
            push    EDI

            jmp     @@Start

    @@InvalidBytes:

            db  $C0, $C1, $F5, $F6, $F7, $F8, $F9, $FA
            db  $FB, $FC, $FD, $FE, $FF, $00

    @@Win1252Table:

            //     00     01     02     03     04     05     06     07     08     09     0A     0B     0C     0D     0E     0F
            dw  $20AC, $FFFF, $201A, $0192, $201E, $2026, $2020, $2021, $02C6, $2030, $0160, $2039, $0152, $FFFF, $017D, $FFFF  // 80
            dw  $FFFF, $2018, $2019, $201C, $201D, $2022, $2013, $2014, $02DC, $2122, $0161, $203A, $0153, $FFFF, $017E, $0178  // 90
            dw  $00A0, $00A1, $00A2, $00A3, $00A4, $00A5, $00A6, $00A7, $00A8, $00A9, $00AA, $00AB, $00AC, $00AD, $00AE, $00AF  // A0
            dw  $00B0, $00B1, $00B2, $00B3, $00B4, $00B5, $00B6, $00B7, $00B8, $00B9, $00BA, $00BB, $00BC, $00BD, $00BE, $00BF  // B0
            dw  $00C0, $00C1, $00C2, $00C3, $00C4, $00C5, $00C6, $00C7, $00C8, $00C9, $00CA, $00CB, $00CC, $00CD, $00CE, $00CF  // C0
            dw  $00D0, $00D1, $00D2, $00D3, $00D4, $00D5, $00D6, $00D7, $00D8, $00D9, $00DA, $00DB, $00DC, $00DD, $00DE, $00DF  // D0
            dw  $00E0, $00E1, $00E2, $00E3, $00E4, $00E5, $00E6, $00E7, $00E8, $00E9, $00EA, $00EB, $00EC, $00ED, $00EE, $00EF  // E0
            dw  $00F0, $00F1, $00F2, $00F3, $00F4, $00F5, $00F6, $00F7, $00F8, $00F9, $00FA, $00FB, $00FC, $00FD, $00FE, $00FF  // F0
            dw  $FFFF

    @@Start:

            cld
            mov     ESI,    InData
            mov     EDI,    OutData
            mov     EBX,    InDataSize
            jz      @@FinishString

            mov     EAX,    0       // loaded byte
            mov     ECX,    0       // unicode code-point
            mov     EDX,    0       // expected quantity of trailing bytes

    @@Loop:

            lodsb                   // load next byte
            dec     EBX             // decrement remaining bytes counter

            // test if null byte

            cmp     AL,     0       // byte == 0 ?
            je      @@Error         // yes, finish with error

            // test if byte ASCII 7BIT (<=127)

            cmp     AL,     $7F     // compare with 127
            ja      @@SearchByte    // if greater, check if valid byte

            cmp     DL,     0       // is there a character being composed?
            jne     @@Error         // yes, finish program with error
            jmp     @@StoreChar     // no, save ASCII character in out buffer

    @@SearchByte:

            // test if byte is in the list of invalid bytes

            push    ECX             // save ECX in stack
            push    EDI             // save EDI in stack

            lea     EDI,    CS:[OFFSET @@InvalidBytes]
            mov     ECX,    14

            repne   scasb           // load byte AL in EDI
            cmp     ECX,    0       // found invalid byte?

            pop     EDI             // load EDI from stack
            pop     ECX             // load ECX from stack

            jne     @@Error         // yes, finish with error

            mov     AH,     AL      // save loaded byte in AH

    @@LeadingByte3:

            // test if leading byte 11110xxx (1+3) (not suported here)

            shr     AH,     3       // move 3 bits to the right
            cmp     AH,     $1E     // testar if == 00011110
            je      @@Error         // match, finish program with error

    @@LeadingByte2:

            // test if leading byte 1110xxxx (1+2)

            shr     AH,     1       // move 4 bits to the right
            cmp     AH,     $0E     // test if == 00001110
            jne     @@LeadingByte1  // diferent, go to next test

            cmp     DL,     0       // is there a character being composed?
            jne     @@Error         // yes, finish program with error

            mov     DH,     2       // sequence of 2 bytes (after leading byte)
            mov     DL,     2       // 2 trailing bytes remaining

            xor     AH,     AH      // zero AH
            mov     CX,     AX      // save current byte in CX
            shl     CX,     12      // 000000000 0000LLLL << 12 = LLLL0000 00000000
            or      CX,     $0FFF   // LLLL0000 00000000 OR 00001111 11111111 = LLLL1111 11111111

            jmp     @@LoopEnd

    @@LeadingByte1:

            // test if leading byte 110xxxxx (1+1)

            shr     AH,     1       // move 5 bits to the right
            cmp     AH,     $06     // test if == 00000110
            jne     @@ContByte      // diferent, go to next test

            cmp     DL,     0       // is there a character being composed?
            jne     @@Error         // yes, finish program with error

            mov     DH,     1       // sequence of 1 bytes (after leading byte)
            mov     DL,     1       // 1 trailing byte remaining

            xor     AH,     AH      // zero AH
            mov     CX,     AX      // save current byte in CX
            shl     CX,     6       // 00000000 110LLLLL << 6 = 00110LLL LL000000
            or      CX,     $003F   // 00110LLL LL000000 OR 00000000 00111111 = 00110LLL LL111111
            and     CX,     $07FF   // 00110LLL LL111111 AND 00000111 11111111 = 00000LLL LL111111

            jmp     @@LoopEnd

    @@ContByte:

            // test if trailing byte (10xxxxxx)

            shr     AH,     1       // move 6 bits to the right
            cmp     AH,     $02     // test if == 00000010
            jne     @@InvalidByte   // diferent, did not pass any tests

            cmp     DL,     0       // is it expecting a trailing byte?
            je      @@Error         // no, finish program with error

            dec     DL
            cmp     DL,     1       // is this the second-to-last byte of sequence?
            jne     @@ContByte2     // no, go to next test

    @@ContByte1:

            // check second-to-last byte of sequence

            xor     AH,     AH      // zero AH
            shl     AX,     10      // 00000000 10CCCCCC << 10 = CCCCCC00 00000000
            shr     AX,     4       // CCCCCC00 00000000 >> 4  = 0000CCCC CC000000
            or      AX,     $F03F   // 0000CCCC CC000000 OR 11110000 00111111 = 1111CCCC CC111111
            and     CX,     AX      // concatenate byte in CX

            jmp     @@LoopEnd

    @@ContByte2:

            // check last byte of sequence

            xor     AH,     AH      // zero AH
            or      AX,     $FFC0   // 00000000 10CCCCCC OR 11111111 11000000 = 11111111 11CCCCCC
            and     AX,     CX      // concatenate byte in AX

            // unicode code-point composed in AX, convert

            cmp     DH,     1       // was that a 1-byte sequence?
            je      @@Translate1    // validate sequence

            cmp     DH,     2       // was that a 2-byte sequence?
            je      @@Translate2    // validate sequence

    @@InvalidByte:

            // did not pass any tests, invalid byte

            jmp     @@Error         // finish program with error

    @@LoopEnd:

            cmp     EBX,    0       // remaining bytes counter == 0 ?
            jne     @@Loop          // diferent, retorn to loop beginning

            // end of data, check if there was a leading byte before

            cmp     DL,     0       // is there a character being composed?
            je      @@FinishString  // no, terminate program
            jmp     @@Error         // yes, finish program with error

    @@Translate1:

            // check range of 1-byte sequence (1+1)

            cmp     AX,     $0080   // compare with 128
            jb      @@Error         // lower, finish program with error
            jmp     @@Translate

    @@Translate2:

            // check range of 2-byte sequence (1+2)

            cmp     AX,     $0800   // compare with 0x0800
            jb      @@Error         // lower, finish program with error
            jmp     @@Translate

    @@Translate:

            // convert unicode code-point to WIN-1252

            cmp     AX,     $FFFF   // compare with 0xFFFF
            je      @@Error         // match, finish program with error

            push    EDI             // save EDI in stack

            lea     EDI,    CS:[OFFSET @@Win1252Table]
            mov     ECX,    129     // load table size in ECX

            repne   scasw           // search word AX in EDI (decrementing ECX)

            pop     EDI             // load EDI from stack

            cmp     ECX,    0       // character found?
            je      @@Error         // no, finish with error

            mov     EAX,    256
            sub     EAX,    ECX     // EAX := 256 - ECX

            // zero control

            xor     EDX,    EDX

    @@StoreChar:

            stosb                   // save byte in AL in out buffer
            jmp     @@LoopEnd

    @@FinishString:

            mov     AL,     0
            stosb                   // finalize string with null

            xor     EDX,    EDX     // zero error flag
            jmp     @@Done

    @@Error:

            mov     EDX,    InDataSize
            sub     EDX,    EBX

    @@Done:

            mov     ESI,    [ErrorPos]
            mov     [ESI],  EDX

            pop     EDI
            pop     ESI
            pop     EDX
            pop     ECX
            pop     EBX
            pop     EAX

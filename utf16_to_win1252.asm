            push    EAX
            push    EBX
            push    ECX
            push    EDX
            push    ESI
            push    EDI

            jmp     @@Start

    @@Win1252Table:

            //     00     01     02     03     04     05     06     07     08     09     0A     0B     0C     0D     0E     0F
            dw         $0001, $0002, $0003, $0004, $0005, $0006, $0007, $0008, $0009, $000A, $000B, $000C, $000D, $000E, $000F  // 00
            dw  $0010, $0011, $0012, $0013, $0014, $0015, $0016, $0017, $0018, $0019, $001A, $001B, $001C, $001D, $001E, $001F  // 10
            dw  $0020, $0021, $0022, $0023, $0024, $0025, $0026, $0027, $0028, $0029, $002A, $002B, $002C, $002D, $002E, $002F  // 20
            dw  $0030, $0031, $0032, $0033, $0034, $0035, $0036, $0037, $0038, $0039, $003A, $003B, $003C, $003D, $003E, $003F  // 30
            dw  $0040, $0041, $0042, $0043, $0044, $0045, $0046, $0047, $0048, $0049, $004A, $004B, $004C, $004D, $004E, $004F  // 40
            dw  $0050, $0051, $0052, $0053, $0054, $0055, $0056, $0057, $0058, $0059, $005A, $005B, $005C, $005D, $005E, $005F  // 50
            dw  $0060, $0061, $0062, $0063, $0064, $0065, $0066, $0067, $0068, $0069, $006A, $006B, $006C, $006D, $006E, $006F  // 60
            dw  $0070, $0071, $0072, $0073, $0074, $0075, $0076, $0077, $0078, $0079, $007A, $007B, $007C, $007D, $007E, $007F  // 70
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

            mov     EDX,    ByteInverted

    @@CheckLength:

            // check if data length is EVEN

            shr     EBX,    1       // divide length by 2
            jc      @@Error         // division has remainder, finish program with error

    @@Loop:

            lodsw                   // load next word in AX
            dec     EBX             // decrement remaining word counter

            // invert byte-order if needed

            cmp     EDX,    0
            je      @@CheckChar

            rol     AX,     8       // invert AL x AH

    @@CheckChar:

            // test if word is a surrogate (D800-DFFF) (not supported here)

            mov     CX,     AX
            shr     CX,     11
            cmp     CX,     $001B   // AX = 11011xxxxxxxxxxx?
            je      @@Error         // yes, finish program with error

            // test if == FFFF

            cmp     AX,     $FFFF   // AX = FFFF
            je      @@Error         // yes, finish program with error

    @@Translate:

            // convert unicode code-point to WIN-1252

            push    EDI             // save EDI in stack

            lea     EDI,    CS:[OFFSET @@Win1252Table]
            mov     ECX,    256     // load table size in ECX

            repne   scasw           // search word AX in EDI (decrementing ECX)

            pop     EDI             // load EDI from stack

            cmp     ECX,    0       // caracter found?
            je      @@Error         // no, finish program with error

            mov     EAX,    256
            sub     EAX,    ECX     // EAX := 256 - ECX

    @@StoreChar:

            stosb                   // save byte in AL in out buffer
            jmp     @@LoopEnd

    @@LoopEnd:

            cmp     EBX,    0       // remaining word counter == 0 ?
            jne     @@Loop          // no, retorn to loop beginning
            jmp     @@FinishString  // yes, terminate program

    @@FinishString:

            mov     AL,     0
            stosb                   // finalize string with null

            xor     EDX,    EDX     // zero error flag
            jmp     @@Done

    @@Error:

            mov     EDX,    InDataSize
            shl     EBX,    1
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

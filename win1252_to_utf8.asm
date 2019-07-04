            push    EAX
            push    EBX
            push    ECX
            push    EDX
            push    ESI
            push    EDI

            jmp     @@Start

    @@Win1252Table:


            // posição = ISO8859-15, conteúdo = UNICODE
            // _0     _1     _2     _3     _4     _5     _6     _7     _8     _9     _A     _B     _C     _D     _E     _F
            dw $0000, $0001, $0002, $0003, $0004, $0005, $0006, $0007, $0008, $0009, $000A, $000B, $000C, $000D, $000E, $000F // 0_
            dw $0010, $0011, $0012, $0013, $0014, $0015, $0016, $0017, $0018, $0019, $001A, $001B, $001C, $001D, $001E, $001F // 1_
            dw $0020, $0021, $0022, $0023, $0024, $0025, $0026, $0027, $0028, $0029, $002A, $002B, $002C, $002D, $002E, $002F // 2_
            dw $0030, $0031, $0032, $0033, $0034, $0035, $0036, $0037, $0038, $0039, $003A, $003B, $003C, $003D, $003E, $003F // 3_
            dw $0040, $0041, $0042, $0043, $0044, $0045, $0046, $0047, $0048, $0049, $004A, $004B, $004C, $004D, $004E, $004F // 4_
            dw $0050, $0051, $0052, $0053, $0054, $0055, $0056, $0057, $0058, $0059, $005A, $005B, $005C, $005D, $005E, $005F // 5_
            dw $0060, $0061, $0062, $0063, $0064, $0065, $0066, $0067, $0068, $0069, $006A, $006B, $006C, $006D, $006E, $006F // 6_
            dw $0070, $0071, $0072, $0073, $0074, $0075, $0076, $0077, $0078, $0079, $007A, $007B, $007C, $007D, $007E, $007F // 7_
            dw $20AC, $0020, $201A, $0192, $201E, $2026, $2020, $2021, $02C6, $2030, $0160, $2039, $0152, $0020, $017D, $0020 // 8_
            dw $0020, $2018, $2019, $201C, $201D, $2022, $2013, $2014, $02DC, $2122, $0161, $203A, $0153, $0020, $017E, $0178 // 9_
            dw $00A0, $00A1, $00A2, $00A3, $00A4, $00A5, $00A6, $00A7, $00A8, $00A9, $00AA, $00AB, $00AC, $00AD, $00AE, $00AF // A_
            dw $00B0, $00B1, $00B2, $00B3, $00B4, $00B5, $00B6, $00B7, $00B8, $00B9, $00BA, $00BB, $00BC, $00BD, $00BE, $00BF // B_
            dw $00C0, $00C1, $00C2, $00C3, $00C4, $00C5, $00C6, $00C7, $00C8, $00C9, $00CA, $00CB, $00CC, $00CD, $00CE, $00CF // C_
            dw $00D0, $00D1, $00D2, $00D3, $00D4, $00D5, $00D6, $00D7, $00D8, $00D9, $00DA, $00DB, $00DC, $00DD, $00DE, $00DF // D_
            dw $00E0, $00E1, $00E2, $00E3, $00E4, $00E5, $00E6, $00E7, $00E8, $00E9, $00EA, $00EB, $00EC, $00ED, $00EE, $00EF // E_
            dw $00F0, $00F1, $00F2, $00F3, $00F4, $00F5, $00F6, $00F7, $00F8, $00F9, $00FA, $00FB, $00FC, $00FD, $00FE, $00FF // F_

    @@Start:

            cld
            mov     ESI,    InData                        // ESI = Source Index -> início da string original
            mov     EDI,    OutData                       // EDI = Destination Index -> início da string convertida
            mov     EBX,    InDataSize                    // EBX = tamanho da string original
            jz      @@FinishString                        // se EBX == 0, finalizar

    @@Loop:

            lodsb                                         // AL = próximo byte da string original
            dec     EBX                                   // decrementar contador de bytes restantes

            // testar se byte nulo

            cmp     AL,     0                             // AL == 0?
            je      @@Error                               // sim, terminar com erro

            // testar se byte ASCII 7BIT (<=127)

            cmp     AL,     $7F                           // AL <= CHR(127)?
            jbe     @@1ByteChar                           // sim, gravar caracter ASCII na string de resposta

    @@Translate:

            // converter caractere WIN-1252 para code-point unicode

            push    ESI                                   // guardar ESI no stack

            lea     ESI,    CS:[OFFSET @@Win1252Table]    // ESI = início da tabela
            and     EAX,    $000000FF                     // EAX = AL
            shl     EAX,    1                             // EAX = EAX * 2
            add     ESI,    EAX                           // ESI = posição do byte lido na tabela (ESI + EAX)

            lodsw                                         // carregar code point da tabela em AX

            pop     ESI                                   // recuperar ESI do stack

            cmp     AX,     $FFFF                         // AX == 0xFFFF?
            je      @@Error                               // sim, terminar programa com erro

            cmp     AX,     $007F                         // AX <= 0x007F (é ASCII)?
            jbe     @@1ByteChar                           // sim, montar caractere de 1 byte

            cmp     AX,     $07FF                         // AX <= 0x07FF?
            jbe     @@2ByteChar                           // sim, montar caractere de 2 bytes

            jmp     @@3ByteChar                           // AX > 0x07FF, montar caractere de 3 bytes

    @@1ByteChar:

            // code point <= ASCII, gravar byte

            stosb                                         // gravar byte em AL na string de retorno

            jmp     @@LoopEnd                             // pular para o fim do loop

    @@2ByteChar:

            // montar caractere de 2 bytes

            // 00000xxx xxxxxxxx => 110xxxxx	10xxxxxx
            // ***AH*** ***AL***

            mov     DX,     AX                            // DX = AX
            shl     DX,     2                             // DH=00000xxx DL=xxxxxxxx -> DH=000xxxxx DL=xxxxxx00

            // montar primeiro byte (110xxxxx)

            mov     AL,     $C0                           // 11000000
            or      AL,     DH                            // 11000000|000xxxxx -> 110xxxxx (1º byte)

            // montar segundo byte (10xxxxxx)

            mov     AH,     DL
            shr     AH,     2                             // xxxxxx00 -> 00xxxxxx
            or      AH,     $80                           // 10000000|00xxxxxx -> 10xxxxxx (2º byte)

            stosw                                         // gravar word em AX (AL||AH) na string de retorno

            jmp     @@LoopEnd                             // pular para o fim do loop

    @@3ByteChar:

            // montar caractere de 3 bytes

            // xxxxxxxx xxxxxxxx => 1110xxxx	10xxxxxx	10xxxxxx
            // ***AH*** ***AL***

            // montar primeiro byte (xxxx.... ........ = 1110xxxx)

            push    EAX                                   // salvar EAX no stack

            shr     AX,     12                            // AH=xxxx.... AL=........ -> AH=00000000 AL=0000xxxx
            or      AL,     $E0                           // AL = 0000xxxx|11100000 -> 1110xxxx (1º byte)

            stosb                                         // gravar byte em AL na string de retorno

            pop     EDX                                   // recuperar EDX do stack (EDX = EAX)

            // montar segundo byte (....xxxx xx...... = 10xxxxxx)

            shl     DX,     2                             // DH=....xxxx DL=xx...... -> DH=..xxxxxx DL=......00
            and     DH,     $3F                           // zerar os 2 primeiros bits de DH (..xxxxxx&00111111 = 00xxxxxx)

            mov     AL,     $80                           // AL = 10000000
            or      AL,     DH                            // AL = 10000000|00xxxxxx -> 10xxxxxx (2º byte)

            // montar terceiro byte (........ ..xxxxxx = 10xxxxxx)

            shr     DL,     2                             // DL = xxxxxx00 -> 00xxxxxx
            mov     AH,     $80                           // AH = 10000000
            or      AH,     DL                            // AH = 10000000|00xxxxxx -> 10xxxxxx (3º byte)

            stosw                                         // gravar word em AX (AL||AH) na string de retorno

    @@LoopEnd:

            // fim do loop, verificar se há mais caracteres

            cmp     EBX,    0                             // contador de bytes restantes == 0?
            jne     @@Loop                                // não, retornar ao início do loop

    @@FinishString:

            // finalizar string e encerrar processo

            xor     AL,     AL
            stosb                                         // finalizar string com nulo

            xor     EDX,    EDX                           // zerar indicador de erro
            jmp     @@Done                                // pular para a finalização

    @@Error:

            // colocar posição do erro em EDX

            mov     EDX,    InDataSize
            sub     EDX,    EBX

    @@Done:

            // finalização

            mov     ESI,    [ErrorPos]
            mov     [ESI],  EDX

            pop     EDI
            pop     ESI
            pop     EDX
            pop     ECX
            pop     EBX
            pop     EAX

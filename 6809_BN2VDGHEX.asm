;
; BN2HEX
;
; Convert binary value in A into two VDG hexadecimal characters.
;
; Returns:
;   A = high nibble character
;   B = low nibble character
;

BN2HEX:
        TFR     A,B             ; Save original byte

;
; Convert high nibble
;
        LSRA
        LSRA
        LSRA
        LSRA
        CMPA    #9
        BLS     HIGH_DEC

        SUBA    #9              ; 10-15 -> 1-6
        BRA     HIGH_DONE

HIGH_DEC:
        ADDA    #48             ; 0-9 -> '0'-'9'

HIGH_DONE:

;
; Convert low nibble
;
        ANDB    #$0F
        CMPB    #9
        BLS     LOW_DEC

        SUBB    #9              ; 10-15 -> 1-6
        RTS

LOW_DEC:
        ADDB    #48             ; 0-9 -> '0'-'9'
        RTS

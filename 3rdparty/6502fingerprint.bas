
 const font = hex

 rem **background color...
 COLUBK=$0
 scorecolor=$0f

 dim RESA    = a
 dim RESP    = b
 dim CRC2    = score+0
 dim CRC1    = score+1
 dim CRC0    = score+2

 asm
; ===== CONFIG (CRC-24/OPENPGP) =====
; Poly = 0x864CFB, Init = 0xB704CE, RefIn/RefOut = false, XorOut = 0
; We feed 8 bytes in this exact order:
;   1) Probe #1  (d=0,c=1,a=E5,m=B8): A′, NVZC
;   2) Probe #2  (d=0,c=1,a=36,m=6B): A′, NVZC
;   3) Probe #3  (d=1,c=0,a=F6,m=6B): A′, NVZC
;   4) Probe #4  (d=0,c=0,a=06,m=6B): A′, NVZC

    JSR RUN_ARR_FINGERPRINT
    JMP DONE_ARR_FINGERPRINT

; ===== ZERO PAGE SCRATCH =====
;RESA    = $00
;RESP    = $01
;CRC0    = $02
;CRC1    = $03
;CRC2    = $04
; ^-- already dim'ed in basic

; ===== SAVE_P: store NVZC(P') masked =====
SAVE_P
    PHP
    PLA
    AND #$C3
    STA RESP
    RTS

; ===== CRC-24/OPENPGP =====
CRC24_INIT
    LDA #$CE
    STA CRC0
    LDA #$04
    STA CRC1
    LDA #$B7
    STA CRC2
    RTS

CRC24_FEED
    EOR CRC2
    STA CRC2
    LDX #$08
CRC24_FEED_BIT
    LDA CRC2
    AND #$80
    BEQ CRC24_SHIFT_ONLY
    ASL CRC0
    ROL CRC1
    ROL CRC2
    LDA CRC0
    EOR #$FB
    STA CRC0
    LDA CRC1
    EOR #$4C
    STA CRC1
    LDA CRC2
    EOR #$86
    STA CRC2
    JMP CRC24_NEXT
CRC24_SHIFT_ONLY
    ASL CRC0
    ROL CRC1
    ROL CRC2
CRC24_NEXT
    DEX
    BNE CRC24_FEED_BIT
    RTS

; ===== PROBE #1 =====
PROBE1
    CLD
    SEC
    LDA #$E5
    .byte $6B
    .byte $B8
    STA RESA
    JSR SAVE_P
    RTS

; ===== PROBE #2 =====
PROBE2
    CLD
    SEC
    LDA #$36
    .byte $6B
    .byte $6B
    STA RESA
    JSR SAVE_P
    RTS

; ===== PROBE #3 =====
PROBE3
    SED
    CLC
    LDA #$F6
    .byte $6B
    .byte $6B
    STA RESA
    JSR SAVE_P
    RTS

; ===== PROBE #4 =====
PROBE4
    CLD
    CLC
    LDA #$06
    .byte $6B
    .byte $6B
    STA RESA
    JSR SAVE_P
    RTS

; ===== MAIN =====
RUN_ARR_FINGERPRINT
    JSR CRC24_INIT

    JSR PROBE1
    LDA RESA
    JSR CRC24_FEED
    LDA RESP
    JSR CRC24_FEED

    JSR PROBE2
    LDA RESA
    JSR CRC24_FEED
    LDA RESP
    JSR CRC24_FEED

    JSR PROBE3
    LDA RESA
    JSR CRC24_FEED
    LDA RESP
    JSR CRC24_FEED

    JSR PROBE4
    LDA RESA
    JSR CRC24_FEED
    LDA RESP
    JSR CRC24_FEED

    RTS
DONE_ARR_FINGERPRINT
end

main
  drawscreen
 goto main


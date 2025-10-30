; NB: SELF MODIFYING CODE !!!
.opt illegals
.org 0
loop:
d_val:
    CLD
c_val:
    CLC
lda_val:
    LDA #$00
arr_val:
    ARR #$00
    NOP
    NOP ; somehow print or record A' and P'
    NOP
    NOP
inc_a:
    INC lda_val+1
    BNE loop
inc_imm
    INC arr_val+1
    BNE loop
inc_d
    LDA d_val
    CMP #$D8
    BEQ set_d
clr_d:
    LDA #$D8
    STA d_val
inc_c:
    LDA c_val
    CMP #$18
    BEQ set_c
clr_c:
    LDA #$18
    STA $01
    JMP loop
set_c:
    LDA #$38
    STA c_val
    JMP loop
set_d:
    LDA #$F8
    STA d_val
    JMP loop

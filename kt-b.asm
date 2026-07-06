    PRAGMA autobranchlength
    ORG $400
screen
   	fcb	$01,$36,$83,$83,$c3,$c3,$c3,$68,$69,$6b,$7f,$61,$62,$63,$64,$80,$80,$80,$80,$80,$80,$80,$80,$64,$7d,$45,$4e,$54,$45,$52,$80,$80
	fcb	$01,$35,$83,$83,$c3,$c3,$c3,$6f,$6e,$6d,$6c,$7b,$7a,$79,$78,$80,$80,$80,$80,$80,$80,$80,$80,$63,$7d,$43,$4c,$45,$41,$52,$80,$80
	fcb	$01,$34,$83,$83,$c3,$c3,$c3,$77,$76,$75,$74,$73,$72,$71,$70,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
	fcb	$01,$33,$83,$83,$c3,$c3,$c3,$6a,$7e,$5f,$7c,$5e,$5a,$59,$58,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
	fcb	$01,$32,$83,$83,$c3,$c3,$c3,$57,$56,$55,$54,$53,$52,$51,$50,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
	fcb	$01,$31,$83,$83,$c3,$c3,$c3,$4f,$4e,$4d,$4c,$4b,$4a,$49,$48,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
	fcb	$01,$30,$83,$83,$c3,$c3,$c3,$47,$46,$45,$44,$43,$42,$41,$40,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
	fcb	$80,$80,$80,$80,$80,$80,$80,$c5,$c5,$c5,$c5,$c5,$c5,$c5,$c5,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
	fcb	$02,$37,$83,$83,$c3,$c3,$c3,$c7,$c5,$c5,$c5,$c5,$c5,$c5,$c5,$80,$80,$80,$80,$80,$80,$80,$80,$62,$7d,$42,$52,$45,$41,$4b,$80,$80
	fcb	$02,$36,$83,$83,$c3,$c3,$c3,$c3,$c7,$c5,$c5,$c5,$c5,$c5,$c5,$80,$80,$80,$80,$80,$80,$80,$80,$61,$7d,$41,$4c,$54,$80,$80,$80,$80
	fcb	$02,$35,$83,$83,$c3,$c3,$c3,$c3,$c3,$c7,$c5,$c5,$c5,$c5,$c5,$80,$80,$80,$80,$80,$80,$80,$80,$6a,$7d,$53,$50,$41,$43,$45,$80,$80
	fcb	$02,$34,$83,$83,$c3,$c3,$c3,$c3,$c3,$c3,$c7,$c5,$c5,$c5,$c5,$80,$80,$80,$80,$80,$80,$80,$80,$7c,$7d,$44,$4f,$57,$4e,$80,$80,$80
	fcb	$02,$33,$83,$83,$c3,$c3,$c3,$c3,$c3,$c3,$c3,$c7,$c5,$c5,$c5,$80,$80,$80,$80,$80,$80,$80,$80,$68,$7d,$53,$48,$49,$46,$54,$80,$80
	fcb	$02,$32,$83,$83,$c3,$c3,$c3,$c3,$c3,$c3,$c3,$c3,$c7,$c5,$c5,$80,$80,$80,$80,$80,$80,$80,$80,$69,$7d,$46,$72,$80,$80,$80,$80,$80
	fcb	$02,$31,$83,$83,$c3,$c3,$c3,$c3,$c3,$c3,$c3,$c3,$c3,$c7,$c5,$80,$80,$80,$80,$80,$80,$80,$80,$6b,$7d,$46,$71,$80,$80,$80,$80,$80
	fcb	$02,$30,$83,$83,$c3,$c3,$c3,$c3,$c3,$c3,$c3,$c3,$c3,$c3,$c7,$80,$80,$80,$80,$80,$80,$80,$80,$7f,$7d,$43,$54,$52,$4c,$80,$80,$80
 
    org $6000
outb rmb 1
ina rmb 1
input_count rmb 1

start
initialize
    clr $71         ; Force cold start on reset
    
    ; --- Configure Side A ($FF00/$FF01) as INPUT ---
    ldb $ff01       ; Get Control Register A
    andb #%11111011 ; Clear bit 2 to select DDR
    stb $ff01
    lda #%00000000  ; Set all pins on Side A to INPUT
    sta $ff00
    ldb $ff01
    orb #%00000100  ; Set bit 2 to select Data Register
    stb $ff01
    
    ; --- Configure Side B ($FF02/$FF03) as OUTPUT ---
    ldb $ff03       ; Get Control Register B
    andb #%11111011 ; Clear bit 2 to select DDR
    stb $ff03
    lda #%11111111  ; Set all pins on Side B to OUTPUT
    sta $ff02
    ldb $ff03
    orb #%00000100  ; Set bit 2 to select Data Register
    stb $ff03
    
mainloop
    lda #%01111111  ; Start by pulling row 7 low (or high, depending on your hardware)
    sta outb
    
subloop
    lda #32
    sta input_count

output_rows
input_cols
    lda outb
    sta $ff02       ; Output the row strobe to Side B
    
    ; Optional: If you experience ghosting, insert a few NOPs here 
    ; to let the lines settle before reading.
    
    lda $ff00       ; Read the column results from Side A
    sta ina
    
    ; --- Your Debug Display ---
#     lda ina
#     jsr BN2HEX
#     std $400
#     
#     lda outb
#     jsr BN2HEX
#     std $402

* draw side a
    lda ina
    ldx #pia0a_table
    ldb #7
    bsr update_traces

* draw side b
    lda outb
    ldx #pia0b_table
    ldb #8
    bsr update_traces
    
* handle matrix drawing
    lda ina
    ldb outb
    bsr update_matrix
    
* handle repeat    
    dec input_count
    bne output_rows

* handle a side shift   
    lda outb
    orcc #%00000001
    rora
    sta outb
    cmpa #$ff
    beq mainloop
    bra subloop
   
; highlite button text on screen
; Input: a = value
; saved: nothing
update_button_text
    ldx #1233
    pshs a
    lda #4
@loop
    lsr ,s
    bcs @skip
    ldb ,x
    andb #%10111111
    stb ,x
    ldb 1,x
    andb #%10111111
    stb 1,x
    ldb 2,x
    andb #%10111111
    stb 2,x
@skip
    leax -32,x
    deca
    bne @loop
    puls a,pc
    
; update invert on keyboard matrix
update_matrix
    ldx #1230
    bra @shift
@loop
    leax -1,x
@shift
    lsrb
    bcs @skip
    bsr dim_characters
@skip
    cmpx #1223
    bne @loop
    rts

; dim character on screen
; input: x = video address, a = binary value to show
; registers saved: b, x
dim_characters
    pshs a,b,x
    pshs a
    lda #7
@shift
    lsr ,s
    bcs @loop
    ldb ,x
    andb #%10111111
    stb ,x
@loop
    leax -32,x
    deca
    beq @done
    bra @shift
@done
    puls a
    puls a,b,x,pc
    
; update trace graphics
; input: a = binary value to show, b = trace count, x = table
; regesters saved: none
update_traces
    pshs b
    ldb #$ff
@again
    incb
    cmpb ,s
    beq @done
    lsra
    bcs @next
    bsr set_trace
    bra @again
@next
    bsr reset_trace
    bra @again
@done
    puls b,pc

    INCLUDE trace.asm
    
; Drawing tables: Start address, move right count, move up count
button_table
    fdb 1231
    fcb 3,1
    fdb 1199
    fcb 3,1
    fdb 1167
    fcb 3,1
    fdb 1135
    fcb 3,1
    
pia0a_table
    fdb 1220
    fcb 4,1
    fdb 1188
    fcb 4,1
    fdb 1156
    fcb 4,1
    fdb 1124
    fcb 4,1
    fdb 1092
    fcb 4,1
    fdb 1060
    fcb 4,1
    fdb 1028
    fcb 4,1
pia0b_table
    fdb 1508
    fcb 11,10
    fdb 1476
    fcb 10,9
    fdb 1444
    fcb 9,8
    fdb 1412
    fcb 8,7
    fdb 1380
    fcb 7,6
    fdb 1348
    fcb 6,5
    fdb 1316
    fcb 5,4
    fdb 1284
    fcb 4,3

matrix_table
    fdb 1230

#  INCLUDE "6809_BN2VDGHEX.asm"    
    end start
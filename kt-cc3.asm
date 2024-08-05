    PRAGMA autobranchlength
    ORG $400
screen
    fcb	$01,$36,$83,$83,$c3,$c3,$c3,$68,$69,$6b,$7f,$61,$62,$63,$64,$80,$80,$80,$80,$80,$80,$80,$80,$64,$7d,$45,$4e,$54,$45,$52,$80,$80
	fcb	$01,$35,$83,$83,$c3,$c3,$c3,$6f,$6e,$6d,$6c,$7b,$7a,$79,$78,$80,$80,$80,$80,$80,$80,$80,$80,$63,$7d,$43,$4c,$45,$41,$52,$80,$80
	fcb	$01,$34,$83,$83,$c3,$c3,$c3,$77,$76,$75,$74,$73,$72,$71,$70,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
	fcb	$01,$33,$83,$83,$c3,$c3,$c3,$6a,$7e,$5f,$7c,$5e,$5a,$59,$58,$c3,$c3,$4c,$42,$72,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
	fcb	$01,$32,$83,$83,$c3,$c3,$c3,$57,$56,$55,$54,$53,$52,$51,$50,$c3,$c3,$52,$42,$72,$80,$80,$80,$43,$43,$73,$80,$49,$4e,$54,$80,$80
	fcb	$01,$31,$83,$83,$c3,$c3,$c3,$4f,$4e,$4d,$4c,$4b,$4a,$49,$48,$c3,$c3,$4c,$42,$71,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
	fcb	$01,$30,$83,$83,$c3,$c3,$c3,$47,$46,$45,$44,$43,$42,$41,$40,$c3,$c3,$52,$42,$71,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
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
int_count fdb 0
ic_buffer rmb 10

sr_irq equ $fef7
sr_firq equ $fef4
sr_nmi equ $fefd
use_sr equ sr_firq

start
* setup keyboard interrupt
    clr $71 ; force cold start on reset
    orcc #$50 ; disable interrupts
    lda #%00000010 ; choose keyboard firq
    sta $ff93
    lda #$cc ; enable firq
    ora #%00010000
    sta $ff90
    ldx #firq_interrupt-(use_sr+3)
    stx use_sr+1
    andcc #$af ; enable interrupts

mainloop
    ; reset interrupt
    lda #$00
    sta $ff02
    ; convert interrupt count to ascii
    ldd int_count
    ldx #ic_buffer
    jsr BN2DEC
    ; write value to screen
    ldx #ic_buffer
    ldy #1239-32
    ldb ,x+
display_loop
    beq display_done
    lda ,x+
    sta ,y+
    decb
    bra display_loop
display_done
    bra mainloop

firq_interrupt
    pshs a,b,x,y,u
    orcc #$50 ; disable interrupts

test_joy
    lda #$ff
    sta $ff02
    nop
    lda $ff00
    ora #%11110000
    sta ina
    cmpa #$ff
    beq do_keyboard ; no joystick button, go see if any keys are down.
* clear side b traces
	lda #$ff
    ldx #pia0b_table
    ldb #8
    bsr update_traces
* draw joystick traces
    lda ina
    ldx #button_table
    ldb #4
    bsr update_traces
    lda ina
    bsr update_button_text
    lda ina
    ldx #pia0a_table
    ldb #7
    bsr update_traces
 	bra done

do_keyboard
    ; clear Joy traces
    lda #$ff
    ldx #button_table
    ldb #4
    bsr update_traces

    lda #%01111111
    sta outb
roll
    lda outb
    sta $ff02
    nop
    lda $ff00
    ora #%10000000
    sta ina
    cmpa #$ff
    bne draw_traces
    lda outb
    lsra
    ora #%10000000
    sta outb
    cmpa #$ff
    beq clear_traces
    bra roll
draw_traces
    ; draw side b
    lda outb
    ldx #pia0b_table
    ldb #8
    bsr update_traces
    ; draw side a
    lda ina
    ldx #pia0a_table
    ldb #7
    bsr update_traces
    ; handle matrix drawing
    lda ina
    ldb outb
    bsr update_matrix
    bra done
clear_traces
    ; draw side b
    lda #$ff
    ldx #pia0b_table
    ldb #8
    bsr update_traces
    ; draw side a
    lda #$ff
    ldx #pia0a_table
    ldb #7
    bsr update_traces
done
    inc int_count+1
    bne skip
    inc int_count
skip
    lda $ff93
    puls a,b,x,y,u
    rti

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
    INCLUDE 6809_BN2DEC.asm
    
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
    
    end start
; set/reset a trace
; input: b = trace number, x = trace table
; regesters saved: a, b, x
set_trace
    pshs a,b,x
    aslb
    aslb
    abx
    ldy ,x++
    ldb ,x+
@repeat1
    decb
    beq @next
    lda ,y
    ora  #%00110000
    anda #%10111111
    sta ,y
    leay 1,y
    bra @repeat1
@next
    ldb ,x
@repeat2
    decb
    beq @done
    lda ,y
    ora  #%00110000
    anda #%10111111
    sta ,y
    leay -32,y
    bra @repeat2
@done
    puls a,b,x,pc

reset_trace
    pshs a,b,x
    aslb
    aslb
    abx
    ldy ,x++
    ldb ,x+
@repeat1
    decb
    beq @next
    lda ,y
    ora  #%01000000
    anda #%11001111
    sta ,y
    leay 1,y
    bra @repeat1
@next
    ldb ,x
@repeat2
    decb
    beq @done
    lda ,y
    ora  #%01000000
    anda #%11001111
    sta ,y
    leay -32,y
    bra @repeat2
@done
    puls a,b,x,pc

//=====================================
// Super GameBoy BIOS Patches
//
// Code patches provided by the official
// SGB SDK.  These patches are only
// required on earlier BIOS revisions,
// later revisions include them in
// the BIOS ROM.
//
// See Game Boy Programming Manual v1.1
// page 186
//=====================================
function CmdPatchInit {
DATA_SND_CODE_START()
    DATA_SND($0810, $00, $0B)
    jmp $0820
    nop; nop; nop; nop; nop
    rts
    nop; nop

    DATA_SND($081B, $00, $0B)
    nop; nop; nop; nop; nop
    // --$0820--
    lda.b #$01
    cmp.w $0C4F
    db $D0  // bne $0860

    DATA_SND($0826, $00, $0B)
    db $39  // bne $0860
    cmp.w $0C48
    bne $0860
    lda.b $C9
    cmp.b #$80
    db $D0  // bne $083E

    DATA_SND($0831, $00, $0B)
    db $0C  // bne $083E
    lda.b $CA
    cmp.b #$7E
    bne $083E
    lda.b $CB
    cmp.b #$7E

    DATA_SND($083C, $00, $0B)
    beq $0850
    // --$083E--
    lda.b $C9
    cmp.b #$C8
    bne $0860
    lda.b $CA
    db $C9  //cmp.b #$C4

    DATA_SND($0847, $00, $0B)
    db $C4  //cmp.b #$C4
    bne $0860
    lda.b $CB
    cmp.b #$05
    bne $0860
    // --$0850--
    ldx.b #$28

    DATA_SND($0852, $00, $0B)
    lda.b #$E7
    // --$0854--
    sta $7EC001,x
    inx; inx; inx; inx
    db $E0  // cpx.b #$8C

    DATA_SND($085D, $00, $0B)
    db $8C  // cpx.b #$8C
    bne $0854
    // --$0860--
    rts
    fill $07,$00
DATA_SND_CODE_END()
}

function CmdPatchSoundTrn {
DATA_SND_CODE_START()
    DATA_SND($0900, $00, $0B)
    lda.w $02C2
    cmp.b #$09
    bne $0921
    lda.b #$01
    db $8D,$00  // sta.w $4200

    DATA_SND($090B, $00, $0B)
    db $42      // sta.w $4200
    lda.l $00FFDB
    beq $0917
    jsr $C573
    db $08  // bra $091A

    DATA_SND($0916, $00, $0B)
    db $03  // bra $091A
    // --0917--
    jsr $C576
    // --$091A--
    lda.b #$31
    sta.w $4200
    pla
    pla

    DATA_SND($0921, $00, $0B)
    // --$0921--
    rts
    fill $0A,$00

    DATA_SND($0800, $00, $03)
    jmp $0900
    fill $08,$00
DATA_SND_CODE_END()
}

fill $10,$00

architecture sm83
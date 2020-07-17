macro CHECKSUM(sum) {
origin $00014E
    endian msb
    dw      {sum}
    endian lsb
}

variable _currentBank = 1

macro ROMBANK(bank) {
    if pc() > $8000 {
        evaluate oldBank = _currentBank
        evaluate offset = origin()
        error "Bank {oldBank} overrun at file offset {offset}"
    }
    _currentBank = {bank}
    origin {bank} << 14
    base $4000
}

macro FARCALL_NOSAVE(variable TargetBank, variable Target, variable ReturnBank) {
    ld      hl,wFarcallParams
    ld      a,TargetBank
    ld      (hl+),a
    ld      a,Target>>8
    ld      (hl+),a
    ld      a,Target
    ld      (hl+),a
    ld      a,ReturnBank
    ld      (hl),a
    call    Farcall
}

macro FARCALL(variable TargetBank, variable Target, variable ReturnBank) {
    push    af
    push    bc
    push    de
    push    hl
    FARCALL_NOSAVE(TargetBank, Target, ReturnBank)
    pop     hl
    pop     de
    pop     bc
    pop     af
}
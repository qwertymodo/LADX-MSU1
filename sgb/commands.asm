//=====================================
// Super GameBoy Utility Macros
//=====================================

// ===[SGB System Command Codes]===
namespace CMD_CODE {
    constant PAL01      = $00
    constant PAL23      = $01
    constant PAL03      = $02
    constant PAL12      = $03
    constant ATTR_BLK   = $04
    constant ATTR_LIN   = $05
    constant ATTR_DIV   = $06
    constant ATTR_CHR   = $07
    constant SOUND      = $08
    constant SOU_TRN    = $09
    constant PAL_SET    = $0A
    constant PAL_TRN    = $0B
    constant ATRC_EN    = $0C
    constant ICON_EN    = $0E
    constant DATA_SND   = $0F
    constant DATA_TRN   = $10
    constant MLT_REQ    = $11
    constant JUMP       = $12
    constant CHR_TRN    = $13
    constant PCT_TRN    = $14
    constant ATTR_TRN   = $15
    constant ATTR_SET   = $16
    constant MASK_EN    = $17
    constant PAL_PRI    = $19
}

// ===[MASK_EN Command Options]===
namespace MASK {
    constant CANCEL     = %00
    constant FREEZE     = %01
    constant BLACK      = %10
    constant COLOR0     = %11
}

// ===[SGB System Command Macros]===
macro SYS_CMD(cmd, len) {
    db ({cmd} << $03) | ({len} & $07)
}

macro PAL01() {
    SYS_CMD(CMD_CODE.PAL01, 1)
}

macro PAL23() {
    SYS_CMD(CMD_CODE.PAL23, 1)
}

macro PAL03() {
    SYS_CMD(CMD_CODE.PAL03, 1)
}

macro PAL12() {
    SYS_CMD(CMD_CODE.PAL12, 1)
}

macro BGR555(rgb888) {
    define r = ({rgb888} >> 16) & $FF
    define g = ({rgb888} >> 8) & $FF
    define b = {rgb888} & $FF

    evaluate r = {r} + (({r} & $04) << 1)
    evaluate g = {g} + (({g} & $04) << 1)
    evaluate b = {b} + (({b} & $04) << 1)

    dw ({b} << 7) | ({g} << 2) | ({r} >> 3)
}

macro DATA_SND(addr, bank, len) {
    SYS_CMD(CMD_CODE.DATA_SND, 1)
    dw {addr}
    db {bank}
    db {len}
    if {defined DATA_SND_CODE} {
        base {addr}
    }
}

//=========================================================
// Only use these START and END macros within a scoped
// function containing SNES code instructions
//=========================================================
inline DATA_SND_CODE_START() {
    enqueue base
    architecture wdc65816
    define DATA_SND_CODE
}

inline DATA_SND_CODE_END() {
    dequeue base
    architecture sm83
}

macro MLT_REQ(players) {
    SYS_CMD(CMD_CODE.MLT_REQ, 1)
    if {players} == 1 {
        db %00
    } else if {players} == 2 {
        db %01
    } else if {players} == 4 {
        db %11
    } else {
        error("Invalid number of players")
    }
    fill $0E,$00
}

macro JUMP(address, nmi) {
    SYS_CMD(CMD_CODE.JUMP, 1)
    dw {address}
    db {address}>>16
    dw {nmi}
    db {nmi}>>16
    fill $09,$00
}

macro CHR_TRN(bank) {
    SYS_CMD(CMD_CODE.CHR_TRN, 1)
if {defined USE_EXPANDED_BORDER} {
    if {bank} > 5 {
        error "Invalid tile bank"
    }
    db {bank}
} else {
    db {bank} & $01
}
    fill $0E,$00
}

macro PCT_TRN() {
    SYS_CMD(CMD_CODE.PCT_TRN, 1)
    fill $0F,$00
}

macro MASK_EN(option) {
    SYS_CMD(CMD_CODE.MASK_EN, 1)
    db {option} & $03
    fill $0E,$00
}

macro PAL_PRI(option) {
    SYS_CMD(CMD_CODE.PAL_PRI, 1)
    db {option} & $01
    fill $0E,$00
}

//=====================================
// Super GameBoy Command Definitions
//=====================================
if !{defined USE_EXISTING_SGB_SDK} {

// Align to $10 byte boundary
while ((pc() & $0F) > 0) {
    db $0
}

CmdSetScreenMaskBlack:
    MASK_EN(MASK.BLACK)

CmdCancelScreenMask:
    MASK_EN(MASK.CANCEL)

CmdVRAMTransferTilesLo:
    CHR_TRN(0)

CmdVRAMTransferTilesHi:
    CHR_TRN(1)

CmdVRAMTransferMetadata:
    PCT_TRN()

CmdForceApplicationPalette:
    PAL_PRI(1)

CmdRequestOnePlayer:
    MLT_REQ(1)

CmdRequestTwoPlayers:
    MLT_REQ(2)

CmdRequestFourPlayers:
    MLT_REQ(4)

if !{defined USE_CUSTOM_PALETTE} {
CmdSetCustomPalette:
PAL01()
// Palette 0
BGR555($F8F0B0)
BGR555($78C078)
BGR555($688840)
BGR555($583820)
//Palette 1
BGR555($78C078)
BGR555($688840)
BGR555($583820)
db $00
} // if !{defined USE_CUSTOM_PALETTE}

include "patches.asm"

if {defined USE_EXPANDED_BORDER} {
CmdVRAMTransferTilesExpLo:
    CHR_TRN(2)

CmdVRAMTransferTilesExpHi:
    CHR_TRN(3)

function CmdUploadExpandedBorder {
DATA_SND_CODE_START()
    DATA_SND($1800, $00, $0B)
    lda $4210
    lda.b #$B1; sta $4200
    cli
    wai
    rts

    DATA_SND($180B, $00, $0B)
    sei
    lda $4210
    lda.b #$31; sta $4200       // Disable NMI
    lda.b #$80
    
    DATA_SND($1816, $00, $0B)
    sta $2100; sta $2115
    lda.b #$01
    sta $4360

    DATA_SND($1821, $00, $0B)
    rep #$20
        lda.w #$B50B; sta $00BB // Reset default NMI vector
        lda.w #$1000
        
    DATA_SND($182C, $00, $0B)
        sta $4365               // Transfer size
        lda.w #$0000
        ldx $0212
        beq +

    DATA_SND($1837, $00, $0B)
        -;  clc
            adc #$0800
            dex
            bne -
    +;  sta $2116               // VRAM destination
        clc

    DATA_SND($1842, $00, $0A)
        asl
        and.w #$1000
        adc.w #$8000
        sta $4362               // Transfer source

    fill $01,$00
    DATA_SND($184C, $00, $09)
    sep #$20
    lda.b #$7E; sta $4364       // Transfer source bank
    lda.b #$FE

    fill $02,$00
    DATA_SND($1855, $00, $0A)
    trb $0212
    lda.b #$18; sta $4361
    lda.b #$40
    
    fill $01,$00
    DATA_SND($185F, $00, $0B)
    sta $420B
    lda.b #$0F
    sta $2100
    lda $4211

    DATA_SND($186A, $00, $02)
    cli
    rti
DATA_SND_CODE_END()
Jump:
JUMP($1800, $180B)
}
} // if {defined USE_EXPANDED_BORDER}
} // if !{defined USE_EXISTING_SGB_SDK}

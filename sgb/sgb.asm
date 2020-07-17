namespace SGB {

if !{defined USE_EXISTING_SGB_SDK} {

macro SEND_UPLOAD_COMMAND(address) {
    ld      hl,{address}
    call    SendUploadCommand
}

macro WAIT_FOR_N_FRAMES(frames) {
    ld      bc,({frames} & $FFFF)
    call    WaitForBCFrames
}

//=====================================
// Detect and initialize the SGB
//=====================================
function Init {
    // Wait for 30 frames
    WAIT_FOR_N_FRAMES($1E)

    // Detect the SGB by whether or not it
    // responds to multiplayer requests
    SEND_UPLOAD_COMMAND(CmdRequestTwoPlayers)
    call    WaitFor60ms
    ldh     a,($00) // P1
    and     $03     // J_RIGHT | J_LEFT
    cp      $03
    jr      nz,sgbFound
    ld      a,$20
    ldh     ($00),a
    ldh     a,($00)
    ldh     a,($00)
    ld      a,$30
    ldh     ($00),a
    ld      a,$10
    ldh     ($00),a
    ldh     a,($00)
    ldh     a,($00)
    ldh     a,($00)
    ldh     a,($00)
    ldh     a,($00)
    ldh     a,($00)
    ld      a,$30
    ldh     ($00),a
    ldh     a,($00)
    ldh     a,($00)
    ldh     a,($00)
    ldh     a,($00)
    and     $03
    cp      $03
    jr      nz,sgbFound

sgbNotFound:
    SEND_UPLOAD_COMMAND(CmdRequestOnePlayer)
    call    WaitFor60ms
    sub     a
    ret

sgbFound:
    // SGB detected, return to single-player mode
    SEND_UPLOAD_COMMAND(CmdRequestOnePlayer)
    call    WaitFor60ms

    // Set the display to black
    SEND_UPLOAD_COMMAND(CmdSetScreenMaskBlack)
    WAIT_FOR_N_FRAMES($06)
    // Give priority to the ROM-defined color palette
if {defined USE_CUSTOM_PALETTE} {
    SEND_UPLOAD_COMMAND(CmdForceApplicationPalette)
    WAIT_FOR_N_FRAMES($06)
}

    // Upload official SGB BIOS patches to SNES WRAM
    SEND_UPLOAD_COMMAND(CmdPatchInit+$70)
    WAIT_FOR_N_FRAMES($06)
    SEND_UPLOAD_COMMAND(CmdPatchInit+$60)
    WAIT_FOR_N_FRAMES($06)
    SEND_UPLOAD_COMMAND(CmdPatchInit+$50)
    WAIT_FOR_N_FRAMES($06)
    SEND_UPLOAD_COMMAND(CmdPatchInit+$40)
    WAIT_FOR_N_FRAMES($06)
    SEND_UPLOAD_COMMAND(CmdPatchInit+$30)
    WAIT_FOR_N_FRAMES($06)
    SEND_UPLOAD_COMMAND(CmdPatchInit+$20)
    WAIT_FOR_N_FRAMES($06)
    SEND_UPLOAD_COMMAND(CmdPatchInit+$10)
    WAIT_FOR_N_FRAMES($06)
    SEND_UPLOAD_COMMAND(CmdPatchInit)
    WAIT_FOR_N_FRAMES($06)

    SEND_UPLOAD_COMMAND(CmdPatchSoundTrn)
    WAIT_FOR_N_FRAMES($06)
    SEND_UPLOAD_COMMAND(CmdPatchSoundTrn+$10)
    WAIT_FOR_N_FRAMES($06)
    SEND_UPLOAD_COMMAND(CmdPatchSoundTrn+$20)
    WAIT_FOR_N_FRAMES($06)
    SEND_UPLOAD_COMMAND(CmdPatchSoundTrn+$30)
    WAIT_FOR_N_FRAMES($06)
    SEND_UPLOAD_COMMAND(CmdPatchSoundTrn+$40)
    WAIT_FOR_N_FRAMES($06)

    // Upload the application palette
    SEND_UPLOAD_COMMAND(CmdSetCustomPalette)
    WAIT_FOR_N_FRAMES($06)

if {defined USE_CUSTOM_BORDER} {

if {defined USE_EXPANDED_BORDER} {
    SEND_UPLOAD_COMMAND(CmdUploadExpandedBorder)
    WAIT_FOR_N_FRAMES($06)
    SEND_UPLOAD_COMMAND(CmdUploadExpandedBorder+$10)
    WAIT_FOR_N_FRAMES($06)
    SEND_UPLOAD_COMMAND(CmdUploadExpandedBorder+$20)
    WAIT_FOR_N_FRAMES($06)
    SEND_UPLOAD_COMMAND(CmdUploadExpandedBorder+$30)
    WAIT_FOR_N_FRAMES($06)
    SEND_UPLOAD_COMMAND(CmdUploadExpandedBorder+$40)
    WAIT_FOR_N_FRAMES($06)
    SEND_UPLOAD_COMMAND(CmdUploadExpandedBorder+$50)
    WAIT_FOR_N_FRAMES($06)
    SEND_UPLOAD_COMMAND(CmdUploadExpandedBorder+$60)
    WAIT_FOR_N_FRAMES($06)
    SEND_UPLOAD_COMMAND(CmdUploadExpandedBorder+$70)
    WAIT_FOR_N_FRAMES($06)
    SEND_UPLOAD_COMMAND(CmdUploadExpandedBorder+$80)
    WAIT_FOR_N_FRAMES($06)
    SEND_UPLOAD_COMMAND(CmdUploadExpandedBorder+$90)
    WAIT_FOR_N_FRAMES($06)
    SEND_UPLOAD_COMMAND(CmdUploadExpandedBorder+$A0)
    WAIT_FOR_N_FRAMES($06)

if {defined USE_CUSTOM_SGB_CODE} {
    ld      hl,UserCommandPayload
-;  call    SendUploadCommand
        WAIT_FOR_N_FRAMES($06)
        ld      a,(hl)
        and     a
        jr      nz,-
}

    // Upload the first part of the expanded frame tiles data
    ld      hl,SGBFrameTiles2
    ld      de,CmdVRAMTransferTilesExpLo
    call    SendVRAMData

    SEND_UPLOAD_COMMAND(CmdUploadExpandedBorder.Jump)
    WAIT_FOR_N_FRAMES($06)

    // Upload the second part of the expanded frame tiles data
    //ld      hl,SGBFrameTiles3
    //ld      de,CmdVRAMTransferTilesExpHi
    //call    SendVRAMData

    //SEND_UPLOAD_COMMAND(CmdUploadExpandedBorder.Jump)
    //WAIT_FOR_N_FRAMES($06)
}
    // Upload the first part of the frame tiles data
    ld      hl,SGBFrameTiles0
    ld      de,CmdVRAMTransferTilesLo
    call    SendVRAMData

    // Upload the second part of the frame tiles data
    ld      hl,SGBFrameTiles1
    ld      de,CmdVRAMTransferTilesHi
    call    SendVRAMData

    // Upload frame tilemap and palettes
    ld      hl,SGBFrameMetadata
    ld      de,CmdVRAMTransferMetadata
    call    SendVRAMData

    // Clear VRAM after transfer
    ld      hl,$8000
    ld      bc,$2000
-;  xor     a       // for (bc = $2000; bc > 0; bc--)
        ld      (hl+),a // *(ptr++) = 0
        dec     bc
        ld      a,b
        or      c
        jr      nz,-
}

    ld      a,$81
    ldh     ($40),a     // Enable LCDC interrupt
    WAIT_FOR_N_FRAMES($06)

    SEND_UPLOAD_COMMAND(CmdCancelScreenMask)
    WAIT_FOR_N_FRAMES($06)

    xor     a
    ldh     ($40),a     // Disable LCDC interrupt
    ret
}

//=====================================
// Send SGB system command
//
// Input: HL - Address of the start of
//             the packet
//=====================================
function SendUploadCommand {
    ld      a,(hl)      // first byte is (command_id << $03) + (packet_count & $07)
    and     $07
    ret     z           // if packet_count is 0, transfer is complete
    ld      b,a         // b = packet_count
    ld      c,$00
start:
    push    bc
        xor     a       // reset pulse low
        ld      (c),a
        ld      a,$30   // reset pulse high
        ld      (c),a
        ld      b,$10   // for (b = $10; b > 0; b--)    ; $10 bytes
    -;  ld      e,$08   // for (e = $08; e > 0; e--)    ; $08 bits
            ld      a,(hl+)
            ld      d,a         // d = *(ptr++)
        -;  bit     0,d         // check LSB of d
                ld      a,$10   // $10: transmit '1' bit
                jr      nz,+    // $20: transmit '0' bit
                    ld      a,$20
            +;  ld      (c),a
                ld      a,$30
                ld      (c),a
                rr      d       // d >>= 1
                dec     e
                jr      nz,-
            dec     b
            jr      nz,--
        ld      a,$20           // stop bit '0'
        ld      (c),a
        ld      a,$30
        ld      (c),a
        pop     bc              // b = packet_count
        dec     b               // packet_count--
        ret     z               // if packet_count is 0, this was the last packet
        call    WaitFor60ms     // wait 60ms for the transmission to complete
        jr      start           // start transmitting the next packet
}

//=====================================
// Busy wait loop (~60ms)
//=====================================
function WaitFor60ms {
    ld      de,$1B58
-;  nop; nop; nop
        dec     de
        ld      a,d
        or      e
        jr      nz,-
    ret
}

//=====================================
// Busy wait loop
//
// Input: BC - Number of frames to wait
//=====================================
function WaitForBCFrames {
-;  push    de
        ld      de,$06D6    // for (de = $06D6; de > 0; de--)
    -;  nop
            nop
            nop
            dec     de
            ld      a,d
            or      e
            jr      nz,-
    pop     de
    dec     bc
    ld      a,b
    or      c
    jr      nz,--
    ret
}

//=====================================
// Copy data to SGB via VRAM transfer
//
// Input: HL - Source data address
//        DE - Address of SGB SYS_CMD
//
// Modifies: A, BC, DE, HL
//=====================================
function SendVRAMData {
    push    de
        ld      a,%11100100
        ldh     ($47),a     // BG Palette Data
        ld      de, $8800   // CopyData destination address
        ld      bc, $1000   // CopyData size
        call    CopyData

        ld      hl,$9800
        ld      de,$000C
        ld      a,$80
        ld      c,$0D       // for (c = $0D; c > 0; c--)
    -;  ld      b,$14       // for (b = $14; b > 0; b--)
        -;  ld      (hl+),a     // *(ptr++) == a++
                inc     a
                dec     b
                jr      nz,-
            add     hl,de   // ptr += $0C
            dec     c
            jr      nz,--

        ld      a,$81
        ldh     ($40),a     // Enable LCDC interrupt
        WAIT_FOR_N_FRAMES($05)
    pop     hl              // SGB SYS_CMD address originally stored in DE
    call    SendUploadCommand
    WAIT_FOR_N_FRAMES($06)

    xor     a
    ldh     ($40),a         // Disable LCDC interrupt
    ret
}

//=====================================
// Copy data
//
// Input: BC - Number of bytes to copy
//        DE - Destination address
//        HL - Source address
//=====================================
function CopyData {
-;  ld      a,(hl+)
        ld      (de),a
        inc     de
        dec     bc
        ld      a,b
        or      c
        jr      nz,-
    ret
}

}   // if !{defined USE_EXISTING_SGB_SDK}

include "commands.asm"

if {defined USE_CUSTOM_PALETTE} {
    define USE_CUSTOM_PALETTE
CmdSetCustomPalette:
    PAL01()
    include "sgb_user_palette.asm"

    if pc()-CmdSetCustomPalette > $10 {
        error "Custom palette too large"
    } else {
        // Add the final padding byte, if it was omitted
        fill $10-(pc()-CmdSetCustomPalette),$00
    }
}   // if {defined USE_CUSTOM_PALETTE}

if {defined USE_CUSTOM_SGB_CODE} {
UserCommandPayload:
    include "sgb_user_commands.asm"
    fill $10,$00
}   // if {defined USE_CUSTOM_SGB_CODE}

if {defined USE_CUSTOM_BORDER} {
    include "sgb_user_frame.asm"
}   // if {defined USE_CUSTOM_BORDER}

}   // namespace SGB
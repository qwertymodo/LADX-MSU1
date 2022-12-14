//===Track list:===
// 01: Title Screen
// 02: Trendy Game!
// 03: Game Over
// 04: Mabe Village
// 05: Overworld
// 06: Tal Tal Heights
// 07: Shop
// 08: Raft Ride
// 09: Mysterious Forest
// 10: Inside the Houses
// 11: Animal Village
// 12: Fairy Fountain
// 13: Title Screen (No Intro)
// 14: The Moblins Took BowWow!
// 15: Your Sword
// 16: Item Catch
// 17: Player Select
// 18: Wind Fish's Egg
// 19: Kanalet Castle
// 20: Level 1: Tail Cave
// 21: Level 2: Bottle Grotto
// 22: Level 3: Key Cavern
// 23: Level 4: Angler's Tunnel
// 24: Instrument of the Sirens
// 25: Boss Battle
// 26: The Storm/Opening
// 27: Holding the Instrument
// 28: Link's Awake
// 29: Sword Search
// 30: Dreaming in the Bed
// 31: Southern Shrine
// 32: Full Moon Cello
// 33: Dungeon Basement
// 34: The Wise Owl
// 35: Final Boss
// 36: Dream Shrine Upper Level
// 37: Big Heart Container
// 38: Cave
// 39: Guardian Acorn/Piece of Power
// 40: Conch Horn
// 41: Sea Lily's Bell
// 42: Surf Harp
// 43: Wind Marimba
// 44: Coral Triangle
// 45: Organ of Evening Calm
// 46: Thunder Drum
// 47: Marin Sings the Ballad of the Wind Fish
// 48: Manbo's Mambo
// 49: Let the Journey Begin!
// 50: Mr. Write's House
// 51: Telephone Booth
// 52: Tarin is Being Chased by Bees!
// 53: The Frog's Song of Soul
// 54: Monkeys Build a Bridge
// 55: Christine's House
// 56: Totaka's Song (Unused?)
// 57: The Turtle Awakens!
// 58: Fishing Under the Bridge
// 59: Unknown Short SFX
// 60: Player Select - TOTAKA
// 61: Ending/Staff Credits
// 62: The Moblins' Hideout
// 63: Song of Awakening
// 64: Richard's Villa
// 65: Ballad of the Wind Fish (1-2 Instruments)
// 66: Ballad of the Wind Fish (3 Instruments)
// 67: Ballad of the Wind Fish (4 Instruments)
// 68: Ballad of the Wind Fish (5 Instruments)
// 69: Ballad of the Wind Fish (6 Instruments)
// 70: Ballad of the Wind Fish (7 Instruments)
// 71: Ballad of the Wind Fish (8 Instruments)
// 72: The Ghost's House
// 73: Guardian Acorn/Piece of Power (No Fanfare)
// 74: Link and Marin's Song
// 75: Level 5: Catfish's Maw
// 76: Angler's Tunnel Revealed
// 77: Found Marin
// 78: Link and Marin Talk
// 79: Unknown Short Jingle
// 80: Miniboss Battle
// 81: Kanalet Castle (Unused?)
// 82: Level 1: Tail Cave (Unused?)
// 83: Dream Shrine Lower Level
// 84: Evil Eagle Battle
// 85: Rooster Resurrection
// 86: Seashell Mansion - Get Sword 
// 87: Cucco House
// 88: Level 6: Face Shrine
// 89: The Wind Fish
// 90: Level 8: Turtle Rock
// 91: Level 7: Eagle's Tower
// 92: Evil Eagle Battle (Unused?)
// 93: Final Battle
// 94: Boss Warning
// 95: Final Boss Defeated
// 96: Player Select - ZELDA
// 97: Color Dungeon
//
// ---Alternate/Expanded Tracks---
// 98: Player Select - MARIN
// 99: The Wise Owl - Final Message
// 100: Fishing Pond
// 101: Tal Tal Heights (After Rescue)
// 102: Seashell Mansion
// 103: Li'l Devil
// 104: Song for the Sleeping Walrus
// 105: Got Marin! (Overworld w/Marin + intro)
// 106: Overworld (w/Marin, no intro)
// 107: Mysterious Forest (w/Marin)
// 108: Tal Tal Heights (w/Marin)
// 109: Final Boss Battle

architecture gb-cpu

if {defined input} {
    origin 0
    insert "{input}"
    origin 0
} else {
    error "No input file specified"
}

include "macros.inc"
include "constants.inc"

origin 3
//    db 1    // Set debug flag 1

origin 4
//    db 1    // Set debug flag 2

origin 5
//    db 1    // Set debug flag 3

origin Offset_Farcall
Farcall:

origin Offset_CheckEntityCountdownTimer
CheckEntityCountdownTimer:

origin Offset_CopyData
CopyData:

origin Offset_IncrementEntityState
IncrementEntityState:

origin 0
base wSGBCommandBuffer
namespace CommandBuffer {
origin 0
SGBCommand:

origin 1
DestinationAddress:

origin 4
TransferSize:

origin 5
IdleFlag:

origin 6
TrackNumber:

origin 7
MSUCommand:

origin 8
SetSettings:

origin 9
ClearSettings:

origin 10
TargetVolume:

origin 11
CurrentVolume:

origin 12
FadeRate:

origin 13
Settings:

origin 14
CurrentTrack:

origin 15
PreviousTrack:
}

origin 0
base 0

//-------------------------------------------------------------------
ROMBANK($01)

origin Offset_DebugSaveData
fill $43,$00
origin Offset_DebugSaveData

function SetVolume {
half:
    ld      a,$30
    jr      set
full:
    ld      a,$70
set:
    ld      ($FFAA),a
    FARCALL($3C, PlaySong, $01)
    ret
}

function TheEndSave {
    call CommitSaveData
    ret
}

origin Offset_InitDebugSave
    FARCALL_NOSAVE($3C, InitDebugSave, $01)
    nop; nop

origin Offset_Hook_CheckFilenames
if REGION == ROM_REGION_US {
    FARCALL_NOSAVE($3C, CheckFilenames, $01)
    nop
    db      $18         // jr nz -> jr
}

origin Offset_Hook_SetVolume_Half
    call    SetVolume.half
    nop

origin Offset_Hook_SetVolume_Full
    call    SetVolume.full
    nop

origin Offset_CommitSaveData
CommitSaveData:

//-------------------------------------------------------------------
ROMBANK($02)
origin Offset_Hook_CheckNewGameSong
    call CheckShieldLevel

origin Offset_FreeSpace_Bank02
function CheckShieldLevel {
    ld      a,(wShieldLevel)
    and     a
    jp      nz,+
    ld      d,$00
+;  ld      a,(wSwordLevel)
    ret
}

//-------------------------------------------------------------------
ROMBANK($16)
origin Offset_FlyingBookEntity
if {DISABLE_COLOR_DUNGEON} == 1 {
    // Delete flying book entity from library
    db      $FF, $FF
}

//-------------------------------------------------------------------
ROMBANK($17)
origin Offset_Hook_TheEndSave
    jp      CallTheEndSave

origin Offset_FreeSpace_Bank17
function CallTheEndSave {
    FARCALL_NESTED($01, TheEndSave, $17)
    insert "{input}", Offset_Hook_TheEndSave, $03
}

//-------------------------------------------------------------------
ROMBANK($18)

// $18:4F37 MadBatterEntityHandler.state2
//origin Offset_Hook_LilDevil_Start
//    jp      PlayLilDevilTrack

// $18:507D MadBatterEntityHandler.state8
origin Offset_Hook_LilDevil_Stop
    jp      PlayLilDevilTrack.stop

// $18:55BC WalrusEntityHandler.state1
origin Offset_WalrusTrack
    db      $68     // Track $68: Song for the Sleeping Walrus

origin Offset_DeactivateCurrentEnity_18
DeactivateCurrentEnity_18:

origin Offset_FreeSpace_Bank18
function PlayLilDevilTrack {
    // ld      a,$67   // Track $67: Li'l Devil
    // ld      (wRequestedMusicTrack),a
    // jp      IncrementEntityState
stop:
    ld      a,$26   // Track $26: Cave
    ld      (wRequestedMusicTrack),a
    jp      DeactivateCurrentEnity_18
}

//-------------------------------------------------------------------
// Music Bank 1
//=====================================
ROMBANK($1B)

origin Offset_Hook_JumpToPlaySong
    call    JumpToPlaySong

// SFX pan fix
origin Offset_SFXPanFix_Bank1B
    ld      a,$01
    nop

origin Offset_FreeSpace_Bank1B
function JumpToPlaySong {
    FARCALL ($3C, PlaySong, $1B)
    jp      $413B
}

//-------------------------------------------------------------------
// Music Bank 2
//=====================================
ROMBANK($1E)

// SFX pan fix
origin Offset_SFXPanFix_Bank1E
    ld      a,$01
    nop

//-------------------------------------------------------------------
ROMBANK($1F)

origin Offset_ClearCurrentTrack
    nop; nop; nop

origin Offset_NOPSlide
    push    hl
    ld      hl,Farcall_1F_ret
    push    hl
    ld      a,$FE
    ld      (wActiveMusicTrack),a
    xor     a
Farcall_1F:
    FARCALL ($3C, PlaySong, $1F)
    ret
Farcall_1F_ret:
    pop     hl

origin Offset_Hook_Fade_Decrement
//    call    Fade.decrement
//    nop

origin Offset_Hook_Fade_Increment
//    call    Fade.increment
//    nop

origin Offset_FreeSpace_Bank1F
function Fade {
decrement:
    sub     $10
    jr      set
increment:
    add     a,$10
set:
    ld      ($FFAA),a
    jp      Farcall_1F
}

//-------------------------------------------------------------------
ROMBANK($20)

origin Offset_ColorDungeonPuzzle
if {DISABLE_COLOR_DUNGEON} == 1 {
    // Disable color dungeon graveyard puzzle
    db      $18         // jr nz -> jr
}

origin Offset_MadBatterEntityHandlerPtr
    dw      MadBatterEntityHandler
    db      $3C

//-------------------------------------------------------------------
// Super GameBoy Support Bank
//=====================================
ROMBANK($3C)

origin Offset_Hook_SGBTransfer
    call TransferMSU1Code

origin Offset_Hook_MSUInit
    call MSUInit

origin Offset_SendUploadCommand
SendUploadCommand:

origin Offset_WaitFor60ms
WaitFor60ms:

origin Offset_WaitForBCFrames
WaitForBCFrames:

origin Offset_SendVRAMData
SendVRAMData:

origin Offset_FreeSpace_Bank3C
define USE_EXISTING_SGB_SDK
define USE_CUSTOM_SGB_CODE
include "sgb/sgb.asm"

function TransferMSU1Code {
    insert "{input}", Offset_Hook_SGBTransfer, $03

// Display MSU-1 splash screen
    ld      hl,SGB.MSU1SplashScreenPalette
    call    SendUploadCommand
    ld      bc,6
    call    WaitForBCFrames

    FARCALL_NESTED($3E, DisplayLoadingScreen, $3C)
    ld      bc,6
    call    WaitForBCFrames
    ld      hl,$6870
    call    SendUploadCommand
    ld      bc,6
    call    WaitForBCFrames
    xor     a
    ldh     ($40),a
    //call    WaitFor60ms

// Play splash screen SFX jingle
    ld      hl,SGB.MSU1SplashScreenSFX
    call    SendUploadCommand
    ld      bc,6
    call    WaitForBCFrames

// Upload MSU-1 engine payload
    ld      hl,SGB.MSU1CodePayload
-;  call    SendUploadCommand
        ld      bc,6
        call    WaitForBCFrames
        ld      a,(hl)
        and     a
        jr      nz,-
    
    // Clear VRAM after transfer
    ld      hl,$8000
    ld      bc,$2000
-;  xor     a       // for (bc = $2000; bc > 0; bc--)
        ld      (hl+),a // *(ptr++) = 0
        dec     bc
        ld      a,b
        or      c
        jr      nz,-
    
    ld      a,$81
    ldh     ($40),a     // Enable LCDC interrupt
    ld      bc,6
    call    WaitForBCFrames
    xor     a
    ldh     ($40),a     // Disable LCDC interrupt
    ld      bc,6
    call    WaitForBCFrames

    ret
}

function MSUInit {
    call    SendVRAMData
    ld      hl,SGB.MSU1InitPayload
    call    SendUploadCommand
    ret
}

function ClearCommandBuffer {
    ld      hl,CommandBuffer.DestinationAddress
    ld      a,$00
    ld      d,$0F
-;  ld      (hl+),a
        dec     d
        jr      nz,-
    ret
}

// Destination address (Bank 0) in bc
function SetDestinationAddress {
    ld      hl,CommandBuffer.DestinationAddress+1
    ld      a,b
    ld      (hl-),a
    ld      (hl),c
    ret
}

function ChangeVolume {
    call    ClearCommandBuffer
    ld      bc,{MSU1BASE}   // Destination address $001800 (MSUIdle)
    call    SetDestinationAddress
    ld      a,$06       // Transfer 6 bytes
    ld      (CommandBuffer.TransferSize),a
    ld      hl,$FFAA
    ld      a,(hl)
    sla     a
    or      (hl)
    jr      z,+
        or      $0F
+;  ld      (CommandBuffer.TargetVolume),a
    ld      hl,wSGBCommandBuffer
    call    SendUploadCommand
    ld      bc,6
    jp      WaitForBCFrames
}

function StopPlayback {
    call    ClearCommandBuffer
    ld      bc,{MSU1BASE}   // Destination address $001800 (MSUIdle)
    call    SetDestinationAddress
    ld      a,$03       // Transfer 3 bytes
    ld      (CommandBuffer.TransferSize),a
    ld      a,$80       // Stop playback command
    ld      (CommandBuffer.MSUCommand),a
    ld      hl,wSGBCommandBuffer
    call    SendUploadCommand
    ld      bc,6
    jp      WaitForBCFrames
}

function FadeOut {
    call    ClearCommandBuffer
    ld      bc,{MSU1BASE}   // Destination address $001800 (MSUIdle)
    call    SetDestinationAddress
    ld      a,$06       // Transfer 6 bytes
    ld      (CommandBuffer.TransferSize),a
    ld      hl,wSGBCommandBuffer
    call    SendUploadCommand
    ld      bc,6
    jp      WaitForBCFrames
}

function LoadTrack {
    ld      bc,{MSU1BASE}   // Destination address $001800 (MSUIdle)
    call    SetDestinationAddress
    ld      a,$06       // Transfer 6 bytes
    ld      (CommandBuffer.TransferSize),a
    ld      a,(wActiveMusicTrack)  // Track number
    ld      (CommandBuffer.TrackNumber),a
    ld      c,a
    cp      $1A         // Track $1A: The Storm/Opening
    jr      nz,+        // Fully reset initial state
        ld      a,$0B   // Transfer 11 bytes
        ld      (CommandBuffer.TransferSize),a
        ld      a,$10   // Fade rate
        ld      (CommandBuffer.FadeRate),a
        ld      a,$04   // FLAG_AUTO_RESUME
        ld      (CommandBuffer.Settings),a
        jp      ++
+;  cp      $22         // Track $22: The Wise Owl
    jr      nz,+        // Prior to the egg, don't set resume flag
        ldh     a,(hMapId)
        cp      $00
        jr      nz,+
        ldh     a,(hRoomId)
        cp      $16     // Below Wind Fish's Egg
        jr      nz,+
        ld      a,$03
        jp      ++
+;  ld      b,$00
    ld      hl,tracklist
    add     hl,bc
    ld      a,(hl)      // Track play command
+;  ld      (CommandBuffer.MSUCommand),a
    ld      a,$FF
//    ld      hl,$FFAA
//    ld      a,(hl)
//    sla     a
//    or      (hl)
//    jr      z,+
//        or      $0F
+;  ld      (CommandBuffer.TargetVolume),a
    ret
}

// Flags to set are in the A register
function SetFlags {
    ld      hl,(CommandBuffer.SetSettings)
    or      (hl)
    ld      (CommandBuffer.SetSettings),a
    ret
}

// Flags to clear are in the A register
function ClearFlags {
    ld      hl,(CommandBuffer.ClearSettings)
    or      (hl)
    ld      (CommandBuffer.ClearSettings),a
    ret
}

function PlaySong {
    push    af
    push    bc
    push    de
    push    hl
    ld      a,$79       // $79: DATA_SND command, single packet
    ld      (wSGBCommandBuffer),a
    ld      a,(wActiveMusicTrack)
    and     a
    jr      nz,+
        call    ChangeVolume
        jp      done

//===$FF: Stop playback command===
+;  cp      $FF
    jr      nz,+
        call    StopPlayback
        jp done
//===$FE: Fade out command===
+;  cp      $FE
    jr      nz,+
        call    FadeOut
        jp      done

+;  call    ClearCommandBuffer

//=====================================
// Alternate/expanded tracks
//=====================================
    ld      a,(wIsMarinFollowingLink)
    cp      $01
    ld      a,(wActiveMusicTrack)
    jr      nz,noMarin
    cp      $05         // Track $05: Overworld
    jr      nz,++
        ldh     a,(hRoomId)
        cp      $FD     // Walrus Beach
        jr      nz,+
            jp      flags
    +;  ld      a,$6A   // Extended Track - Overworld w/Marin (no intro)
        jp      setAlt
+;  cp      $06         // Track $06: Tal Tal Heights
    jr      nz,+
        ld      a,$6C   // Extended Track - Tal Tal Heights w/Marin
        jp      setAlt
+;  cp      $09         // Track $09: Mysterious Forest
    jr      nz,+
        ld      a,$6B   // Extended Track - Mysterious Forest w/Marin
        jp      setAlt
+;  cp      $31         // Track $31: Let the Journey Begin!
    jr      nz,+
        ld      a,$69   // Extended Track - Overworld w/Marin (with intro)
        jp      setAlt
noMarin:
+;  cp      $02         // Track $02: Trendy Game/Fishing Pond
    jr      nz,+
        ldh     a,(hMapId)
        cp      $0F
        jr      nz,flags
        ldh     a,(hRoomId)
        cp      $B1     // Fishing Pond
        jr      nz,flags
        ld      a,$64   // Alternate track $64 - Fishing Pond
        jp      setAlt
+;  cp      $06         // Track $06: Mt. Tamaranch
    jr      nz,+
        ld      a,(wOverworldRoomStatus+8)
        and     $10     // ROOM_STATUS_CHANGED
        jr      z,flags
        ld      a,$65   // Alternate track $65 - Mt. Tamaranch (After Rescue)
        jp      setAlt
+;  cp      $0A         // Track $0A: Inside the Houses
    jr      nz,+
        ldh     a,(hMapId)
        cp      $10
        jr      nz,flags
        ldh     a,(hRoomId)
        cp      $E9     // Seashell Mansion
        jr      nz,flags
        ld      a,$66   // Alternate track $66 - Seashell Mansion
        jp      setAlt
+;  cp      $22         // Track $22: The Wise Owl
    jr      nz,+
        ldh     a,(hMapId)
        cp      $00
        jr      nz,flags
        ldh     a,(hRoomId)
        cp      $06     // Outside Wind Fish's Egg
        jr      nz,flags
        ld      a,$63   // Alternate track $63: The Wise Owl - Final Message
        jp      setAlt
+;  cp      $50         // Track $50: Miniboss Battle
    jr      nz,+
        ldh     a,(hMapId)
        cp      $08
        jr      nz,flags
        ldh     a,(hRoomId)
        cp      $74     // Wind Fish final battle room
        ld      a,$6D
//        jp      setAlt

+;
setAlt:
    ld      (wActiveMusicTrack),a

//=====================================
// Set no-interrupt flag
//   Called by the tracks which need to play
//   to the end without interruption
//=====================================
flags:
    ld      a,(wActiveMusicTrack)
+;  cp      $1A         // Track $1A: The Storm/Opening
    jr      z,+
    cp      $25         // Track $25: Big Heart Container
    jr      z,+
    cp      $30         // Track $30: Manbo's Mambo
    jr      z,+
    cp      $34         // Track $34: Tarin is Being Chased by Bees!
    jr      z,+
    cp      $35         // Track $35: The Frog's Song of Soul
    jr      z,+
    cp      $41         // Track $41: Ballad of the Wind Fish (1-2 Instruments)
    jr      nc,++
//    jr      z,+
//    cp      $42         // Track $42: Ballad of the Wind Fish (3 Instruments)
//    jr      z,+
//    cp      $43         // Track $43: Ballad of the Wind Fish (4 Instruments)
//    jr      z,+
//    cp      $44         // Track $44: Ballad of the Wind Fish (5 Instruments)
//    jr      z,+
//    cp      $45         // Track $45: Ballad of the Wind Fish (6 Instruments)
//    jr      z,+
//    cp      $46         // Track $46: Ballad of the Wind Fish (7 Instruments)
//    jr      z,+
//    cp      $47         // Track $47: Ballad of the Wind Fish (8 Instruments)
//    jr      nz,++
    cp      $48
    jr      c,++
    +;  ld      a,$01   // FLAG_NO_INTERRUPT
        call    SetFlags
        ld      a,(wActiveMusicTrack)

//=====================================
// Set allow restart flag
//   Called by tracks that are allowed to restart
//=====================================
+;  cp      $59         // Track $89: The Wind Fish
    jr      nz,++
    +;  ld      a,$02   // FLAG_ALLOW_RESTART
        call    SetFlags
        ld      a,(wActiveMusicTrack)

//=====================================
// Set auto-resume flag
//   Called by the tracks which will interrupt
//   other tracks which will auto-resume after
//=====================================
+;  cp      $0F         // Track $0F: Your Sword
    jr      z,+
    cp      $10         // Track $10: Item Catch
    jr      nz,++
    +;  ld      a,$04   // FLAG_AUTO_RESUME
        call    SetFlags
        ld      a,(wActiveMusicTrack)

//=====================================
// Clear no-interrupt flag
//   Called by the tracks which are not allowed
//   to interrupt the previous one
//=====================================
+;  cp      $0D         // Track $0D: Title Screen (No Intro)
    jr      z,+
    cp      $11         // Track $11: Player Select
//    jr      z,+
//    cp      $1B         // Track $1B: Holding the Instrument
    jr      nz,++
    +;  ld      a,$01   // FLAG_NO_INTERRUPT
        call    ClearFlags
        ld      a,(wActiveMusicTrack)

//=====================================
// Clear allow restart flag
//   Called by tracks which are not allowed to restart
//   but which follow tracks that are
//=====================================
+;  cp      $3F         // Track $3F: Song of Awakening
    jr      nz,++
    +;  ld      a,$02
        call    ClearFlags
        ld      a,(wActiveMusicTrack)

//=====================================
// Clear auto-resume flag
//   Called by tracks which need to disable
//   the auto-resume feature e.g. because they
//   are followed by another fanfare before
//   the original song auto-resumes
//=====================================
+;  cp      $30         // Track $30: Manbo's Mambo
    jr      z,+
    cp      $34         // Track $34: Tarin is Being Chased by Bees!
    jr      z,+
    cp      $35         // Track $35: The Frog's Song of Soul
    jr      z,+
    cp      $36         // Track $36: Monkeys Build a Bridge
    jr      z,+
    cp      $55         // Track $55: Rooster Resurrection
    jr      z,+
    cp      $56         // Track $56: Seashell Mansion - Get Sword
    jr      z,+
    cp      $5F         // Track $5F: Final Boss Defeated
    jr      nz,++
        // Clear auto-resume flag
    +;  ld      a,$04   // FLAG_AUTO_RESUME
        call    ClearFlags

//=====================================
// Send the track load command
//=====================================
+;  FARCALL_NESTED($1B, Offset_SFXCancel_Bank1B, $3C)
    call    LoadTrack
    ld      hl,wSGBCommandBuffer
    call    SendUploadCommand
    ld      bc,6
    call    WaitForBCFrames
    ld      a,(wActiveMusicTrack)
    ld      c,a
    ld      b,$00
    ld      hl,tracklist
    add     hl,bc
    ld      a,(hl)
    and     $03
    jr      z,+
done:
        ld      a,$00
        ld      (wActiveMusicTrack),a
+;  pop     hl
    pop     de
    pop     bc
    pop     af
    ret
}

function PlayJingle {
    // $D360-$D361
    //  $01: Chest open - 21_ItemGetFanfare.ry.48.dspadpcm
    //  $02: Puzzle solved - 17_NazoTokiSeikaiOn.ry.48.dspadpcm
    //  ??: Golden leaf get - KonohaGetFanfare.ry.48.dspadpcm
    // $D370-$D371
    //  $01: Secret seashell get - KaigaraGetFanfare.ry.48.dspadpcm
    //  $09: Ocarina BotWF jingle
    //  $0A: Ocarina frog jingle
    //  $0B: Ocarina fish jingle
    //  $1B: Key detected in room jingle
}

DebugSaveData:
insert "{input}", Offset_DebugSaveData, $43

function InitDebugSave {
    ld      e,$00
    ld      d,$00
    ld      bc,$A405
loop:
    ld      hl,DebugSaveData
    add     hl,de
    ld      a,(hl+)
    ld      (bc),a
    inc     bc
    inc     e
    ld      a,e
    cp      $43
    jr      nz,loop
    ret
}

function MadBatterEntityHandler {
    ld      hl,$C2D0
    add     hl,bc
    ld      a,(hl)
    and     a
    jr      nz,done
    ldh     a,($F8)
    and     $20
    jr      nz,done
    ldh     a,($F0)
    cp      $03
    jr      nz,done
    call    CheckEntityCountdownTimer
    jr      nz,done
    ld      a,$67   // Track $67: Li'l Devil
    ld      (wRequestedMusicTrack),a
done:
    ld      a,Offset_MadBatterEntityHandler >> $0E
    ld      (wCurrentBank),a
    FARCALL_NOSAVE((Offset_MadBatterEntityHandler >> $0E), (Offset_MadBatterEntityHandler & $3FFF)+$4000, $3C)
    ret
}

if REGION == ROM_REGION_JP {
    // $39,$29,$39,$00,$00: $60
    // $14,$10,$09,$09,$00: $3C
    // $1F,$28,$2E,$00,$00: $62
} else if REGION == ROM_REGION_US {
function CheckFilenames {
    ld      a,(wSaveSlot)
    ld      e,a
    sla     a
    sla     a
    add     a,e
    ld      e,a
    ld      d,$00
    ld      hl,wSaveFile1Name
    add     hl,de

    ld      a,(hl+)
    cp      'Z'+1
    jp      nz,marin
    ld      a,(hl+)
    cp      'E'+1
    jp      nz,done
    ld      a,(hl+)
    cp      'L'+1
    jp      nz,done
    ld      a,(hl+)
    cp      'D'+1
    jp      nz,done
    ld      a,(hl+)
    cp      'A'+1
    jp      nz,done
    ld      a,$60
    jp      load

marin:
    cp      'M'+1
    jr      nz,keke
    ld      a,(hl+)
    cp      'A'+1
    jr      nz,done
    ld      a,(hl+)
    cp      'R'+1
    jr      nz,done
    ld      a,(hl+)
    cp      'I'+1
    jr      nz,done
    ld      a,(hl+)
    cp      'N'+1
    jr      nz,done
    ld      a,$62
    jp      load

keke:
    cp      'K'+1
    jr      nz,done
    ld      a,(hl+)
    cp      'E'+1
    jr      nz,done
    ld      a,(hl+)
    cp      'K'+1
    jr      nz,done
    ld      a,(hl+)
    cp      'E'+1
    jr      nz,done
    ld      a,(hl+)
    cp      0
    jr      nz,done
    ld      a,$3C

load:
    ld      (wRequestedMusicTrack),a

done:
    ret
}
}   else if REGION == ROM_REGION_FR {
    // LOLO: $60
} else if REGION == ROM_REGION_DE {
    // MOYSE: $3C
    // ZELDA: $60
}

origin Offset_MSU1TrackCommandTable
tracklist:
    //  x0  x1  x2  x3  x4  x5  x6  x7  x8  x9  xA  xB  xC  xD  xE  xF
    db $00,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$01  // 0x
    db $05,$03,$03,$03,$03,$03,$03,$03,$03,$03,$01,$01,$03,$03,$01,$03  // 1x
    db $01,$03,$07,$03,$03,$01,$03,$03,$01,$01,$01,$01,$01,$01,$01,$03  // 2x
    db $05,$03,$03,$03,$05,$05,$05,$03,$05,$03,$03,$00,$03,$01,$03,$01  // 3x
    db $03,$01,$01,$01,$01,$01,$01,$01,$03,$03,$01,$03,$05,$01,$03,$00  // 4x
    db $03,$03,$03,$03,$03,$07,$07,$03,$03,$03,$03,$03,$03,$03,$03,$03  // 5x
    db $03,$03,$03,$03,$03,$03,$03,$07,$01,$03,$03,$03,$03,$03,$00,$00  // 6x
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // 7x
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // 8x
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // 9x
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // Ax
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // Bx
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // Cx
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // Dx
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // Ex
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // Fx

//-------------------------------------------------------------------
// MSU-1 splash screen bank
//=====================================
ROMBANK($3E)

//print "Tiles: ", pc(), "\n"
include "sgb/sgb_code_loading_screen.asm"

DisplayLoadingScreen:
    ld      a,$E4
    ldh     ($47),a
    
    ld      hl,LoadingScreenTiles
    ld      bc,LoadingScreenTiles_end-LoadingScreenTiles
    ld      de,$8000

    call    CopyData
    
    ld      hl,LoadingScreenTilemap
    ld      bc,LoadingScreenTilemap_end-LoadingScreenTilemap
    ld      de,$9800

    call    CopyData

    ld      a,$91
    ldh     ($40),a     // Enable LCDC interrupt

    ret
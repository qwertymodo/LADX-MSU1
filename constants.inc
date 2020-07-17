constant ROM_REGION_JP = 1
constant ROM_REGION_US = 2
constant ROM_REGION_FR = 3
constant ROM_REGION_DE = 4

// Default version is US 1.0
variable REGION = ROM_REGION_US
variable REVISION = 0

constant wEntitiesStatusTable = $C280
constant wSGBCommandBuffer = $C370
constant wOverworldRoomStatus = $D800
constant wShieldLevel = $DB44
constant wSwordLevel = $DB4E
constant wCurrentBank = $DBAF
constant wFarcallParams = $DE01
constant wRequestedMusicTrack = $D368
constant wActiveMusicTrack = $D369
constant wSaveFile1Name = $DB80
constant wSaveSlot = $DBA6
constant hRoomId = $FFF6
constant hMapId = $FFF7
constant hLinkRoomPosition = $FFFA
constant hLinkFinalRoomPosition = $FFFB

if !{defined MSU1BASE} {
    define MSU1BASE = $1800
}
evaluate MSU1BASE = {MSU1BASE}

if !{defined DISABLE_COLOR_DUNGEON} {
    define DISABLE_COLOR_DUNGEON = 1
}
evaluate DISABLE_COLOR_DUNGEON = {DISABLE_COLOR_DUNGEON}

if {defined ROM_VERSION_JP_1_0} {
    REGION = ROM_REGION_JP
    REVISION = 0
} else if {defined ROM_VERSION_JP_1_1} {
    REGION = ROM_REGION_JP
    REVISION = 1
} else if {defined ROM_VERSION_JP_1_2} {
    REGION = ROM_REGION_JP
    REVISION = 2
} else if {defined ROM_VERSION_US_1_0} {
    REGION = ROM_REGION_US
    REVISION = 0
} else if {defined ROM_VERSION_US_1_1} {
    REGION = ROM_REGION_US
    REVISION = 1
} else if {defined ROM_VERSION_US_1_2} {
    REGION = ROM_REGION_US
    REVISION = 2
} else if {defined ROM_VERSION_FR_1_0} {
    REGION = ROM_REGION_FR
    REVISION = 0
} else if {defined ROM_VERSION_FR_1_1} {
    REGION = ROM_REGION_FR
    REVISION = 1
} else if {defined ROM_VERSION_DE_1_0} {
    REGION = ROM_REGION_DE
    REVISION = 0
} else if {defined ROM_VERSION_DE_1_1} {
    REGION = ROM_REGION_DE
    REVISION = 1
}

inline OFFSET(name, addr) {
    constant Offset_{name} = {addr}
}

// Common offsets for all revs
OFFSET(Hook_CheckNewGameSong,       $008151)
OFFSET(FreeSpace_Bank02,            $00BD00)
OFFSET(FlyingBookEntity,            $058C92)
OFFSET(Hook_JumpToPlaySong,         $06C032)
OFFSET(SFXPanFix_Bank1B,            $06C2D5)
OFFSET(FreeSpace_Bank1B,            $06CF00)
OFFSET(SFXPanFix_Bank1E,            $078359)
OFFSET(ClearCurrentTrack,           $07FB66)
OFFSET(NOPSlide,                    $07FC00)
OFFSET(Hook_Fade_Decrement,         $07FF9A)
OFFSET(Hook_Fade_Increment,         $07FFBA)
OFFSET(FreeSpace_Bank1F,            $07FFEE)
OFFSET(MadBatterEntityHandlerPtr,   $08025E)
OFFSET(ColorDungeonPuzzle,          $0809A1)
OFFSET(Hook_SGBTransfer,            $0F2B0C)
OFFSET(WaitForBCFrames,             $0F2B92)
OFFSET(SendUploadCommand,           $0F2B51)
OFFSET(FreeSpace_Bank3C,            $0F2C00)
OFFSET(MSU1TrackCommandTable,       $0F3F00)

if REGION == ROM_REGION_JP {
print "ROM Region: JP\n"
    if REVISION == 0 {
        // Rev 0 unique offsets
        OFFSET(Farcall,                     $000BD7)
        OFFSET(CheckEntityCountdownTimer,   $000C05)
        OFFSET(IncrementEntityState,        $003B17)
        OFFSET(DebugSaveData,               $004671)
        OFFSET(InitDebugSave,               $0046CD)
        OFFSET(Hook_CheckFilenames,         $004AE3)
        OFFSET(MadBatterEntityHandler,      $060EDD)
        OFFSET(Hook_SetVolume_Half,         $0056DB)
        OFFSET(Hook_SetVolume_Full,         $0058BA)
        OFFSET(Hook_LilDevil_Start,         $060F41)
        OFFSET(Hook_LilDevil_Stop,          $06107D)
        OFFSET(WalrusTrack,                 $0615CB)
        OFFSET(DeactivateCurrentEnity_18,   $063F08)
        OFFSET(FreeSpace_Bank18,            $063FF0)

    } else {
        // Rev 1+2 common offets
        OFFSET(Farcall,                     $000BD3)
        OFFSET(CheckEntityCountdownTimer,   $000C01)
        OFFSET(IncrementEntityState,        $003B0E)
        OFFSET(DebugSaveData,               $004674)
        OFFSET(InitDebugSave,               $0046D0)
        OFFSET(Hook_CheckFilenames,         $004AE6)
        OFFSET(MadBatterEntityHandler,      $060EE1)
        OFFSET(Hook_LilDevil_Start,         $060F45)
        OFFSET(Hook_LilDevil_Stop,          $061061)
        OFFSET(WalrusTrack,                 $0615D9)
        OFFSET(DeactivateCurrentEnity_18,   $063F29)
        OFFSET(FreeSpace_Bank18,            $063FF7)

        if REVISION == 1 {
            // Rev 1 unique offsets
            OFFSET(Hook_SetVolume_Half,         $0056DE)
            OFFSET(Hook_SetVolume_Full,         $0058A8)

        } else if REVISION == 2 {
            // Rev 2 unique offsets
            OFFSET(Hook_SetVolume_Half,         $005702)
            OFFSET(Hook_SetVolume_Full,         $0058CC)
        }
    }
   
} else if REGION == ROM_REGION_US {
print "ROM Region: US\n"
    if REVISION == 0 {
        // Rev 0 unique offsets
        OFFSET(Farcall,                     $000BD7)
        OFFSET(CheckEntityCountdownTimer,   $000C05)
        OFFSET(IncrementEntityState,        $003B12)
        OFFSET(DebugSaveData,               $004667)
        OFFSET(InitDebugSave,               $0046C3)
        OFFSET(Hook_CheckFilenames,         $004AD0)
        OFFSET(Hook_SetVolume_Half,         $00568C)
        OFFSET(Hook_SetVolume_Full,         $00586B)
        OFFSET(MadBatterEntityHandler,      $060EDD)
        OFFSET(Hook_LilDevil_Start,         $060F41)
        OFFSET(Hook_LilDevil_Stop,          $06107D)
        OFFSET(WalrusTrack,                 $0615CB)
        OFFSET(DeactivateCurrentEnity_18,   $063F08)
        OFFSET(FreeSpace_Bank18,            $063FF7)

    } else {
        // Rev 1+2 common offets
        OFFSET(Farcall,                     $000BD3)
        OFFSET(CheckEntityCountdownTimer,   $000C01)
        OFFSET(IncrementEntityState,        $003B09)
        OFFSET(DebugSaveData,               $00466A)
        OFFSET(InitDebugSave,               $0046C6)
        OFFSET(Hook_CheckFilenames,         $004AD3)
        OFFSET(MadBatterEntityHandler,      $060EE1)
        OFFSET(Hook_LilDevil_Start,         $060F45)
        OFFSET(Hook_LilDevil_Stop,          $061081)
        OFFSET(WalrusTrack,                 $0615D9)
        OFFSET(DeactivateCurrentEnity_18,   $063F29)
        OFFSET(FreeSpace_Bank18,            $063FF7)

        if REVISION == 1 {
            // Rev 1 unique offsets
            OFFSET(Hook_SetVolume_Half,         $00568F)
            OFFSET(Hook_SetVolume_Full,         $00586E)

        } else if REVISION == 2 {
            // Rev 2 unique offsets
            OFFSET(Hook_SetVolume_Half,         $0056B3)
            OFFSET(Hook_SetVolume_Full,         $005892)
        } else {
            error "Invalid ROM revision"
        }
    }

} else if REGION == ROM_REGION_FR {
print "ROM Region: FR\n"
    // Common offsets for all revs
    OFFSET(Farcall,                     $000BC7)
    OFFSET(CheckEntityCountdownTimer,   $000BF5)
    OFFSET(IncrementEntityState,        $003B0D)
    OFFSET(DebugSaveData,               $004667)
    OFFSET(InitDebugSave,               $0046C3)
    OFFSET(Hook_CheckFilenames,         $004AD4)
    OFFSET(MadBatterEntityHandler,      $060EE1)
    OFFSET(Hook_LilDevil_Start,         $060F45)
    OFFSET(Hook_LilDevil_Stop,          $061081)
    OFFSET(WalrusTrack,                 $0615D9)
    OFFSET(DeactivateCurrentEnity_18,   $063F29)
    OFFSET(FreeSpace_Bank18,            $063FF7)

    if REVISION == 0 {
        // Rev 0 unique offsets
        OFFSET(Hook_SetVolume_Half,         $00568B)
        OFFSET(Hook_SetVolume_Full,         $00586A)

    } else if REVISION == 1 {
        // Rev 1 unique offsets
        OFFSET(Hook_SetVolume_Half,         $0056AF)
        OFFSET(Hook_SetVolume_Full,         $00588E)

    } else {
        error "Invalid ROM revision"
    }

} else if REGION == ROM_REGION_DE {
print "ROM Region: DE\n"
    // Common offsets for all revs
    OFFSET(Farcall,                     $000BC7)
    OFFSET(CheckEntityCountdownTimer,   $000BF5)
    OFFSET(IncrementEntityState,        $003B10)
    OFFSET(DebugSaveData,               $00465B)
    OFFSET(InitDebugSave,               $0046B7)
    OFFSET(Hook_CheckFilenames,         $004A9A)
    OFFSET(MadBatterEntityHandler,      $060EE1)
    OFFSET(Hook_LilDevil_Start,         $060F45)
    OFFSET(Hook_LilDevil_Stop,          $061081)
    OFFSET(WalrusTrack,                 $0615D9)
    OFFSET(DeactivateCurrentEnity_18,   $063F29)
    OFFSET(FreeSpace_Bank18,            $063FF7)

    if REVISION == 0 {
        // Rev 0 unique offsets
        OFFSET(Hook_SetVolume_Half,         $0056E8)
        OFFSET(Hook_SetVolume_Full,         $0058C7)

    } else if REVISION == 1 {
        // Rev 1 unique offsets
        OFFSET(Hook_SetVolume_Half,         $00570C)
        OFFSET(Hook_SetVolume_Full,         $0058EB)

    } else {
        error "Invalid ROM revision"
    }
}

print "ROM Revision: 1."
print REVISION
print "\n"

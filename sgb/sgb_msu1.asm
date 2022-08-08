architecture wdc65816

define ENABLE_MSU_FALLBACK = 1

if !{defined BASEADDRESS} {
    define BASEADDRESS = $1800
}
evaluate BASEADDRESS = {BASEADDRESS}

//===Read registers===
constant REG_MSU_STATUS     = $2000
constant REG_MSU_DATA       = $2001
constant REG_MSU_ID_0       = $2002
constant REG_MSU_ID_1       = $2003
constant REG_MSU_ID_2       = $2004
constant REG_MSU_ID_3       = $2005
constant REG_MSU_ID_4       = $2006
constant REG_MSU_ID_5       = $2007

//===Write registers===
constant REG_MSU_SEEK_0     = $2000
constant REG_MSU_SEEK_1     = $2001
constant REG_MSU_SEEK_2     = $2002
constant REG_MSU_SEEK_3     = $2003
constant REG_MSU_TRACK      = $2004
constant REG_MSU_TRACK_LO   = $2004
constant REG_MSU_TRACK_HI   = $2005
constant REG_MSU_VOLUME     = $2006
constant REG_MSU_CONTROL    = $2007

constant NMI_VECTOR         = $0000BB

//===Settings flags===
// Wait for non-looping tracks to finish before starting a new one
constant FLAG_NO_INTERRUPT  = $01

// Allow restarting the track that is currently playing
constant FLAG_ALLOW_RESTART = $02

// Automatically resume looping tracks after playing non-looping jingles
constant FLAG_AUTO_RESUME = $04

origin 0
base {BASEADDRESS}
IdleFlag:       // $1800
db $01

TrackNumber:    // $1801
db $00

Command:        // $1802
db $00

SetSettings:    // $1803
db $00

ClearSettings:  // $1804
db $00

TargetVolume:   // $1805
db $00

CurrentVolume:  // $1806
db $00

FadeRate:       // $1807
db $10

Settings:       // $1808
db FLAG_AUTO_RESUME

CurrentTrack:   // $1809
db $00

PreviousTrack:  // $180A
db $00

origin $000E
HandlerPointer: //$180E
dw MSU1ActiveHandler.done

// Must be in bank $00!
origin $0010
function MSU1NMISetup {
    rep #$10; sep #$20
        ldx.w REG_MSU_ID_0; cpx.w #$2D53; bne done
        ldx.w REG_MSU_ID_2; cpx.w #$534D; bne done
        ldx.w REG_MSU_ID_4; cpx.w #$3155; bne done

        ldx.w #$0000;
        stx.w REG_MSU_SEEK_0
        stx.w REG_MSU_SEEK_2
        stx.w REG_MSU_TRACK
        stx.w REG_MSU_VOLUME

        ldx.w #MSU1IdleHandler; stx.b NMI_VECTOR
        lda.b #$DC; sta $0810  // jmp [$00BB]
        ldx.w #$00BB; stx $0811

        //lda.b #$20; sta $4207
        //lda.b #$DE; sta $4209

done:
    sep #$30
    cli
    rts
}

function MSU1NOPHandler {
define x = 20
while {x} > 0 {
    //nop
    evaluate x = {x} - 1
}
    //sep #$20
    //    pha
    //        lda.w $4212; and.b #$80; beq +
    //        pla; rti// plp; rtl
    //    +; lda.w $4210
    //    pla
    //rti
}

function MSU1IdleHandler {
    sep #$20
        pha
        //lda.w $4210
        lda.l IdleFlag; beq notIdle
    pla
    sep #$30; jmp $0820

notIdle:
        phb; phd
        rep #$10
            phx
            ldx.w #{BASEADDRESS}; phx; pld
            lda.b #$00; pha; plb

        +;  lda.b TrackNumber; beq ++
                lda.b ClearSettings; ora.b SetSettings; beq +
                    // Set settings change handler
                    ldx.w #MSU1ChangeSettings
                    bra activate
                // Set track load handler
            +;  ldx.w #MSU1TrackPreload
                bra activate
        +;  lda.b Command; beq +
                // Set command handler
                ldx.w #MSU1Command
                bra activate
        +;  lda.b CurrentVolume; cmp.b TargetVolume; beq +
                // Set fade handler
                ldx.w #MSU1Fade
                bra activate
            // Check if we need to monitor the current track
        +;  lda.w REG_MSU_STATUS; bit #$20; bne idle
            lda.b Settings; bit.b #FLAG_NO_INTERRUPT; beq +
                lda.b ClearSettings; bit.b #FLAG_NO_INTERRUPT; beq monitor
                lda.b Settings
        +;  bit.b #FLAG_AUTO_RESUME; beq idle
            lda.b PreviousTrack; beq idle

monitor:
        ldx.w #MSU1PlaybackMonitor; stx.w NMI_VECTOR
        bra done
idle:   
        inc IdleFlag;
        bra done
activate:
        stx.b HandlerPointer
        ldx.w #MSU1ActiveHandler; stx.w NMI_VECTOR
done:
        plx; pld; plb; pla
        sep #$30; jmp $0820
}

function MSU1ActiveHandler {
    sep #$20; rep #$10
    pha; phb; phd; phx;
        //lda.w $4210
        ldx.w #{BASEADDRESS}; phx; pld
        lda.b #$00; pha; plb
        jmp (HandlerPointer)
updateHandler:
    stx.b HandlerPointer
done:
    bra MSU1IdleHandler.done
}

function MSU1PlaybackMonitor {
    sep #$20
        pha; phb
        //lda.w $4210
        lda.b #$00; pha; plb
        lda.w REG_MSU_STATUS; bit.b #$10; beq notPlaying
        lda.w TrackNumber; ora.w Command; beq wait

    // Only set the LSB of the pointer, must be in the same
    // $0100 block as MSU1IdleHandler
    if (MSU1PlaybackMonitor & $FF00) != (MSU1IdleHandler & $FF00) {
        error "MSU1PlaybackMonitor must be in the same $0100 block as MSU1IdleHandler"
    }
    lda.b #MSU1IdleHandler; sta.w NMI_VECTOR
wait:
    plb; pla
    sep #$30; jmp $0820

notPlaying:
        phd
        rep #$10
            phx
            ldx.w #{BASEADDRESS}; phx; pld

            lda.b Settings; bit.b #FLAG_AUTO_RESUME; beq idle

            lda.b PreviousTrack; beq idle
            sta.b TrackNumber; stz.b PreviousTrack

            lda.b #$03; sta.b Command
            stz.b CurrentVolume
            ldx.w #MSU1TrackPreload; bra MSU1IdleHandler.activate

idle:
        inc IdleFlag
        ldx.w #MSU1IdleHandler; stx.w NMI_VECTOR

done:
        bra MSU1IdleHandler.done
}

// Apply new settings and return
function MSU1ChangeSettings {
    lda.b ClearSettings; eor.b #$FF; and.b Settings;
    ora.b SetSettings; sta.b Settings
    stz.b SetSettings; stz.b ClearSettings
    ldx.w #MSU1TrackPreload
    jmp MSU1ActiveHandler.updateHandler
}

function MSU1TrackPreload {
    // Check if we're currently playing
    lda.w REG_MSU_STATUS; bit.b #$10; beq +
    // Check if we're loading a new track or restarting the same one
    lda.b TrackNumber; cmp.b CurrentTrack; bne +
        // Check if reloading the same track is currently allowed
        lda.b Settings; bit.b #FLAG_ALLOW_RESTART; bne ++
            stz.b TrackNumber; stz.b Command
            ldx.w #MSU1IdleHandler; stx.w NMI_VECTOR
            jmp MSU1ActiveHandler.done
+;  lda.b Settings
+;  bit.b #FLAG_NO_INTERRUPT; beq +
        // No interrupt, check if current track is done playing
        lda.w REG_MSU_STATUS; and.b #$30; cmp.b #$10; beq done
+;  lda.b Command; bit.b #$04; beq +
    lda.w REG_MSU_STATUS; bit.b #$20; beq +
        lda.b CurrentTrack; sta.b PreviousTrack
+;  ldx.w #MSU1StopPlayback
    jmp MSU1ActiveHandler.updateHandler

done:
    jmp MSU1ActiveHandler.done
}

function MSU1StopPlayback {
    // Avoid causing a buzz on the SD2SNES
    stz.w REG_MSU_VOLUME
    // Stop current track (with resume flag, if requested, and if currently looping)
    lda.w REG_MSU_STATUS; bit #$10; beq +
        //stz.w REG_MSU_CONTROL
        lsr; lsr; lsr; and.b #$04; and.b Command//; beq +
        //lda.b Command; and.b #$04//; beq +
            sta.w REG_MSU_CONTROL
+;  
    ldx.w #MSU1TrackLoad
    jmp MSU1ActiveHandler.updateHandler
}

// Load the requested track
function MSU1TrackLoad {
    // Check that the current track is stopped (SD2SNES workaround)
    lda.w REG_MSU_STATUS
    bit #$20; bne stop
    bit #$10; bne done

    // Load new track
    lda.b TrackNumber
    sta.w REG_MSU_TRACK_LO; stz.w REG_MSU_TRACK_HI
    sta.b CurrentTrack; stz.b TrackNumber
    lda.b Command; and.b #$03; sta.b Command

    ldx.w #MSU1CheckLoadedTrack
    jmp MSU1ActiveHandler.updateHandler

stop:
    ldx.w #MSU1StopPlayback
    jmp MSU1ActiveHandler.updateHandler
    
done:
    jmp MSU1ActiveHandler.done
}

function MSU1CheckLoadedTrack {
    // Check if the audio is currently busy loading
    lda.w REG_MSU_STATUS; bit.b #$40; bne done
    
    // If we try and load a new track while this one
    // is still loading switch to the new one instead
    lda.b TrackNumber; beq +
        ldx.w #MSU1IdleHandler; stx.w NMI_VECTOR
        bra done

if {defined ENABLE_MSU_FALLBACK} {
    // Check if the track is missing
+;  lda.w REG_MSU_STATUS; bit.b #$08; beq +
        // If the track is missing, attempt to load fallback
        sep #$10
            lda.b CurrentTrack; tax
            lda.w MSUFallbackTable,x; sta.b TrackNumber
        rep #$10
        ldx.w #MSU1IdleHandler; stx.w NMI_VECTOR
        bra done
}

+;  ldx.w #MSU1Command
    jmp MSU1ActiveHandler.updateHandler

done:
    jmp MSU1ActiveHandler.done
}

function MSU1Command {
    lda.b CurrentVolume; sta.w REG_MSU_VOLUME
    //lda.b #$FF; sta.w REG_MSU_VOLUME
    lda.b Command
    and.b #$07; sta.w REG_MSU_CONTROL
    stz.b Command
    ldx.w #MSU1IdleHandler; stx.w NMI_VECTOR
    jmp MSU1ActiveHandler.done
}

function MSU1Fade {
    lda.b TrackNumber; ora.b Command; beq +
        lda.b Settings; bit.b FLAG_NO_INTERRUPT; beq idle

+;  lda.b CurrentVolume; cmp.b TargetVolume; beq endFade; bcc increment

        // Decrement and check for overflow
        sbc.b FadeRate; bcc endFade
        // Check for non-overflow fade past target
        cmp.b TargetVolume; bcs done; bra endFade

increment:  // Increment and check for overflow
        adc.b FadeRate; bcs endFade
        // Check for non-overflow fade past target
        cmp.b TargetVolume; bcc done

endFade:
    lda.b TargetVolume; sta.b CurrentVolume; sta.w REG_MSU_VOLUME

idle:
    ldx.w #MSU1IdleHandler; stx.w NMI_VECTOR
    jmp MSU1ActiveHandler.done

done:
    sta.b CurrentVolume; sta.w REG_MSU_VOLUME
    jmp MSU1ActiveHandler.done
}

if {defined ENABLE_MSU_FALLBACK} {
MSUFallbackTable:
    //  x0  x1  x2  x3  x4  x5  x6  x7  x8  x9  xA  xB  xC  xD  xE  xF
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // 0x
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // 1x
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // 2x
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$60,$00,$00,$00  // 3x
    db $00,$47,$47,$47,$47,$47,$47,$00,$00,$00,$00,$00,$00,$00,$00,$00  // 4x
    db $00,$13,$14,$00,$00,$00,$55,$00,$00,$00,$00,$00,$54,$00,$00,$00  // 5x
    db $00,$00,$60,$22,$02,$06,$0A,$2F,$00,$31,$05,$09,$06,$50,$00,$00  // 6x
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00  // 7x
}
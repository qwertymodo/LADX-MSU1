architecture wdc65816

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
MSUIdle:            // $1800
db $01

MSUTrackNumber:     // $1801
db $00

MSUCommand:         // $1802
db $00

MSUSetSettings:     // $1803
db $00

MSUClearSettings:   // $1804
db $00

MSUTargetVolume:    // $1805
db $00

MSUCurrentVolume:   // $1806
db $00

MSUFadeRate:        // $1807
db $10

MSUSettings:        // $1808
db FLAG_AUTO_RESUME

MSUCurrentTrack:    // $1809
db $00

MSUPreviousTrack:   // $180A
db $00

origin $000E
MSUHandlerPointer:  //$180E
dw MSU1ActiveHandler.done

// Must be in bank $00!
origin $0010
function MSU1NMISetup {
    php
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
        lda $4210
        lda.b #$B1; sta $4200;

done:
    plp
    cli
    rts
}

function MSU1IdleHandler {
    php
    sep #$20
        pha
        lda.w $4210
        lda.l {BASEADDRESS}; beq notIdle
    pla; plp
    rti

notIdle:
        phb; phd
        rep #$10
            phx
            ldx.w #{BASEADDRESS}; phx; pld
            lda.b #$00; pha; plb

        +;  lda.b MSUTrackNumber; beq ++
                lda.b MSUClearSettings; ora.b MSUSetSettings; beq +
                    // Set settings change handler
                    ldx.w #MSU1ChangeSettings
                    bra activate
                // Set track load handler
            +;  ldx.w #MSU1TrackPreload
                bra activate
        +;  lda.b MSUCommand; beq +
                // Set command handler
                ldx.w #MSU1Command
                bra activate
        +;  lda.b MSUCurrentVolume; cmp.b MSUTargetVolume; beq +
                // Set fade handler
                ldx.w #MSU1Fade
                bra activate
        +;  lda.b MSUSettings; bit.b #FLAG_AUTO_RESUME; beq idle
            lda.w REG_MSU_STATUS; and.b #$30; cmp.b #$10; bne idle
                ldx.w #MSU1PlaybackMonitor
                bra activate
idle:   
        inc MSUIdle;
        bra done
activate:
        stx.b MSUHandlerPointer
        ldx.w #MSU1ActiveHandler; stx.w NMI_VECTOR
done:
        plx; pld; plb; pla; plp;
        rti
}

function MSU1ActiveHandler {
    php
    sep #$20; rep #$10
    phb; phd; pha; phx;
        lda.w $4210
        ldx.w #{BASEADDRESS}; phx; pld
        lda.b #$00; pha; plb
        jmp (MSUHandlerPointer)
updateHandler:
    stx.b MSUHandlerPointer
done:
    plx; pla; pld; plb; plp;
    rti
}

// Apply new settings and return
function MSU1ChangeSettings {
    lda.b MSUClearSettings; eor.b #$FF; and.b MSUSettings;
    ora.b MSUSetSettings; sta.b MSUSettings
    stz.b MSUSetSettings; stz.b MSUClearSettings
    ldx.w #MSU1TrackPreload
    jmp MSU1ActiveHandler.updateHandler
}

function MSU1TrackPreload {
    // Check if we're currently playing
    lda.w REG_MSU_STATUS; bit.b #$10; beq +
    // Check if we're loading a new track or restarting the same one
    lda.b MSUTrackNumber; cmp.b MSUCurrentTrack; bne +
        // Check if reloading the same track is currently allowed
        lda.b MSUSettings; bit.b #FLAG_ALLOW_RESTART; bne ++
            stz.b MSUTrackNumber; stz.b MSUCommand
            ldx.w #MSU1IdleHandler; stx.w NMI_VECTOR
            jmp MSU1ActiveHandler.done
+;  lda.b MSUSettings
+;  bit.b #FLAG_NO_INTERRUPT; beq +
        // No interrupt, check if current track is done playing
        lda.w REG_MSU_STATUS; and.b #$30; cmp.b #$10; beq done
+;  lda.b MSUCommand; bit.b #$04; beq +
    lda.w REG_MSU_STATUS; bit.b #$20; beq +
        lda.b MSUCurrentTrack; sta.b MSUPreviousTrack
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
        lsr; lsr; lsr; and.b #$04; and.b MSUCommand//; beq +
        //lda.b MSUCommand; and.b #$04//; beq +
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
    lda.b MSUTrackNumber
    sta.w REG_MSU_TRACK_LO; stz.w REG_MSU_TRACK_HI
    sta.b MSUCurrentTrack; stz.b MSUTrackNumber
    lda.b MSUCommand; and.b #$03; sta.b MSUCommand

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
    lda.b MSUTrackNumber; beq +
        ldx.w #MSU1IdleHandler; stx.w NMI_VECTOR
        bra done

+;  ldx.w #MSU1Command
    jmp MSU1ActiveHandler.updateHandler

done:
    jmp MSU1ActiveHandler.done
}

function MSU1Command {
    lda.b MSUCommand
    and.b #$07; sta.w REG_MSU_CONTROL
    stz.b MSUCommand
    lda.b MSUCurrentVolume; sta.w REG_MSU_VOLUME
    //lda.b #$FF; sta.w REG_MSU_VOLUME
    ldx.w #MSU1IdleHandler; stx.w NMI_VECTOR
    jmp MSU1ActiveHandler.done
}

function MSU1Fade {
    lda.b MSUTrackNumber; ora.b MSUCommand; beq +
        lda.b MSUSettings; bit.b FLAG_NO_INTERRUPT; beq idle

+;  lda.b MSUCurrentVolume; cmp.b MSUTargetVolume; beq endFade; bcc increment

        // Decrement and check for overflow
        sbc.b MSUFadeRate; bcc endFade
        // Check for non-overflow fade past target
        cmp.b MSUTargetVolume; bcs done; bra endFade

increment:  // Increment and check for overflow
        adc.b MSUFadeRate; bcs endFade
        // Check for non-overflow fade past target
        cmp.b MSUTargetVolume; bcc done

endFade:
    lda.b MSUTargetVolume; sta.b MSUCurrentVolume; sta.w REG_MSU_VOLUME

idle:
    ldx.w #MSU1IdleHandler; stx.w NMI_VECTOR
    jmp MSU1ActiveHandler.done

done:
    sta.b MSUCurrentVolume; sta.w REG_MSU_VOLUME
    jmp MSU1ActiveHandler.done
}

function MSU1PlaybackMonitor {
    lda.w REG_MSU_STATUS; bit #$20; bne idle; bit.b #$10; beq +
        lda.b MSUSettings; bit.b #FLAG_NO_INTERRUPT; beq +
        lda.b MSUClearSettings; bit.b #FLAG_NO_INTERRUPT; beq done

+;  lda.b MSUPreviousTrack; beq idle
    lda.w REG_MSU_STATUS; bit #$10; bne done
    lda.b MSUTrackNumber; ora.b MSUCommand; bne idle

    lda.b MSUPreviousTrack; sta.b MSUTrackNumber; stz.b MSUPreviousTrack
    lda.b #$03; sta.b MSUCommand
    stz.b MSUCurrentVolume
    ldx.w #MSU1TrackPreload; jmp MSU1ActiveHandler.updateHandler

idle:
    ldx.w #MSU1IdleHandler; stx.w NMI_VECTOR
done:
    jmp MSU1ActiveHandler.done
}

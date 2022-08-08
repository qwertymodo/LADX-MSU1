MSU1SplashScreenPalette:
PAL01()
// Palette 0
BGR555($000000)
BGR555($FFFFFF)
BGR555($FF0000)
BGR555($000000)
//Palette 1
db $00,$00,$00,$00

fill $10-(pc()-MSU1SplashScreenPalette),$00

MSU1SplashScreenSFX:
SOUND()
db $19
db $00
db $02
db $00

fill $0B,$00

MSU1InitPayload:
JUMP({MSU1BASE}+$10,$0000)

MSU1CodePayload:
insert "sgb_msu1.bin"

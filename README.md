# Link's Awakening MSU-1

This ROM hack adds MSU-1 audio support to Link's Awakening DX.  MSU-1 support for Game Boy games requires the use of the Super Game Boy, so a fully compatible Super Game Boy emulator or flash cart must be used.

## Patching The Game

This patch is meant to be applied to the .gbc ROM file for Link's Awakening DX.  Patch files are provided for all known official revisions of the game.  Use Floating IPS (FlIPS) or beat to apply the appropriate .bps patch to the corresponding version of the game.  BPS patch files include checksums to ensure that the patch is applied to the correct base ROM.  Note that sometimes revisions of this game are labeled as "Rev A" or "Rev B".  In this case, "A" is version 1.1, and "B" is version 1.2.  Files with no revision listed are 1.0.

## Running The Game

### PC Emulators
Currently, only bsnes and some of its forks (such as bsnes+) support MSU-1 on SGB.  SGB game loading differs between versions, but generally you will install the SGB boot ROM into the emulator's system folder, then load the SGB BIOS file using the System>Load Game or Sytem>Load Special>Load Super Game Boy Cartridge dialog, and then it will prompt you to load the GB ROM file.  Due to inconsistencies in the MSU-1 file matching between different versions of different forks of the emulator, the best option for file naming is to ensure that the file names match for the SGB BIOS file, the GB ROM file, the MSU data ROM file, and all PCM files.

## SD2SNES/FXPAK Pro/MiSTer
SGB + MSU-1 support is currently implemented in the SD2SNES/FXPAK Pro flash cart, as well as in the MiSTer FPGA SGB core.  Setup for these devices involves copying the SGB BIOS and boot ROM files into the correct system folder, and then renaming all MSU-1 related files (MSU-1 data ROM and PCM audio files) to match the GB ROM file name, then simply load the GB ROM file normally.

## Building From Source
Building on Linux requires the use of ARM9's fork of the bass assembler, which can be downloaded [here](https://github.com/ARM9/bass/releases/latest).

Also required is Floating IPS (Flips) v1.31, wich can be downloaded [here](https://www.smwcentral.net/?a=details&id=11474&p=section)

### Base Game
To build a specific version of the game, the original ROM must be copied to the root directory of this repository and renamed to ladx_(region code)(revision).gbc.

Valid region codes are:

J (JPN)<br />
U (USA)<br />
F (FRA)<br />
G (GER)<br />

Valid revisions are 1.0-1.2, depending on the region.

e.g.

ladx_j1.0.gbc<br />
ladx_u1.2.gbc<br />
ladx_f1.1.gbc<br />
etc.

Once the base ROM has been provided, you can build by running

> make version

where "version" is the region code and revision, without a '.' in the version number.

e.g.

> make j10<br />
> make u12<br />
> make f11<br />

etc.

The makefile does not currently support building on Windows, but you can manually invoke the assembler, or you can use WSL on Windows 10+.

## PCM Audio Tracks
The full track list can be found [here](ladx-msu1.asm)
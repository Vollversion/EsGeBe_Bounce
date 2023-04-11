# EsGeBe Bounce

Little intro for the Super Game Boy we made during the Revision 2023 demoparty.

## PLEASE DO NOT JUDGE ME FOR THIS CODE. I ONLY UPLOADED THIS TO DOCUMENT MY DRUNKEN, TIRED STATE AND MY DESPERATION TO FINISH THIS IN TIME FOR THE COMPO DEADLINE. I WILL UPLOAD A CLEANED AND FIXED VERSION IN A COUPLE OF DAYS. 
---
### If you ware interested in the technical details, please take a look at the .nfo file and contact me (BinaryCounter) about any questions you might have.
---


- Music composition: **Sebb** (https://www.youtube.com/@Sebb_Music)
- Music programming: **Livvy94** (https://www.youtube.com/@livvy94)
- Code: **BinaryCounter** (https://twitter.com/BinaryCounter)



# Build

## Dependencies

- A *nix-like environment (Cygwin works fine for Windows users).
- make
- LibSFX (https://github.com/Optiroc/libSFX)
- RGBDS (https://github.com/gbdev/rgbds)
- Python 3

## Build process

- Adjust the loaction of the LibSFX directory in `SNES/Makefile`
- enter the root directory of this project and run `build.sh`
- If the build succeds, your GB ROM will appear in `GB/bin/`

# Running

## Hardware
- Just put the ROM on any GB flashcart of your choice. SD2SNES works too.
- This demo was programmed for PAL Super Nintendo and PAL Super Gameboy 1
- Since this demo does not make use of PAL-exclusive features and the SGB1 BIOS is regionless, it might also work on NTSC hardware. I treportedly also works on SGB2 (Tested by @TomTheDragon with a SD2SNES at the party)

## Emulator

- Super Game Boy emulator support can be spotty at times.
- I recommend using Mesen2 (https://github.com/SourMesen/Mesen2), it has excellent development/debugging features as well. Force SGB1 mode and PAL for best results.
- In any case, you'll need a SGB1 BIOS ROM. One way to legally aquire this is to dump it from your own hardware, either through a cartridge dumper or by using the technique demonstrated in this demo to make your own program that dumps the ROM to the flashcart.
  

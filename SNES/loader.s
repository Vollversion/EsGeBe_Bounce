.include "libSFX.i"

.segment "ROM1"
Main:
.org $7F0000



lda #$00
pha
plb ; push to DB too

lda #02
sta $2140

; Set NMI Handler
lda #.lobyte(VBlank_None)
sta $BB
lda #.hibyte(VBlank_None)
sta $BC
lda #$7F
sta $BD

stz $30
inc $30

lda #%10101010
sta $2123
lda #$ff
sta $212E
sta $212F

; Enable NMI
lda #$80
sta NMITIMEN

fade_loop:
lda $30
cmp #$81
bne fade_loop

stz $2123

RW_forced a8i16
; Disable NMI
stz NMITIMEN
lda     f:RDNMI  
lda #$80
sta INIDISP

ldx #0000
ldy #$FFFF
lda #$0
jsr .loword(demo_memset)

ldy #$280
sty .loword(VMADDL)

ldx #$E500
ldy #$800
lda #$7
jsr .loword(demo_memcpy)


ldx #$0
phx

ldy #$2000
sty .loword(VMADDL)

tilemap_loop:
ldx #.loword(tilemap)
ldy #22
lda #$7F
jsr .loword(demo_memcpy)
plx
inx
phx
cpx #100
bne tilemap_loop

ldy #.loword(text)
sty $04

.A8
.i8
RW_forced a8i8



; Set NMI Handler
lda #.lobyte(Vblank_scroller)
sta $BB
lda #.hibyte(Vblank_scroller)
sta $BC
lda #$7F
sta $BD
pha
plb ; push to DB too

RW_forced a16i16
ldy #0
ldx #0
tile_buffer_loop:
lda .loword(tile), y
sta .loword(tile_buffer),x
sta .loword(tile_buffer+2),x
sta .loword(tile_buffer+4),x
sta .loword(tile_buffer+6),x
sta .loword(tile_buffer+8),x
sta .loword(tile_buffer+10),x
sta .loword(tile_buffer+12),x
sta .loword(tile_buffer+14),x
txa
clc
adc #16
tax
iny
iny
cpy #66
bne tile_buffer_loop

RW_forced a8i8

lda #$80
sta INIDISP


lda #0

;; Generates Sine wave from quarter sine table. No arguments
;; 32 bytes
generate_sine:
tay ;1                                                         
tax ;1
sine_section1: ; section 1, copy
lda .loword(quarter_sine),y ;2
sta .loword(sine), y ;2
iny ;1
cpy #$40 ;2
bne sine_section1 ;2
tyx ;1
sine_section2: ; section 2, read backwards
lda a:.loword(sine),x ;2
sta .loword(sine),y ;2
iny ;1
dex ;1
bne sine_section2 ;2
sine_section3: ; section 3, flip section1-2 upside down
lda #$80 ;2
sbc .loword(sine-$80),y ;2
adc #$80
sta .loword(sine),y ;2
iny ;1
bne sine_section3 ;2

ldy #0
halfheight_loop:
lda .loword(sine),y
lsr
sta .loword(halfheight_sine),y
lsr
sta .loword(quarterheight_sine),y
tya
asl
asl
sta .loword(sine_offsets1),y
iny
bne halfheight_loop


jsr .loword(setupGreetsText)

RW_forced a8i16

lda #0
pha
plb ; push to DB too


ldy #$6000
sty .loword(VMADDL)
ldx #.loword(greets_buffer)
ldy #32*64*2
lda #$7F
jsr .loword(text_memcpy)

ldy #$1000
sty .loword(VMADDL)

ldx #.loword(tile_buffer)
ldy #$200
lda #$7F
jsr .loword(demo_memcpy)


lda #$12
sta CGADD
lda #$7f
ldx #.loword(tilePal)
ldy #$30
jsr .loword(demo_CGRAM_memcpy)

stz CGADD
lda #$7f
ldx #.loword(textPal)
ldy #$6
jsr .loword(demo_CGRAM_memcpy)

RW_forced a8i8





; Enable NMI
lda #$80
sta NMITIMEN

lda #$00
pha
plb ; push to DB too

lda     #bgmode(BG_MODE_2, 1, BG_SIZE_8X8, BG_SIZE_8X8, BG_SIZE_8X8, BG_SIZE_8X8)
sta     BGMODE
lda     #1
sta     BG12NBA
lda     #bgsc($4000, SC_SIZE_32X32)
sta     BG1SC
lda     #bgsc($9000, SC_SIZE_64X32)
sta     BG2SC
lda     #bgsc($A000, SC_SIZE_64X32)
sta     BG3SC

lda #%11
sta TM


lda #$00
sta INIDISP
stz $06

; Enable NMI
lda #$80
sta NMITIMEN





loop:

bra loop


Vblank_scroller:
inc $07

HDMA_set_absolute 1,0, $2C, RES_HDMA_SWITCH_TM

lda #%11
sta TM

lda #%10
sta HDMAEN

jsr .loword(fadein)

lda     f:RDNMI                   ;Clear NMI


ldy $60
iny
sty $60
RW_forced a16i16
tya
RW_forced a8i16
sta BG1VOFS
xba
sta BG1VOFS
xba
RW_forced a16i16
asl
asl
RW_forced a8i16
sta BG1HOFS
xba
sta BG1HOFS


phb
lda #$7F
pha
plb
RW_forced a8i8

lda #$3F
sta $0a63

ldx #0
sine_col_loop:
lda .loword(sine_offsets1), x
inc a
sta .loword(sine_offsets1), x
tay
lda .loword(quarterheight_sine), y
xba
txa
asl
tay
xba
sbc #$92
sta .loword(sine_columns1), y
lda #$C0
iny
sta .loword(sine_columns1), y
inx
cpx #64
bne sine_col_loop

lda .loword(sine_columns1)
plb
sta BG2VOFS
stz BG2VOFS



RW_forced a8i16
ldy #$5020
sty .loword(VMADDL)

ldx #.loword(sine_columns1)
ldy #$40
lda #$7F
jsr .loword(demo_memcpy)

ldy $02
iny
sty $02
RW_forced a16i16
tya
and #%1111111111111000
RW_forced a8i16

sta BG2HOFS
xba
sta BG2HOFS

lda $03
and #%00000001
beq screen2
ldy #$4800
sty .loword(VMADDL)
bra endScr
screen2:
ldy #$4C00
sty .loword(VMADDL)
endScr:
ldx $04
ldy #$20
lda #$7F
jsr .loword(text_memcpy)

lda $02
bne skipTextIncrement
RW_forced a16i16
lda $04
clc
adc #32
sta $04
skipTextIncrement:
RW_forced a16i16
lda $04
cmp #.loword(text+400)
bcc skipEnd
RW_forced a8i8
jsr .loword(fadeout)
skipEnd:
RW_forced a8i8
lda $06
cmp #$FE
beq greetsSetup

rti

greetsSetup:
lda #.lobyte(Vblank_greets)
sta $BB
lda #.hibyte(Vblank_greets)
sta $BC
lda #$7F
sta $BD

lda     #bgmode(BG_MODE_1, 1, BG_SIZE_8X8, BG_SIZE_8X8, BG_SIZE_8X8, BG_SIZE_8X8)
sta     BGMODE
lda     #bgnba(0, 0, 0, 0)
sta     BG12NBA
lda     #bgsc($8000, SC_SIZE_64X32)
sta     BG1SC
lda     #bgsc($B800, SC_SIZE_32X64)
sta     BG2SC

lda #%10
sta HDMAEN


stz BG2VOFS
stz BG2VOFS
stz BG2HOFS
stz BG2HOFS
stz $20
stz $21
stz $22

rti

Vblank_greets:
inc $07
jsr .loword(fadein)

lda $07
and #$01
bne doingSomething
rti
doingSomething:



RW_forced a8i16
ldy $20
cpy #$100
bne notPageBound
lda $22
bne notScrolling
stz $20
inc $20
stz $21
lda #$ff
sta $22
lda     #bgsc($C000, SC_SIZE_32X64)
sta     BG2SC

notPageBound:
ldy $20
iny
sty $20
RW_forced a16i16
tya
RW_forced a8i16
sta BG2VOFS
xba
sta BG2VOFS
notScrolling:

RW_forced a8i8


rti

VBlank_None:
lda #$80
sbc $30
sta $2126
lda #$80
adc $30
sta $2127
inc $30
inc $30
rti

demo_memset:
RW_assume a8i16
stz     MDMAEN          ;Disable DMA
stx     VMADDL          ;Destination offset
sty     DAS7L           ;Length
sta     ZPAD            ;Source value
lda     #VMA_TIMING_1   ;VRAM transfer mode
sta     VMAINC
ldx     #$1809          ;Mode: DMA_DIR_MEM_TO_PPU + DMA_FIXED + DMA_TRANS_2_LH, Destination: $4218
stx     DMAP7
ldx     #ZPAD           ;Source offset
stx     A1T7L
lda     #^ZPAD          ;Source bank
sta     A1B7
lda     #%10000000
sta     MDMAEN
rts

demo_memcpy:
RW_assume a8i16
stz     MDMAEN          ;Disable DMA
stx     A1T7L           ;Data offset
sta     A1B7            ;Data bank
sty     DAS7L           ;Size
lda     #$01
sta     DMAP7           ;DMA mode (word, normal, increment)
lda     #$18
sta     BBAD7           ;Destination register = VMDATA ($2118/19)
lda     #%10000000
sta     MDMAEN          ;Start DMA transfer
rts

text_memcpy:
RW_assume a8i16
stz     MDMAEN          ;Disable DMA
stx     A1T7L           ;Data offset
sta     A1B7            ;Data bank
lda #$00
sta VMAINC
sty     DAS7L           ;Size
lda     #$00
sta     DMAP7           ;DMA mode (word, normal, increment)
lda     #$18
sta     BBAD7           ;Destination register = VMDATA ($2118/19)
lda     #%10000000
sta     MDMAEN          ;Start DMA transfer
lda #$80
sta VMAINC
rts

demo_CGRAM_memcpy:
        RW_assume a8i16
        stz     MDMAEN          ;Disable DMA
        stx     A1T7L           ;Data offset
        sta     A1B7            ;Data bank
        sty     DAS7L           ;Size
        stz     DMAP7           ;DMA mode (byte, normal increment)
        lda     #$22
        sta     BBAD7           ;Destination register = $2122
        lda     #%10000000
        sta     MDMAEN          ;Start DMA transfer
        rts



fadein:
lda $06
cmp #$10
beq fadein_complete
lda $07
and #%00000001
bne fadein_complete
lda $06
sta INIDISP
inc $06
fadein_complete:
rts

fadeout:
lda $06
cmp #$FF
beq fadeout_complete
lda $07
and #%00000001
bne fadeout_complete
lda $06
sta INIDISP
dec $06
dec $06
fadeout_complete:
rts

setupGreetsText:
RW_forced a8i16
ldx #0
ldy #0
setupGreetsTextLoop:
lda .loword(greets), x
beq newline
sta .loword(greets_buffer),y
iny
inx
cpx #.loword(greetsEnd-greets)
bne setupGreetsTextLoop
rts
newline:
RW_forced a16i16
tya
and #%1111111111100000
inc a
adc #32
tay
RW_forced a8i16
inx
cpx #.loword(greetsEnd-greets)
bne setupGreetsTextLoop
rts


text:
.byte "HEYO, THIS IS A LITTLE PARTYHACK DEMONSTRATING TAKING OVER THE SNES FROM A GAMEBOY CART USING OBSCURE SGB COMMANDS. TO DO THIS IN 4K WE ARE ABUSING CODE AND ASSETS FROM THE BIOS, LIKE THIS FONT OR THE INSTRUMENTS AND SOUND DRIVER. THE TUNE YOU ARE HEARING WAS WRITTEN BY SEBB AND PORTED TO N-SPC BY LIVVY94. WE NEED MORE DEMOS ON THIS WEIRD PLATFORM. ANYWAY, ENJOY YOUR REVISION EVERYONE, CHEERS. AMIGAAAAAAAAAAAAAAAAAAAAAAAA",0
greets:
.byte " GREETZ:",0,0,0,"MOLIVE",0,"FGENESIS",0,"4PLAY",0,"GLOWBUSH",0,"INFU",0,"SOUR",0,"NOVA SQUIRREL",0,"SALKINITZOR",0,"THRONO CRIGGER",0,"FLOPINE",0,"EVERYONE FROM ABOC",0,"JESSA JOYCE",0,"SUMMERSAULT",0,"MARYSTRAWBERRY",0,"PLASMARIEL",0,"THE PK HACK CREW",0,"KALEIDOSIUM",0,"KANDOWONTU",0,"BISQUICK",0,"ANDREW",0,"DRVERTEX",0,"ROPESNEK",0,"FRAILDOG",0,0,"ANYONE WHO MAKES A DEMO",0,"ON THIS WEIRD PLATFORM",0,0,0,0,0,0,0,0,0,0,0,0,"COMPOSITION:   SEBB",0,0,"SOUND PROGRAM: LIVVY94",0,0,"CODE:          BINARYCOUNTER",0,0,0,0,"VOLLVERSION WILL BE BACK"
greetsEnd:
textPal:
.byte $02,$20,$FF,$11,$30,$00 

tilePal:
.byte $21,$04,$42,$10,$84,$20,$05,$29,$86,$31,$A6,$3A,$C9,$2F,$F4,$33,$DF,$23,$9E,$1E,$F9,$21,$1E,$11,$F4,$1C,$53,$25,$CE,$2C,$A9,$24,$C8,$34,$B1,$5C,$9E,$6D,$BF,$6A,$76,$7F,$8E,$7E,$E8,$7D,$43,$65


tile: .byte $FF, $00, $00, $00, $00, $FF, $00, $00, $FF, $FF, $00, $00, $00, $00, $FF, $00, $FF, $00, $FF, $00, $00, $FF, $FF, $00, $FF, $FF, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $FF, $FF, $00, $FF, $00, $00, $FF, $FF, $FF, $00, $FF, $FF, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF
tilemap: .byte $00,$04, $01,$04, $02,$04, $03,$04, $04,$04, $05,$04, $09,$04, $0a,$04, $0b,$04, $0c,$04, $0d,$04

RES_HDMA_SWITCH_TM:
.byte 80, tm(ON, ON, OFF, OFF, OFF), 80, tm(OFF, ON, OFF, OFF, OFF), 1, tm(ON, ON, OFF, OFF, OFF),0,0 

quarter_sine:
.byte $80, $83, $86, $89, $8C, $90, $93, $96, $99, $9C, $9F, $A2, $A5, $A8, $AB, $AE, $B1, $B3, $B6, $B9, $BC, $BF, $C1, $C4, $C7, $C9, $CC, $CE, $D1, $D3, $D5, $D8, $DA, $DC, $DE, $E0, $E2, $E4, $E6, $E8, $EA, $EB, $ED, $EF, $F0, $F1, $F3, $F4, $F5, $F6, $F8, $F9, $FA, $FA, $FB, $FC, $FD, $FD, $FE, $FE, $FE, $FF, $FF, $FF 
.byte "This code is awful, please don't look at it"
sine: .res 256
halfheight_sine: .res 256
quarterheight_sine: .res 256
sine_offsets1: .res 256
sine_columns1: .res 256
text_buffer: .res 1024
greets_buffer: .res 2048
tile_buffer: .res 15*8*4














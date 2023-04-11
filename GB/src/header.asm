
INCLUDE "defines.asm"


SECTION "Header", ROM0[$100]


	jr EntryPoint

	; Make sure to allocate some space for the header, so no important
	; code gets put there and later overwritten by RGBFIX.
	; RGBFIX is designed to operate over a zero-filled header, so make
	; sure to put zeros regardless of the padding value. (This feature
	; was introduced in RGBDS 0.4.0, but the -MG etc flags were also
	; introduced in that version.)
	ds $150 - @, 0

EntryPoint:
Reset::

	; Kill sound
	xor a
	ldh [rNR52], a

	ei

	;Turn on LCD
	ld A, $80
	ldh [rLCDC], A
	
	ld a, $01
	ldh [rIE], a

	ld de, SNESCode
	ld hl, $8000
	ld bc, $800
	call LCDMemcpy

	ld de, SNESCode
	ld hl, $8000
	ld bc, $800
	call LCDMemcpy

	ld de, SNESCode
	ld hl, $8000
	ld bc, $800
	call LCDMemcpy

	di
	
	;Turn off LCD
	ld A, $00
	ldh [$40], A
	
	ld de, SBN
	ld hl, $8000
	ld bc, $800
	call LCDMemcpy

	call FillScreenWithSGBMap
	
	ld hl, TransferSoundPacket
	call SendPackets


	ld de, SNESCode
	ld hl, $8000
	ld bc, $800
	call LCDMemcpy


	ld de, SNESCode
	ld hl, $8000
	ld bc, $800
	call LCDMemcpy

	ld de, SNESCode
	ld hl, $8000
	ld bc, $800
	call LCDMemcpy


	ld de, SNESCode
	ld hl, $8000
	ld bc, $800
	call LCDMemcpy

		;Turn off LCD
		ld A, $00
		ldh [$40], A
		

	ld de, SNESCode
	ld hl, $8000
	ld bc, $800
	call LCDMemcpy
	
	call FillScreenWithSGBMap
	
	ld hl, TransferDataPacket
	call SendPackets
	
	ld hl, JumpPacket
	call SendPackets
	
	stop
	
TransferSoundPacket:
	sgb_packet SOU_TRN, 1, $00, $00, $7F ,0,0,0,0,0,0,0,0,0,0,0,0,0
		

	TransferDataPacket:
		sgb_packet DATA_TRN, 1, $00, $00, $7F ,0,0,0,0,0,0,0,0,0,0,0,0,0
	
	JumpPacket:
		sgb_packet JUMP, 1, $00, $00, $7F ,0,0,0,0,0,0,0,0,0,0,0,0,0
	
	

SBN:
	dw 28 ; Size of pattern data
	dw $2bAF ; Pattern data start
	incbin "demosong.spc", $3200, 28
	dw 1222
	dw $3118
	incbin "demosong.spc", $3218, 1222
	dw 0
	dw $400


	SNESCode:
	INCBIN "loader.sfc",$8000,$800
	
	

SECTION "OAM DMA routine", ROMX



SECTION "Global vars", HRAM

; 0 if CGB (including DMG mode and GBA), non-zero for other models
hConsoleType:: db

; Copy of the currently-loaded ROM bank, so the handlers can restore it
; Make sure to always write to it before writing to ROMB0
; (Mind that if using ROMB1, you will run into problems)
hCurROMBank:: db


SECTION "OAM DMA", HRAM



SECTION UNION "Shadow OAM", WRAM0,ALIGN[8]

wShadowOAM::
	ds NB_SPRITES * 4


; This ensures that the stack is at the very end of WRAM
SECTION "Stack", WRAM0[$D000 - STACK_SIZE]

	ds STACK_SIZE
wStackBottom:


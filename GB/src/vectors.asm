
INCLUDE "defines.asm"

SECTION "Vectors", ROM0[0]
NULL::
	; This traps jumps to $0000, which is a common "default" pointer
	; $FFFF is another one, but reads rIE as the instruction byte
	; Thus, we put two `nop`s that may serve as operands, before soft-crashing
	; The operand will always be 0, so even jumps will work fine. Nice!
	nop
	nop
	rst Crash
	ds $08 - @ ; 5 free bytes

; Waits for the next VBlank beginning
; Requires the VBlank handler to be able to trigger, otherwise will loop infinitely
; This means IME should be set, the VBlank interrupt should be selected in IE,
; and the LCD should be turned on.
; WARNING: Be careful if calling this with IME reset (`di`), if this was compiled
; with the `-h` flag, then a hardware bug is very likely to cause this routine to
; go horribly wrong.
; Note: the VBlank handler recognizes being called from this function (through `hVBlankFlag`),
; and does not try to save registers if so. To be safe, consider all registers to be destroyed.
; @destroy Possibly every register. The VBlank handler stops preserving anything when executed from this function
WaitVBlank::
	ld a, 1
	ldh [hVBlankFlag], a
.wait
	halt
	jr .wait
	ds $10 - 1 - @ ; 0 free bytes

MemsetLoop:
	ld a, d
; You probably don't want to use this for writing to VRAM while the LCD is on. See LCDMemset.
Memset::
	ld [hli], a
	ld d, a
	dec bc
	ld a, b
	or c
	jr nz, MemsetLoop
	ret
	ds $18 - @ ; 0 free bytes

MemcpySmall::
	ld a, [de]
	ld [hli], a
	inc de
	dec c
	jr nz, MemcpySmall
	ret
	ds $20 - @ ; 1 free byte

MemsetSmall::
	ld [hli], a
	dec c
	jr nz, MemsetSmall
	ret
	ds $28 - 3 - @ ; 0 free bytes

; Dereferences `hl` and jumps there
; All other registers are passed to the called code intact, except Z is reset
; Soft-crashes if the jump target is in RAM
; @param hl Pointer to an address to jump to
JumpToPtr::
	ld a, [hli]
	ld h, [hl]
	ld l, a
; Jump to some address
; All registers are passed to the called code intact, except Z is reset
; (`jp CallHL` is equivalent to `jp hl`, but with the extra error checking on top)
; Soft-crashes if attempting to jump to RAM
; @param hl The address of the code to jump to
CallHL::
	bit 7, h
	error nz
	jp hl
	ds $30 - @ ; 3 free bytes


; Jumps to some address
; All registers are passed to the target code intact, except Z is reset
; (`jp CallDE` would be equivalent to `jp de` if that instruction existed)
; Soft-crashes if attempting to jump to RAM
; @param de The address of the code to jump to
CallDE::
	bit 7, d
	push de
	ret z ; No jumping to RAM, boy!
	rst Crash
	ds $38 - @ ; 3 free bytes

; Perform a soft-crash. Prints debug info on-screen
Crash::
	ds $40 - @

; VBlank handler
	jp VBlankHandler
	ds $48 - @

; STAT handler
	reti
	ds $50 - @

; Timer handler
	reti
	ds $58 - @

; Serial handler
	reti
	ds $60 - @

; Joypad handler (useless)
	reti

SECTION "VBlank handler", ROM0

VBlankHandler:
reti
SECTION "VBlank HRAM", HRAM

; DO NOT TOUCH THIS
; When this flag is set, the VBlank handler will assume the caller is `WaitVBlank`,
; and attempt to exit it. You don't want that to happen outside of that function.
hVBlankFlag:: db

; High byte of the address of the OAM buffer to use.
; When this is non-zero, the VBlank handler will write that value to rDMA, and
; reset it.
hOAMHigh:: db

; Shadow registers for a bunch of hardware regs.
; Writing to these causes them to take effect more or less immediately, so these
; are copied to the hardware regs by the VBlank handler, taking effect between frames.
; They also come in handy for "resetting" them if modifying them mid-frame for raster FX.
hLCDC:: db
hSCY:: db
hSCX:: db
hBGP:: db
hOBP0:: db
hOBP1:: db

; Keys that are currently being held, and that became held just this frame, respectively.
; Each bit represents a button, with that bit set == button pressed
; Button order: Down, Up, Left, Right, Start, select, B, A
; U+D and L+R are filtered out by software, so they will never happen
hHeldKeys:: db
hPressedKeys:: db

; If this is 0, pressing SsAB at the same time will not reset the game
hCanSoftReset:: db

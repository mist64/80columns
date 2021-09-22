; 80COLUMNS.PRG
;
; * Original author unknown
; * Fast scrolling by Ilker Ficicilar
; * Reverse-engineered and improved by Michael Steil

; KERNAL defines
R6510  = $01
DFLTN  = $99   ; Default Input Device (0)
DFLTO  = $9A   ; Default Output (CMD) Device (3)
NDX    = $C6   ; No. of Chars. in Keyboard Buffer (Queue)
RVS    = $C7   ; Flag: Print Reverse Chars. -1=Yes, 0=No Used
LXSP   = $C9   ; Cursor X-Y Pos. at Start of INPUT
INDX   = $C8   ; Pointer: End of Logical Line for INPUT
BLNSW  = $CC   ; Cursor Blink enable: 0 = Flash Cursor
GDBLN  = $CE   ; Character Under Cursor
BLNON  = $CF   ; Flag: Last Cursor Blink On/Off
BLNCT  = $CD   ; Timer: Countdown to Toggle Cursor
CRSW   = $D0   ; Flag: INPUT or GET from Keyboard
PNT    = $D1   ; Pointer: Current Screen Line Address
PNTR   = $D3   ; Cursor Column on Current Line
QTSW   = $D4   ; Flag: Editor in Quote Mode, $00 = NO
LNMX   = $D5   ; Physical Screen Line Length
TBLX   = $D6   ; Current Cursor Physical Line Number
DATA   = $D7   ; Temp Data Area
INSRT  = $D8   ; Flag: Insert Mode, >0 = # INSTs
USER   = $F3   ; Pointer: Current Screen Color RAM loc.
KEYD   = $0277 ; Keyboard Buffer Queue (FIFO)
COLOR  = $0286 ; Current Character Color Code
GDCOL  = $0287 ; Background Color Under Cursor
SHFLAG = $028D ; Flag: Keyb'rd SHIFT Key/CTRL Key/C= Key
MODE   = $0291 ; Flag: $00=Disable SHIFT Keys, $80 = Enable SHIFT Keys
CINV   = $0314
IBASIN = $0324
IBSOUT = $0326
USRCMD = $032E

; new zero page defines
bitmap_ptr  = $DD
charset_ptr = $DF
tmp_ptr     = $E1

; addresses
VICSCN = $C000 ; NEW Video Matrix: 25 Lines X 80 Columns
VICCOL = $D800 ; new color RAM is in RAM at the same address
BITMAP = $E000

.ifndef USE_REU
USE_REU = 0
.endif

.if USE_REU

REU_STATUS      = $DF00                 ; Status register
REU_COMMAND     = $DF01                 ; Command register
REU_C64ADDR     = $DF02                 ; C64 base address register
REU_REUADDR     = $DF04                 ; REU base address register
REU_COUNT       = $DF07                 ; Transfer count register
REU_IRQMASK     = $DF09                 ; IRQ mask register
REU_CONTROL     = $DF0A                 ; Control register
REU_TRIGGER     = $FF00                 ; REU command trigger

OP_COPYFROM     = $ED
OP_COPYTO       = $EC
.macro REU_OP addr, len, op
        lda R6510
        pha
        lda #%00110101
        sta R6510
        lda #0
        sta $DF0A ; hold neither address
        lda #<(addr)
        sta REU_C64ADDR
        lda #>(addr)
        sta REU_C64ADDR+1


        lda #<(len)
        sta REU_COUNT
        lda #>(len)
        sta REU_COUNT+1

        ldx #op
        jsr reu_op
        pla
        sta R6510

.endmacro

.macro REU_COPYFROM addr, len
        REU_OP addr, len, OP_COPYFROM
.endmacro

.macro REU_COPYTO addr, len
        REU_OP addr, len, OP_COPYTO
.endmacro

.macro REU_MEMMOVE addr1, addr2, len
        REU_COPYTO addr1, len
        REU_COPYFROM addr2, len
.endmacro
.endif
; constants
COLUMNS = 80
LINES   = 25

.import charset

.segment "CODE"

start:
	sec
	jsr MODE_enable_i ; allow switching charsets, returns A=#$00
	sta QTSW
	sta INSRT ; disable quote and insert mode
	jsr cmd_clr ; clear screen
	lda #$3B ; bitmap mode
	sta $D011
	lda #$68
	sta $D018
	lda #$90 ; VIC bank $C000-$FFFF, bit 7 is important for cmd_graphics
	sta $DD00
	jsr cmd_graphics ; upper case
	sei
	lda #<new_cinv
	sta CINV
	lda #>new_cinv
	sta CINV + 1
	lda #<new_basin
	sta IBASIN
	lda #>new_basin
	sta IBASIN + 1
	lda #<new_bsout
	sta IBSOUT
	lda #>new_bsout
	sta IBSOUT + 1
	lda $D021
	asl
	asl
	asl
	asl
	sta bgcolor
	ora COLOR
	sta COLOR
	cli
	jmp ($A000) ; BASIC cold start

new_bsout:
	sta DATA
	pha
	lda DFLTO
	cmp #3
	bne :+
	txa
	pha
	tya
	pha
	lda DATA
	jsr bsout_core
	pla
	tay
	pla
	tax
	pla
	clc
	cli ; XXX user may have wanted interrupts off!
	rts
:	jmp $F1D5 ; original non-screen BSOUT

bsout_core:
	tax
	and #$60
	beq @2
	txa
	jsr $E684 ; if open quote toggle cursor quote flag
	jsr petscii_to_screencode
	clc
	adc RVS
	ldx COLOR
	jsr draw_move
	lda INSRT
	beq @1
	dec INSRT
@1:	rts
; special character
@2:	cpx #$0D ; CR
	beq special_char
	cpx #$8D ; LF
	beq special_char
	lda INSRT
	beq @3
	cpx #$94 ; INSERT
	beq special_char
	dec INSRT
	bpl @4
@3:	cpx #$14 ; DEL
	beq special_char
	lda QTSW
	beq special_char
; quote or insert mode
@4:	txa
	bpl @5
	sec
	sbc #$40
@5:	ora #$80
	ldx COLOR
draw_move:
	jsr _draw_char_with_col
	jmp move_csr_right

; interpret special character
special_char:
	txa
	bpl @1
	sec
	sbc #$60 ; fold $80-$9F -> $20-$3F
@1:	tay
	lda code_table,y
	clc
	adc #<rts0
	sta USRCMD
	lda #>rts0
	adc #0
	sta USRCMD + 1
	txa
	jmp (USRCMD)

.macro ADDR addr
	.byte addr - rts0
.endmacro

code_table:
	ADDR rts0
	ADDR rts0
	ADDR rts0
	ADDR rts0
	ADDR rts0
	ADDR set_col_white   ; $05: WHITE
	ADDR rts0
	ADDR rts0
	ADDR MODE_disable    ; $08: SHIFT DISABLE
	ADDR MODE_enable     ; $09: SHIFT ENABLE
	ADDR rts0
	ADDR rts0
	ADDR rts0
	ADDR cmd_cr          ; $0D: CR
	ADDR cmd_text        ; $0E: TEXT MODE
	ADDR rts0
	ADDR rts0
	ADDR move_csr_down   ; $11: CURSOR DOWN
	ADDR set_rvs_on      ; $12: REVERSE ON
	ADDR cmd_home        ; $13: HOME
	ADDR cmd_del         ; $14: DEL
	ADDR rts0
	ADDR rts0
	ADDR rts0
	ADDR rts0
	ADDR rts0
	ADDR rts0
	ADDR rts0
	ADDR set_col_red     ; $1C: RED
	ADDR move_csr_right  ; $1D: CURSOR RIGHT
	ADDR set_col_green   ; $1E: GREEN
	ADDR set_col_blue    ; $1F: BLUE
	ADDR rts0
	ADDR set_col_orange  ; $81: ORANGE
	ADDR rts0
	ADDR rts0
	ADDR rts0
	ADDR rts0
	ADDR rts0
	ADDR rts0
	ADDR rts0
	ADDR rts0
	ADDR rts0
	ADDR rts0
	ADDR rts0
	ADDR cmd_cr          ; $8D: LF
	ADDR cmd_graphics    ; $8E: GRAPHICS
	ADDR rts0
	ADDR set_col_black   ; $90: BLACK
	ADDR move_csr_up     ; $91: CURSOR UP
	ADDR set_rvs_off     ; $92: REVERSE OFF
	ADDR cmd_clr         ; $93: CLR
	ADDR cmd_inst        ; $94: INSERT
	ADDR set_col_brown   ; $95: BROWN
	ADDR set_col_ltred   ; $96: LIGHT RED
	ADDR set_col_dkgray  ; $97: DARK GRAY
	ADDR set_col_gray    ; $98: MIDDLE GRAY
	ADDR set_col_ltgreen ; $99: LIGHT GREEN
	ADDR set_col_ltblue  ; $9A: LIGHT BLUE
	ADDR set_col_ltgray  ; $9B: LIGHT GRAY
	ADDR set_col_purple  ; $9C: PURPLE
	ADDR move_csr_left   ; $9D: CURSOR LEFT
	ADDR set_col_yellow  ; $9E: YELLOW
	ADDR set_col_cyan    ; $9F: CYAN

rts0:	rts

set_col_black:
	lda #0
	.byte $2c
set_col_white:
	lda #1
	.byte $2c
set_col_red:
	lda #2
	.byte $2c
set_col_cyan:
	lda #3
	.byte $2c
set_col_purple:
	lda #4
	.byte $2c
set_col_green:
	lda #5
	.byte $2c
set_col_blue:
	lda #6
	.byte $2c
set_col_yellow:
	lda #7
	.byte $2c
set_col_orange:
	lda #8
	.byte $2c
set_col_brown:
	lda #9
	.byte $2c
set_col_ltred:
	lda #$0A
	.byte $2c
set_col_dkgray:
	lda #$0B
	.byte $2c
set_col_gray:
	lda #$0C
	.byte $2c
set_col_ltgreen:
	lda #$0D
	.byte $2c
set_col_ltblue:
	lda #$0E
	.byte $2c
set_col_ltgray:
	lda #$0F
set_col:
	sta COLOR
	lda bgcolor
	ora COLOR
	sta COLOR
	rts

MODE_disable:
MODE_enable:
	lsr
MODE_enable_i:
	lda #0
	ror
	eor #$80
	sta MODE
	rts

cmd_cr:
	lda #0
	sta INSRT
	sta QTSW
	sta RVS
move_csr_down_pntr:
	sta PNTR
move_csr_down:
	inc TBLX
	lda TBLX
	cmp #LINES
	bne calc_pnt_user
	dec TBLX
	jsr _scroll_up ;returns Z clear
	bne calc_pnt_user ;always

move_csr_right:
	inc PNTR
	lda PNTR
	sec
	sbc #COLUMNS
	beq move_csr_down_pntr
	rts ;returns Z clear

cmd_text:
cmd_graphics:
	asl
	lda $D018
	and #<~2
	bcs store_d018
	ora #2
store_d018:
	sta $D018
	rts

set_rvs_on:
set_rvs_off:
	asl
	lda #0
	ror
	eor #$80
	sta RVS
	rts

move_csr_up:
	lda TBLX
	beq calc_pnt_user
	dec TBLX
	bpl calc_pnt_user ;always

cmd_clr:
	lda #LINES - 1
	sta TBLX
:	jsr _clr_curline
	dec TBLX
	bpl :-

cmd_home:
	lda #0
	sta PNTR
	sta TBLX
calc_pnt_user:
	jsr calc_pnt

calc_user:
	lda TBLX
	asl a ;clear carry
	tax
	lda mul_40_tab,x
	sta USER
	lda mul_40_tab + 1,x
	adc #>VICCOL
	sta USER + 1
	rts ;returns Z clear because of LDA

cmd_del:
	lda PNTR
	beq move_csr_left
	pha
	dec PNTR
@1:	lda #' '
	ldy PNTR
	cpy #COLUMNS - 1
	php
	beq @2
	iny
	lda (PNT),y
@2:	ldx COLOR
	jsr _draw_char_with_col
	inc PNTR
	plp
	bne @1
	pla
	sta PNTR

move_csr_left:
	dec PNTR
	bpl @2
	lda TBLX
	beq @1
	jsr move_csr_up
	lda #COLUMNS - 1
@1:	sta PNTR
@2:	rts

cmd_inst:
	lda PNTR
	sta pntr2
	lda #COLUMNS
	sta PNTR
@1:	dec PNTR
	lda #' '
	ldy PNTR
	cpy pntr2
	php
	beq @2
	dey
	lda (PNT),y
@2:	ldx COLOR
	jsr _draw_char_with_col
	plp
	bne @1
	inc INSRT
	rts

clr_curline:
	jsr calc_pnt
	ldy #COLUMNS - 1
	lda #' '
:	sta (PNT),y
	dey
	bpl :-
	jsr calc_user
	ldy #40
	sty PNTR
	dey
	lda COLOR
:	sta (USER),y
	dey
	bpl :-
	jsr calc_bitmap_ptr
	tya
	ldy #160
:	dey
	sta (bitmap_ptr),y
	bne :-
	sty PNTR
	jsr calc_bitmap_ptr
	ldy #160
	lda #$FF
:	dey
	sta (bitmap_ptr),y
	bne :-
	rts

mul_40_tab:
	.repeat 25, i
	.word i*40
	.endrep

calc_bitmap_ptr:
	lda TBLX
	asl a ;clear carry
	tax
	lda PNTR
	and #$FE
	adc mul_80_tab,x
	sta bitmap_ptr
	lda mul_80_tab + 1,x
	adc #0
	asl bitmap_ptr
	rol
	asl bitmap_ptr
	rol
	adc #>BITMAP
	sta bitmap_ptr + 1
	rts

calc_pnt:
	lda TBLX
	asl a ;clear carry
	tax
	lda mul_80_tab,x
	sta PNT
	lda mul_80_tab + 1,x
	adc #>VICSCN
	sta PNT + 1
	rts

mul_80_tab:
	.repeat 25, i
	.word i*80
	.endrep

scroll_up:
	ldy PNTR
	sty pntr2
	lda (PNT),y
	jsr _draw_char ; draw character under cursor again XXX ???
; delay if CBM pressed
	lda SHFLAG
	and #4
	tay
	beq @2
; ***START*** identical to $E94B in KERNAL
	ldy #0
@1:	nop
	dex
	bne @1
	dey
	bne @1
@2:
        ; note that Y is now 0
; ***END*** identical to $E94B in KERNAL
; scroll screen up
.if USE_REU
        ; move bitmap RAM (starting at BITMAP) up by 320 bytes
        REU_MEMMOVE BITMAP+320, BITMAP, 24*40*8
        ; move character RAM (starting at VICSCN) up by 80 bytes
        REU_MEMMOVE VICSCN+80, VICSCN, 24*80
.else
	lda #COLUMNS
	sta PNT
	lda #>VICSCN
	sta PNT + 1
	sty tmp_ptr
	sta tmp_ptr + 1
:	lda (PNT),y
	sta (tmp_ptr),y
	iny
	bne :-
	inc PNT + 1
	inc tmp_ptr + 1
	lda PNT + 1
	cmp #200
	bcc :-
:	.repeat 48, i
	lda BITMAP + i * 160 + 320,y
	sta BITMAP + i * 160,y
	.endrepeat
	iny
	cpy #$a0
	beq :+
	jmp :-
:
.endif
	ldy #40
	lda #>VICCOL
	sty USER
	sta USER + 1
	ldy #0
	sty tmp_ptr
	sta tmp_ptr + 1
:	lda (USER),y
	sta (tmp_ptr),y
	iny
	bne :-
	inc USER + 1
	inc tmp_ptr + 1
	lda tmp_ptr + 1
	cmp #>(VICCOL+$0300)
	bcc :-
:	lda VICCOL + 807,y
	sta VICCOL + 807 - 40,y
	iny
	cpy #$C0
	bcc :-
	lda #LINES - 1
	sta TBLX
	jsr clr_curline
	lda pntr2
	sta PNTR
	lda #4
	sta BLNCT
	rts ;returns Z clear because of LDA
petscii_to_screencode:
	cmp #$FF ; PI
	bne @1
	lda #$7E ; screencode for PI
@1:	pha
	and #$E0
	ldx #6
@2:	cmp tab1-1,x
	beq @3
	dex
	bne @2
@3:	pla
	and #$1F
	ora tab2-1,x
	rts

tab1:	.byte $E0,$C0,$A0,$60,$40,$20
tab2:	.byte $60,$40,$60,$40,$00,$20

draw_char_with_col:
	stx DATA
	jsr draw_char

set_viccol:
	lda PNTR
	lsr a
	tay
	lda DATA
	sta (USER),y
	rts

draw_char:
	ldy PNTR
	sta (PNT),y
	ldy #$FF
	asl
	bcc @1
	clc
	iny
@1:	sty rvs_mask
	ldy is_text
	beq @2
	sec
@2:	sta charset_ptr
	lda #(>charset) >> 3
	rol
	asl charset_ptr
	rol
	asl charset_ptr
	rol
	sta charset_ptr + 1
	jsr calc_bitmap_ptr
	lda PNTR
	and #1
	bne @3
	ldy #7
	.repeat 8
	lda (charset_ptr),y
	eor rvs_mask
	eor (bitmap_ptr),y
	and #$F0
	eor (bitmap_ptr),y
	sta (bitmap_ptr),y
	dey
	.endrepeat
	rts
@3:	ldy #7
	.repeat 8
	lda (charset_ptr),y
	eor rvs_mask
	eor (bitmap_ptr),y
	and #$0F
	eor (bitmap_ptr),y
	sta (bitmap_ptr),y
	dey
	.endrepeat
	rts

new_basin:
; ***START*** almost identical to $F157 in KERNAL
	lda DFLTN
	bne @1
	lda PNTR
	sta LXSP + 1
	lda TBLX
	sta LXSP
	bpl @10 ;always

@3:	jsr bsout_core
@4:	lda NDX
	sta BLNSW
	beq @4
	sei
	lda BLNON
	beq @5
	lda #0
	sta BLNON
	lda #2
	sta BLNCT
	ldx GDCOL
	lda GDBLN
	jsr _draw_char_with_col
; ***START*** almost identical to $E5E7 in KERNAL
@5:	jsr $E5B4 ; input from the keyboard buffer
	cmp #$83
	bne @7
	ldx #9
	sei
	stx NDX
@6:	lda $ECE7 - 1,x ; "LOAD\rRUN\r"
	sta KEYD - 1,x
	dex
	bne @6
	beq @4
@7:	cmp #$0D
	bne @3
	ldy #COLUMNS - 1 ; ***DIFFERENCE***
	sty CRSW
@8:	lda (PNT),y
	cmp #$20
	bne @9
	dey
	bne @8
@9:	iny
	sty INDX
	ldy #0
; ***DIFFERENCE*** missing STY $0292
	sty PNTR
	sty QTSW
	lda LXSP
	bmi @11
; ***DIFFERENCE*** missing JSR
	cmp TBLX
	bne @11
	lda LXSP + 1
	sta PNTR
	cmp INDX
	bcc @11
	bcs @15

@1:	cmp #3
	bne @2
	sta CRSW
	lda LNMX
	sta INDX

@10:	tya
	pha
	txa
	pha
	lda CRSW
	beq @4
@11:	ldy PNTR
	lda (PNT),y
	sta DATA
	and #$3F
	asl DATA
	bit DATA
	bpl @12
	ora #$80
@12:	bcc @13
	ldx QTSW
	bne @14
@13:	bvs @14
	ora #$40
@14:	inc PNTR
	jsr $E684 ; if open quote toggle cursor quote flag
	cpy INDX
	bne @18
@15:	lda #0
	sta CRSW
	lda #$0D
	ldx DFLTN
	cpx #3
	beq @16
	ldx DFLTO
	cpx #3
	beq @17
@16:	jsr bsout_core ; ***DIFFERENCE*** (JSR $E716)
@17:	lda #$0D
@18:	sta DATA
	pla
	tax
	pla
	tay
	lda DATA
	cmp #$DE ; convert PI
	bne :+
	lda #$FF
:	clc
	rts
; ***END*** almost identical to $E5E7 in KERNAL

@2:	jmp $F173 ; part of BASIN
; ***END*** almost identical to $F157 in KERNAL

new_cinv:
	jsr $FFEA ; increment real time clock
	lda $D021
	asl
	asl
	asl
	asl
	sta bgcolor
	lda R6510
	pha
	lda #0
	sta R6510
	lda BLNSW
	bne @2
	dec BLNCT
	bne @2
	lda #30
	sta BLNCT
	ldy PNTR
	lsr BLNON
	ldx GDCOL
	lda (PNT),y
	bcs @1
	inc BLNON
	sta GDBLN
	lda PNTR
	lsr a
	tay
	lda (USER),y
	sta GDCOL
	ldx COLOR
	lda GDBLN
@1:	eor #$80
	jsr _draw_char_with_col
@2:	lda bgcolor
	cmp color2
	beq @5
	sta color2
	lda TBLX
	pha
	lda #LINES - 1
	sta TBLX
@3:	jsr calc_user
	ldy #40 - 1
@4:	lda (USER),y
	and #$0F
	ora color2
	sta (USER),y
	dey
	bpl @4
	dec TBLX
	bpl @3
	lda COLOR
	and #$0F
	ora color2
	sta COLOR
	lda GDCOL
	and #$0F
	ora color2
	sta GDCOL
	pla
	sta TBLX
	jsr calc_user
@5:	pla
	sta R6510
	lda $D018
	and #2
	cmp is_text
	beq @a6
	sta is_text
	lda PNTR
	pha
	lda TBLX
	pha
	jsr cmd_home
@a1:	ldy PNTR
	lda (PNT),y
	and #$7F
	cmp #$20
	beq @a3
@a2:	lda (PNT),y
	jsr _draw_char ; re-draw character
@a3:	lda PNTR
	cmp #COLUMNS - 1
	bne @a4
	lda TBLX
	cmp #LINES - 1
	beq @a5
@a4:	jsr move_csr_right
	bne @a1 ;always
@a5:	pla
	sta TBLX
	pla
	sta PNTR
	jsr calc_pnt
	jsr calc_user
@a6:	jmp $EA61

.if USE_REU
reu_op:
        lda #0
        sta REU_REUADDR
        sta REU_REUADDR+1
        sta REU_REUADDR+2

        stx REU_COMMAND

        lda REU_TRIGGER
        sta REU_TRIGGER

        rts
.endif

.macro exec0 addr, save_y
	php
	sei
.ifnblank save_y
	tay
.endif
	lda R6510
	pha
	lda #0
	sta R6510
.ifnblank save_y
	tya
.endif
	jsr addr
	pla
	sta R6510
	plp
	rts
.endmacro

_draw_char_with_col:
	exec0 draw_char_with_col, Y

_clr_curline:
	exec0 clr_curline

_draw_char:
	exec0 draw_char, Y

_scroll_up:
	exec0 scroll_up

bgcolor:
	.byte 0
pntr2:
	.byte 0
rvs_mask:
	.byte 0
color2:
	.byte 0
is_text:
	.byte 0

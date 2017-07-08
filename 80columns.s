; 80COLUMNS.PRG
; http://mikenaberezny.com/hardware/projects/c64-soft80/

COLOR  = $0286
CINV   = $0314
IBASIN = $0324
IBSOUT = $0326
USRCMD = $032E

	jsr LC806
	jmp ($A000) ; BASIC warm start

LC806:	jsr LC964
	lda #$00
	sta $D4
	sta $D8
	jsr LCA1C
	lda #$3B
	sta $D011
	lda #$68
	sta $D018
	lda #$90
	sta $DD00
	jsr LC9FC
	sei
	lda #<LCE31
	sta CINV
	lda #>LCE31
	sta CINV + 1
	lda #<LCCE6
	sta IBASIN
	lda #>LCCE6
	sta IBASIN + 1
	lda #<LC855
	sta IBSOUT
	lda #>LC855
	sta IBSOUT + 1
	lda #$00
	sta LCFF2
	lda COLOR
	sta $D020
	sta $D021
	cli
	rts

	nop
	nop

LC855:	pha
	lda $9A
	cmp #$03
	beq LC85F
	jmp $F1D5 ; part of BASIN

LC85F:	pla
	pha
	sta $D7
	txa
	pha
	tya
	pha
	lda $D7
	jsr LC874
	pla
	tay
	pla
	tax
	pla
	clc
	cli
	rts

LC874:	tax
	and #$60
	beq LC893
	txa
	jsr $E684 ; if open quote toggle cursor quote flag
	jsr LCC48
	clc
	adc $C7
	ldx COLOR
	jsr LCE84
	jsr LC9DA
	lda $D8
	beq LC892
	dec $D8
LC892:	rts

LC893:	cpx #$0D
	beq LC8C2
	cpx #$8D
	beq LC8C2
	lda $D8
	beq LC8A8
	cpx #$94
	beq LC8C2
	dec $D8
	jmp LC8B0

LC8A8:	cpx #$14
	beq LC8C2
	lda $D4
	beq LC8C2
LC8B0:	txa
	bpl LC8B6
	sec
	sbc #$40
LC8B6:	ora #$80
	ldx COLOR
	jsr LCE84
	jsr LC9DA
	rts

LC8C2:	txa
	bpl LC8C8
	sec
	sbc #$E0
LC8C8:	asl a
	tax
	lda LC8D9,x
	sta USRCMD
	lda LC8D9+1,x
	sta USRCMD + 1
	jmp (USRCMD)

LC8D9:	.addr LCAD7
	.addr LCAD7
	.addr LCAD7
	.addr LCAD7
	.addr LCAD7
	.addr LC959
	.addr LCAD7
	.addr LCAD7
	.addr LC95E
	.addr LC964
	.addr LCAD7
	.addr LCAD7
	.addr LCAD7
	.addr LC96A
	.addr LC978
	.addr LCAD7
	.addr LCAD7
	.addr LC981
	.addr LC995
	.addr LC99A
	.addr LC9A7
	.addr LCAD7
	.addr LCAD7
	.addr LCAD7
	.addr LCAD7
	.addr LCAD7
	.addr LCAD7
	.addr LCAD7
	.addr LC9D5
	.addr LC9DA
	.addr LC9EA
	.addr LC9EF
	.addr LCAD7
	.addr LC9F4
	.addr LCAD7
	.addr LCAD7
	.addr LCAD7
	.addr LCAD7
	.addr LCAD7
	.addr LCAD7
	.addr LCAD7
	.addr LCAD7
	.addr LCAD7
	.addr LCAD7
	.addr LCAD7
	.addr LC9F9
	.addr LC9FC
	.addr LCAD7
	.addr LCA05
	.addr LCA0A
	.addr LCA17
	.addr LCA1C
	.addr LCA64
	.addr LCA95
	.addr LCA9A
	.addr LCA9F
	.addr LCAA4
	.addr LCAA9
	.addr LCAAE
	.addr LCAB3
	.addr LCAB8
	.addr LCABD
	.addr LCACD
	.addr LCAD2
LC959:	lda #$01
	jmp LCAD8

LC95E:	lda #$80
	sta $0291
	rts

LC964:	lda #$00
	sta $0291
	rts

LC96A:	lda #$00
	sta $D3
	sta $D8
	sta $D4
	jsr LCA17
	jmp LC981

LC978:	lda $D018
	ora #$02
	sta $D018
	rts

LC981:	inc $D6
	lda $D6
	cmp #$19
	bne LC98E
	dec $D6
	jsr LCEBB
LC98E:	jsr LCB54
	jsr LCAEB
	rts

LC995:	lda #$80
	sta $C7
	rts

LC99A:	lda #$00
	sta $D3
	sta $D6
	jsr LCB54
	jsr LCAEB
	rts

LC9A7:	lda $D3
	bne LC9AE
	jmp LCABD

LC9AE:	pha
LC9AF:	ldy $D3
	ldx COLOR
	lda ($D1),y
	dec $D3
	jsr LCE84
	inc $D3
	inc $D3
	lda $D3
	cmp #$50
	bne LC9AF
	dec $D3
	lda #$20
	ldx COLOR
	jsr LCE84
	pla
	sta $D3
	dec $D3
	rts

LC9D5:	lda #$02
	jmp LCAD8

LC9DA:	inc $D3
	lda $D3
	cmp #$50
	bne LC9E9
	lda #$00
	sta $D3
	jsr LC981
LC9E9:	rts

LC9EA:	lda #$05
	jmp LCAD8

LC9EF:	lda #$06
	jmp LCAD8

LC9F4:	lda #$08
	jmp LCAD8

LC9F9:	jmp LC96A

LC9FC:	lda $D018
	and #$FD
	sta $D018
	rts

LCA05:	lda #$00
	jmp LCAD8

LCA0A:	lda $D6
	beq LCA10
	dec $D6
LCA10:	jsr LCB54
	jsr LCAEB
	rts

LCA17:	lda #$00
	sta $C7
	rts

LCA1C:	lda #$18
	sta $D6
LCA20:	jsr LCE97
	dec $D6
	bpl LCA20
	jmp LC99A

LCA2A:	jsr LCB54
	ldy #$4F
	lda #$20
LCA31:	sta ($D1),y
	dey
	bpl LCA31
	jsr LCAEB
	ldy #$27
	lda COLOR
LCA3E:	sta ($F3),y
	dey
	bpl LCA3E
	lda #$28
	sta $D3
	jsr LCB2F
	ldy #$A0
	lda #$00
LCA4E:	dey
	sta ($DD),y
	bne LCA4E
	lda #$00
	sta $D3
	jsr LCB2F
	ldy #$A0
	lda #$00
LCA5E:	dey
	sta ($DD),y
	bne LCA5E
	rts

LCA64:	ldy #$4F
	lda ($D1),y
	cmp #$20
	bne LCA94
	lda $D3
	sta LCFF0
	lda #$4F
	sta $D3
LCA75:	ldy $D3
	cpy LCFF0
	beq LCA8A
	dey
	ldx COLOR
	lda ($D1),y
	jsr LCE84
	dec $D3
	jmp LCA75

LCA8A:	lda #$20
	ldx COLOR
	jsr LCE84
	inc $D8
LCA94:	rts

LCA95:	lda #$09
	jmp LCAD8

LCA9A:	lda #$0A
	jmp LCAD8

LCA9F:	lda #$0B
	jmp LCAD8

LCAA4:	lda #$0C
	jmp LCAD8

LCAA9:	lda #$0D
	jmp LCAD8

LCAAE:	lda #$0E
	jmp LCAD8

LCAB3:	lda #$0F
	jmp LCAD8

LCAB8:	lda #$04
	jmp LCAD8

LCABD:	dec $D3
	bpl LCACC
	lda $D6
	beq LCACA
	jsr LCA0A
	lda #$4F
LCACA:	sta $D3
LCACC:	rts

LCACD:	lda #$07
	jmp LCAD8

LCAD2:	lda #$03
	jmp LCAD8

LCAD7:	rts

LCAD8:	asl a
	asl a
	asl a
	asl a
	sta COLOR
	lda LCFEF
	and #$0F
	ora COLOR
	sta COLOR
	rts

LCAEB:	lda $D6
	asl a
	tax
	lda LCAFD,x
	sta $F3
	lda LCAFD+1,x
	clc
	adc #$D8
	sta $F4
	rts

LCAFD:	.word $0000,$0028,$0050,$0078
	.word $00A0,$00C8,$00F0,$0118
	.word $0140,$0168,$0190,$01B8
	.word $01E0,$0208,$0230,$0258
	.word $0280,$02A8,$02D0,$02F8
	.word $0320,$0348,$0370,$0398
	.word $03C0
LCB2F:	lda $D6
	asl a
	tax
	lda $D3
	and #$FE
	clc
	adc LCB66,x
	sta $DD
	lda LCB66+1,x
	adc #$00
	sta $DE
	asl $DD
	rol $DE
	asl $DD
	rol $DE
	lda #$E0
	clc
	adc $DE
	sta $DE
	rts

LCB54:	lda $D6
	asl a
	tax
	lda LCB66,x
	sta $D1
	lda LCB66+1,x
	clc
	adc #$C0
	sta $D2
	rts

LCB66:	.word $0000,$0050,$00A0,$00F0
	.word $0140,$0190,$01E0,$0230
	.word $0280,$02D0,$0320,$0370
	.word $03C0,$0410,$0460,$04B0
	.word $0500,$0550,$05A0,$05F0
	.word $0640,$0690,$06E0,$0730
	.word $0780
LCB98:	ldy $D3
	sty LCFF0
	lda ($D1),y
	jsr LCEA8
	lda $028D
	and #$04
	beq LCBB2
	ldy #$00
LCBAB:	nop
	dex
	bne LCBAB
	dey
	bne LCBAB
LCBB2:	ldy #$50
	lda #$C0
	sty $D1
	sta $D2
	ldy #$00
	sty $E1
	sta $E2
LCBC0:	lda ($D1),y
	sta ($E1),y
	iny
	bne LCBC0
	inc $D2
	inc $E2
	lda $D2
	cmp #$C8
	bcc LCBC0
	ldy #$40
	lda #$E1
	sty $DD
	sta $DE
	ldy #$00
	lda #$E0
	sty $E1
	sta $E2
LCBE1:	lda ($DD),y
	sta ($E1),y
	iny
	bne LCBE1
	inc $DE
	inc $E2
	lda $E2
	cmp #$FE
	bcc LCBE1
	ldy #$28
	lda #$D8
	sty $F3
	sta $F4
	ldy #$00
	sty $E1
	sta $E2
LCC00:	lda ($F3),y
	sta ($E1),y
	iny
	bne LCC00
	inc $F4
	inc $E2
	lda $E2
	cmp #$DB
	bcc LCC00
LCC11:	lda $DB27,y
	sta $DAFF,y
	iny
	cpy #$C0
	bcc LCC11
	lda #$18
	sta $D6
	jsr LCA2A
	lda LCFF0
	sta $D3
	lda #$04
	sta $CD
	rts

	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
LCC48:	cmp #$FF
	bne LCC4E
	lda #$7E
LCC4E:	pha
	and #$E0
	ldx #$05
LCC53:	cmp LCC64,x
	beq LCC5D
	dex
	bpl LCC53
	ldx #$00
LCC5D:	pla
	and #$1F
	ora LCC6A,x
	rts

LCC64:	.byte $E0,$C0,$A0,$60,$40,$20
LCC6A:	.byte $60,$40,$60,$40,$00,$20
LCC70:	stx $D7
	jsr LCC79
	jsr LCCDD
	rts

LCC79:	ldy $D3
	sta ($D1),y
	ldy #$00
	sty LCFF3
	cmp #$00
	bpl LCC8D
	ldy #$FF
	sty LCFF3
	and #$7F
LCC8D:	ldy LCFF5
	beq LCC94
	ora #$80
LCC94:	sta $DF
	lda #$1A
	sta $E0
	asl $DF
	rol $E0
	asl $DF
	rol $E0
	asl $DF
	rol $E0
	jsr LCB2F
	lda $D3
	and #$01
	bne LCCC6
	ldy #$07
LCCB1:	lda ($DD),y
	and #$0F
	sta ($DD),y
	lda ($DF),y
	eor LCFF3
	and #$F0
	ora ($DD),y
	sta ($DD),y
	dey
	bpl LCCB1
	rts

LCCC6:	ldy #$07
LCCC8:	lda ($DD),y
	and #$F0
	sta ($DD),y
	lda ($DF),y
	eor LCFF3
	and #$0F
	ora ($DD),y
	sta ($DD),y
	dey
	bpl LCCC8
	rts

LCCDD:	lda $D3
	lsr a
	tay
	lda $D7
	sta ($F3),y
	rts

LCCE6:	lda $99
	bne LCCF5
	lda $D3
	sta $CA
	lda $D6
	sta $C9
	jmp LCD68

LCCF5:	cmp #$03
	bne LCD02
	sta $D0
	lda $D5
	sta $C8
	jmp LCD68

LCD02:	jmp $F173 ; part of BASIN

LCD05:	jsr LC874
LCD08:	lda $C6
	sta $CC
	beq LCD08
	sei
	lda $CF
	beq LCD23
	lda #$00
	sta $CF
	lda #$02
	sta $CD
	ldx $0287
	lda $CE
	jsr LCE84
LCD23:	jsr $E5B4 ; input from the keyboard buffer
	cmp #$83
	bne LCD3A
	ldx #$09
	sei
	stx $C6
LCD2F:	lda $ECE6,x
	sta $0276,x
	dex
	bne LCD2F
	beq LCD08
LCD3A:	cmp #$0D
	bne LCD05
	ldy #$4F
	sty $D0
LCD42:	lda ($D1),y
	cmp #$20
	bne LCD4B
	dey
	bne LCD42
LCD4B:	iny
	sty $C8
	ldy #$00
	sty $D3
	sty $D4
	lda $C9
	bmi LCD70
	ldx $D6
	cpx $C9
	bne LCD70
	lda $CA
	sta $D3
	cmp $C8
	bcc LCD70
	bcs LCD93
LCD68:	tya
	pha
	txa
	pha
	lda $D0
	beq LCD08
LCD70:	ldy $D3
	lda ($D1),y
	sta $D7
	and #$3F
	asl $D7
	bit $D7
	bpl LCD80
	ora #$80
LCD80:	bcc LCD86
	ldx $D4
	bne LCD8A
LCD86:	bvs LCD8A
	ora #$40
LCD8A:	inc $D3
	jsr $E684 ; if open quote toggle cursor quote flag
	cpy $C8
	bne LCDAA
LCD93:	lda #$00
	sta $D0
	lda #$0D
	ldx $99
	cpx #$03
	beq LCDA5
	ldx $9A
	cpx #$03
	beq LCDA8
LCDA5:	jsr LC874
LCDA8:	lda #$0D
LCDAA:	sta $D7
	pla
	tax
	pla
	tay
	jmp LCECC

	nop
LCDB4:	jsr $FFEA ; increment real time clock
LCDB7:	lda $D021
	sta LCFEF
	lda $01
	pha
	lda #$00
	sta $01
	lda $CC
	bne LCDF2
	dec $CD
	bne LCDF2
	lda #$1E
	sta $CD
	ldy $D3
	lsr $CF
	ldx $0287
	lda ($D1),y
	bcs LCDED
	inc $CF
	sta $CE
	lda $D3
	lsr a
	tay
	lda ($F3),y
	sta $0287
	ldx COLOR
	lda $CE
LCDED:	eor #$80
	jsr LCE84
LCDF2:	lda LCFEF
	and #$0F
	cmp LCFF4
	beq LCE37
	sta LCFF4
	lda $D6
	pha
	lda #$18
	sta $D6
LCE06:	jsr LCAEB
	ldy #$27
LCE0B:	lda ($F3),y
	and #$F0
	ora LCFF4
	sta ($F3),y
	dey
	bpl LCE0B
	dec $D6
	bpl LCE06
	lda COLOR
	and #$F0
	ora LCFF4
	sta COLOR
	lda $0287
	and #$F0
	ora LCFF4
	jmp LCED6

LCE31:	jmp LCDB4

	jmp LCDB7

LCE37:	pla
	sta $01
	lda $D018
	and #$02
	cmp LCFF5
	beq LCE81
	sta LCFF5
	lda $D3
	pha
	lda $D6
	pha
	jsr LC99A
LCE50:	ldy $D3
	lda ($D1),y
	and #$7F
	cmp #$20
	beq LCE63
	bne LCE5E
	bcc LCE63
LCE5E:	lda ($D1),y
	jsr LCEA8
LCE63:	lda $D3
	cmp #$4F
	bne LCE6F
	lda $D6
	cmp #$18
	beq LCE75
LCE6F:	jsr LC9DA
	jmp LCE50

LCE75:	pla
	sta $D6
	pla
	sta $D3
	jsr LCB54
	jsr LCAEB
LCE81:	jmp $EA61

LCE84:	php
	sei
	tay
	lda $01
	pha
	lda #$00
	sta $01
	tya
	jsr LCC70
	pla
	sta $01
	plp
	rts

LCE97:	php
	sei
	lda $01
	pha
	lda #$00
	sta $01
	jsr LCA2A
	pla
	sta $01
	plp
	rts

LCEA8:	php
	sei
	tay
	lda $01
	pha
	lda #$00
	sta $01
	tya
	jsr LCC79
	pla
	sta $01
	plp
	rts

LCEBB:	php
	sei
	lda $01
	pha
	lda #$00
	sta $01
	jsr LCB98
	pla
	sta $01
	plp
	rts

LCECC:	lda $D7
	cmp #$DE
	bne LCED4
	lda #$FF
LCED4:	clc
	rts

LCED6:	sta $0287
	pla
	sta $D6
	jsr LCAEB
	jmp LCE37

	.byte $EA,$EA,$EA,$EA,$EA,$EA,$EA,$EA
	.byte $EA,$EA,$EA,$EA,$EA,$EA,$EA,$EA
	.byte $EA,$EA,$EA,$EA,$EA,$EA,$EA,$EA
	.byte $EA,$EA,$EA,$EA,$EA,$EA,$4D,$4F
	.byte $44,$49,$46,$49,$45,$44,$20,$46
	.byte $4F,$52,$20,$20,$20,$20,$20,$20
	.byte $43,$50,$2F,$4D,$20,$20,$20,$20
	.byte $20,$42,$5B,$FF,$FF,$FF,$D0,$FF
	.byte $FF,$FF,$FF,$FF,$FF,$FF,$DF,$DF
	.byte $DF,$DF,$DF,$DF,$DF,$DF,$DF,$DF
	.byte $DF,$DF,$DF,$DF,$DF,$DF,$DF,$DF
	.byte $DF,$DF,$DF,$DF,$DF,$DF,$DF,$DF
	.byte $DF,$DF,$DF,$DF,$DF,$DF,$DF,$DF
	.byte $DC,$DF,$DF,$DF,$DF,$DF,$DF,$DF
	.byte $DF,$DF,$DF,$DF,$DF,$DF,$DF,$DF
	.byte $DF,$DF,$DF,$DF,$DF,$DF,$DF,$DF
	.byte $DF,$DF,$DF,$DF,$DF,$DF,$DF,$DF
	.byte $DF,$DF,$DF,$DF,$DF,$DF,$DF,$DF
	.byte $DF,$DF,$DF,$DF,$DF,$DF,$DF,$DF
	.byte $DF,$DF,$DF,$DF,$DF,$DF,$DF,$DF
	.byte $DF,$DF,$DF,$DF,$DF,$DF,$DF,$DF
	.byte $DF,$DF,$DF,$DF,$DF,$EA,$EA,$EA
	.byte $EA,$EA,$EA,$EA,$EA,$EA,$EA,$EA
	.byte $EA,$EA,$EA,$EA,$EA,$EA,$EA,$EA
	.byte $EA,$EA,$EA,$EA,$EA,$EA,$EA,$EA
	.byte $EA,$EA,$EA,$EA,$EA,$EA,$EA,$EA
	.byte $EA,$EA,$EA,$EA,$EA,$EA,$EA,$EA
	.byte $EA,$EA,$EA,$EA,$EA,$EA,$EA,$EA
	.byte $EA,$EA,$EA,$EA,$EA,$EA,$EA,$EA
	.byte $EA,$EA,$EA,$EA,$EA,$EA,$EA,$EA
	.byte $EA,$EA,$EA,$EA,$EA,$EA,$EA,$EA
	.byte $EA,$EA,$EA,$EA,$EA,$EA,$EA,$EA
	.byte $EA,$EA,$EA,$EA,$EA,$EA,$EA,$EA
	.byte $EA,$EA,$EA,$EA,$EA
LCFEF:	.byte $F0
LCFF0:	.byte $EA,$EA
LCFF2:	.byte $00
LCFF3:	.byte $FF
LCFF4:	.byte $00
LCFF5:	.byte $00,$EA,$EA,$EA,$EA,$EA,$EA,$EA
	.byte $EA,$EA,$EA
charset:.byte $00,$22,$55,$77,$77,$44,$33,$00
	.byte $00,$22,$55,$77,$55,$55,$55,$00
	.byte $00,$66,$55,$66,$55,$55,$66,$00
	.byte $00,$22,$55,$44,$44,$55,$22,$00
	.byte $00,$66,$55,$55,$55,$55,$66,$00
	.byte $00,$77,$44,$77,$44,$44,$77,$00
	.byte $00,$77,$44,$66,$44,$44,$44,$00
	.byte $00,$22,$55,$44,$77,$55,$22,$00
	.byte $00,$55,$55,$77,$55,$55,$55,$00
	.byte $00,$77,$22,$22,$22,$22,$77,$00
	.byte $00,$77,$11,$11,$11,$55,$22,$00
	.byte $00,$44,$55,$66,$44,$66,$55,$00
	.byte $00,$44,$44,$44,$44,$44,$77,$00
	.byte $00,$55,$77,$55,$55,$55,$55,$00
	.byte $00,$66,$55,$55,$55,$55,$55,$00
	.byte $00,$77,$55,$55,$55,$55,$77,$00
	.byte $00,$66,$55,$55,$66,$44,$44,$00
	.byte $00,$22,$55,$55,$55,$22,$11,$00
	.byte $00,$66,$55,$55,$66,$55,$55,$00
	.byte $00,$33,$44,$22,$11,$55,$22,$00
	.byte $00,$77,$22,$22,$22,$22,$22,$00
	.byte $00,$55,$55,$55,$55,$55,$77,$00
	.byte $00,$55,$55,$55,$55,$55,$22,$00
	.byte $00,$55,$55,$55,$55,$77,$55,$00
	.byte $00,$55,$55,$22,$22,$55,$55,$00
	.byte $00,$55,$55,$55,$22,$22,$22,$00
	.byte $00,$77,$11,$22,$22,$44,$77,$00
	.byte $00,$66,$44,$44,$44,$44,$66,$00
	.byte $00,$33,$22,$77,$22,$22,$77,$00
	.byte $00,$33,$11,$11,$11,$11,$33,$00
	.byte $00,$22,$77,$22,$22,$22,$22,$00
	.byte $00,$00,$22,$44,$77,$44,$22,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$22,$22,$22,$22,$00,$22,$00
	.byte $00,$55,$55,$00,$00,$00,$00,$00
	.byte $00,$55,$77,$55,$77,$55,$55,$00
	.byte $00,$33,$66,$22,$33,$77,$22,$00
	.byte $00,$55,$11,$22,$22,$44,$55,$00
	.byte $00,$22,$55,$55,$22,$55,$77,$00
	.byte $00,$11,$22,$00,$00,$00,$00,$00
	.byte $00,$22,$44,$44,$44,$44,$22,$00
	.byte $00,$22,$11,$11,$11,$11,$22,$00
	.byte $00,$00,$00,$55,$22,$55,$00,$00
	.byte $00,$00,$22,$22,$77,$22,$22,$00
	.byte $00,$00,$00,$00,$00,$22,$44,$00
	.byte $00,$00,$00,$00,$77,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$22,$00
	.byte $00,$11,$11,$22,$22,$44,$44,$00
	.byte $00,$22,$55,$55,$55,$55,$22,$00
	.byte $00,$22,$66,$22,$22,$22,$77,$00
	.byte $00,$22,$55,$11,$22,$44,$77,$00
	.byte $00,$66,$11,$22,$11,$11,$66,$00
	.byte $00,$55,$55,$55,$77,$11,$11,$00
	.byte $00,$77,$44,$22,$11,$55,$22,$00
	.byte $00,$33,$44,$66,$55,$55,$22,$00
	.byte $00,$77,$55,$11,$22,$22,$22,$00
	.byte $00,$22,$55,$22,$55,$55,$22,$00
	.byte $00,$22,$55,$55,$33,$11,$66,$00
	.byte $00,$00,$00,$22,$00,$22,$00,$00
	.byte $00,$00,$00,$22,$00,$22,$44,$00
	.byte $00,$11,$22,$44,$44,$22,$11,$00
	.byte $00,$00,$00,$77,$00,$77,$00,$00
	.byte $00,$44,$22,$11,$11,$22,$44,$00
	.byte $00,$22,$55,$11,$22,$00,$22,$00
	.byte $00,$00,$00,$00,$FF,$00,$00,$00
	.byte $00,$00,$00,$22,$77,$77,$22,$00
	.byte $44,$44,$44,$44,$44,$44,$44,$44
	.byte $00,$00,$00,$FF,$00,$00,$00,$00
	.byte $00,$00,$FF,$00,$00,$00,$00,$00
	.byte $00,$FF,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$FF,$00,$00
	.byte $44,$44,$44,$44,$44,$44,$44,$44
	.byte $22,$22,$22,$22,$22,$22,$22,$22
	.byte $00,$00,$00,$00,$CC,$22,$22,$22
	.byte $22,$22,$22,$22,$11,$00,$00,$00
	.byte $22,$22,$22,$22,$CC,$00,$00,$00
	.byte $88,$88,$88,$88,$88,$88,$88,$FF
	.byte $88,$88,$44,$44,$22,$22,$11,$11
	.byte $11,$11,$22,$22,$44,$44,$88,$88
	.byte $FF,$88,$88,$88,$88,$88,$88,$88
	.byte $FF,$11,$11,$11,$11,$11,$11,$11
	.byte $00,$00,$22,$77,$77,$77,$22,$00
	.byte $00,$00,$00,$00,$00,$00,$FF,$00
	.byte $00,$00,$00,$55,$77,$77,$22,$00
	.byte $88,$88,$88,$88,$88,$88,$88,$88
	.byte $00,$00,$00,$00,$11,$22,$22,$22
	.byte $99,$99,$66,$66,$66,$66,$99,$99
	.byte $00,$00,$22,$55,$55,$55,$22,$00
	.byte $00,$00,$00,$22,$55,$22,$22,$00
	.byte $11,$11,$11,$11,$11,$11,$11,$11
	.byte $00,$00,$22,$22,$77,$22,$22,$00
	.byte $22,$22,$22,$22,$FF,$22,$22,$22
	.byte $88,$44,$88,$44,$88,$44,$88,$44
	.byte $22,$22,$22,$22,$22,$22,$22,$22
	.byte $00,$00,$00,$88,$77,$55,$55,$00
	.byte $FF,$77,$77,$33,$33,$11,$11,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $CC,$CC,$CC,$CC,$CC,$CC,$CC,$CC
	.byte $00,$00,$00,$00,$FF,$FF,$FF,$FF
	.byte $FF,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$FF
	.byte $88,$88,$88,$88,$88,$88,$88,$88
	.byte $AA,$55,$AA,$55,$AA,$55,$AA,$55
	.byte $11,$11,$11,$11,$11,$11,$11,$11
	.byte $00,$00,$00,$00,$AA,$55,$AA,$55
	.byte $FF,$EE,$EE,$CC,$CC,$88,$88,$00
	.byte $11,$11,$11,$11,$11,$11,$11,$11
	.byte $22,$22,$22,$22,$33,$22,$22,$22
	.byte $00,$00,$00,$00,$33,$33,$33,$33
	.byte $22,$22,$22,$22,$33,$00,$00,$00
	.byte $00,$00,$00,$00,$EE,$22,$22,$22
	.byte $00,$00,$00,$00,$00,$00,$FF,$FF
	.byte $00,$00,$00,$00,$33,$22,$22,$22
	.byte $22,$22,$22,$22,$FF,$00,$00,$00
	.byte $00,$00,$00,$00,$FF,$22,$22,$22
	.byte $22,$22,$22,$22,$EE,$22,$22,$22
	.byte $88,$88,$88,$88,$88,$88,$88,$88
	.byte $CC,$CC,$CC,$CC,$CC,$CC,$CC,$CC
	.byte $33,$33,$33,$33,$33,$33,$33,$33
	.byte $FF,$FF,$00,$00,$00,$00,$00,$00
	.byte $FF,$FF,$FF,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$FF,$FF,$FF
	.byte $11,$11,$11,$11,$11,$11,$11,$FF
	.byte $00,$00,$00,$00,$CC,$CC,$CC,$CC
	.byte $33,$33,$33,$33,$00,$00,$00,$00
	.byte $22,$22,$22,$22,$EE,$00,$00,$00
	.byte $CC,$CC,$CC,$CC,$00,$00,$00,$00
	.byte $CC,$CC,$CC,$CC,$33,$33,$33,$33
	.byte $00,$22,$55,$77,$77,$44,$33,$00
	.byte $00,$00,$66,$11,$33,$55,$33,$00
	.byte $00,$44,$44,$66,$55,$55,$66,$00
	.byte $00,$00,$22,$55,$44,$55,$22,$00
	.byte $00,$11,$11,$33,$55,$55,$33,$00
	.byte $00,$00,$22,$55,$77,$44,$22,$00
	.byte $00,$22,$44,$66,$44,$44,$44,$00
	.byte $00,$00,$33,$55,$55,$33,$11,$66
	.byte $00,$44,$44,$66,$55,$55,$55,$00
	.byte $00,$22,$00,$66,$22,$22,$77,$00
	.byte $00,$11,$00,$33,$11,$11,$55,$22
	.byte $00,$44,$44,$55,$66,$66,$55,$00
	.byte $00,$66,$22,$22,$22,$22,$77,$00
	.byte $00,$00,$55,$77,$55,$55,$55,$00
	.byte $00,$00,$66,$55,$55,$55,$55,$00
	.byte $00,$00,$22,$55,$55,$55,$22,$00
	.byte $00,$00,$66,$55,$55,$66,$44,$44
	.byte $00,$00,$33,$55,$55,$33,$11,$11
	.byte $00,$00,$66,$55,$44,$44,$44,$00
	.byte $00,$00,$33,$44,$22,$11,$66,$00
	.byte $00,$44,$66,$44,$44,$55,$22,$00
	.byte $00,$00,$55,$55,$55,$55,$33,$00
	.byte $00,$00,$55,$55,$55,$55,$22,$00
	.byte $00,$00,$55,$55,$55,$77,$55,$00
	.byte $00,$00,$55,$55,$22,$55,$55,$00
	.byte $00,$00,$55,$55,$55,$33,$11,$66
	.byte $00,$00,$77,$11,$22,$44,$77,$00
	.byte $00,$66,$44,$44,$44,$44,$66,$00
	.byte $00,$33,$22,$77,$22,$22,$77,$00
	.byte $00,$33,$11,$11,$11,$11,$33,$00
	.byte $00,$22,$77,$22,$22,$22,$22,$00
	.byte $00,$00,$22,$44,$77,$44,$22,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$22,$22,$22,$22,$00,$22,$00
	.byte $00,$55,$55,$00,$00,$00,$00,$00
	.byte $00,$55,$77,$55,$77,$55,$55,$00
	.byte $00,$33,$66,$22,$33,$77,$22,$00
	.byte $00,$55,$11,$22,$22,$44,$55,$00
	.byte $00,$22,$55,$55,$22,$55,$77,$00
	.byte $00,$11,$22,$00,$00,$00,$00,$00
	.byte $00,$22,$44,$44,$44,$44,$22,$00
	.byte $00,$22,$11,$11,$11,$11,$22,$00
	.byte $00,$00,$00,$55,$22,$55,$00,$00
	.byte $00,$00,$22,$22,$77,$22,$22,$00
	.byte $00,$00,$00,$00,$00,$22,$44,$00
	.byte $00,$00,$00,$00,$77,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$22,$00
	.byte $00,$11,$11,$22,$22,$44,$44,$00
	.byte $00,$22,$55,$55,$55,$55,$22,$00
	.byte $00,$22,$66,$22,$22,$22,$77,$00
	.byte $00,$22,$55,$11,$22,$44,$77,$00
	.byte $00,$66,$11,$22,$11,$11,$66,$00
	.byte $00,$55,$55,$55,$77,$11,$11,$00
	.byte $00,$77,$44,$22,$11,$55,$22,$00
	.byte $00,$33,$44,$66,$55,$55,$22,$00
	.byte $00,$77,$55,$11,$22,$22,$22,$00
	.byte $00,$22,$55,$22,$55,$55,$22,$00
	.byte $00,$22,$55,$55,$33,$11,$66,$00
	.byte $00,$00,$00,$22,$00,$22,$00,$00
	.byte $00,$00,$00,$22,$00,$22,$44,$00
	.byte $00,$11,$22,$44,$44,$22,$11,$00
	.byte $00,$00,$00,$77,$00,$77,$00,$00
	.byte $00,$44,$22,$11,$11,$22,$44,$00
	.byte $00,$22,$55,$11,$22,$00,$22,$00
	.byte $00,$00,$00,$00,$FF,$00,$00,$00
	.byte $00,$22,$55,$77,$55,$55,$55,$00
	.byte $00,$66,$55,$66,$55,$55,$66,$00
	.byte $00,$22,$55,$44,$44,$55,$22,$00
	.byte $00,$66,$55,$55,$55,$55,$66,$00
	.byte $00,$77,$44,$77,$44,$44,$77,$00
	.byte $00,$77,$44,$66,$44,$44,$44,$00
	.byte $00,$22,$55,$44,$77,$55,$22,$00
	.byte $00,$55,$55,$77,$55,$55,$55,$00
	.byte $00,$77,$22,$22,$22,$22,$77,$00
	.byte $00,$77,$11,$11,$11,$55,$22,$00
	.byte $00,$44,$55,$66,$44,$66,$55,$00
	.byte $00,$44,$44,$44,$44,$44,$77,$00
	.byte $00,$55,$77,$55,$55,$55,$55,$00
	.byte $00,$66,$55,$55,$55,$55,$55,$00
	.byte $00,$77,$55,$55,$55,$55,$77,$00
	.byte $00,$66,$55,$55,$66,$44,$44,$00
	.byte $00,$22,$55,$55,$55,$22,$11,$00
	.byte $00,$66,$55,$55,$66,$55,$55,$00
	.byte $00,$33,$44,$22,$11,$55,$22,$00
	.byte $00,$77,$22,$22,$22,$22,$22,$00
	.byte $00,$55,$55,$55,$55,$55,$77,$00
	.byte $00,$55,$55,$55,$55,$55,$22,$00
	.byte $00,$55,$55,$55,$55,$77,$55,$00
	.byte $00,$55,$55,$22,$22,$55,$55,$00
	.byte $00,$55,$55,$55,$22,$22,$22,$00
	.byte $00,$77,$11,$22,$22,$44,$77,$00
	.byte $22,$22,$22,$22,$FF,$22,$22,$22
	.byte $88,$44,$88,$44,$88,$44,$88,$44
	.byte $22,$22,$22,$22,$22,$22,$22,$22
	.byte $55,$AA,$55,$AA,$55,$AA,$55,$AA
	.byte $33,$99,$CC,$66,$33,$99,$CC,$66
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $CC,$CC,$CC,$CC,$CC,$CC,$CC,$CC
	.byte $00,$00,$00,$00,$FF,$FF,$FF,$FF
	.byte $FF,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$FF
	.byte $88,$88,$88,$88,$88,$88,$88,$88
	.byte $AA,$55,$AA,$55,$AA,$55,$AA,$55
	.byte $11,$11,$11,$11,$11,$11,$11,$11
	.byte $00,$00,$00,$00,$AA,$55,$AA,$55
	.byte $CC,$99,$33,$66,$CC,$99,$33,$66
	.byte $11,$11,$11,$11,$11,$11,$11,$11
	.byte $22,$22,$22,$22,$33,$22,$22,$22
	.byte $00,$00,$00,$00,$33,$33,$33,$33
	.byte $22,$22,$22,$22,$33,$00,$00,$00
	.byte $00,$00,$00,$00,$EE,$22,$22,$22
	.byte $00,$00,$00,$00,$00,$00,$FF,$FF
	.byte $00,$00,$00,$00,$33,$22,$22,$22
	.byte $22,$22,$22,$22,$FF,$00,$00,$00
	.byte $00,$00,$00,$00,$FF,$22,$22,$22
	.byte $22,$22,$22,$22,$EE,$22,$22,$22
	.byte $88,$88,$88,$88,$88,$88,$88,$88
	.byte $CC,$CC,$CC,$CC,$CC,$CC,$CC,$CC
	.byte $33,$33,$33,$33,$33,$33,$33,$33
	.byte $FF,$FF,$00,$00,$00,$00,$00,$00
	.byte $FF,$FF,$FF,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$FF,$FF,$FF
	.byte $00,$00,$00,$00,$11,$AA,$44,$00
	.byte $00,$00,$00,$00,$CC,$CC,$CC,$CC
	.byte $33,$33,$33,$33,$00,$00,$00,$00
	.byte $22,$22,$22,$22,$EE,$00,$00,$00
	.byte $CC,$CC,$CC,$CC,$00,$00,$00,$00
	.byte $CC,$CC,$CC,$CC,$33,$33,$33,$33

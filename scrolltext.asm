///
/// NOT WORKING
///
///
BasicUpstart2(init)

*= $1000 "main"
 
.var screen = $0400
 
init:
  ldx #38
  ldy #0
scroll:
  lda screen+1,y
  sta screen,y
  iny
  dex
  bpl scroll
 
  lda #$41 
  sta screen+39
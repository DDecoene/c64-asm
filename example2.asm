BasicUpstart2(init)
   *=$0810 "Main Code"
init:   ldx #$80 //; #128 works too!
        stx $07f8 //; Sprite pointer 1
        ldy #%00000001
        sty $d015 //; Sprite 1 enabled
        stx $d000
        stx $d001 //; Sprite1 x,y = #128
        rts

*=$2000 "Sprite 128"
    .import c64 "./bin/sprite1.prg"
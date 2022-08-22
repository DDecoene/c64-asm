BasicUpstart2(init)
   *=$0810 "Main Code"
//Variable Declaration block
PlayerY: .byte $80
PlayerX: .byte $80
buttonsDown: .byte $00
.var Joy2Reg = $DC00 //; Joystick helper variables
.var Joy1Reg = $DC01
.var UpMask     = %00000001
.var DownMask   = %00000010
.var LeftMask   = %00000100
.var RightMask  = %00001000
.var FireMask   = %00010000
//***

init:   CLS(0)
       jsr InitIRQ
loop:  
       jmp loop

InitIRQ:
       sei
       lda #<irq1
       ldx #>irq1
       sta $0314
       stx $0315 //; set interrupt addr    

       lda #$7f
       sta $dc0d //; timer A off on cia1/kb
       sta $dd0d //; timer A off on cia2
            
       lda #$81
       sta $d01a //; raster interrupts on
       lda #$1b //; screen ctrl: default
       sta $d011
             
       lda #$01
       sta $d012 //; interrupt at line 0
            
       lda $dc0d //; clrflg (cia1)
       lda $dd0d //; clrflg (cia2)
       asl $d019 //; clr interrupt flag (just in case)
       cli
       rts

//; Code for Scanline #1
irq1:  
       CheckInput()
       DrawSprite(PlayerX,PlayerY)

       asl $d019
       jmp $ea81 //; set flag and end

//; End Scanline #1 block

   *=$2000 "Sprite 128"
       .import c64 "./bin/sprite1.prg"

.macro CheckInput(){
CheckUp:lda #UpMask
        bit Joy2Reg //; is this mask present in the joystick register?
        bne CheckRight //; if not, check next 'button'
        Joy(0)
CheckRight:lda #RightMask
        bit Joy2Reg
        bne CheckDown
        Joy(3)
CheckDown:lda #DownMask
        bit Joy2Reg
        bne CheckLeft
        Joy(1)
CheckLeft:lda #LeftMask
        bit Joy2Reg
        bne CheckFire
        Joy(2)
CheckFire:
        lda #FireMask
        bit Joy2Reg
        bne unPressFire //; if fire is already pressed last frame...
        Joy(4)
        jmp endCheckInput
unPressFire:
        lda #buttonsDown
        eor FireMask //; xor it to remove it from the buttonsDown register.
        sta buttonsDown
endCheckInput:
}

.macro Joy(button){       
       .if(button==0) dec PlayerY
       .if(button==3) inc PlayerX
       .if(button==1) inc PlayerY
       .if(button==2) dec PlayerX

       .if(button==4){
               //fire
               lda #FireMask
               bit buttonsDown //; have we marked fire in buttonsDown?
               beq endJoy//; if so, skip to end
                //; if not, fire button code:
                inc $d020
                //;
                eor buttonsDown //; XOR to add #FireMask to buttonsDown
                sta buttonsDown
       }
endJoy:
}

.macro DrawSprite(x1, y1){
       ldx #$80
       stx $07f8 //; Sprite pointer 1
       ldy #%00000001
       sty $d015 //; Sprite 1 enabled
       ldx x1 //; x1 now points to PlayerX, a byte address, so # must be removed
       ldy y1 //; removing the argument in favor of direct reference is also possible
       stx $d000
       sty $d001 //; Sprite1 x,y = #128
}

.macro CLS(color){
       lda #color
       sta $d020
       sta $d021
       jsr $e544 //; clr screen char mem
}
//https://c64mac.wordpress.com/chapter-2-first-program/
BasicUpstart2(init)
*=$0810
init: inc $d020 
 jmp init
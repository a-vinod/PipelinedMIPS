addi $a0 $0   0x00
addi $a1 $0   0x00
addi $a2 $0   0x50
NOP # to optimize performance
addi $a0 $a0  0x01
addi $a1 $a1  0x02
bne  $a0 $a2 0xfffc

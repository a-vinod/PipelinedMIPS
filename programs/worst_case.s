ADDI $a0 $zero 0x0000 # a0  = 0x00
ADDI $a1 $zero 0x0000 # a1  = 0x00
ADDI $a2 $zero 0x0010 # a2  = 0x10
ADDI $a3 $zero 0x0010 # a3  = 0x10
ADDI $t2 $zero 0x0001 # t2  = 0x01
ADDI $t0 $zero 0x0000 # t0  = 0x00
ADDI $t0 $t0   0x0001 # t0 += 0x01 <- outer loop
ADDI $t1 $zero 0x0000 # t1  = 0x00
ADDI $t1 $t1   0x0001 # t1 += 0x01 <- inner loop
BNE  $a1 $zero 0x0002 # if a1 != 0: PC += 2*4 + 4
ADDI $a0 $a0   0x0002 # a0 += 0x02
ADDI $a1 $a0   0x0001 # a1 += 0x01
BEQ  $a1 $zero 0x0002 # if a1 = 0: PC += 2*4 + 4
ADDI $a0 $a0   0x0002 # a0 += 0x02
SUB  $a1 $a1   $t2    # a1 -= 0x01
BNE  $t1 $a2   0xFFF8 # if t1 != a1: PC -= 8*4 + 4
BNE  $t0 $a3   0xFFF5 # if t0 != a3: PC -= 11*4 + 4
JAL			   0x0013
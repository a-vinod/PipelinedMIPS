ADDI $a0 $zero 0x0000 # a0  = 0x00
ADDI $a1 $zero 0x0010 # a1  = 0x10
ADDI $a2 $zero 0x0010 # a2  = 0x10
ADDI $t0 $zero 0x0000 # t0  = 0x00 <- Outer for loop
ADDI $t0 $t0   0x0001 # t0 += 0x01 <- Inner for loop
ADDI $t1 $zero 0x0000 # t1  = 0x00
ADDI $t1 $t1   0x0001 # t1 += 0x01
ADDI $a0 $a0   0x0002 # a0 += 0x02
BNE  $t1 $a1   0xFFFD # if t1 != a1: PC -= 3*4 + 4 (Inner loop)
BNE  $t0 $a2   0xFFFA # if t0 != a2: PC -= 6*4 + 4 (Outer loop)
JAL			   0x000C


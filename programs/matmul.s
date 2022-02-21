# Load matrix to data memory (column-major)
# [1 2 3]
# [4 5 6]
# [7 8 9]
addi $t0 $0 0x1
addi $t1 $0 0x4
addi $t2 $0 0x7
addi $t3 $0 0x2
addi $t4 $0 0x5
addi $t5 $0 0x8
addi $t6 $0 0x3
addi $t7 $0 0x6 
addi $t8 $0 0x9
SW   $t0 0x00($0)
SW   $t1 0x04($0)
SW   $t2 0x08($0)
SW   $t3 0x0c($0)
SW   $t4 0x10($0)
SW   $t5 0x14($0)
SW   $t6 0x18($0)
SW   $t7 0x1c($0)
SW   $t8 0x20($0)

# Load vector to data memory
# [2 4 6]
addi $t0 $0 0x2
addi $t1 $0 0x4
addi $t2 $0 0x6
SW   $t0 0x24($0)
SW   $t1 0x28($0)
SW   $t2 0x2c($0)

# Store results of each cell in [a0 a1 a2]
addi $a0 $0 0x0
addi $a1 $0 0x0
addi $a2 $0 0x0
addi $t9 $0 0x0  # Address offset for matrix
addi $t8 $0 0x24 # Used to branch/loop later
addi $t7 $0 0x24 # Address offset for vector

# Load vector and matrix elements from memory
LW   $t0 0x00($t7) # vector element v(i)
LW   $t1 0x00($t9) # matrix element m(1,i)
LW   $t2 0x04($t9) # matrix element m(2,i)
LW   $t3 0x08($t9) # matrix element m(3,i)
# Multiply and accumulate the partial sums 
MULT $t0 $t1
MFLO $t6
ADD  $a0 $a0 $t6
MULT $t0 $t2
MFLO $t6
ADD  $a1 $a1 $t6
MULT $t0 $t3
MFLO $t6
ADD  $a2 $a2 $t6
# Add to address offset of matrix and vector 
# to use next column and cell respectively
ADDI $t7 $t7 0x04
ADDI $t9 $t9 0x0C
# Loop up to loading data from memory with
# new offset 3 times to complete computation
BNE  $t9 $t8 FFF0 # -16 2's complement

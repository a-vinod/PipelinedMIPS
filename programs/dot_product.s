ADDI $v0 $zero 0x1C
SW   $v0 0x0($zero)
ADDI $v0 $zero 0x6E
SW   $v0 0x1($zero)
LUI  $v0 0xFFFF
ADDI $v0 $zero 0xFFD7
SW   $v0 0x2($zero)
ADDI $v0 $zero 0x17
SW   $v0 0x3($zero)
LUI  $v0 0xFFFF
ADDI $v0 $zero 0xFFBD
SW   $v0 0x4($zero)
LUI  $v0 0xFFFF
ADDI $v0 $zero 0xFF10
SW   $v0 0x5($zero)
ADDI $v0 $zero 0x5B
SW   $v0 0x6($zero)
LUI  $v0 0xFFFF
ADDI $v0 $zero 0xFF9B
SW   $v0 0x7($zero)
ADDI $v0 $zero 0x96
SW   $v0 0x8($zero)
ADDI $v0 $zero 0x58
SW   $v0 0x9($zero)

ADDI $v0 $zero 0x0
LW $a0 0x0($zero)
LW $a1 0x5($zero)
MULT $a0 $a1
MFLO $a0
ADD $v0 $a0 $v0
LW $a0 0x1($zero)
LW $a1 0x6($zero)
MULT $a0 $a1
MFLO $a0
ADD $v0 $a0 $v0
LW $a0 0x2($zero)
LW $a1 0x7($zero)
MULT $a0 $a1
MFLO $a0
ADD $v0 $a0 $v0
LW $a0 0x3($zero)
LW $a1 0x8($zero)
MULT $a0 $a1
MFLO $a0
ADD $v0 $a0 $v0
LW $a0 0x4($zero)
LW $a1 0x9($zero)
MULT $a0 $a1
MFLO $a0
ADD $v0 $a0 $v0

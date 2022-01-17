	.text
	.globl main
main:	
addi $v0,$0,28  
la $a0, value1
sw $v0, 0($a0) 
addi $v0,$0,110
sw $v0, 4($a0) 
addi $v0,$0,-41 
sw $v0, 8($a0) 
addi $v0,$0,23 
sw $v0, 12($a0) 
addi $v0,$0,-67 
sw $v0, 16($a0) 

addi $v0,$0,-240 
addi $a0,$a0,20
sw $v0, 0($a0) 
addi $v0,$0,91
sw $v0, 4($a0) 
addi $v0,$0,-101
sw $v0, 8($a0) 
addi $v0,$0,150 
sw $v0, 12($a0) 
addi $v0,$0,88
sw $v0, 16($a0) 
#Pervious part should be done before execution

la $a0, value1
#actually using  instead of value
add $t9,$0,$0
addi $t8,$0,5
add $v1,$0,$0
loop:
lw $t0, 0($a0)
lw $t1, 20($a0)
mult $t0,$t1
mflo $t2
add $v1,$v1,$t2
addi $t9, $t9, 1
addi $a0,$a0,4
bne $t8, $t9, loop


.data # data section
value1: .word 10, 20, 0
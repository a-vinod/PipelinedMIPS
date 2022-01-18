	.text
	.globl main
main:	
addi $v0,$0,1  #v0 = 1
ori $v1,$0,5   #v1 = 5
and $t0,$v0,$v1 #t0 = 1
or $t1,$v0,$v1 #t1 = 5
add $a0,$t1,$t0 #a0 = 6
sw $t1, 48($a0) 
lw $t2, 48($a0) #t2 = 5
sub $t3, $t0, $t2 #t3 = -4
beq $t2,$t1,nexta #branch
addi $v0,$0,113  #Should not perform
nexta:
addi $t4,$0,3  #t4 = 3
xor $t5,$t4,$t2 #t5 = 6
beq $t5,$t4,nextb #Should not perform
xori $t5,$t2,1 #t5 = 4
bne $t5,$t4,nextc #branch
nextb:
addi $v0,$0,113  #Should not perform
nextc:
slt $t6,$t5,$t4 #t6 = 0
slti $t6,$t5,8 #t6 = 1
lui $t7,1 #t7 = 10000 HEX
sub $t7,$t7,$t0 #t7 = FFFF HEX
andi $t8,$t7,4 #t8 = 4
lui $t9, 8 #80000 HEX
mult $t7,$t9 #mult = 7FFF80000 HEX
mflo $t9 #t9 = FFF80000 HEX
mfhi $a1 #a1 = 7
addi $a1,$a1,1 #a1=8
sw $t1, 52($a0) 
#xnor $t5,$t4,$t2 #t5 = 1
jal other

other:

.data # data section
value: .word 10, 20, 0
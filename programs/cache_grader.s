addi $a0 $0 0x0  #a0 = 0x0 = 0b0_00000000_00_00 (tag_set_blockoffset_byteoffset)
addi $a1 $0 0x4  #a1 = 0x4
SW $a1 0x00($a0)
addi $a1 $a1 0x4 #a1 = 0x8
SW $a1 0x04($a0)
addi $a1 $a1 0x4 #a1 = 0xc
SW $a1 0x08($a0)
addi $a1 $a1 0x4 #a1 = 0x10
SW $a1 0x0c($a0)
addi $a1 $a1 0x4 #a1 = 0x14
addi $a2 $0  0x1000 #a2 = 0x1000 = 0b1_00000000_00_00 (tag_set_blockoffset_byteoffset) to test LRU behavior
SW $a1 0x0($a2) # 
addi $a1 $a1 0x4 #a1 = 0x18
SW $a1 0x4($a2)
addi $a1 $a1 0x4 #a1 = 0x1c
SW $a1 0x8($a2)
addi $a1 $a1 0x4 #a1 = 0x20
SW $a1 0xc($a2)
LW $t0 0x0c($a2) #t0 = 0x20
LW $t1 0x08($a2) #t1 = 0x1c
LW $t2 0x04($a2) #t2 = 0x18
LW $t3 0x00($a2) #t3 = 0x14
LW $t4 0x0c($a0) #t4 = 0x10
LW $t5 0x08($a0) #t5 = 0xc
LW $t6 0x04($a0) #t6 = 0x8
LW $t7 0x00($a0) #t7 = 0x4

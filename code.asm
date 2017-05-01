isSubstrEven:
	sub $sp, $sp, 72
	sw $ra, 0($sp)
	sw $fp, 4($sp)
	la $fp, 72($sp)
	sw $t0, 12($sp)
	sw $t1, 16($sp)
	sw $t2, 20($sp)
	sw $t3, 24($sp)
	sw $t4, 28($sp)
	sw $t5, 32($sp)
	sw $t6, 36($sp)
	sw $t7, 40($sp)
	sw $t8, 44($sp)
	sw $t9, 48($sp)
	sw $s0, 52($sp)
	sw $s1, 56($sp)
	sw $s2, 60($sp)
	sw $s3, 64($sp)
	sw $s4, 68($sp)
	li $v0, 82
	sub $sp, $sp, $v0
	sw $a0, 0($sp)
	sw $a1, 8($sp)
	sw $a2, 16($sp)
	li $s6, 92
	add $s7, $fp, $s6
	lw $t1, 0($s7)
	addi $t1, $0, 0
	li $s6, 88
	add $s7, $fp, $s6
	lw $t2, 0($s7)
	li $s6, 114
	add $s7, $fp, $s6
	lw $t3, 0($s7)
	move $t2, $t3

isSubstrOdd:
	sub $sp, $sp, 72
	sw $ra, 0($sp)
	sw $fp, 4($sp)
	la $fp, 72($sp)
	sw $t0, 12($sp)
	sw $t1, 16($sp)
	sw $t2, 20($sp)
	sw $t3, 24($sp)
	sw $t4, 28($sp)
	sw $t5, 32($sp)
	sw $t6, 36($sp)
	sw $t7, 40($sp)
	sw $t8, 44($sp)
	sw $t9, 48($sp)
	sw $s0, 52($sp)
	sw $s1, 56($sp)
	sw $s2, 60($sp)
	sw $s3, 64($sp)
	sw $s4, 68($sp)
	li $v0, 124
	sub $sp, $sp, $v0
	sw $a0, 0($sp)
	sw $a1, 8($sp)
	sw $a2, 16($sp)
	sw $a3, 20($sp)
	li $s6, 82
	add $s7, $fp, $s6
	lw $t4, 0($s7)
	move $a 0, $t4
	li $s6, 90
	add $s7, $fp, $s6
	lw $t0, 0($s7)
	move $a 1, $t0
	li $s6, 98
	add $s7, $fp, $s6
	lw $t5, 0($s7)
	move $a 2, $t5
	li $s6, 106
	add $s7, $fp, $s6
	lw $t6, 0($s7)
	move $a 3, $t6
	li $s6, 118
	add $s7, $fp, $s6
	lw $t7, 0($s7)
	move $a 4, $t7
	li $s6, 80
	add $s7, $fp, $s6
	lw $t8, 0($s7)
	move $a 5, $t8
	li $s6, 126
	add $s7, $fp, $s6
	lw $t9, 0($s7)
	move $a 6, $t9
	li $s6, 92
	add $s7, $fp, $s6
	lw $s0, 0($s7)
	move $a 7, $s0

main:
	la $fp, $sp
	sub $sp, $sp, 1000128
	li $s6, 1000004
	add $s7, $fp, $s6
	lw $s1, 0($s7)
	addi $s1, $0, 1
	li $s6, 0
	add $s7, $fp, $s6
	lw $s2, 0($s7)
	addi $s2, $0, 1
	li $s6, 0
	add $s7, $fp, $s6
	lw $s3, 0($s7)
	move $a 0, $s3
	li $s6, 8
	add $s7, $fp, $s6
	lw $s4, 0($s7)
	move $a 1, $s4
	li $s6, 20
	add $s7, $fp, $s6
	sw $t1, 0($s7)
	li $s6, 16
	add $s7, $fp, $s6
	lw $t1, 0($s7)
	move $a 2, $t1
	addi $s2, $0, 1
	addi $s2, $0, 1
	li $s6, 16
	add $s7, $fp, $s6
	sw $t2, 0($s7)
	li $s6, 8
	add $s7, $fp, $s6
	lw $t2, 0($s7)
	li $s6, 42
	add $s7, $fp, $s6
	sw $t3, 0($s7)
	li $s6, 0
	add $s7, $fp, $s6
	lw $t3, 0($s7)
	move $t2, $t3
	move $a 3, $s3
	li $s6, 10
	add $s7, $fp, $s6
	sw $t4, 0($s7)
	li $s6, 20
	add $s7, $fp, $s6
	lw $t4, 0($s7)
	move $a 4, $t4
	li $s6, 18
	add $s7, $fp, $s6
	sw $t0, 0($s7)
	li $s6, 28
	add $s7, $fp, $s6
	lw $t0, 0($s7)
	move $a 5, $t0
	move $a 6, $t2
	addi $s2, $0, 1
	li $s6, 26
	add $s7, $fp, $s6
	sw $t5, 0($s7)
	li $s6, 40
	add $s7, $fp, $s6
	lw $t5, 0($s7)
	move $a 7, $t5
	move $a 8, $s3
	li $s6, 34
	add $s7, $fp, $s6
	sw $t6, 0($s7)
	li $s6, 48
	add $s7, $fp, $s6
	lw $t6, 0($s7)
	move $a 9, $t6
	move $a 10, $t2
	addi $s2, $0, 1
	addi $s2, $0, 1


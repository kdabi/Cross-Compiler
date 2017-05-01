.data
_newline: .asciiz "\n"
DataString0: .asciiz "value of a: "
DataString1: .asciiz "value of b: "
DataString2: .asciiz "value of c: "
DataString3: .asciiz "value of d: "

.text
main:
	la $fp, ($sp)
	sub $sp, $sp, 112
	li $s6, 0
	sub $s7, $fp, $s6
	lw $t1, 0($s7)
	addi $t1, $0, 1
	li $s6, 4
	sub $s7, $fp, $s6
	lw $t2, 0($s7)
	addi $t2, $0, 2
	li $s6, 16
	sub $s7, $fp, $s6
	lw $t3, 0($s7)
	sub $t3, $t1, $t2
	li $s6, 8
	sub $s7, $fp, $s6
	lw $t4, 0($s7)
	move $t4, $t3
	li $s6, 24
	sub $s7, $fp, $s6
	lw $t0, 0($s7)
	mult $t1, $t2
	mflo $t0
	li $s6, 12
	sub $s7, $fp, $s6
	lw $t5, 0($s7)
	move $t5, $t0
	li $s6, 32
	sub $s7, $fp, $s6
	lw $t6, 0($s7)
	addi $t6, $t5, 8
	move $t5, $t6
	li $s6, 40
	sub $s7, $fp, $s6
	lw $t7, 0($s7)
	addi $t7, $t4, -17
	move $t4, $t7
	la $a0, DataString0
	li $v0, 4
	syscall
	move $a0, $t1
	li $v0, 1
	syscall
	li $v0, 4
	la $a0, _newline
	syscall
	la $a0, DataString1
	li $v0, 4
	syscall
	move $a0, $t2
	li $v0, 1
	syscall
	li $v0, 4
	la $a0, _newline
	syscall
	la $a0, DataString2
	li $v0, 4
	syscall
	move $a0, $t4
	li $v0, 1
	syscall
	li $v0, 4
	la $a0, _newline
	syscall
	la $a0, DataString3
	li $v0, 4
	syscall
	move $a0, $t5
	li $v0, 1
	syscall
	li $v0, 4
	la $a0, _newline
	syscall
	li $a0, 0
	li $v0, 10
	syscall


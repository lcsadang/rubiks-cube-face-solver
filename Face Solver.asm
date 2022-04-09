# CS 21 B -- S2 AY 2020-2021
# Lee Monique C. Sadang -- 08/28/2021
# 201906432.asm -- a program that either solves one face of a Rubik's cube or scrambles the cube based on given instructions.

.data
	state:		.space	56
	action:		.space	1002
	act_taken:	.space	1002
	color:		.space	3
		
.eqv	mode	$t0
.eqv	index	$t1
.eqv	curr	$t2
.eqv	temp1	$t3
.eqv	temp2	$t4
.eqv	chosen	$t5
.eqv	comp	$t6
	
.macro 	do_syscall(%n)
	li 	$v0, %n
	syscall
.end_macro

.macro 	rotate(%fr, %to)	
	li	temp1, %fr
	li	temp2, %to
	lb	$t7, state(temp1)
	lb	$t8, state(temp2)
	sb	$t7, state(temp2)
	sb	$t8, state(temp1)	
.end_macro

.macro	same_compare(%ind, %dest)
	li	temp1, %ind
	lb	chosen, state(temp1)
	lb	comp,	color
	bne	chosen, comp, %dest
.end_macro

.macro	diff_compare(%ind, %dest)
	li	temp1, %ind
	lb	chosen, state(temp1)
	lb	comp,	color
	beq	chosen, comp, %dest
.end_macro

.text 
input:	
	li	index, 0
	
	la	$a0, state
	li 	$a1, 56
	do_syscall(8)
	
	do_syscall(5)
	move	mode, $v0
	
	beq	mode, 1, solve__mode

free__mode:
	la	$a0, action
	li 	$a1, 1002
	do_syscall(8)
	
read__action:
	la	$ra, read__action
	lb	curr, action(index)
	beq	curr, 10, print__state
	
	addi	temp1, index, 1
	lb	temp2, action(temp1)
	
	beq	temp2, 39, reverse
	beq	curr, 'F', front
	beq	curr, 'B', back
	beq	curr, 'L', left
	beq	curr, 'R', right
	beq	curr, 'U', up
	beq	curr, 'D', down	
	beq	curr, 'H', horizontal
	beq	curr, 'V', vertical

reverse:
	beq	curr, 'F', rev__front	
	beq	curr, 'B', rev__back
	beq	curr, 'L', rev__left
	beq	curr, 'R', rev__right
	beq	curr, 'U', rev__up
	beq	curr, 'D', rev__down				
	
print__state:
	la	$a0, state
	do_syscall(4)
	
	do_syscall(10)
	
solve__mode:
	la	$a0, color
	li 	$a1, 3
	do_syscall(8)
	
match_up:
in_u:	same_compare(40, in_f)
	j	cross
in_f:	same_compare(4, in_r)
	jal	vertical
	j	cross
in_r:	same_compare(13, in_b)
	jal	horizontal
	jal	horizontal
	jal	horizontal
	jal	vertical
	j	cross
in_b:	same_compare(22, in_l)
	jal	horizontal
	jal	horizontal
	jal	vertical
	j	cross
in_l:	same_compare(31, in_d)
	jal	horizontal
	jal	vertical
	j	cross
in_d:
	jal	vertical
	jal	vertical
	j	cross
	
cross:
	same_compare(37, in_3)
	same_compare(39, in_3)
	same_compare(41, in_3)
	same_compare(43, in_3)
	j	corner
in_3:	same_compare(3, in_5)
	diff_compare(39, occ_3)
	jal	rev__left
	j	cross
occ_3:	jal	up
	j	in_3
in_5:	same_compare(5, in_7)
	diff_compare(41, occ_5)
	jal	right
	j	cross
occ_5:	jal	up
	j	in_5
in_7:	same_compare(7, in_52)
	diff_compare(43, occ_7)
	jal	front
	jal	up
	jal	rev__left
	jal	rev__up
	j	cross
occ_7:	jal	up
	j	in_7
in_52:	same_compare(52, in_1)
	diff_compare(37, occ_52)
	jal	back
	jal	back
	j	cross
occ_52:	jal	up
	j	in_52
in_1:	same_compare(1, cross_next)
	jal	front
	j	cross
	
cross_next:
	jal	horizontal
	j	cross

corner:
	same_compare(36, in_8)
	same_compare(38, in_8)
	same_compare(42, in_8)
	same_compare(44, in_8)
	j	print__actions
in_8:	same_compare(8, in_6)
	diff_compare(44, occ_8)
	jal	rev__down
	jal	rev__right
	jal	down
	jal	right
	j	corner
occ_8:	jal	up
	j	in_8
in_6:	same_compare(6, in_2)
	diff_compare(42, occ_6)
	jal	down
	jal	left
	jal	rev__down
	jal	rev__left
	j	corner
occ_6:	jal	up
	j	in_6
in_2:	same_compare(2, in_0)
	jal	rev__right
	jal	down
	jal	right
	j	corner
in_0:	same_compare(0, in_47)
	jal	left
	jal	rev__down
	jal	rev__left
	j	corner
in_47:	same_compare(47, in_45)
	jal	rev__right
	jal	down
	jal	right
	j	corner
in_45:	same_compare(45, corner_next)
	jal	left
	jal	rev__down
	jal	rev__left
	j	corner
		
corner_next:
	jal	horizontal
	j	corner
	
	
print__actions:	
	la	$a0, act_taken
	do_syscall(4)	
		
	do_syscall(10)

front:	
	li	$t9, 'F'
	sb	$t9, act_taken(index)
	addi	index, index, 1
	
	rotate(0, 2)
	rotate(6, 0)
	rotate(8, 6)
	rotate(1, 5)
	rotate(3, 1)
	rotate(7, 3)
	
	rotate(42, 9)
	rotate(43, 12)
	rotate(44, 15)
	
	rotate(35, 42)
	rotate(32, 43)
	rotate(29, 44)
	
	rotate(47, 35)
	rotate(46, 32)
	rotate(45, 29)
	
	jr	$ra

back:	
	li	$t9, 'B'
	sb	$t9, act_taken(index)
	addi	index, index, 1
	
	rotate(18, 20)
	rotate(24, 18)
	rotate(26, 24)
	rotate(19, 23)
	rotate(21, 19)
	rotate(25, 21)
	
	rotate(38, 27)
	rotate(37, 30)
	rotate(36, 33)
	
	rotate(17, 38)
	rotate(14, 37)
	rotate(11, 36)
	
	rotate(51, 17)
	rotate(52, 14)
	rotate(53, 11)
	
	jr	$ra
	
left:
	li	$t9, 'L'
	sb	$t9, act_taken(index)
	addi	index, index, 1
	
	rotate(27, 29)
	rotate(33, 27)
	rotate(35, 33)
	rotate(28, 32)
	rotate(30, 28)
	rotate(34, 30)
	
	rotate(36, 0)
	rotate(39, 3)
	rotate(42, 6)
	
	rotate(26, 36)
	rotate(23, 39)
	rotate(20, 42)
	
	rotate(45, 26)
	rotate(48, 23)
	rotate(51, 20)
	
	jr	$ra
	
right:
	li	$t9, 'R'
	sb	$t9, act_taken(index)
	addi	index, index, 1
	
	rotate(9, 11)
	rotate(15, 9)
	rotate(17, 15)
	rotate(10, 14)
	rotate(12, 10)
	rotate(16, 12)
	
	rotate(38, 24)
	rotate(41, 21)
	rotate(44, 18)
	
	rotate(2, 38)
	rotate(5, 41)
	rotate(8, 44)
	
	rotate(47, 2)
	rotate(50, 5)
	rotate(53, 8)
	
	jr	$ra

up:	
	li	$t9, 'U'
	sb	$t9, act_taken(index)
	addi	index, index, 1
	
	rotate(36, 38)
	rotate(42, 36)
	rotate(44, 42)
	rotate(37, 41)
	rotate(39, 37)
	rotate(43, 39)
	
	rotate(0, 27)
	rotate(1, 28)
	rotate(2, 29)

	rotate(9, 0)
	rotate(10, 1)
	rotate(11, 2)
	
	rotate(18, 9)
	rotate(19, 10)
	rotate(20, 11)
	
	jr	$ra

down:
	li	$t9, 'D'
	sb	$t9, act_taken(index)
	addi	index, index, 1
	
	rotate(45, 47)
	rotate(51, 45)
	rotate(53, 51)
	rotate(46, 50)
	rotate(48, 46)
	rotate(52, 48)
	
	rotate(6, 15)
	rotate(7, 16)
	rotate(8, 17)
	
	rotate(33, 6)
	rotate(34, 7)
	rotate(35, 8)
	
	rotate(24, 33)
	rotate(25, 34)
	rotate(26, 35)
	
	jr	$ra

rev__front:
	li	$t9, 'F'
	sb	$t9, act_taken(index)
	addi	index, index, 1
	li	$t9, '\''
	sb	$t9, act_taken(index)
	addi	index, index, 1
	
	rotate(0, 6)
	rotate(2, 0)
	rotate(8, 2)
	rotate(1, 3)
	rotate(5, 1)
	rotate(7, 5)
	
	rotate(9, 42)
	rotate(12, 43)
	rotate(15, 44)
	
	rotate(47, 9)
	rotate(46, 12)
	rotate(45, 15)
	
	rotate(35, 47)
	rotate(32, 46)
	rotate(29, 45)

	jr	$ra
	
rev__back:
	li	$t9, 'B'
	sb	$t9, act_taken(index)
	addi	index, index, 1
	li	$t9, '\''
	sb	$t9, act_taken(index)
	addi	index, index, 1
	
	rotate(18, 24)
	rotate(20, 18)
	rotate(26, 20)
	rotate(19, 21)
	rotate(23, 19)
	rotate(25, 23)
	
	rotate(36, 11)
	rotate(37, 14)
	rotate(38, 17)
	
	rotate(33, 36)
	rotate(30, 37)
	rotate(27, 38)
	
	rotate(53, 33)
	rotate(52, 30)
	rotate(51, 27)

	jr	$ra
	
rev__left:	
	li	$t9, 'L'
	sb	$t9, act_taken(index)
	addi	index, index, 1
	li	$t9, '\''
	sb	$t9, act_taken(index)
	addi	index, index, 1
	
	rotate(27, 33)
	rotate(29, 27)
	rotate(35, 29)
	rotate(28, 30)
	rotate(32, 28)
	rotate(34, 32)
	
	rotate(36, 26)
	rotate(39, 23)
	rotate(42, 20)
	
	rotate(0, 36)
	rotate(3, 39)
	rotate(6, 42)
	
	rotate(45, 0)
	rotate(48, 3)
	rotate(51, 6)

	jr	$ra

rev__right:
	li	$t9, 'R'
	sb	$t9, act_taken(index)
	addi	index, index, 1
	li	$t9, '\''
	sb	$t9, act_taken(index)
	addi	index, index, 1
	
	rotate(9, 15)
	rotate(11, 9)
	rotate(17, 11)
	rotate(10, 12)
	rotate(14, 10)
	rotate(16, 14)
	
	rotate(44, 8)
	rotate(41, 5)
	rotate(38, 2)
	
	rotate(18, 44)
	rotate(21, 41)
	rotate(24, 38)
	
	rotate(53, 18)
	rotate(50, 21)
	rotate(47, 24)

	jr	$ra

rev__up:
	li	$t9, 'U'
	sb	$t9, act_taken(index)
	addi	index, index, 1
	li	$t9, '\''
	sb	$t9, act_taken(index)
	addi	index, index, 1
	
	rotate(36, 42)
	rotate(38, 36)
	rotate(44, 38)
	rotate(39, 43)
	rotate(37, 39)
	rotate(41, 37)
	
	rotate(0, 9)
	rotate(1, 10)
	rotate(2, 11)
	
	rotate(27, 0)
	rotate(28, 1)
	rotate(29, 2)
	
	rotate(18, 27)
	rotate(19, 28)
	rotate(20, 29)

	jr	$ra

rev__down:
	li	$t9, 'D'
	sb	$t9, act_taken(index)
	addi	index, index, 1
	li	$t9, '\''
	sb	$t9, act_taken(index)
	addi	index, index, 1
	
	rotate(45, 51)
	rotate(47, 45)
	rotate(53, 47)
	rotate(46, 48)
	rotate(50, 46)
	rotate(52, 50)
	
	rotate(6, 33)
	rotate(7, 34)
	rotate(8, 35)
	
	rotate(15, 6)
	rotate(16, 7)
	rotate(17, 8)
	
	rotate(24, 15)
	rotate(25, 16)
	rotate(26, 17)

	jr	$ra

horizontal:
	li	$t9, 'H'
	sb	$t9, act_taken(index)
	addi	index, index, 1
	
	rotate(0, 9)
	rotate(1, 10)
	rotate(2, 11)
	rotate(3, 12)
	rotate(4, 13)
	rotate(5, 14)
	rotate(6, 15)
	rotate(7, 16)
	rotate(8, 17)
	
	rotate(27, 0)
	rotate(28, 1)
	rotate(29, 2)
	rotate(30, 3)
	rotate(31, 4)
	rotate(32, 5)
	rotate(33, 6)
	rotate(34, 7)
	rotate(35, 8)
	
	rotate(18, 27)
	rotate(19, 28)
	rotate(20, 29)
	rotate(21, 30)
	rotate(22, 31)
	rotate(23, 32)
	rotate(24, 33)
	rotate(25, 34)
	rotate(26, 35)
		
	rotate(36, 42)
	rotate(38, 36)
	rotate(44, 38)
	rotate(39, 43)
	rotate(37, 39)
	rotate(41, 37)
		
	rotate(45, 47)
	rotate(51, 45)
	rotate(53, 51)
	rotate(46, 50)
	rotate(48, 46)
	rotate(52, 48)
	
	jr	$ra
	
vertical:
	li	$t9, 'V'
	sb	$t9, act_taken(index)
	addi	index, index, 1
	
	rotate(0, 36)
	rotate(1, 37)
	rotate(2, 38)
	rotate(3, 39)
	rotate(4, 40)
	rotate(5, 41)
	rotate(6, 42)
	rotate(7, 43)
	rotate(8, 44)
	
	rotate(45, 0)
	rotate(46, 1)
	rotate(47, 2)
	rotate(48, 3)
	rotate(49, 4)
	rotate(50, 5)
	rotate(51, 6)
	rotate(52, 7)
	rotate(53, 8)
	
	rotate(26, 45)
	rotate(25, 46)
	rotate(24, 47)
	rotate(23, 48)
	rotate(22, 49)
	rotate(21, 50)
	rotate(20, 51)
	rotate(19, 52)
	rotate(18, 53)
	
	rotate(9, 11)
	rotate(15, 9)
	rotate(17, 15)
	rotate(10, 14)
	rotate(12, 10)
	rotate(16, 12)
		
	rotate(27, 33)
	rotate(29, 27)
	rotate(35, 29)
	rotate(28, 30)
	rotate(32, 28)
	rotate(34, 32)
	
	jr	$ra

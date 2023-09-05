# Written by Arsal Hussain for CS 2340.005, Assignment 5, starting 27 March 2023
# This program asks for user input that will sort the numbers from smallest to
# largest, these are achieved with floating point numbers

	.include 	"SysCalls.asm"
	.data
Array:	.space	800
sto:	.space	4
zero:	.double	0.0
msg1:	.asciiz	"Enter double precision number (Enter 0 to exit):\n"
msg2:	.asciiz	"Sorted list:\n"
msg3:	.asciiz	"Count: "
msg4:	.asciiz	"Sum: "
msg5:	.asciiz	"Average: "

	.text
	# main method will only prompt the user to enter a double precision number
	# and set the array address to zero
main:
	li	$v0, SysPrintString
	la	$a0, msg1
	syscall					# prints out the user prompt
	li	$t1, 0				# sets $t1 to zero
	la	$s0, Array			# initializes the array address
	l.d	$f6, zero			# sets f6 register to equal zero
	
	# readNum will take in user input as a double, then checks if zero
	# zero will end the program, but a non-zero number will be stored in array
readNum:
	li	$v0, SysReadDouble
	syscall					# reads in user input as double
	c.eq.d	$f0, $f6			# compares user input to f6, to check if zero
	bc1t	sortArray			# if the number is zero, goes to sort array
	s.d	$f0, 0($s0)			# stores the double precision number in array
	addi	$s0, $s0, 8			# increments by 8 to make space for next number
	addi	$t1, $t1, 1			# decrements by 1
	j	readNum				# continues to loop readNum until zero is entered

	# sortArray will take in all non-zero numbers entered and sort by least to greatest
	# calls sort function to efficiently read through array
sortArray:
	sw	$t1, sto			# stores t1 inside sto
	la	$a1, Array			# loads address of array to read first number
	lw	$a0, sto			# loads amount of numbers in array
	jal	sort				# calls the sort function to read numbers in increasing order
	la	$a1, Array			# once sorted, prints out array in increasing order
	lw	$a2, sto			# prints out count of how many numbers
	jal	printMsg			# jumps to printMsg to present statistics
	li	$v0, SysExit			
	syscall					# ends program
	
	# printMsg will print out the sorted list message which gets followed with each number
printMsg:
	li	$v0, SysPrintString		
	la	$a0, msg2			# prints out message of sorted list
	syscall
	l.d	$f20, zero			# loads f20 with zero
	
	# printNum will print each number sorted out in increasing order
printNum:
	beqz	$a2, convert			# if a2 is equal to zero, branch to convert for processor
	l.d	$f12, 0($a1)			# loads next number in array
	li	$v0, SysPrintDouble
	syscall					# prints out the number
	li	$v0, SysPrintChar
	li	$a0, '\n'
	syscall					# prints next line character to create space for array
	add.d	$f20, $f20, $f12		# adds current number to f20 to find sum
	addi	$a1, $a1, 8			# increments to next number in array
	addi	$a2, $a2, -1			# decreases the count of numbers remaining
	j	printNum			# loops printNum until there is no numbers left in array

	# convert will copy integer to convert into a floating double
convert:
	lw	$t1, sto			# loads count of numbers
	mtc1	$t1, $f26			# moves value in f26 to t1 for floating point processor
	cvt.d.w	$f26, $f26			# converts integer to floating double
	div.d	$f22, $f20, $f26		# divides sum by current number to get average
	li	$v0, SysPrintString
	la	$a0, msg3
	syscall					# prints out message of count
	lw	$a0, sto			# loads in count to a0
	li	$v0, SysPrintInt
	syscall					# prints out count
	li	$v0, SysPrintChar
	li	$a0, '\n'
	syscall					# next line character printed
	li	$v0, SysPrintString
	la	$a0, msg4		
	syscall					# prints out message of sum
	mov.d	$f12, $f20			# moves sum value into f12
	li	$v0, SysPrintDouble
	syscall					# prints out sum
	li	$v0, SysPrintChar
	li	$a0, '\n'
	syscall					# next line character printed
	li	$v0, SysPrintString
	la	$a0, msg5
	syscall					# prints out message of average
	mov.d	$f12, $f22			# moves average value into f12
	li	$v0, SysPrintDouble
	syscall					# prints out average
	li	$v0, SysPrintChar
	li	$a0, '\n'
	syscall					# next line character printed
	jr	$ra				# saves contents
	
	# sorts each number from array in increasing order
sort:
	add	$sp, $sp, 4			# increments stack pointer by 4 to get next element
	sw	$ra, 0($sp)			# stores the return address to stack
	move	$t2, $a0			# moves amount of numbers to t2
	move	$s0, $a1			# moves contents of array to s0
	addi	$t2, $t2, -1			# decrements count of numbers

	# section is called when element in array loop is not equal to zero
sorti:
	move	$s0, $a1			# moves to next count of numbers
	move	$t3, $t2			# t3 is used as j in nested loop of array

	# section is called when element in array loop not equal to zero
sortj:
	l.d	$f4, 0($s0)			# sets f4 to index j of array
	l.d	$f6, 8($s0)			# sets f6 to index j+1 of array to later compare values
	c.le.d	$f4, $f6			# if index j is less than index j+1, jump to next
	bc1t	next
	l.d	$f10, 0($s0)			# sets f10 to index j of array
	l.d	$f12, 8($s0)			# sets f12 to index j+1 of array to compare values
	s.d	$f10, 8($s0)			# moves index j+1 back a position as it is less than j
	s.d	$f12, 0($s0)			# moves index j up a position as it is more than j+1

	# section is called when two elements are in correct ascending order
next:
	add	$s0, $s0, 8			# increments to next element in array to be sorted
	addi	$t3, $t3, -1			# decrements count of number of values in array to be sorted
	bnez	$t3, sortj			# if the number of values in array is not zero, repeat sortj
	addi	$t2, $t2, -1			# decrememnts count of number of values in array to sort
	bnez	$t2, sorti			# if the number of values in array is not zero, repeat sorti
	lw	$ra, 0($sp)			# retrieve return address from stack
	add	$sp, $sp, -4			# moves stack pointer back 4 positions
	jr	$ra				# save contents

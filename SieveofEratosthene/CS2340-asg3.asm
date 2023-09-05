# Written by Arsal Hussain for CS2340.005, assignment 3, starting March 2, 2023
#	NetID: SAH210004
# The Sieve of Eratosthene, finding prime numbers based on user input

	.include "SysCalls.asm"
	.data
prompt:	.asciiz	"Enter a number between 3 and 160,000: "
state:	.asciiz	"Prints starting with bit 2: "
nline:	.asciiz	"\n"
comma:	.asciiz ", "
error_msg:	.asciiz "Number must be between range, try again."

	.text           # start of code
	# main will ask user to enter a number, then start to allocate bits
	# necessary, creating array of bits
main:
	li	$s0, 3
	li	$s1, 160000
	li	$v0, SysPrintString	# Print user prompt
	la	$a0, prompt
	syscall
	li	$v0, SysReadInt		# Read user input
	syscall
	move	$t0, $v0		# Store user input in $t0
	blt	$t0, $s0, error		# branches if user input out of range
	bgt	$t0, $s1, error		# branches if user input out of range
	mul	$a0, $t0, 8		# Allocate the n/8 of bits necessary
	li	$v0, SysAlloc		# Heap-allocate
	syscall
	move	$t1, $v0		# Move array
	li	$t2, 0			# Initialize counter
	
	# enter each bit to be zero in array, ends loop when max number reached
array_loop:
	sb	$zero, 0($t1)		# set a zero for each byte
	beq	$t0, $t2, endloop	# if the max number is achieved, end loop
	addi	$t1, $t1, 1		# increment to next pointer
	addi	$t2, $t2, 1		# increment counter
	j	array_loop		# continue looping through until branch

	# starts counter and called upon when to end loop	
endloop:
	li	$t2, 1			# initialize counter
	
	# increases counter and loads the current index of array
sieve:
	addi	$t2, $t2, 1		# increment counter
	mult	$t2, $t2		# square counter
	mflo	$t3			# store squared coutner
	bgt	$t3, $t0, exit		# if counter is bigger than user input, sieve is done
	lb	$t4, 0($t1)		# if the prime counter is equal to zero, load current index
	bnez	$t4, sieve		# repeat sieve if value is not zero
	mul	$t5, $t2, $t2		# new count will be old count squared
	
	# calculates index position
index_find:
	bgt	$t5, $t0, sieve		# repeat sieve if new count is larger than user input
	add	$t6, $t5, $t1		# find the current index of array
	sb	$t2, 0($t6)		# will set current index to next non-zero value
	add	$t5, $t5, $t2		# new count added by old count
	j	index_find		# repeats section until branch
	
	# prints the message of prime numbers
exit:
	li	$v0, SysPrintString	# print out message of prime numbers
	la	$a0, state
	syscall
	li	$t2, 1			# initialize counter of printing
	
	# prints the each prime number until there is none left
print:
	addi	$t2, $t2, 1		# increment array index
	bgt	$t2, $t0, newline	# if the counter is bigger than user input, new line
	add	$t3, $t1, $t2		# calculate array offset
	lb	$t4, 0($t3)		# load current value into current array index
	bnez	$t4, print		# loop again if current bit is not zero
	li	$v0, SysPrintInt	# print out prime number one by one
	move	$a0, $t2		
	syscall
	li	$v0, SysPrintString	# print out the comma after each prime number
	la	$a0, comma
	syscall
	j print				# continue to loop back until no more prime numbers

	# print out a new line
newline:
	li	$v0, SysPrintString	# print out the new line string
	la	$a0, nline
	syscall
	li	$v0, SysExit		# exit program
	syscall
error:
	li	$v0, SysPrintString	# print out error message
	la	$a0, error_msg
	syscall
	li	$v0, SysPrintString	# print out new line
	la	$a0, nline
	syscall
	j main

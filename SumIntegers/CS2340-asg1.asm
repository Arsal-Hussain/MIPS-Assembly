# Written by Arsal Hussain for CS2340.005, assignment 1, starting February 1, 2023
#	NetID: SAH210004
# Display a prompt for a user to enter an integer and print out the total sum of all integers
#
	.include "SysCalls.asm"
	.data
entry:	.asciiz "Enter an integer: "
sum:	.asciiz	"The sum is: "
intc:	.asciiz	"The number of integers entered was: "
newline: .asciiz "\n"

# Start of code
	.text
	.globl main
main:
	li $v0, SysPrintString	# Print out the initial string prompt
	la $a0, entry		# Load address of string being printed
	syscall			# operating system will print msg 1
	li $v0, SysReadInt	
	syscall			# number entered by user read by operator
	add $t0, $v0, $zero	# stores user entry from $v0 into $t0
	add $t1, $t1, $zero	# initialize sum variable
	add $t2, $t2, $zero	# initialize count variable
input:				# utilize user entries
	beqz $t0, print		# if entry = 0, exit
	add $t1, $t1, $t0	# sum = sum + user input
	addi $t2, $t2, 1	# increments count for each non-zero user input
	j main			# continues while "loop" until branch is true
print:
	li $v0, SysPrintString
	la $a0, sum
	syscall			# prints out msg 2
	li $v0, SysPrintInt
	move $a0, $t1
	syscall			# prints out the sum of all non-zero integers 
	li $v0, SysPrintString
	la $a0, newline
	syscall			# simply creates a new line for organization
	li $v0, SysPrintString
	la $a0, intc
	syscall			# prints out msg 3
	li $v0, SysPrintInt
	move $a0, $t2
	syscall			# prints out the number of non-zero integers used
	li $v0, SysExit
	syscall			# ends execution
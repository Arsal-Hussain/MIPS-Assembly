# Written by Arsal Hussain for CS2340.005, assignment 2, starting February 12, 2023
#	NetID: SAH210004
# Code used with permission from Prof. Cole's Web Page and modified
# Read in user input for a number as a string and convert to binary

	 .include "SysCalls.asm"
	 .data
prompt:  .asciiz 	"Enter a number: "
newline: .asciiz 	"\n"
msgerror:.asciiz 	"Invalid character, try again."
sum:	 .asciiz	"Sum = "
valid:	 .asciiz 	"Count of valid numbers = "
errors:	 .asciiz	"Total number of errors: "
buffer:	 .space		12

#Start of code
	.text
	.globl main
	#initializes all variables to zero, and asks the user to enter a number
	#will read the number as a string and store in a buffer
main:
	add	$t0, $t0, $zero		#initializes sum
	add	$t1, $t1, $zero		#initializes valid inputs count
	add	$t2, $t2, $zero		#initializes error inputs count
	add	$k0, $k0, $zero		#initializes accumulator
	li	$s1, '\n'		#unchanged newline character
	li	$s2, '-'		#unchanged negative character
	li	$v0, SysPrintString
	la	$a0, prompt		#prints the prompt for user input
	syscall
	la	$a0, buffer		#loads the address of buffer to store in $a0
	li	$a1, 12			#length of buffer
	li	$v0, SysReadString	#stores user input in $v0
	syscall
	move	$t3, $a0		#moves address of buffer ($a0) to $t3
	lbu	$t4, ($t3)		#loads the character in $t3 to $t4
	
	#verifies if the first character is either a new line or negative and will branch if true
check:
	beq	$t4, $s1, print		#branches to print section if first character is new line
	beq	$t4, $s2, negative	#branches to negative section if first character is '-'
	
	#if the number is positive, will add and convert to binary
	#goes through process of binary conversion, whereas the value is subtracted by 48
	#then the accumulator will be multiplied by 10 and add the value of the character
	#both the positive and negative section are similar, only one step differs due to
	#the value being an integer
positive:
	lbu	$t4, ($t3)		#loads character in $t3 to $t4
	beq	$t4, $s1, total		#moves to total section if no next value
	blt	$t4, 48, error		#flagged for error as value is outside ASCII range
	bgt	$t4, 57, error		#flagged for error as value is outside ASCII range
	sub	$t4, $t4, 48		#subtracts 48 from $t4 to convert to binary
	mul	$k0, $k0, 10		#multiplies accumulator by 10
	add	$k0, $k0, $t4		#subtracts accumulator by value in $t4
	addi	$t3, $t3, 1		#increments to next character
	j positive			#continues to loop positive until there is a branch
	
	#if the number is negative, will subtract and convert to binary
	#goes through process of binary conversion, whereas the value is subtracted by 48
	#then the accumulator will be multiplied by 10 and subtract the value of the character
negative:
	addi	$t3, $t3, 1		#moves to next character since first is '-'
	lbu	$t4, ($t3)		#loads character in $t3 to $t4
	beq	$t4, $s1, total		#moves to total section if no next value
	blt	$t4, 48, error		#flagged for error as value is outside ASCII range
	bgt	$t4, 57, error		#flagged for error as value is outside ASCII range
	sub	$t4, $t4, 48		#subtracts 48 from $t4 to convert to binary
	mul	$k0, $k0, 10		#multiplies accumulator by 10
	sub	$k0, $k0, $t4		#subtracts accumulator by value in $t4
	j negative			#continues to loop negative until there is a branch
	
	#adds all the binary numbers together
	#will also increment the amount of valid numbers since assembly
total:
	add	$t0, $t0, $k0		#adds  sum with accumulator's value
	addi	$t1, $t1, 1		#num of valid inputs incremented by 1
	add	$k0, $zero, $zero	#resets accumulator to zero
	j main				#repeats prompt until new line character

	#section is called if there is an error in user input and informs them
	#will also increment the amount of errors since assembly
error:
	li	$v0, SysPrintString	#tells user there is an error in their input
	la	$a0, msgerror
	syscall
	addi	$t2, $t2, 1		#increments amount of errors by 1
	li	$v0, SysPrintString
	la	$a0, newline		#new line to clean format
	syscall
	j main				#returns to prompt for new user input

	#prints out the sum, valid numbers, and number of errors
print:
	li 	$v0, SysPrintString	#prints the sum statement from all user inputs
	la 	$a0, sum
	syscall
	li 	$v0, SysPrintInt	#prints value of sum
	move 	$a0, $t0
	syscall
	li	$v0, SysPrintString	#new line to clean format
	la	$a0, newline		
	syscall
	li	$v0, SysPrintString	#prints the valid statement from all user inputs
	la	$a0, valid
	syscall
	li	$v0, SysPrintInt	#prints value of valid inputs
	move	$a0, $t1
	syscall
	li	$v0, SysPrintString
	la	$a0, newline		#new line to clean format
	syscall
	li 	$v0, SysPrintString	#prints the error statement from all user inputs
	la 	$a0, errors
	syscall
	li 	$v0, SysPrintInt	#prints value of error inputs
	move 	$a0, $t2
	syscall
# Written by Arsal Hussain for CS 2340.005, Assignment 4, starting March 15 2023
# This program considers a user input to check if it is a palindrome through
# entering the data into a stack and going through a
# recursive method of checking each letter and seeing if they are symmetrical

	.include	 "SysCalls.asm"
	.eqv 	buffSize 201	# buffer to hold user input and null terminator
	.data
userPrompt:	.asciiz	"Please enter a string: "
isPalindrome:	.asciiz "Palindrome\n"
notPalindrome:	.asciiz	"Not a Palindrome\n"
		.align 2
strBuffer:	.space buffSize

	.text
	# The main section is intended to input the string and store into buffer
	# the subroutines are called to identify upper cases and removing special
	# characters, as well as search for new line character being called
	.globl main
main:
	li	$v0, SysPrintString
	la	$a0, userPrompt
	syscall					# Prints out user prompt for entering a string
	li	$v0, SysReadString
	la	$a0, strBuffer			# String is read into a buffer
	li	$a1, buffSize
	syscall					# Stores user entered string in $v0 and the address of the string into $a0
	move	$s0, $a0			# Stores address of string in another temporary register
	jal 	toUpper				# jumps to toUpper section to remove first character
	jal	removeNonAlphaNum		# jumps to removeNonAlphaNum to check for special characters
	jal 	strSize				# jumps to the strSize function to check for null
	lbu	$t0, ($a0)			# loads first character into register t0
	beq	$t0, '\n', exit			# Exits the program if the enter key is pressed
	jal	recurPalindrome
	
	# prints out the is a palindrome statement
.globl	printTrue
printTrue:
	add	$t5, $v0, $zero			# checks boolean case
	beqz	$t5, printFalse
	li	$v0, SysPrintString
	la	$a0, isPalindrome		# prints out statement that string is palindrome
	syscall
	j 	main

	# prints out the not a palindrome statement
.globl	printFalse	
printFalse:
	li	$v0, SysPrintString
	la	$a0, notPalindrome		# prints out statement that string is not palindrome
	syscall
	j 	main
	
# Terminates the program
exit: 
	li $v0, SysExit				# terminates the program
	syscall




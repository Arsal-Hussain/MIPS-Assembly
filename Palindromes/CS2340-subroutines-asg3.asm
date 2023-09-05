# Written by Arsal Hussain for CS 2340.005, Assignment 4, starting March 15 2023
# Subroutines file which recursively calls the string as well as other routines
# intended for the main file
	
	.eqv	stackSize 12	# sets the size of the stack to 12
	.eqv 	lengthVar 4
	.eqv	memVar 8
	
	.data
	.text
		
	# loads each character to find length and checks for null terminator
.globl strSize
strSize:
	lbu 	$t0, ($a0)			# Load the first character into $t0
	beq 	$t0, $zero, storeSize		# Branch if character is null
	addi 	$a0, $a0, 1			# increment to the next character
	j	strSize				# Loop to next character until empty
	
	# considers size of string and finds length
storeSize:
	sub	$t1, $a0, $s0			# Subtracts the incremented address with the base address
	subi 	$t1, $t1, 2			# Minus one more for the new line character
	move	$a0, $s0			# Resets the address to origin
	jr 	$ra				# copy contents into stack

	# converts each letter to upper case
.globl toUpper
toUpper:
	lbu 	$t0, ($a0)			# load the first character in register t0
	beq	$t0, $zero, upperEnd		# branches if the character is null
	blt	$t0, 'a', incr			# goes to the next byte if current is less than 'a'
	bgt	$t0, 'z', incr			# goes to the next byte if current is more than 'z'
	sub	$t0, $t0, 32			# Subtracts the byte by 32 to convert from lower to upper
	sb	$t0, ($a0)			# Store that byte back to the string
	
	# moves to the next byte of string address
incr:
	addi	$a0, $a0, 1			# increments to next byte
	j	toUpper				# repeats step of converting to upper case
	
	# moves address back to starting position
upperEnd:
	move	$a0, $s0			# Resets the address to origin
	jr	$ra				# save contents
	
	# checks to see if current byte is special character and removes
	# if the character is not in ascii table
.globl	removeNonAlphaNum
removeNonAlphaNum:
	lbu	$t0, ($a0)			# Load the first character to $t0
	beq	$t0, '\n', removeEnd		# If the character is the new line character then end loop
	slti	$t1, $t0, '0'			# If the ascii value is less than '0'
	bne	$t1, $zero, begin			# branch to remove the character
	slti	$t1, $t0, ':'			# If the ascii value is greater than ':' 
	slti	$t2, $t0, 'A'			# AND the ascii value is less than 'A'
	slt	$t3, $t1, $t2			# Compare the truth values
	bne	$t3, $zero, begin			# branch to remove the character
	slti	$t1, $t0, '['			# If the character is greater  than '['
	beq	$t1, $zero, begin			# branch to remove the character
	addi	$a0, $a0, 1			# Increment to the next byte
	j	removeNonAlphaNum		# loops again to look for special character

	# utilizes two registers to temporarily store the address of current byte to be
	# used by next and following byte
begin:
	move	$t1, $a0			# Moves current string address for n+1 character
	move	$t2, $a0			# Moves current string address for the nth character
	
	# shifts every byte to the previous position to remove special characters	
removeLoop:
	addi	$t1, $t1, 1			# Increments to next byte for the n+1 character
	lbu	$t0, ($t1)			# Loads the next character to $t0
	sb	$t0, ($t2)			# Stores the next character in the current character spot
	beq	$t0, $zero, removeNonAlphaNum	# If the next character is a null terminator then branch
	addi 	$t2, $t2, 1			# Else increment to the next byte
	j 	removeLoop
	
	# removes end character and resets memory address to origin
removeEnd:
	move	$a0, $s0			# Resets the address to the origin
	jr	$ra				# copy contents into stack

	# checks to see if string is a palindrome by loading length of previous string
	# from stack and determine if characters are symmetrical
.globl	recurPalindrome
recurPalindrome:
	slti	$t5, $t1, 1			# checks if string length is less than 1
	beq	$t5, 1, setTrue
	addi 	$sp, $sp, -stackSize		# reserves space for the return address and string index
	sw 	$ra, ($sp)			
	sw	$t1, lengthVar($sp)		# store return address in register t1
	sw	$a0, memVar($sp)		# stores the space plus memory into register a0
	lw	$t2, memVar($sp)		# loads current space and memory into register t2
	lbu	$t3, ($t2)			# loads first byte to check if empty
	move	$t6, $t2			# move string address into register t6
	add	$t2, $t1, $t2			# increments byte
	lbu	$t4, ($t2)			# loads next byte into register
	bne	$t3, $t4, setFalse		# address of t3 and t4 must be equal to continue
	addi	$a0, $t6, 1			# increment address of string to next byte
	addi	$t1, $t1, -2			# decreases string length of beginning and end character
	jal 	recurPalindrome			# continue to loop string to read each byte

	# sets boolean case to true
setTrue:
	addi	$v0, $zero, 1			# boolean true, or 1
	j	printTrue
	
	# sets boolean case to false
setFalse:
	add	$v0, $zero, $zero		# boolean false, or 0
	j	printTrue
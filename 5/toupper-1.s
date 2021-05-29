# PURPOSE: This program converts an STDIN
#          to STDOUT with all letters
#          converted to uppercase.

# PROCESSING: 1) Open STDIN
#             2) Open STDOUT
#             3) While we’re not at the end of the input file
#                a) read part of file into our memory buffer
#                b) go through each byte of memory
#                   if the byte is a lower-case letter,
#                   convert it to uppercase
#                c) write the memory buffer to output file

# P.S: Because programm reads stdout stream, after user type 
#      user should press Ctrl+D in shell, to pass STDIN to program
#      after that program send processed stream to STDOUT without
#      line feed (\n)
#      Or user can do this from shell: echo "this is test" | ./toupper-1

# first step:  as --32 -o toupper-1.o toupper-1.s
# second step: ld -melf_i386 -o toupper-1 toupper-1.o



.section .data
####### CONSTANTS ########

# system call numbers
.equ	SYS_OPEN,	5
.equ	SYS_WRITE,	4
.equ	SYS_READ,	3
.equ	SYS_CLOSE,	6
.equ	SYS_EXIT,	1

# options for open (look at /usr/include/asm/fcntl.h for
# various values. You can combine them by adding them or
# ORing them)

# This is discussed at greater length
# in "Counting Like a Computer"

.equ	O_RDONLY,	0
.equ	O_RDWR,		2
.equ	O_CREAT_WRONLY_TRUNC,	03101

# standard file descriptors
.equ	STDIN,	0
.equ	STDOUT,	1
.equ	STDERR,	2

# system call interrupt
.equ	LINUX_SYSCALL,	0x80
.equ	END_OF_FILE,	0

# This is the return value of read which means we’ve
# hit the end of the file

.equ	NUMBER_ARGUMENTS,	2

.section .bss
# Buffer - this is where the data is loaded into
#          from the data file and written from into
#          the output file. This should never
#          exceed 16,000 for various reasons.

.equ	BUFFER_SIZE,	500
.lcomm	BUFFER_DATA,	BUFFER_SIZE


.section .text

# STACK POSITIONS
.equ	ST_SIZE_RESERVE,	8
.equ	ST_FD_IN,	-4
.equ	ST_FD_OUT,	-8
.equ	ST_ARGC,	0       # Number of arguments
.equ	ST_ARGV_1,	8	# Input file name
.equ	ST_ARGV_2,	12	# Output file name

.globl _start

	_start:

### INITIALIZE PROGRAM ###
		mov	%esp, %ebp		# save the stack pointer
		sub	$ST_SIZE_RESERVE, %esp	# Allocate space for our file descriptors on the stack

### BEGIN MAIN LOOP ###
	read_loop_begin:
### READ IN A BLOCK FROM THE INPUT FILE ###
		mov	$SYS_READ, %eax			# get the input file descriptor
		mov	$STDIN, %ebx			# the location to read into
		mov	$BUFFER_DATA, %ecx		# the location to read into
		mov	$BUFFER_SIZE, %edx		# the size of the buffer
		int	$LINUX_SYSCALL			# size of buffer read is returned in %eax

### EXIT IF WE’VE REACHED THE END ###

		cmp	$END_OF_FILE, %eax		# check for end of file marker
		jle	end_loop			# if found or on error, go to the end

	continue_read_loop:
### CONVERT THE BLOCK TO UPPER CASE ###
		push	$BUFFER_DATA			# location of buffer
		push	%eax				# size of the buffer
		call	convert_to_upper
		pop	%eax				# get the size back	
		add	$4, %esp			# restore %esp

### WRITE THE BLOCK OUT TO THE OUTPUT FILE ###

		mov	%eax, %edx			# size of the buffer
		mov	$SYS_WRITE, %eax		# 
		mov	$STDOUT, %ebx			# file to use
		mov	$BUFFER_DATA, %ecx		# location of the buffer
		int	$LINUX_SYSCALL

### CONTINUE THE LOOP ###
		jmp	read_loop_begin

	end_loop:
### CLOSE THE FILES ###
# NOTE - we don’t need to do error checking
#        on these, because error conditions
#        don’t signify anything special here

### EXIT ###
		mov	$SYS_EXIT, %eax
		mov	$0, %ebx
		int	$LINUX_SYSCALL

# PURPOSE: This function actually does the
#          conversion to upper case for a block
#
#
# INPUT:   The first parameter is the location
#          of the block of memory to convert
#          The second parameter is the length of
#          that buffer
#
#
# OUTPUT:  This function overwrites the current
#          buffer with the upper-casified version.
#
#
# VARIABLES: 
#            %eax - beginning of buffer
#            %ebx - length of buffer
#            %edi - current buffer offset
#            %cl - current byte being examined
#            (first part of %ecx)

### CONSTANTS ##

# The lower boundary of our search
.equ	LOWERCASE_A,	'a'
# The upper boundary of our search
.equ	LOWERCASE_Z,	'z'
# Conversion between upper and lower case
.equ	UPPER_CONVERSION,	'A' - 'a'

### STACK STUFF ###
.equ	ST_BUFFER_LEN,	8 # Length of buffer
.equ	ST_BUFFER,	12
# actual buffer

convert_to_upper:
		push	%ebp
		mov	%esp, %ebp
### SET UP VARIABLES ###
		mov	ST_BUFFER(%ebp), %eax
		mov	ST_BUFFER_LEN(%ebp), %ebx
		mov	$0, %edi
		
# if a buffer with zero length was given
# to us, just leave
		cmp	$0, %ebx
		je	end_convert_loop

convert_loop:
		mov	(%eax,%edi,1), %cl	# get the current byte
# go to the next byte unless it is between
# ’a’ and ’z’
		cmp	$LOWERCASE_A, %cl
		jl	next_byte
		cmp	$LOWERCASE_Z, %cl
		jg	next_byte

		add	$UPPER_CONVERSION, %cl	# otherwise convert the byte to uppercase
		mov	%cl, (%eax,%edi,1)	# and store it back

	next_byte:

		inc	%edi			# next byte
		cmp	%edi, %ebx		# continue unless
						# we’ve reached the
						# end
		jne	convert_loop

	end_convert_loop:

		mov	%ebp, %esp		
		pop	%ebp
		ret				# no return value, just leave


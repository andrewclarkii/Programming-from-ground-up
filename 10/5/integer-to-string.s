
# PURPOSE:  Convert an integer number to a octal string
#           for display. 
#
# INPUT:   A buffer large enough to hold the largest
#          possible number An integer to convert
#
# OUTPUT:  The buffer will be overwritten with the
#          decimal string
#
# Variables:
#
#  %ecx will hold the count of characters processed
#  %eax will hold the current value
#  %edi will hold the base (10)

.equ	ST_VALUE,	8
.equ	ST_BUFFER,	12

.globl	integer2string
.type	integer2string,	@function

integer2string:

		push	%ebp		# Normal function beginning
		mov	%esp, %ebp

		xor	%ecx, %ecx	# Current character count

		mov	ST_VALUE(%ebp), %eax	# Move the value into position

		mov	ST_BUFFER(%ebp), %esi	# took conversion base as our divider
						# it must be in a register or memory location

	conversion_loop:

	# Division is actually performed on the
	# combined %edx:%eax register, so first
	# clear out %edx

		xor	%edx, %edx

	# Divide %edx:%eax (which are implied) by 10.
	# Store the quotient in %eax and the remainder
	# in %edx (both of which are implied).
		mov	$10, %edi

		div	%edi

	# Quotient is in the right place.  %edx has
	# the remainder, which now needs to be converted
	# into a number.  So, %edx has a number that is
	# 0 through 9.  You could also interpret this as
	# an index on the ASCII table starting from the
	# character '0'.  The ascii code for '0' plus zero
	# is still the ascii code for '0'.  The ascii code
	# for '0' plus 1 is the ascii code for the
	# character '1'.  Therefore, the following
	# instruction will give us the character for the
	# number stored in %edx

	#	cmp	$0x0a, %edx	# if byte lesser than 10
	#	jl	bypass		# we do not do anything
	#	add	$0x07, %edx	# otherwise we add 7 bytes
					# because ascii symbol are
					# appears after 7 bytes from 
					# digits
	bypass:
		add	$'0', %edx

	# Now we will take this value and push it on the
	# stack.  This way, when we are done, we can just
	# pop off the characters one-by-one and they will
	# be in the right order.  Note that we are pushing
	# the whole register, but we only need the byte
	# in %dl (the last byte of the %edx register) for
	# the character.

		push	%edx
		inc	%ecx		# Increment the digit count

	# Check to see if %eax is zero yet, go to next
	# step if so.

		test	%eax, %eax
		je	end_conversion_loop

		jmp	conversion_loop	# %eax already has its new value.


	end_conversion_loop:

	# The string is now on the stack, if we pop it
	# off a character at a time we can copy it into
	# the buffer and be done.


		mov	ST_BUFFER(%ebp), %edx	# Get the pointer to the buffer in %edx

	copy_reversing_loop:
	
	# We pushed a whole register, but we only need
	# the last byte.  So we are going to pop off to
	# the entire %eax register, but then only move the
	# small part (%al) into the character string.

		pop	%eax
		movb	%al, (%edx)
		dec	%ecx		# Decreasing %ecx so we know when we are finished

	# Increasing %edx so that it will be pointing to
	# the next byte

		inc	%edx
		test	%ecx, %ecx		# Check to see if we are finished
		je	end_copy_reversing_loop	# If so, jump to the end of the function
		jmp	copy_reversing_loop	# Otherwise, repeat the loop

	end_copy_reversing_loop:

		movb	$0, (%edx)	# Done copying.  Now write a null byte and return

		mov  %ebp, %esp
		pop  %ebp
		ret

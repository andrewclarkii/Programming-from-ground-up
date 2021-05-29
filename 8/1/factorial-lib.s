# PURPOSE - This function computes the factorial. 
#           For example, the factorial of
#           3 is 3 * 2 * 1, or 6. The factorial of
#           4 is 4 * 3 * 2 * 1, or 24, and so on.
#
# INPUT: takes parameter from stack
#	 
#
# OUTPUT: %edx size of a string in bytes

#
# first step:  as --32 -o factorial-lib.o factorial-lib.s
# second step: ld -melf_i386 -shared factorial-lib.o -o libfactorial.so


.section .text

.globl factorial			# this is unneeded unless we want to share
					# this function among other programs
.type	factorial, @function

	factorial:

		push	%ebp		# standard function stuff - we have to
					# restore %ebp to its prior state before
					# returning, so we have to push it

		mov	%esp, %ebp	# This is because we don’t want to modify
					# the stack pointer, so we use %ebp.

		mov	8(%ebp), %eax	# This moves the first argument to %eax
					# 4(%ebp) holds the return address, and
					# 8(%ebp) holds the first parameter

		cmp	$1, %eax	# If the number is 1, that is our base
					# case, and we simply return (1 is
					# already in %eax as the return value)
		je	end_factorial

		dec	%eax		# otherwise, decrease the value
		push	%eax		# push it for our call to factorial
		call	factorial	# call factorial
		mov	8(%ebp), %ebx	# %eax has the return value, so we
					# reload our parameter into %ebx
		imul	%ebx, %eax	# multiply that by the result of the
					# last call to factorial (in %eax)
                                        # the answer is stored in %eax, which
					# is good since that’s where return
					# values go.

	end_factorial:
		
		mov	%ebp, %esp	# standard function return stuff - we
		pop	%ebp		# have to restore %ebp and %esp to where
					# they were before the function started
		ret			# return to the function (this pops the
					# return value, too)

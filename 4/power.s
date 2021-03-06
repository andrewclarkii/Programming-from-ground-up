# PURPOSE: Program to illustrate how functions work
#          This program will compute the value of 2^3 + 5^2
#
# Everything in the main program is stored in registers,
# so the data section doesn’t have anything.
#
# first step:  as --32 -o power.o power.s
# second step: ld -melf_i386 -o power power.o


.section .data

.section .text

.globl _start

_start:
		push	$3				# push second argument
		push	$2				# push first argument
		call	power				# call the function

		add	$8, %esp			# move stack pointer back
		push	%eax				# save the first answer before

		push	$2				# push second argument
		push	$5				# push first argument
		call    power				# call the function

		add     $8, %esp                        # move stack pointer back
                pop	%ebx                            # The second answer is already
							# in %eax. We saved the first
							# answer onto the stack,
							# so now we can just pop it
							# out into %ebx

		add	%eax, %ebx			# add them together the result is in %ebx

		movl	$0x01, %eax			# 1 is the exit() syscall
		int	$0x80

# PURPOSE: This function is used to compute
#          the value of a number raised to
#          a power.
#
# INPUT: First argument - the base number
#        Second argument - the power to
#        raise it to
#
# OUTPUT: Will give the result as a return value
#
# NOTES: The power must be 1 or greater
#
# VARIABLES: %ebx - holds the base number
#            %ecx - holds the power
#            -4(%ebp) - holds the current result
#

.type	power, @function

	power:

		push	%ebp				# save old base pointer
		mov	%esp, %ebp			# make stack pointer the base pointer
		sub	$4, %esp			# get room for our local storage

		mov	8(%ebp), %ebx			# put first argument in %ebx
		mov	12(%ebp), %ecx			# put second argument in %ecx

        	mov	%ebx, -4(%ebp)			# store current result

	power_loop_start:

		cmp	$1, %ecx			# if the power is 1, we are done	
		je	end_power			# 

		mov	-4(%ebp), %eax			# move the current result into %eax
		imul	%ebx, %eax			# multiply the current result by
		mov	%eax, -4(%ebp)			# store the current result
		dec	%ecx				# decrease the power
		jmp	power_loop_start		# run for the next power

	end_power:

		mov	-4(%ebp), %eax			# return value goes in %eax
		mov	%ebp, %esp			# restore the stack pointer
                pop	%ebp				# restore the base pointer
		ret

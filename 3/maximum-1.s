# PURPOSE: This program finds the minimum number of a
#          set of data items.
#
# VARIABLES: The registers have the following uses:
#
# %edi - Holds the index of the data item being examined
# %ebx - Largest data item found
# %eax - Current data item
#
# The following memory locations are used:
#
# data_items - contains the item data. A 0 is used
#              to terminate the data
#
# first step:  as --32 -o maximum-1.o maximum-1.s
# second step: ld -melf_i386 -o maximum-1 maximum-1.o


.section .data
data_items:

#These are the data items
.long	3,67,34,222,45,75,54,34,44,33,22,11,66,0

.section .text
.globl _start

_start:
		mov	$0x00, %edi			# move 0 into the index register
		mov	data_items(,%edi,4), %eax	# load the first byte of data
		mov	%eax, %ebx			# since this is the first item, %eax is
							# the biggest

	start_loop:					# start loop

		cmp	$0x00, %eax			# check to see if we’ve hit the end
		je	loop_exit			
		inc	%edi				# load next value
		mov	data_items(,%edi,4), %eax	
		cmp	%ebx, %eax			# compare values
		jge	start_loop			# jump to loop beginning if the new
							# one is bigger
		mov	%eax, %ebx			# move the value as the largest
		jmp	start_loop			# jump to loop beginning

	loop_exit:
		
# %ebx is the status code for the exit system call
# and it already has the minimum number
		
		movl	$0x01, %eax			# 1 is the exit() syscall
		int	$0x80

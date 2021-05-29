# PURPOSE: This program finds the maximum number of a
#          set of data items using an ending address of the string
#
# VARIABLES: The registers have the following uses:
#
# %edi - Holds the index of the data item being examined
# %ebx - Largest data item found
# %eax - Current data item
#
# The following memory locations are used:
#
# data_items - contains the item data.
#
# first step:  as --32 -o maximum-3.o maximum-3.s
# second step: ld -melf_i386 -o maximum-3 maximum-3.o


.section .data
data_items:

#These are the data items
.long	3,67,34,222,45,75,54,34,44,33,22,11,66,0

.section .text
.globl _start

_start:
		mov	$14, %ecx			#
		mov	$data_item, %eax		# put address of data_item in %eax
		

		mov	$data_items(,%edi,4), %eax	# take first item from array
		mov	%eax, %ebx			# since this is the first item, %eax is
							# the biggest


	start_loop:					# start loop

		cmp	data_items(,%ecx,4), %ebx	# check to see if we’ve hit the end
		je	loop_exit			
		inc	%edi				# load next value
		inc	%edx				# increase our counter
		mov	data_items(,%edi,4), %eax	
		cmp	%ebx, %eax			# compare values
		jle	start_loop			# jump to loop beginning if the new
							# one isn’t bigger
		mov	%eax, %ebx			# move the value as the largest
		jmp	start_loop			# jump to loop beginning

	loop_exit:
		
# %ebx is the status code for the exit system call
# and it already has the maximum-3 number
		
		movl	$0x01, %eax			# 1 is the exit() syscall
		int	$0x80

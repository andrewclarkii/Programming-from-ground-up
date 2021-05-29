# Create a program to find the smallest age in the file and return that age as the
# status code of the program.

.include "linux.s"
.include "record-def.s"

.section .data

input_file_name:	.ascii "test.dat\0"

.section .bss

.lcomm	record_buffer,	RECORD_SIZE
.lcomm	current_age,	4

# Stack offsets of local variables

.equ	ST_INPUT_DESCRIPTOR,	-4

.section .text

.globl	_start
	_start:
		
		mov	%esp, %ebp	# Copy stack pointer and make room for local variables
		sub	$8, %esp
		

		# Open file for reading

		mov	$SYS_OPEN, %eax
		mov	$input_file_name, %ebx
		mov	$0, %ecx
		mov	$0666, %edx
		int	$LINUX_SYSCALL

		mov	%eax, ST_INPUT_DESCRIPTOR(%ebp)
		
	loop_begin:

		push	ST_INPUT_DESCRIPTOR(%ebp)
		push	$record_buffer
		call	read_record
		add	$8, %esp

		# Returns the number of bytes read.
		# If it isn’t the same number we
		# requested, then it’s either an
		# end-of-file, or an error, so we’re
		# quitting
		
		cmp	$RECORD_SIZE, %eax
		jne	loop_end

		push	%ebx		# save ebx

		cmp	$0, current_age
		je	put_value


		mov	record_buffer + RECORD_AGE, %ebx	# put our age in ebx

	age_compare:

		cmp	current_age, %ebx			# compare current age and new one
		jl	write_current_age			# if it lesser then write it
		
                pop     %ebx                                    # restore original ebx


		jmp	loop_begin

	write_current_age:

		mov	%ebx, current_age			# write current age in variable
		pop	%ebx					# restore original ebx
		jmp	loop_begin
	
	put_value:

		mov     record_buffer + RECORD_AGE, %ebx
		mov	%ebx, current_age
		jmp	age_compare
		

	loop_end:

		mov	$SYS_EXIT, %eax
		mov	current_age, %ebx
		int	$LINUX_SYSCALL


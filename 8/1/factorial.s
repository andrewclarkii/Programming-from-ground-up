# PURPOSE - Given a number, this program computes the
#           factorial. For example, the factorial of
#           3 is 3 * 2 * 1, or 6. The factorial of
#           4 is 4 * 3 * 2 * 1, or 24, and so on.
# This program shows how to call a function recursively.
#
# first step:  as --32 -o factorial.o factorial.s
# second step: ld -melf_i386 -dynamic-linker /lib/ld-linux.so.2 factorial.o -o factorial -L /usr/x86_64-linux-gnu/lib32 -L . -lfactorial -lc


.section .data #This program has no global data

message:	.ascii "Factorial number is: %d\n\0"

.section .text

.globl	_start

	_start:

		push	$4		# The factorial takes one argument - the
					# number we want a factorial of. So, it
					# gets pushed

		call	factorial	# run the factorial function
		add	$4, %esp	# Scrubs the parameter that was pushed on

		push	%eax
		push	$message
		call	printf

		push	$0
		call	exit

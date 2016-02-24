.section    .init
.globl     _start

_start:
    b       main

.section .text

main:
    	mov     	sp, #0x8000 // Initializing the stack pointer
	bl		EnableJTAG  // Enable JTAG
	bl		InitUART    // Initialize the UART


// You can use WriteStringUART and ReadLineUART functions here after the UART initializtion.
	ldr	r0, = createdBy
	mov	r1,#23
	bl	WriteStringUART		// Print createdBy

do:	ldr	r0, = numStudent
	mov	r1, #38
	bl	WriteStringUART		// Print numStudent

	ldr	r0, = ABuff	        // Store address
	mov	r1,#256		       	// Number of chars
	bl	ReadLineUART		// ABuff now stores input

	ldr	r0, = ABuff
	ldrb	r2, [r0]		// ldrb - take ONE byte
atoi:	sub	r2, #48		     	// r2 now stores num of students

test:	cmp	r2, #1			// Test conditions
	blt	error
	cmp	r2, #9
	bgt	error
	b	Grades

error:	ldr	r0, = invStudent	// Provide error msg upon invalid num
	mov	r1, #66
	bl	WriteStringUART
	b	do

Grades:	ldr	r0, = totalSum
	mov	r1, #12
	bl	WriteStringUART

	

	

haltLoop$:
	b	haltLoop$

.section .data

createdBy:  // Char: 23
	.ascii	"Created By: Raza Qazi\n\r"

numStudent: // Char: 38
	.ascii	"Please enter the number of students:\n\r"

Grade:	    // Char: 34 per line.
	.ascii	"Please enter the first grade:   \n\rPlease enter the second grade:  \n\rPlease enter the third grade:   \n\rPlease enter the fourth grade:  \n\rPlease enter the fifth grade:   \n\rPlease enter the sixth grade:   \n\rPlease enter the seventh grade: \n\rPlease enter the eighth grade:  \n\rPlease enter the ninth grade:   \n\r"

wrongNum:   // Char: 22
	.ascii	"Wrong number format!\n\r"

invNum:     // Char: 62
	.ascii	"Invalid number! The number grade should be between 0 and 100\n\r"

invStudent: // Char: 66
	.ascii	"Invalid number! The number of students should be between 1 and 9\n\r"

totalSum:   // Char: 12
	.ascii	"The sum is: "

totalAvg:   // Char: 16
	.ascii	"The average is: "

newLine:    // Char: 2
	.ascii	"\n\r"

ABuff:
	.rept	256
	.byte	0
	.endr

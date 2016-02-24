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

	mov	r10, #10		// Constants to be used later
	mov	r11, #100
	
	ldr	r0, = createdBy
	mov	r1,#23
	bl	WriteStringUART		// Print createdBy

nameCHK:
	ldr	r0, = numStudent
	mov	r1, #38
	bl	WriteStringUART		// Print numStudent

	ldr	r0, = ABuff	        // Store address
	mov	r1,#256		       	// Number of chars
	bl	ReadLineUART		// ABuff now stores input

	ldr	r0, = ABuff
	ldrb	r2, [r0]		// ldrb - take ONE byte
atoi:	sub	r2, #48		     	// r2 now stores num of students

error1:
	cmp	r2, #1
	blt	errorINVS
	cmp	r2, #9
	bgt	errorINVS
	b	Grades

errorINVS:
	ldr	r0, = invStudent	// Provide error msg upon invalid num
	mov	r1, #66
	bl	WriteStringUART
	b	nameCHK			// Branch back to nameCHK - user reenters data

Grades:	ldr	r0, = GradeStr
	mov	r1, #36
	bl	WriteStringUART		// Print question

	add	r0, #4			// Offset address for next time *fingers crossed*

	ldr	r0, = ABuff	        // Store address
	mov	r1,#256		       	// Number of chars
	bl	ReadLineUART		// ABuff now stores input


	ldr	r0, = ABuff		// Continue once # b/w 1-9
	ldrb	r5, [r0, #1]	
	sub	r5, #48			// Contains the first digit
	
	ldrb	r6, [r0]		// Offset by 1 to capture byte @ 10th place
	sub	r6, #48			// Contains the second digit
	mla	r7, r6, r10, r5		// Need to multiply by 10: r7 = r6*r10 (#10) + r5 = 2 digit num
	

error2:
	cmp	r7, #5			// *****Change afterwards******* to 1 and 100
	blt	errorINVG
	cmp	r7, #96
	bgt	errorINVG
	b	cont			// IF number is between 1-99, cont, else, print error msg

errorINVG:
	ldr	r0, = invNum
	mov	r1, #62
	bl	WriteStringUART
	b	Grades
	
cont:	// HAVE MERCY ON US

	ldr	r0, = totalSum
	mov	r1, #12
	bl	WriteStringUART

haltLoop$:
	b	haltLoop$

.section .data

createdBy:  // Char: 23
	.ascii	"Created By: Raza Qazi\n\r"

numStudent: // Char: 38
	.ascii	"Please enter the number of students:\n\r"

GradeStr:   // Char: 36 per line.  OFFSET BY 9 BYTES EACH TIME
	.ascii	"Please enter the first grade:     \n\rPlease enter the second grade:    \n\rPlease enter the third grade:     \n\rPlease enter the fourth grade:    \n\rPlease enter the fifth grade:     \n\rPlease enter the sixth grade:     \n\rPlease enter the seventh grade:   \n\rPlease enter the eighth grade:    \n\rPlease enter the ninth grade:     \n\r"

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

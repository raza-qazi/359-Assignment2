// ---------------------------------------
// Created By: Raza Qazi
// CPSC 359 - Assignment # 2
// ---------------------------------------

.section    .init
.globl     _start

_start:
    b       main

.section .text

/*      r0 - reserved for addresses
        r1 - reserved for byte size
        r2 - number of students
        r3 - placeholder
        r4 - iteration count
        r5 - digit at first place
        r6 - digit at second place
        r7 - digit at third place
        r8 - grade value
        r9 - totalSum
        r10 - Constant 10
        r11 - stores address of Grade string
        tbc'd
*/

main:
    	mov     sp, #0x8000 // Initializing the stack pointer
	bl	EnableJTAG  // Enable JTAG
	bl	InitUART    // Initialize the UART

	// You can use WriteStringUART and ReadLineUART functions here after the UART initializtion.

	mov	r10, #10		// Constant to be used later

	ldr	r0, = createdBy
	mov	r1, #23
	bl	WriteStringUART		// Print createdBy

nameCHK:
	ldr	r0, = numStudent
	mov	r1, #38
	bl	WriteStringUART		// Print numStudent

	ldr	r0, = ABuff	        // Store address
	mov	r1, #1     	       	// Number of chars
	bl	ReadLineUART		// ABuff now stores input

	ldr	r0, = ABuff
	ldrb	r2, [r0]		// ldrb - take ONE byte
	sub	r2, #48		     	// r2 now stores num of students

error1:
	cmp	r2, #1
	blt	errorINVS
//      cmp	r2, #9                  // Redundant since bytes read == 1
//	bgt	errorINVS
	b	Grades

errorINVS:
	ldr	r0, = invStudent	// Provide error msg upon invalid num
	mov	r1, #66
	bl	WriteStringUART
	b	nameCHK			// Branch back to nameCHK - user reenters data

        mov     r4, #0                  // r4 stores iteration count
        ldr     r11, = GradeStr         // Setup address of GradeStr into r11 for use in loop
// For loop begins here
Grades:	cmp     r4, r2                  // while(i < numStudent)
        bge     dispOutput              // Branch out of the loop if i >= numStudent

        mov     r0, r11                 // Updated GradeStr address in r0
	mov	r1, #36
	bl	WriteStringUART		// Print GradeStr for each iteration

        mov     r11, r0
	add	r11, #9			// Offset address for next Grade Q *fingers crossed*

        ldr	r0, = ABuff	        // Store address
	mov	r1,#256		       	// Number of chars
	bl	ReadLineUART		// ABuff now stores input

        // TODO - conditions to check if userInput is 1, 2, or 3 digits
        // Assuming 3 digits with the first two possibly zero [r0, #2] = Xxx, [r0, #1] = xXx, [r0] = xxX
        ldrb    r7, [r0, #2]            // string at third place
        ldrb    r6, [r0, #1]            // String at second place
        ldrb    r5, [r0]                // String at the first place
        cmp     r7, #0
        bne     threeDigit              // If the digit at the third place is not zero, consider a three digit number
        cmp     r6, #0
        bne     twoDigit
        // ----

	ldr	r0, = ABuff		// Continue once # b/w 1-9
	ldrb	r5, [r0, #1]
	sub	r5, #48			// Contains the first digit

	ldrb	r6, [r0]		// Offset by 1 to capture byte @ 10th place
	sub	r6, #48			// Contains the second digit
	mla	r7, r6, r10, r5		// Need to multiply by 10: r7 = r6*r10 (#10) + r5 = 2 digit num

error2:
	cmp	r7, #1			// *****Change afterwards******* to 1 and 100
	blt	errorINVG
	cmp	r7, #100
	bgt	errorINVG
	b	cont			// IF number is between 1-99, cont, else, print error msg

errorINVG:
	ldr	r0, = invNum
	mov	r1, #62
	bl	WriteStringUART
	b	Grades

        add     r4, #1                  // i++
        b       Grades                  // Go to top of the loop

dispOutput:                     	// HAVE MERCY ON US

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

GradeStr:   // Char: 36 per line.  OFFSET BY 9*4 BYTES EACH TIME
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

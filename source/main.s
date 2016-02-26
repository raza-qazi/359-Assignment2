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
        r3 - number of students
        r4 - iteration count
        r5 - digit at first place
        r6 - digit at second place
        r7 - digit at third place
        r8 - grade value
        r9 - totalSum
        r10 - Constant 10
        r11 - stores address of Grade string
        r12 - Constant 0
        r13 - averageStorage
        tbc'd
*/

main:
    	mov     sp, #0x8000 // Initializing the stack pointer
	bl	EnableJTAG  // Enable JTAG
	bl	InitUART    // Initialize the UART

	// You can use WriteStringUART and ReadLineUART functions here after the UART initializtion.

	mov	r10, #10		// Constant 10
        mov     r12, #0                 // Constant 0

	ldr	r0, = createdBy
	mov	r1, #23
	bl	WriteStringUART		// Print createdBy

nameCHK:
	ldr	r0,= numStudent
	mov	r1, #39
	bl	WriteStringUART		// Print numStudent

	ldr	r0, = ABuff	        // Store address
	mov	r1, #1     	       	// Number of chars
	bl	ReadLineUART		// ABuff now stores input

	ldr	r0, = ABuff
	ldrb	r3, [r0]		// ldrb - take ONE byte
	sub	r3, #48		     	// r2 now stores num of students

	cmp	r2, #1
	blt	errorINVS
	b	continue

errorINVS:
	ldr	r0, = invStudent	// Provide error msg upon invalid num
	mov	r1, #66
	bl	WriteStringUART
	b	nameCHK			// Branch back to nameCHK - user reenters data

continue:
        mov     r4, #0                  // r4 stores iteration count
        ldr     r11, = GradeStr         // Setup address of GradeStr into r11 for use in loop

        mov     r9, #0                  // totalSum = 0
        mov     r13, #0                 // Average counter
// For loop begins here
Loop:
	cmp     r4, r3                  // while(i < numStudent)
        bge     continue2               // Branch out of the loop if i >= numStudent

        ldr     r0, = ABuff             // Preparing to reset
        strb    r12, [r0, #2]           // Reset the buffer to zero
        strb    r12, [r0, #1]           // ^ ^^ ^
        strb    r12, [r0]               //  ^  ^

        mov     r8, #0                  // r8 is result


        mov     r0, r11                 // Updated GradeStr address in r0
	mov	r1, #36
	bl	WriteStringUART		// Print GradeStr for each iteration

        ldr	r0, = ABuff	        // Store address
	mov	r1,#256		       	// Number of chars
	bl	ReadLineUART		// ABuff now stores input

        // At this point, r0 contains the length of the input
        cmp     r0, #3
        bgt     errorINVG

        cmp     r0, #0
        beq     errorINVG
        // Assuming 3 digits with the first two possibly zero [r0] = Xxx, [r0, #1] = xXx, [r0, #2] = xxX
	ldr	r0, = ABuff	        // Store address back into r0
        ldrb    r7, [r0, #2]            // string at first place
        ldrb    r6, [r0, #1]            // String at second place
        ldrb    r5, [r0]                // String at third place
test2:
	// From notes
	cmp	r5, #58			// is it any ascii value beyond 9?
	bge	wrongType		// If so, branch to errorMsg
	cmp	r6, #58
	bge	wrongType
	cmp	r7, #58
	bge 	wrongType

	cmp	r7, #0			// Is the digit at 3rd place 0?
	beq	twoDigit		// Branch to the case where the number might be
					// 2 digits in length
        // Create the three digit number
        sub     r5, #48                 // Number as an int
        sub     r6, #48                 // Number as an int
        sub     r7, #48                 // Number as an int

test:	add     r8, r7                  // r8 = r8 (0) + firstDigit
	mov	r10, #10		// Constant 10
        mul     r6, r10                 // r6 = r6*10 - digit at 2nd place
        add     r8, r6                  // r8 = first digit + second digit
	mov	r10, #10		// Constant 10
        mul     r5, r10
        mul     r5, r10                 // r5 = r5 * 100
        add     r8, r5                  // 3 digit num

        cmp	r8, #0
        blt	errorINVG
        cmp	r8, #100
        bgt	errorINVG

	b	totalSum
twoDigit:
	cmp	r5, #0
	beq	oneDigit

	sub     r5, #48                 // Number as an int
        sub     r6, #48                 // Number as an int

	mov	r10, #10		// Constant 10
	mla	r8, r5, r10, r6		// Need to multiply by 10: r7 = r6*r10 (#10) + r5 = 2 digit num
                                        // No error check needed
        b       totalSum
oneDigit:
        sub     r7, #48                 // Number as an int

        add     r8, r7
        b       totalSum
wrongType:
        ldr     r0, = wrongNum
        mov     r1, #22
        bl      WriteStringUART
        b       Loop

errorINVG:
	ldr	r0, = invNum		// Not between 1 and 100
	mov	r1, #62
	bl	WriteStringUART
	b	Loop

totalSum:
        add     r9, r8                  // Add value in current iteration to total grade
	add	r11, #0x24		// Offset address for next Grade Question - Will only happen if the number inputted is correct
        add     r4, #1                  // i++
        b       Loop                    // Go to top of the loop

        // Assuming total value is final
continue2:
	mov	r0, r9			// Temp value to store total sum
	mov	r10, r2			// temp to store numstudent
	mov	r4, #0			// increment i

avgCalc:
        cmp     r0, #0                  // Doc
        beq     dispOutput	                 //
        blt     decrement

        sub	r0, r10			 // Subtract from total, numStudent
					// Repeat until zero or less

        add     r4, #1			// Count one each time

	b	avgCalc			// Go to top and compare

decrement:				// Applicable if the divison is has a remainder
	sub	r4, #1

dispOutput:

	ldr	r0, = totalSumStr
	mov	r1, #12
	bl	WriteStringUART

haltLoop$:
	b	haltLoop$

.section .data

createdBy:  // Char: 23
	.ascii	"Created By: Raza Qazi\n\r"

numStudent: // Char: 39
	.ascii	"Please enter the number of students:\n\r>"

GradeStr:   // Char: 36 per line.  OFFSET BY 9*4 BYTES EACH TIME - 0x24
	.ascii	"Please enter the first grade:     \n\rPlease enter the second grade:    \n\rPlease enter the third grade:     \n\rPlease enter the fourth grade:    \n\rPlease enter the fifth grade:     \n\rPlease enter the sixth grade:     \n\rPlease enter the seventh grade:   \n\rPlease enter the eighth grade:    \n\rPlease enter the ninth grade:     \n\r"

wrongNum:   // Char: 22
	.ascii	"Wrong number format!\n\r"

invNum:     // Char: 62
	.ascii	"Invalid number! The number grade should be between 0 and 100\n\r"

invStudent: // Char: 66
	.ascii	"Invalid number! The number of students should be between 1 and 9\n\r"

totalSumStr:   // Char: 12
	.ascii	"The sum is: "

totalAvg:   // Char: 16
	.ascii	"The average is: "

newLineStr:    // Char: 2
	.ascii	"\n\r"


ABuff:
	.rept	256
	.byte	0
	.endr

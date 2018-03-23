;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------
;- Programmers: Jake Loveland, Jesus Blanco
;- Date: 03-15-2017
;-
;- This project contains the assembly code for our CPE 233 Class Final Project.
;- Our project is based off the popular '2048' game. Our blocks, however, are color
;- coded instead of relying on numbers. The player's objective is to combine blocks
;- of the same color.
;-----------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------
;- Constants
;-----------------------------------------------------------------------------------------
.EQU VGA_HADD  = 0x90				; port for the VGA_HADD --------- OUTPUT
.EQU VGA_LADD  = 0x91 				; port for the VGA_LADD --------- OUTPUT
.EQU VGA_COLOR = 0x92 				; port for the VGA_COLOR -------- OUTPUT
.EQU BUTTONS = 0x9A 				; port for the button input ----- INPUT
.EQU RAND = 0x8A 				; port for random location ------ INPUT
;-----------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------
;- Memory Designation Constants
;-----------------------------------------------------------------------------------------
.DSEG
.ORG 0x000
.DB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
.DB 0xFF, 0x00, 0x00, 0x00, 0x00, 0xFF
.DB 0xFF, 0x00, 0x01, 0x01, 0x00, 0xFF
.DB 0xFF, 0x00, 0x00, 0x00, 0x00, 0xFF
.DB 0xFF, 0x00, 0x00, 0x00, 0x00, 0xFF
.DB 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------
.CSEG
.ORG 0x80

MOV r26, 0x00					; Sets drawing color to black.

Draw_Background:
		 CALL BACKGROUND_M  		; Draws a black background.
		 
MOV r26, 0xFF

Draw_Grid:
		 MOV r28, 0x14 			; Initial X-Coordinate of the upper-left block.
		 MOV r27, 0x0A 			; Initial Y-Coordinate of the upper-left block.
		 MOV r16, 0x07
		 Call Grid_Driver		; Draws grid.
		 SEI				; Enables interrupts.
		 BRN Draw_Grid			

;-----------------------------------------------------------------------------------------
;- SUBROUTINES
;-----------------------------------------------------------------------------------------
;- BLOCK COLOR
;- This Subroutine Identifies the Block's Color
;- (X,Y) = (r28,r27)  with a color stored in r26
;- Other registers used: r15, r16, r26
;-----------------------------------------------------------------------------------------

ColorMain:
		 LD r15, (r16)			; Loads the Block from the Memory.
		 ADD r16, 0x01			; Increments the Memory Address.
		 CMP r15, 0x00			; Compares the block value to determine the color.
		 BREQ WHITE			; Realizes its an Empty Block.
		 CMP r15, 0x01			; Compares the block value to determine the color.
		 BREQ BLOCK2			; Realizes its a block with Value 2.
		 CMP r15, 0x02			; Compares the block value to determine the color.
		 BREQ BLOCK4			; Realizes its a block with Value 4.
		 CMP r15, 0x03			; Compares the block value to determine the color.
		 BREQ BLOCK8			; Realizes its a block with Value 8.
		 CMP r15, 0x04			; Compares the block value to determine the color.
		 BREQ BLOCK16			; Realizes its a block with Value 16.
		 CMP r15, 0x05			; Compares the block value to determine the color.
		 BREQ BLOCK32			; Realizes its a block with Value 32.
		 CMP r15, 0x06			; Compares the block value to determine the color.
		 BREQ BLOCK64			; Realizes its a block with Value 64.
		 CMP r15, 0x07			; Compares the block value to determine the color.
		 BREQ BLOCK128			; Realizes its a block with Value 128.
		 CMP r15, 0x08			; Compares the block value to determine the color.
		 BREQ BLOCK256			; Realizes its a block with Value 256.
		 CMP r15, 0x09			; Compares the block value to determine the color.
		 BREQ BLOCK512			; Realizes its a block with Value 512.
		 CMP r15, 0x0A			; Compares the block value to determine the color.
		 BREQ BLOCK1024			; Realizes its a block with Value 1024.
		 CMP r15, 0x0B			; Compares the block value to determine the color.
		 BREQ BLOCK2048			; Realizes its a block with Value 2048.
		 CMP r15, 0xFF
		 BREQ ColorMain
		 
WHITE:
		 MOV r26, 0xFF			; Sets the color for an empty block.
		 RET
		
BLOCK2:
		 MOV r26, 0x7D			; Sets the color for a block with Value 2.
		 RET
		
BLOCK4:
		 MOV r26, 0x3E			; Sets the color for a block with Value 4.
		 RET
		
BLOCK8:
		 MOV r26, 0x1C			; Sets the color for a block with Value 8.
		 RET
		
BLOCK16:
		 MOV r26, 0x92			; Sets the color for a block with Value 16.
		 RET
		
BLOCK32:
		 MOV r26, 0xE2			; Sets the color for a block with Value 32.
		 RET
		
BLOCK64:
		 MOV r26, 0xE0			; Sets the color for a block with Value 64.
		 RET
		
BLOCK128:
		 MOV r26, 0xFC			; Sets the color for a block with Value 128.
		 RET
		
BLOCK256:
		 MOV r26, 0xBD			; Sets the color for a block with Value 256.
		 RET
		
BLOCK512:
		 MOV r26, 0x9F			; Sets the color for a block with Value 512.
		 RET
		
BLOCK1024:
		 MOV r26, 0xB3			; Sets the color for a block with Value 1024.
		 RET
		
BLOCK2048:
		 MOV r26, 0x13			; Sets the color for a block with Value 2048.
		 RET

;-----------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------
;- DRAW BACKGROUND
;- This Subroutine Draws the entire BACKGROUND
;- (X,Y) = (r28,r27)  with a color stored in r26
;- Other registers used: r22, r23
;-----------------------------------------------------------------------------------------
BACKGROUND_M:
		 CALL draw_dot			; Draws an individual black dot.
		 ADD r28, 0x01			; Increments the X-Coordinate by one.
		 CMP r23, 0x80			; Checks to see if the maximum X-Coordinate is reached.
		 BREQ BACKGROUND_N
		 ADD r23, 0x01			; Increments the X-Coordinate counter.
		 BRN BACKGROUND_M

BACKGROUND_N:
		 CMP r22, 0x60			; Checks to see if the maximum Y-Coordinate is reached.
		 BREQ BACKGROUND_DONE
		 ADD r22, 0x01			; Increments the Y-Coordinate counter.
		 MOV r28, 0x00			; Resets the X-Coordinate.
		 MOV r23, 0x00			; Resets the X-Coordinate counter.
		 ADD r27, 0x01			; Increments the Y-Coordinate.
		 BRN BACKGROUND_M

BACKGROUND_DONE:
		 MOV r22, 0x00			; Clears the Y-Coordinate Counter.
		 MOV r23, 0x00			; Clears the X-Coordinate Counter.
		 RET
;-----------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------
;- DRAW Grid
;- This subroutine draws the entire grid
;- (X,Y) = (r28,r27)  with a color stored in r26  
;- Other registers used: r13, r14
;-----------------------------------------------------------------------------------------
Grid_Driver:
		 CMP r13, 0x04			; Checks to see if the maximum grid width is reached.
		 BREQ Grid_Col			
		 BRN Grid_Row	
		 
Grid_Row:
		 CALL DRAW_BLOCK		; Draws a block.
		 ADD r28, 0x0A			; Increments the X-Coordinate by 16.
		 ADD r13, 0x01			; Increments the X-Coordinate Counter.
		 CMP r13, 0x04			; Checks to see if the maximum grid width is reached.
		 BREQ Grid_Driver
		 BRN Grid_Row
		 
Grid_Col:
		 ADD r14, 0x01			; Increments the Y-Coordinate Counter.
		 MOV r13, 0x00			; Resets the X-Coordinate Counter.
		 MOV r28, 0x14			; Resets the X-Coordinate.
		 ADD r27, 0x0A			; Increments the Y-Coordinate by 16.
		 CMP r14, 0x04			; Checks to see if the maximum grid height is reached.
		 BREQ Grid_Done
		 BRN Grid_Row
		 
Grid_Done:
		 MOV r13, 0x00			; Clears the X-Coordinate Counter.
		 MOV r14, 0x00			; Clears the Y-Coordinate Counter.
		 RET
		 
;-----------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------
;- DRAW BLOCK
;- This subroutine draws one single block
;- (X,Y) = (r28,r27)  with a color stored in r26  
;- Other registers used: r12, r29, r30, r31,
;-----------------------------------------------------------------------------------------

DRAW_BLOCK:
		 CALL ColorMain			; MODIFY TO INCLUDE COLOR BEING DECLARED HERE (DECLARE R6 HERE)
		 MOV r31, r28 			; Copies the block's initial X-Coordinate.
		 MOV r12, r27			; Copies the block's initial Y-Coordinate.
		 BRN BlockDriver

BlockDriver:
		 CMP r29, 0x08			; Checks to see if the block's maximum X-Coordinate is reached.
		 BREQ DRAW_COL
		 BRN DRAW_ROW
		 
DRAW_ROW:
		 CALL draw_dot			; Draws an individual dot of the block's color.
		 ADD r28, 0x01			; Increments the X-Coordinate by one.
		 ADD r29, 0x01			; Increments the X-Coordinate counter.
		 CMP r29, 0x08			; Checks to see if the block's maximum X-Coordinate is reached.
	 	 BREQ BlockDriver
	     	 BRN DRAW_ROW

DRAW_COL:
		 ADD r30, 0x01			; Increments the Y-Coordinate counter.
		 MOV r29, 0x00			; Resets the X-Coordinate counter.
		 MOV r28, r31			; Resets the X-Coordinate.
		 ADD r27, 0x01			; Increments the X-Coordinate by one.
		 CMP r30, 0x08			; Checks to see if the block's maximum Y-Coordinate is reached.
		 BREQ BLOCK_DONE
		 BRN DRAW_ROW

BLOCK_DONE:
		 MOV r29, 0x00			; Clears the Y-Coordinate Counter.
		 MOV r30, 0x00  		; Clears the Y-Coordinate Counter.
		 MOV r28, r31			; Reset the X-Coordinate to the block's initial X-Coordinate.
		 MOV r27, r12			; Reset the Y-Coordinate to the block's initial Y-Coordinate.
		 RET
		 
;-----------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------
;- DRAW_DOT
;- This subroutine draws a dot on the display the given coordinates: 
;- (X,Y) = (r28,r27)  with a color stored in r26  
;- Other registers used: r24,r25 
;-----------------------------------------------------------------------------------------

draw_dot:
         	MOV r24, r27         		; Copies Y-Coordinate
        	MOV r25, r28         		; Copies X-Coordinate
         	AND r25, 0x7F      		; Makes sure the top 1 bits are cleared.
         	AND r24, 0x3F      		; Makes sure the top 2 bits are cleared.
         	LSR r24            		; Place bottom bit of r4 into r5. 
         	BRCS dd_add80 
		 
dd_out:
         	OUT r25, VGA_LADD   		; Write bottom 8 address bits to register.
         	OUT r24, VGA_HADD   		; Write top 5 address bits to register.
         	OUT r26, VGA_COLOR  		; Write color data to frame buffer.
         	RET            
		 
dd_add80:
         	OR  r25, 0x80       		; Set bit if needed.
         	BRN dd_out
		 
;-----------------------------------------------------------------------------------------
;- END OF SUBROUTINES
;-----------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------
;- ISR
;-----------------------------------------------------------------------------------------

ISR:
		 IN  r7,  BUTTONS		; Take in the buttons.
		 CMP r7,  0x01			; If right pressed
	 	 BREQ right			; setup right values.
		 CMP r7,  0x02			; If up pressed
		 BREQ up			; setup up values.
		 CMP r7,  0x04			; If down pressed
		 BREQ down			; setup down values.
		 CMP r7,  0x08			; If left pressed
		 BREQ left			; setup left values.
		 BRN ISR

right:	
		 MOV r2,  0x0A			; Starting address (top right).
		 MOV r3,  0xFF			; Column increment (left).
		 MOV r4,  0x03			; Column reset (3).
		 MOV r5,  0x06			; Row increment (down).
		 BRN main

left:	
		 MOV r2,  0x07			; Starting address (top left).
		 MOV r3,  0x01			; Column increment (right).
		 MOV r4,  0xFD			; Column reset (-3).
		 MOV r5,  0x06			; Row increment (down).
		 BRN main

up:		
		 MOV r2,  0x07			; Starting address (top left).
		 MOV r3,  0x06			; Column increment (down).
		 MOV r4,  0xEE			; Column reset (-18).
		 MOV r5,  0x01			; Row increment (right).
		 BRN main

down:	
		 MOV r2,  0x19			; Starting address (bottom left).
		 MOV r3,  0xFA			; Column increment (up).
		 MOV r4,  0x12			; Column reset (18).
		 MOV r5,  0x01			; Row increment (right).
		 BRN main

main:	
		 MOV r0,  r2			; Get current address.
		 MOV r1,  r2
		 ADD r1,  r3			; Get next address.
		 
newSpot:
		 LD  r10, (r0)			; Value at starting spot.
		 LD  r11, (r1)			; Value in next spot.
		 CMP r11, 0xFF			; If it is an edge
		 BREQ incrRow			; go to the next row.
		 CMP r11, 0x00			; Else if left is empty
		 BREQ incrCol			; go increment the column.
		 CMP r10, 0x00			; Else if the current is empty
		 BREQ swap			; swap current and next.
		 CMP r10, r11			; Else if the left is the same
		 BREQ combine			; merge the two.
		 BRN incrCol			; Else increment the column.

swap:	
		 MOV r10, r11			; Put next in current.
		 MOV r11, 0x00			; Make next 0.
		 MOV r6,  0x01			; Not done boolean.
		 BRN incrCol

combine:
		 ADD r10, 0x01
		 MOV r11, 0x00
		 CMP r10, 0x011
		 BRNE notwin
		 ST  r10, (r0)
		 ST  r11, (r1)
		 RETID
		 
notwin:	
		 BRN incrCol

incrCol:
		ST  r10, (r0)
		ST  r11, (r1)
		ADD r0,  r3			; Increment column of current.
		ADD r1,  r3			; Increment column of next.
		BRN newSpot			; Move on to new spot.

incrRow:
		 CMP r6, 0x01
		 BREQ resetCol
		 ST  r10, (R0)
		 ST  r11, (R1)
		 ADD r1,  r5			; Checking next row.
		 ADD r1,  r4			; Reset columns.
		 LD  r11, (r1)
		 CMP r11, 0xFF			; If next row is an edge
		 BREQ done			; completed entire grid
		 ADD r0,  r4			; Else reset columns
		 ADD r0,  r5			; and increment rows
		 BRN newSpot			; Start again at new row.

resetCol:
		 ST  r10, (R0)
		 ST  r11, (R1)
		 ADD r1,  r4			; Reset columns of next.
		 ADD r0,  r4			; Reset columns of current.
		 MOV r6,  0x00
		 BRN newSpot

done:	 
		 IN  r8,  RAND
		 LD  r18, (r8)
		 CMP r18, 0x00
		 BRNE done
		 MOV r9,  0x01
		 ST  r9,  (r8)
		 RETID

;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------
.ORG 0x3FF					; Interrupt Vector.
BRN ISR							

.code16
.section .data

# 8-byte display
# display[0] is digit 0 through display[7] which is digit 7
display:
    .byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00

# Port A activates one of the 8 display digits at a time.
digit_select:
    .byte 0x01,0x02,0x04,0x08,0x10,0x20,0x40,0x80

# Segment bytes sent to Port B
E = 0x79        # E = a d e f g = 0b01111001 = 0x79
H = 0x76        # H = b c e f g = 0b01110110 = 0x76
S = 0x6D        # S = a c d f g = 0b01101101 = 0x6D
BLANK  = 0x00

.section .text
.globl _start

_start:
    mov $0b10000000,%al     # Load control word
                            # Mode set operation
                            # Port B output, Port C output
                            # Group A Mode 0,
                            # Port A output, Port C output
    mov $0x643h,%dx         # Selects 8255 control port
    out %al,%dx             # Sets control word to 8255

    mov  %0, %bx             # The position of letter E (BL)

main_loop:
    # Build the next 8-digit display that wraps around
    # E at BL
    # H at (BL+1) mod 8
    # S at (BL+2) mod 8

    # Clear all 8 digits to blank first for the shift
    mov  $0, %di
    movw $8, %cx

clear_loop:
    movb $BLANK, display(%di)
    inc  %di
    loop clear_loop

    # Put E into display[BL]
    mov  $0, %bh            
    movw %bx, %di
    movb $E, display(%di)

    # Put H into display[(BL+1) mod 8]
    movw %bx, %di
    inc  %di
    andw $0x0007, %di
    movb $H, display(%di)

    # Put S into display[(BL+2) mod 8]
    movw %bx, %di
    addw $2, %di
    andw $0x0007, %di
    movb $S, display(%di)


    # Refresh the 8-digit multiplexed display
    movw $300, %bp            # Number of refresh passes

refresh_pass:
    mov  $0, %si             # SI is the digit index 

refresh_digit:
    # Send the segment pattern for the current digit to Port B
    movb display(%si), %al
    movw $0x641, %dx          # Port B  segment data
    out  %al, %dx

    # Send the digit-enable byte to Port A
    movb digit_select(%si), %al
    movw $0x640, %dx          # Port A  digit select
    out  %al, %dx

    # Delay
    movw $250, %cx

digit_delay:
    # Delays
    nop
    loop digit_delay

    # moving to next digit
    inc  %si        # Increment the digit index
    cmpw $8, %si
    jne  refresh_digit      # Jumps back if not equal

    dec  %bp
    jne  refresh_pass

    # Advance word one digit to the left with wraparound
    inc  %bl
    # Does the mod operation to wrap around
    andb $0x07, %bl

    jmp  main_loop
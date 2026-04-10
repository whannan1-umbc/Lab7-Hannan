.section .text
.globl _start

_start:
    mov $0b10000000, %al      # set bit command byte A
                              # Group B Mode 0,
                              # Port B output, Port C output
                              # Group A Mode 0,
                              # Port A output, Port C output
    mov $0x643, %dx           # control port for 8255 at base 0x640
    out %al, %dx              # displays

refresh:
    # digit 0 = E
    mov $0x79, %al
    mov $0x641, %dx
    out %al, %dx

    mov $0x01, %al
    mov $0x640, %dx
    out %al, %dx

    # digit 1 = H
    mov $0x76, %al
    mov $0x641, %dx
    out %al, %dx

    mov $0x02, %al
    mov $0x640, %dx
    out %al, %dx

    # digit 2 = S
    mov $0x6D, %al
    mov $0x641, %dx
    out %al, %dx
    
    mov $0x04, %al
    mov $0x640, %dx
    out %al, %dx

    jmp refresh          # keeps SHE at 2, 1, 0 forever
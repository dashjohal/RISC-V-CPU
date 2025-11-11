.text
.globl main

main:
    li a0, 0        #set a0 to 0
    addi a0, a0, 1  #a0 = 0000 0001
    JAL     ra, delay

    slli a0, a0, 1  #a0 = 0000 0010
    addi a0, a0, 1  #a0 = 0000 0011
    JAL     ra, delay

    slli a0, a0, 1  #a0 = 0000 0110
    addi a0, a0, 1  #a0 = 0000 0111
    JAL     ra, delay

    slli a0, a0, 1  
    addi a0, a0, 1  #a0 = 0000 1111
    JAL     ra, delay

    slli a0, a0, 1  
    addi a0, a0, 1  #a0 = 0001 1111
    JAL     ra, delay

    slli a0, a0, 1 
    addi a0, a0, 1  #a0 = 0011 1111
    JAL     ra, delay

    slli a0, a0, 1 
    addi a0, a0, 1  #a0 = 0111 1111
    JAL     ra, delay

    slli a0, a0, 1 
    addi a0, a0, 1  #a0 = 1111 1111



    JAL     ra, delay
    JAL     ra, delay
    JAL     ra, delay

    
    li      a0, 0
    bne     a0, zero, finish    # enter finish state


delay:       
    li      a1, 0x020           # loop_count a1 = 32
_loop1:                         # repeat
    addi    a1, a1, -1          #     decrement a1
    bne     a1, zero, _loop1    # until a1 = 0
    ret

finish:     
    bne     a0, zero, finish     # loop forever
.data
array: .word 7,-12,-1421,-22,-14,20,9,0,-14
array_length: .word 9
.text

main:
    # load array information
    la a0, array
    la a1, array_length
    
    #--------Call ReLU--------#
    # store argument
    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw ra, 8(sp)
    # jump to ReLU
    jal ReLU
    # restore argument
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw ra, 8(sp)
    addi sp, sp, 12
    #-------------------------#


    #-------Call ArgMax-------#
    # store argument
    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw ra, 8(sp)
    # jump to ArgMax
    jal ArgMax # return a0 as index of MaxValue in array
    # restore argument
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw ra, 8(sp)
    addi sp, sp, 12
    #-------------------------#

    # Exit program
    li a0,10
    ecall

#--------------------ReLU function--------------------#
#假設call ReLU 已經將 la a0,array、la a1,array_length
ReLU:
    # check array_length ≥ 1
    blt a1, zero, ReLU_error

    # load array_length count
    lw t1, 0(a1)
ReLU_abs:
    # load number from memory
    lw t0, 0(a0)
    bge t0, zero, ReLU_done

    # negate a0
    sub t0, x0, t0

    # store number back to memory
    sw t0, 0(a0)

    # loop condition -1 and set next index
ReLU_done:
    addi t1, t1, -1
    addi a0, a0, 4
    bne zero, t1, ReLU_abs
    jr ra
ReLU_error:
    li a0, 36
    jr ra
#-----------------------------------------------------#

#-------------------ArgMax function-------------------#
#假設call ReLU 已經將 la a0,array、la a1,array_length
ArgMax:
    # check array_length ≥ 1
    blt a1, zero, ReLU_error
    
    # load array_length count
    lw t1, 0(a1)
    # load number from memory
    lw t0, 0(a0)
    # load array address form memory
    add t3, zero, a0
ArgMax_loop:
    # Load number from memory
    lw t2, 0(t3)
    bge t0, t2, ArgMax_done
    # load array address form memory
    add a0, zero, t3
    # update the max value
    add t0, zero, t2
ArgMax_done:
    addi t1, t1, -1
    addi t3, t3, 4
    bne zero, t1, ArgMax_loop
    jr ra
ArgMax_error:
    li a0, 36
    jr ra
#-----------------------------------------------------#
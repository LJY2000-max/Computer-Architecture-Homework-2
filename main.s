.data
array: .word 7,-12,-1421,-22,-14,20,9,0,-14
array_length: .word 9
array1:.word 1,2,3,4,5,6,7,8,9
array2:.word 6,1,6,1,6,1,6,1,6
array_stride1:.word 2
array_stride2:.word 2
array_length1:.word 9
array_length2:.word 9
calculation_element:.word 5
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

    # load array information
    la a0, array1
    la a1, array2
    la a2, calculation_element
    la a3, array_stride1
    la a4, array_stride2
    # check element will not cause an out-of-bound
    la t0, array_length1
    la t1, array_length2
    lw t0, 0(t0)
    lw t1, 0(t1)
    lw t2, 0(a3)
    lw t3, 0(a4)
    # calculate ceil(array_length1/array_stride1)
    div t4, t0, t2
    rem t6, t0, t2
    beq t6, zero, check1_end
    addi t4, t4, 1
check1_end:
    # calculate ceil(array_length1/array_stride1)
    div t5, t1, t3
    rem t6, t1, t3
    beq t6, zero, check2_end
    addi t5, t5, 1
check2_end:
    # find min(t4, t5)
    blt t4, t5, check3_end
    addi t4, t5, 0
check3_end:
    # ensure t6 less than t4 value
    lw t6, 0(a2)
    blt t6, t4, Exit

    #-----Call DotProduct-----#
    # store argument
    addi sp, sp, -24
    sw ra, 0(sp)
    sw a0, 4(sp)
    sw a1, 8(sp)
    sw a2, 12(sp)
    sw a3, 16(sp)
    sw a4, 20(sp)
    # jump to DotProdunct
    jal DotProduct # return
    # restore argument
    lw ra, 0(sp)
    lw a0, 4(sp)
    lw a1, 8(sp)
    lw a2, 12(sp)
    lw a3, 16(sp)
    lw a4, 20(sp)
    addi sp, sp, 24
    #-------------------------#

Exit:
    # Exit program
    li a0,10
    ecall

#--------------------ReLU function--------------------#
#假設call ReLU 已經將 la a0,array、la a1,array_length
ReLU:
    # check array_length ≥ 1
    li t0, 1
    lw t1, 0(a1)
    blt t1, t0, ReLU_error

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
#假設call ArgMax 已經將 la a0,array、la a1,array_length
ArgMax:
    # check array_length ≥ 1
    li t0, 1
    lw t1, 0(a1)
    blt t1, t0, ReLU_error

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

#-----------------DotProduct function-----------------#
#假設call DotProduct 已經將 la a0,array1、la a1,array2、la a2,calculation_element、la a3,array_stride1、la a4 array_stride2
DotProduct:
    # store temp reg.
    addi sp, sp, -8
    sw s0, 0(sp)
    sw s1, 4(sp)
    addi s0, zero, 0
    

    # check calculation_element ≥ 1
    li t0, 1
    lw t1, 0(a2)
    blt t1, t0, DotProduct_error_element
    # check array_stride ≥ 1
    lw t1 0(a3)
    blt a3, t0, DotProduct_error_stride
    lw t1 0(a4)
    blt a4, t0, DotProduct_error_stride

    # load calculation element count
    lw t2, 0(a2)
    # load array_stride
    lw t3, 0(a3)
    lw t4, 0(a4)
    # change to stride*4
    slli t3, t3, 2
    slli t4, t4, 2
DotProduct_loop:
    # load number from memory
    lw t0, 0(a0)
    lw t1, 0(a1)
    mul s1, t0, t1
    add s0, s0, s1
DotProduct_done:
    addi t2, t2, -1
    add a0, a0, t3
    add a1, a1, t4
    bne zero, t2, DotProduct_loop
    addi a0, s0, 0

    # restore temp reg.
    lw s0, 0(sp)
    lw s1, 4(sp)
    addi sp, sp, 8

    jr ra
DotProduct_error_element:
    li a0, 36
    jr ra
DotProduct_error_stride:
    li a0, 37
    jr ra
#-----------------------------------------------------#
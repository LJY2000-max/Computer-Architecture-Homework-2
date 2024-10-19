.data
array: .word 7,-12,-1421,-22,-14,20,9,0,-14
array_length: .word 9
array1:.word 1,2,3,4,5,6,7,8,9
array2:.word 6,1,6,1,6,1,6,1,6
array1_stride:.word 2
array2_stride:.word 2
array1_length:.word 9
array2_length:.word 9
calculation_element:.word 5
matrix1:    .word 1,5,9,13,17,2,6,10,14,18,3,7,11,15,19,4,8,12,16,20,5,9,13,17,21
matrix2:    .word 5,1,9,5,1,4,6,8,6,2,3,3,7,7,3,2,4,6,8,4,1,5,5,9,5
matrix3:    .space 100
matrix1_row:.word 5
matrix1_col:.word 5
matrix2_row:.word 5
matrix2_col:.word 5
.text

#-----------------Calling  Convention-----------------#
#          Caller: ra、sp、tp、t0~t6、a0～a7
#          Callee: gp、s0~s11
#-----------------------------------------------------#

main:
    # load array information
    la a0, array
    la a1, array_length
    lw a1, 0(a1)
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


    # load array information
    la a0, array
    la a1, array_length
    lw a1, 0(a1)
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
    lw a2, 0(a2)
    la a3, array1_stride
    lw a3, 0(a3)
    la a4, array1_stride
    lw a4, 0(a4)
    # check element will not cause an out-of-bound
    la t0, array1_length
    la t1, array2_length
    lw t0, 0(t0)
    lw t1, 0(t1)
    # calculate ceil(array1_length/array1_stride)
    div t4, t0, a3
    rem t6, t0, a3
    beq t6, zero, check1_end
    addi t4, t4, 1
check1_end:
    # calculate ceil(array1_length/array1_stride)
    div t5, t1, a4
    rem t6, t1, a4
    beq t6, zero, check2_end
    addi t5, t5, 1
check2_end:
    # find min(t4, t5)
    blt t4, t5, check3_end
    addi t4, t5, 0
check3_end:
    # ensure a2 less than t4 value
    blt a2, t4, Exit

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
    jal DotProduct # return a0 as DotProduct result or error code
    # restore argument
    lw ra, 0(sp)
    lw a0, 4(sp)
    lw a1, 8(sp)
    lw a2, 12(sp)
    lw a3, 16(sp)
    lw a4, 20(sp)
    addi sp, sp, 24
    #-------------------------#

    # load matrix information
    la a0, matrix1
    la a1, matrix1_row
    lw a1, 0(a1)
    la a2, matrix1_col
    lw a2, 0(a2)
    la a3, matrix2
    la a4, matrix2_row
    lw a4, 0(a4)
    la a5, matrix2_col
    lw a5, 0(a5)
    la a6, matrix3

    #-----Call MatrixMultiplication-----#
    # store argument
    addi sp, sp, -32
    sw ra, 0(sp)
    sw a0, 4(sp)
    sw a1, 8(sp)
    sw a2, 12(sp)
    sw a3, 16(sp)
    sw a4, 20(sp)
    sw a5, 24(sp)
    sw a6, 28(sp)

    jal MatrixMultiplication

    # restore argument
    lw ra, 0(sp)
    lw a0, 4(sp)
    lw a1, 8(sp)
    lw a2, 12(sp)
    lw a3, 16(sp)
    lw a4, 20(sp)
    lw a5, 24(sp)
    lw a6, 28(sp)
    addi sp, sp, 32
    #-----------------------------------#
Exit:
    # Exit program
    li a0,10
    ecall

#--------------------ReLU function--------------------#
#a0: array address
#a1: array_length
ReLU:
    # check array_length ≥ 1
    li t0, 1
    blt a1, t0, ReLU_error
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
    addi a1, a1, -1
    addi a0, a0, 4
    bne zero, a1, ReLU_abs
    jr ra
ReLU_error:
    li a0, 36
    jr ra
#-----------------------------------------------------#

#-------------------ArgMax function-------------------#
#a0: array address
#a1: array length
ArgMax:
    # check array_length ≥ 1
    li t0, 1
    blt a1, t0, ReLU_error

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
    addi a1, a1, -1
    addi t3, t3, 4
    bne zero, a1, ArgMax_loop
    jr ra
ArgMax_error:
    li a0, 36
    jr ra
#-----------------------------------------------------#

#-----------------DotProduct function-----------------#
#a0: array1 address
#a1: array2 address
#a2: calculation_element
#a3: array1_stride
#a4: array2_stride
DotProduct:
    # store temp reg.
    addi sp, sp, -8
    sw s0, 0(sp)
    sw s1, 4(sp)
    addi s0, zero, 0
    

    # check calculation_element ≥ 1
    li t0, 1
    blt a2, t0, DotProduct_error_element
    # check array_stride ≥ 1
    blt a3, t0, DotProduct_error_stride
    blt a4, t0, DotProduct_error_stride

    # change to stride*4
    slli a3, a3, 2
    slli a4, a4, 2
DotProduct_loop:
    # load number from memory
    lw t0, 0(a0)
    lw t1, 0(a1)
    mul s1, t0, t1
    add s0, s0, s1
DotProduct_done:
    addi a2, a2, -1
    add a0, a0, a3
    add a1, a1, a4
    bne zero, a2, DotProduct_loop
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


#------------MatrixMultiplication function------------#
#a0: matrix1 address
#a1: matrix1_row
#a2: matrix1_col
#a3: matrix2 address
#a4: matrix2_row
#a5: matrix2_col
#a6: matrix3 address
MatrixMultiplication:
    # check any matrix row and col is higher than 1
    bge zero, a1, MatrixMultiplication_error_negtiveRowOrCol
    bge zero, a2, MatrixMultiplication_error_negtiveRowOrCol
    bge zero, a4, MatrixMultiplication_error_negtiveRowOrCol
    bge zero, a5, MatrixMultiplication_error_negtiveRowOrCol
    # check matrix1's col match matrix2's row
    bne a2, a4,  MatrixMultiplication_error_MatrixSizeNotMatch
    addi t0, a5, 0 # out loop variable
    addi t2, a0, 0
MatrixMultiplication_loop_outer:
    addi t1, a1, 0 # in loop variable
    addi a0, t2, 0 
    MatrixMultiplication_loop_inner:
        # store argument
        addi sp, sp, -44
        sw ra, 0(sp)
        sw a0, 4(sp)
        sw a1, 8(sp)
        sw a2, 12(sp)
        sw a3, 16(sp)
        sw a4, 20(sp)
        sw a5, 24(sp)
        sw a6, 28(sp)
        sw t0, 32(sp)
        sw t1, 36(sp)
        sw t2, 40(sp)

        # a0 don't change 、matrix1
        addi t3, a1, 0   
        addi a1, a3, 0   # matrix2
        # a2 don't change 、calculation_element
        addi a3, t3, 0   # array1_stride
        addi a4, zero, 1 # array2_stride
        jal DotProduct
        addi t3, a0, 0 # store return a0 as DotProduct


        # restore argument
        lw ra, 0(sp)
        lw a0, 4(sp)
        lw a1, 8(sp)
        lw a2, 12(sp)
        lw a3, 16(sp)
        lw a4, 20(sp)
        lw a5, 24(sp)
        lw a6, 28(sp)
        lw t0, 32(sp)
        lw t1, 36(sp)
        lw t2, 40(sp)
        addi sp, sp, 44

        addi t1, t1, -1 # loop_inner -1
        sw t3, 0(a6)
        addi a6, a6, 4
        addi a0, a0, 4
        bne t1, zero, MatrixMultiplication_loop_inner
    
    slli a4, a4, 2
    add a3, a3, a4
    srli a4, a4, 2
    addi t0, t0, -1
    bne t0, zero, MatrixMultiplication_loop_outer
MatrixMultiplication_done:
    jr ra
MatrixMultiplication_error_negtiveRowOrCol:
    li a0, 36
    jr ra
MatrixMultiplication_error_MatrixSizeNotMatch:
    li a0, 4
    jr ra
#-----------------------------------------------------#


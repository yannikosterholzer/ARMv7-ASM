.global Matrix4x4_mul
.global matr4_transp

.data
matrix_b_tr: .word 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,	0x00, 0x00, 0x00, 0x00

.text        
Matrix4x4_mul:       @ r0 = ptr auf Matrix_c, r1 = ptr auf Matrix_a, r2 = ptr auf matrix_B
        push {lr}
	push {r4-r6}	
        vpush {d8-d15}   
	vld1.32 {q8}, [r1]!
        vld1.32 {q9}, [r1]!
        vld1.32 {q10}, [r1]!
        vld1.32 {q11}, [r1]!
        ldr r1, =matrix_b_tr
        push {r0}
        mov r0, r2
        bl matr4_transp
        mov r2, r0
        pop {r0}
        mov r3, r0 
        @ lade Matrix_b_tr
        vld1.32 {q12}, [r2]!
        vld1.32 {q13}, [r2]!
        vld1.32 {q14}, [r2]!
        vld1.32 {q15}, [r2]
        @ zeile 1 x spalte 1
        vmul.i32 q0, q8, q12 
        @ zeile 1 x spalte 2
        vmul.i32 q1, q8, q13    
        @ zeile 1 x spalte 3
        vmul.i32 q2, q8, q14
        @ zeile 1 x spalte 4
        vmul.i32 q3, q8, q15
        @ transponiere produktmatrix
        vtrn.32 q0, q1
        vtrn.32 q2, q3
        vmov d8, d1
        vmov d9, d4
        vswp d8, d9
        vmov d1, d8
        vmov d4, d9
        vmov d10, d3
        vmov d11, d6
        vswp d10, d11
        vmov d3, d10
        vmov d6, d11
        vadd.i32 q4, q0, q1
        vadd.i32 q5, q2, q3
        vadd.i32 q6, q4, q5
        vst1.32 {q6}, [r3]!
        @ zeile 2 x spalte 1
        vmul.i32 q0, q9, q12 
        @ zeile 2 x spalte 2
        vmul.i32 q1, q9, q13    
        @ zeile 2 x spalte 3
        vmul.i32 q2, q9, q14
        @ zeile 2 x spalte 4
        vmul.i32 q3, q9, q15
        @ transponiere produktmatrix
        vtrn.32 q0, q1
        vtrn.32 q2, q3
        vmov d8, d1
        vmov d9, d4
        vswp d8, d9
        vmov d1, d8
        vmov d4, d9
        vmov d10, d3
        vmov d11, d6
        vswp d10, d11
        vmov d3, d10
        vmov d6, d11
        vadd.i32 q4, q0, q1
        vadd.i32 q5, q2, q3
        vadd.i32 q6, q4, q5
        vst1.32 {q6}, [r3]!
        @ zeile 3 x spalte 1
        vmul.i32 q0, q10, q12 
        @ zeile 3 x spalte 2
        vmul.i32 q1, q10, q13    
        @ zeile 3 x spalte 3
        vmul.i32 q2, q10, q14
        @ zeile 3 x spalte 4
        vmul.i32 q3, q10, q15
        @ transponiere produktmatrix
        vtrn.32 q0, q1
        vtrn.32 q2, q3
        vmov d8, d1
        vmov d9, d4
        vswp d8, d9
        vmov d1, d8
        vmov d4, d9
        vmov d10, d3
        vmov d11, d6
        vswp d10, d11
        vmov d3, d10
        vmov d6, d11
        vadd.i32 q4, q0, q1
        vadd.i32 q5, q2, q3
        vadd.i32 q6, q4, q5
        vst1.32 {q6}, [r3]!
        @ zeile 4 x spalte 1
        vmul.i32 q0, q11, q12 
        @ zeile 4 x spalte 2
        vmul.i32 q1, q11, q13    
        @ zeile 4 x spalte 3
        vmul.i32 q2, q11, q14
        @ zeile 4 x spalte 4
        vmul.i32 q3, q11, q15
        @ transponiere produktmatrix
        vtrn.32 q0, q1
        vtrn.32 q2, q3
        vmov d8, d1
        vmov d9, d4
        vswp d8, d9
        vmov d1, d8
        vmov d4, d9
        vmov d10, d3
        vmov d11, d6
        vswp d10, d11
        vmov d3, d10
        vmov d6, d11
        vadd.i32 q4, q0, q1
        vadd.i32 q5, q2, q3
        vadd.i32 q6, q4, q5
        vst1.32 {q6}, [r3]
        vpop {d8-d15}    
        pop {r4-r6}    
	pop	{pc}

matr4_transp: @ Transponiere 4x4 Matrix r0 = Matrix_in r1 = Matrix_out
        push {lr}
	push {r0}	
	vld1.32 {q0}, [r0]!
        vld1.32 {q1}, [r0]!
        vld1.32 {q2}, [r0]!
        vld1.32 {q3}, [r0]!
        vtrn.32 q0, q1
        vtrn.32 q2, q3
        vmov d8, d1
        vmov d9, d4
        vswp d8, d9
        vmov d1, d8
        vmov d4, d9
        vmov d10, d3
        vmov d11, d6
        vswp d10, d11
        vmov d3, d10
        vmov d6, d11
        pop {r0}
        mov r0, r1
        vst1.32 {q0}, [r1]!
        vst1.32 {q1}, [r1]!
        vst1.32 {q2}, [r1]!
        vst1.32 {q3}, [r1]
	pop	{pc}

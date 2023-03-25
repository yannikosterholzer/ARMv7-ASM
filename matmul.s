// Mat-Mul: Matrizenmultiplikation
// (3x3) Matrix A * (3x3) Matrix B = Matrix C)

// Kurzbeschreibung:
// Dieser ARMv7-Assembly-Code implementiert eine Matrixmultiplikation von zwei 3x3-Matrizen. 
// Die Matrizen sind als Arrays definiert und die Ergebnismatrix wird ebenfalls als Array im Speicher abgelegt.

// Die Funktion c_rm füllt die Ergebnismatrix durch die Multiplikation von Matrizen in Row-Major-Order. 
// Die Funktion mat_ptr wird verwendet, um bei der Multiplikation den Zeiger auf die jeweils aktuelle Position einer der Matrizen zu erhalten.

//-------------------------------------------------------------
//////////////////////DATA SEGMENT ////////////////////////////
//-------------------------------------------------------------
.data
//------------------------------------Matrix A
//                                      3 | 1 | 7
//                                      ---------
//                                      2 | 5 | 9
//                                      ---------
//                                      8 | 0 | 4
	.align 4
mat_a:
	.word 3, 1, 7, 2, 5, 9, 8, 0, 4

//------------------------------------Matrix B
//                                      6 | 9 | 1
//                                      ---------
//                                      8 | 7 | 2
//                                      ---------
//                                      0 | 4 | 5    
mat_b:
	.word 6, 9, 1, 8, 7, 2, 0, 4, 5

//------------------------------------Result ~ Matrix c
//                                      ? | ? | ?
//                                      ---------
//                                      ? | ? | ?
//                                      ---------
//                                      ? | ? | ?
mat_r:       
	.space 36
_end:
	.align 4

//---------------------------------------------------------------
// //////////////////// CODE SEGMENT ////////////////////////////
//---------------------------------------------------------------
.text 
	 
.global _start
_start:

// -------------------------------------
// MAIN
// -------------------------------------

  ldr sp, =0
	push {r0-r12,lr}
  mov r0, #0
	mov r1, #0
	mov r2, #0
	mov r3, #0
	mov r4, #0
	mov r5, #0
	mov r6, #0
	mov r7, #0
	mov r8, #0
	mov r9, #0
	mov r10, #0
	mov r11, #0
//------------------> springe zu Funktion c_rm 
                       
  push {r0-r3}
	bl c_rm
  pop {r0-r3}

	pop {r0-r12,lr}
end:
	b end 
//----------------------------------------------- Subroutinen


//-----------------------------------------------
// C_RM: Matrix C nach row major order ausfüllen
//-----------------------------------------------
c_rm:
	push {r3,lr}
	mov r1, #0            // C-Reihenindex =  A-Reihenindex
	mov r2, #0            // C-Spaltenindex = B-Spaltenindex
	mov r3, #0            // A-Spaltenindex = B-Reihenindex
loop_rm:
	cmp r1, #3
	beq end_rm
rm_continue:	
  push {r4,r5, r6}
	mov r6, #0
	mov r3, #0
inner_loop:
	cmp r3, #3
	beq end_il
	
	push {r2}
	mov r2, r3
	ldr r0, =mat_a
	                      // get value <- mat_a
	bl mat_ptr
	ldr r4, [r0]          // return value Matrix A
	pop {r2}
	
	push {r1}
	mov r1, r3
	ldr r0, =mat_b
	                      // get value <- mat_b
	bl mat_ptr
	ldr r5, [r0]          // return value Matrix B
	pop {r1}
	
	                      // Multipliziere und Summiere
	mla r6, r4, r5, r6
	
	add r3, r3, #1
	b inner_loop
end_il:
	                      // save value -> Matrix C
	ldr r0, =mat_r
	bl mat_ptr
	str r6, [r0]
	pop {r4,r5, r6}
	cmp r2, #2
	beq r_inc
	add r2, r2, #1
	b repeat
r_inc:
	add r1, r1, #1
	mov r2, #0
repeat:	
	b loop_rm
end_rm:
	pop {r3,pc}

//-------------------------------------------------------------------
// Mat_ptr: Zeiger auf ein bestimmtes Element einer Matrix berechnen
//-------------------------------------------------------------------
// ---------------- int * ptr = mat_a[RI][SI]
mat_ptr:
	push {r3}
	                       //  Parameter
	                       //  a[RI][SI]
	                       //  r0=Basisadresse
	                       //	 r1=Reihenindex
                         //  r2=Spaltenindex
	
	                       //  r3=Spalten pro Reihe
	mov r3, #3
	                       //  x[RI][SI] ~ ( Basisadresse + (RI * S/R + SI) * Elementgröße )
	mla r3, r1, r3, r2
	add r0, r0, r3, lsl #2 //  r0 = ptr
	                       //  ret-val -> r0  
	pop {r3}
	bx lr
                         // daher für get val -> ldr rd, [r0]

/* ************************************ E O F ***************************************** */

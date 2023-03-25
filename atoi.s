// atoi
// Kurzbeschreibung:
// Wandle vom Benutzer eingegebene Ziffern in num. Wert um	
//-----------------------------------------------------------


//-------------------------------------------------------------
//////////////////////DATA SEGMENT ////////////////////////////
//-------------------------------------------------------------
.data
buffer: //Buffer für Userinput
	.space 100
result:
	.word 0x00



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

    push {r0-r3}
	ldr r0, =buffer
	mov r1, #100
	bl read_ju
    pop {r0-r3}
    push {r1-r3}
	ldr r0, =buffer  	// char * ptr = str
	bl atoi 			// returnwert in r0
    pop {r1-r3}
//----------------------------> speichere Resultat in globaler Variable
    push {r1-r3}
	ldr r1, =result
	str r0, [r1] 
    pop {r1-r3}
	pop {r0-r12,lr}
	
end: 
	b end


// CPUlator JTAG_UART Benutzereingabe auslesen	
//-------------------------------------
// Achtung, wenn die Benutzereingabe nicht mit /n beendet wird, 
// wird das zuletzt eingegebene Zeichen eingelesen bis der Buffer voll ist

	
read_ju:
//Zieladresse des Strings in R0 an Funktion übergeben 
//Größe Buffer in r1
	push {r4-r12, lr}
	mov r4, r0    		// Zieladresse String -> R4
	ldr r0, =0xff201000	//JTAG UART	
						// R1 beinhaltet Größe Buffer
	mov r2, #0 
	mov r3, #0 			// counter
rju_loop:
	cmp r3, r1
	bhs read_ju_quit
	ldrb r2, [r0]
	cmp r2, #0x0a 		// ist char = "/n"?
	beq read_ju_quit
	strb r2, [r4, r3]
	add r3, r3, #1
	b rju_loop
read_ju_quit:
	pop {r4-r12, lr}
	bx lr	
//--------------------------------------------------	
	


	
//---------------------------	
// Convert string -> num
// maximal (2^32)-1 = 4294967295 
//---------------------------
atoi: 

	// String in R0 übergeben
	push {r4-r12, lr}
	mov r1, #0
decl:	
	ldrb r2, [r0]
	cmp  r2, #0x30
	blo  quit_atoi
	cmp  r2, #0x39
	bhi  quit_atoi
	
	sub  r2, r2, #0x30
	mov  r3, #10
	mla  r1, r1, r3, r2
	add  r0, r0, #1
	b decl
quit_atoi:
	mov r0, r1
	pop {r4-r12, lr}
	bx lr

//************************************* E O F ******************************************/

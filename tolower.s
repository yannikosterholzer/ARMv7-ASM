
// To_Lower
//
// Kurzbeschreibung:
// Wandelt bei einem vom Benutzer eingegebenen String - 
// Groß in Kleinbuchstaben um und gibt den String wieder aus
// ----------------------------------------------------- 



//-------------------------------------------------------------
//////////////////////DATA SEGMENT ////////////////////////////
//-------------------------------------------------------------
.data
buffer: //Buffer für Userinput
	.space 100

 
//---------------------------------------------------------------
// //////////////////// CODE SEGMENT ////////////////////////////
//---------------------------------------------------------------
.text
.global _start
_start:

// -------------------------------------
// MAIN
// -------------------------------------

// -----------------------------------------------------
	ldr sp, =0
	push {r0-r12,lr}
//---------------Register initialisieren
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
//-----------------> Aufruf: Benutzereingabe lesen
	push {r0-r3}
	ldr r0, =buffer
	mov r1, #100
	bl read_ju
	pop {r0-r3}
//-----------------> Aufruf: Groß zu Klein -Umwandlung
	push {r0-r3}
	LDR   r0, =buffer
	bl tolower 
	pop {r0-r3}

//-----------------> Aufruf: Ausgabe
	push {r0-r3}
	ldr r0, =buffer
	mov r1, #100
	bl write_ju
	pop {r0-r3}
//-----------------------
	pop {r0-r12,lr}
	
end: 
	b end
//---SUBROUTINEN----------------------------------------------------------------




//----------------------------------------------------------------------
// CPUlator JTAG_UART Benutzereingabe auslesen	
//----------------------------------------------------------------------
// Achtung, wenn die Benutzereingabe nicht mit /n beendet wird, 
// wird das zuletzt eingegebene Zeichen eingelesen bis der Buffer voll ist

	
read_ju:
//Zieladresse des Strings in R0 an Funktion übergeben 
//Größe Buffer in r1
	push {r4-r12, lr}
	mov r4, r0    // Zieladresse String -> R4
	ldr r0, =0xff201000	//JTAG UART	
				  // R1 beinhaltet Größe Buffer
	mov r2, #0 
	mov r3, #0    // counter
rju_loop:
	cmp r3, r1
	bhs read_ju_quit
	ldrb r2, [r0]
	cmp r2, #0x0a // ist char = "/n"?
	beq read_ju_quit
	strb r2, [r4, r3]
	add r3, r3, #1
	b rju_loop
read_ju_quit:
	pop {r4-r12, lr}
	bx lr	




//----------------------------------	
// To_lower
// Groß -> Kleinbuchstaben
//----------------------------------	 
tolower:
	push {r4-r12,lr}
	mov r2, #0
tol_loop:
	ldrb r1, [r0, r2]
	cmp r1, #0
	beq quit_tolower
//--------------------- Ist Zeichen ein Großbuchstabe?
	cmp r1, #0x5a	//  Wenn nein -> copy
	bhi copy		//  Wenn ja   -> convert
	cmp r1, #0x41
	blo copy
convert:
	add   r1, #0x20 //  Setze 5. Bit für Kleinbuchstabe
copy:
	strb  r1, [r0, r2]
	add  r2, r2, #0x01
	b 	  tol_loop

quit_tolower: 
	pop {r4-r12,lr}
	bx lr
	

	
//-----------------------------------------------------------------------
// Gib umgewandelten text wieder aus
//------------------------------------------------------------------------
write_ju:
//Quelladresse des Nullterminierten Strings in R0 an Funktion übergeben 
	push {r4-r12, lr}
	mov r4, r0    // Quelladresse String -> R4
	ldr r1, =0xff201000	//JTAG UART	
	mov r2, #0 
	mov r3, #0    // counter
write_ju_loop:
	ldrb r2, [r0,r3]
	cmp r2, #0x00 // ist char = "/0"?
	beq write_ju_quit
	strb r2, [r1]
	add r3, r3, #1
	b write_ju_loop
write_ju_quit:
	pop {r4-r12, lr}
	bx lr	

/* ************************************ E O F ***************************************** */

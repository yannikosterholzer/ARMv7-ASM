// diy_strtok
//
// Kurzbeschreibung:
// ersetzt in einem übergebenen String das erste leerzeichen durch 0x00
// und gibt einen PTR auf das darauf folgende Zeichen in r0 zurück.
// Ausnahme: nächstes Zeichen ist 0, dann gibt die Fkt einen NULLPTR zurück! 
// In r1 wird die übergebene Anfangsadresse zurückgegeben
// ----------------------------------------------------- 



//-------------------------------------------------------------
//////////////////////DATA SEGMENT ////////////////////////////
//-------------------------------------------------------------
.data
text:	
	.ascii "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
	.ascii "Aliquam euismod faucibus justo, sit amet scelerisque lectus dapibus vel."
	.align 4
	.word 0x0
buffer:
	.space 800
	.align 4
	
NULL:
	.word 0xffffffff
//---------------------------------------------------------------
// //////////////////// CODE SEGMENT ////////////////////////////
//---------------------------------------------------------------
.text
.global _start
_start:

// -------------------------------------
// MAIN
// -------------------------------------

mov   r0, #0
	mov   r1, #0
	mov   r2, #0
	mov   r3, #0
	
	ldr r0, =text
	ldr r1, =buffer
	ldr r2, =NULL
while:
	str r0, [r1]
	add r1, r1, #4
	push {r1-r3}
	bl strtok
	mov r10, r1
	pop {r1-r3}
	cmp r0, r2
	bne while
end: 
	b end

// -------------------------------------
// STRTOK
// -------------------------------------

strtok:
	push {r0}
strtok_loop:
	ldrb r1, [r0]
	ldr r3, =NULL
	cmp r1, #0
	beq strtok_null
	cmp r1, #0x20
	beq strtok_xchange
	add r0, r0, #1
	b strtok_loop
strtok_null:
	mov r0, r3
	b end_strtok
strtok_xchange:
	mov r1, #0
	strb r1, [r0]
	add r0, r0, #1
end_strtok:
	pop {r1}
	bx lr



//************************************* E O F ******************************************/

// Selfie
// Selbst replizierender Code
// Um diesen Code im CPUlator zu testen, sollte man die Debugging Checks in den Settings deaktivieren

//---------------------------------------------------------------
// //////////////////// CODE SEGMENT ////////////////////////////
//---------------------------------------------------------------
.text
.global _start
_start:
// -------------------------------------
// MAIN
// -------------------------------------

	selfrepl:	
	mov r3, #0		       // counter initialisieren							
	sub r0, pc, #12	     // Pointer x auf Programmanfang setzen																	
	ldr r1, [r0]	       // Lade Befehl bei x -> y						
	str r1, [r0, #32]    // Pointer x auf Programmende setzen					    
	add r3, r3, #1	     // counter++							
	add r0, r0, #4	     // x++							
	cmp r3, #9		       // if(counter != 9)						    
	subne pc, pc, #28    //    -> jmp to selfrep		   					
.space 20000
_end:	
	b end

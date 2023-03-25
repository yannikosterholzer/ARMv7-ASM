// Selfie
// Selbstreplizierender Code
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
	mov r3, #7 		// Counter initialisieren
	sub r0, pc, #12 	// Pointer x auf Programmanfang setzen
loop:
	ldr r1, [r0]    	// Lade Befehl bei x -> y
	str r1, [r0, #28] 	// Kopiere Befehl von y nach z
	add r0, r0, #4 		// x++
	subs r3, r3, #1 	// counter--
	subne pc, pc, #24
	
	.space 20000
_end:	
	b end

	
//************************************* E O F ******************************************/

// ------------------------------SELFIE-IN-8086-----------------------------	
	
// Zum Vergleich habe ich in 8086 Assembler einen Code mit gleicher Funktionalität programmiert
// Achtung: Dieser Code funktioniert nur als .com File wie erwartet, 
//          Anderenfalls (in einer .exe) zeigen die Segmentregister auf unterschiedliche Adressen
//          Wodurch der Code nicht mehr wie gewünscht funktioniert
// org 100h
//    mov ax, [main-16]
//    mov bx, [void-16]
  
// main:
//    add ax, 16     
//    mov si, ax     
//    add bx, 16     
//    mov di, bx     
//    mov cx, 8     
//    nop            
//    rep movsw      
// void:

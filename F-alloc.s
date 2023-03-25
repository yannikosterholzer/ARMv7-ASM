
// F-ALLOC: Fixed size dynamic Memory-Allocation
// Chunk basierte dynamische Speicherverwaltung
//
// Beschreibung:
// Dieser Code implementiert eine dynamische Speicherverwaltung namens "F-ALLOC" mit Hilfe von zwei Arrays: "tabelle" und "mem". 
// Die "tabelle" dient dazu, den Belegungsstatus des verfügbaren Speicherplatzes zu verfolgen, während "mem" den verfügbaren Speicherplatz enthält. 
// "tab_init" initialisiert die Tabelle für "F-ALLOC".
// Der Code enthält auch zwei Funktionen: "req_mem" für das Anfordern von Speicherplatz und "free_mem" für das Freigeben von Speicherplatz. 
//



//-------------------------------------------------------------
//////////////////////DATA SEGMENT ////////////////////////////
//-------------------------------------------------------------
.data
	.align 4
tabelle:
//  ________________________________________________________
// | Liste zur Speicherverwaltung  
//  ________________________________________________________
// |  Belegungsstatus | Pointer | Belegungsstatus | Pointer ....
//  ________________________________________________________

// |      .word       |  .word	|		.word	  |	 .word  ....
//  _________________________________________________________

// ------------> 100 Einträge
//  Dabei gilt:
//         NULL = 0xffffffff = Belegt  
//                      0x00 = Verfügbar

	.fill 800, 0x00                    //   ---> Größe Tabelle = 
	.space 800                         //    Anzahl Tab-Einträge * 2 * 4 Bytes
//------------------------------------

// -------------------------------------   VERFÜGBARER SPEICHERBEREICH
//Pro Tabelleneintrag 10 * 4 Bytes

mem:
	.fill 4000, 0x00                   // ----> Größe verfügbarer Speicher =
	.space 4000                        // Anzahl Tab-Einträge * 10 * 4 Bytes


//------------------------------------
// Für Testfunktionen: Buffer
//------------------------------------
buffer:
.space 400
//--------------------------------------------------------------




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
//------------------------- Initialisiere Register
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
//------------------------ Aufruf: Tabelle initialisieren
	push {r0-r3}
	bl tab_init
	pop {r0-r3}
//------------------------ Aufruf: Testfunktion 1	
	push {r0-r3}			// Test zur Überprüfung der "malloc"-Funktion
	bl test1
	pop {r0-r3}
//------------------------ Aufruf: Testfunktion 2		
	push {r0-r3}			// Test zur Überprüfung der "free"-Funktion
	mov r1, #1
	lsl r1, #2
	bl test2
	pop {r0-r3}
	push {r0-r3}
	mov r1, #10
	lsl r1, #2
	bl test2
	pop {r0-r3}
	push {r0-r3}
	mov r1, #5
	lsl r1, #2
	bl test2
	pop {r0-r3}
//-------------------------- Ende der Main Funktion  
	pop {r0-r12,lr}
end:	
	b end
  
  
  
  
  
  
//-------------------------------------
//    SUBROUTINEN
//-------------------------------------


//-------------------------------------
// 	Initialisiere Tabelle für "F-alloc"
//-------------------------------------	
tab_init:
	push {r4-r12,lr} 
	ldr r0, =mem
	ldr r1, =tabelle
	mov r2, #0
	add r2, r1, r2
	ldr r3, =4000    // -------------------------> Gesamte allozierbare Speichergröße
	add r3, r0, r3
ti_loop:	
	cmp r0, r3
	bhs quit_tabinit
	str r0, [r2, #4]
	add r2, r2, #8
	add r0, r0, #40
	b ti_loop
	
quit_tabinit:
	pop {r4-r12,lr}
	bx lr
  
  
  
  

//-------------------------------------
// 	Request Memory-Chunk
//-------------------------------------	
req_mem:
	push {r4-r12,lr}
	ldr r0, =tabelle
    mov r1, #0
	ldr r2, =0xffffffff
	ldr r3,=800                // ---------------> Tabellengröße
	add r3, r0, r3
req_loop:
	cmp r0, r3
	bhs no_mem
	ldr r1, [r0]
	cmp r1, r2
	bne ret_mem
	add r0, r0, #8
	b req_loop
ret_mem:
	str r2, [r0]               // R2 = 0xffffffff
	add r0, r0, #4
	ldr r0, [r0]
	b quit_req
no_mem:
	ldr r0, =0xffffffff
quit_req:                          // returnwert in r0
		                   // kein freier Speicher -> r0 = 0xffffffff
	pop {r4-r12,lr}
	bx lr





//-------------------------------------
// 	free Memory ~ free (x)
//-------------------------------------	
//----------------------> Bekommt in R0 Ptr x auf einen Speicherblock übergeben
free_mem:
    push {r4-r12, lr}
//------------------------------------ Initialisiere Register
    mov r1, r0                      // R1 = ptr x auf freizugebenden Speicherbereich
    ldr r2, =tabelle	  
    add r1, r1, #40		    // R1 = ptr x + 40 -> zeigt auf Ende einer "Struct" 
	                            // 10 * 4 Bytes sollen überschrieben werden
    ldr r3, =0xaaaaaaaa             // Wert mit denen der Bereich in Mem überschrieben wird

    push {r0}			     
fm_overwrite:
    cmp r0, r1			    // Kompletter Bereich überschrieben?
    bhs sp_over_end		    // wenn ja -> sp_over_end	 
    str r3, [r0]		    // *ptr = 0xaaaaaaaa
    add r0, r0, #4		    //
    b fm_overwrite		    //
//-----------------------  Initialsiere Search_ptr
				    // Suche Ptr auf freizugebenden Speicherbereich 
				    // in der Speicherverwaltungstabelle "Tabelle"
sp_over_end:			
	ldr r3, =800                //-------> Tabellengröße
    add r3, r2, r3		    // R3 = R2 (=tabelle) + 800 -> Ptr auf (Tabellen-Ende + 4 Bytes)
	pop {r0}			
search_ptr:
	cmp r2, r3		    // Ist Tabellen-Ende erreicht?
    bhs quit_free		    // Wenn ja -> Abbruch
    ldr r1, [r2, #4]	            // Lade Ptr y aus Tabelle
    cmp r1, r0			    // Ist ptr x == ptr y ???
    beq change_fm	     	    // Wenn ja -> change_fm: Ändere den Belegungs-Eintrag
    add r2, r2, #8		    // Wenn nein -> gehe die Tabelle weiter durch
    b search_ptr		    //              bis Abbruchbedingung erreicht

//-----------------------  Ändere Belgungs-Status in der Tabelle
change_fm:
    mov r1, #0			    // Belegungsstatus = 0 bedeutet: nicht reserviert	
    str r1, [r2]		
quit_free:    
    pop {r4-r12, lr}
    bx lr
    
    
    
    
    
    
    
//-------------------------------------------------------------------------- 
//   Test 
//--------------------------------------------------------------------------
// Kurzbeschreibung:

// Die Funktion "test1" testet die korrekte Funktionsweise der Speicherverwaltungsfunktion "req_mem". 
// Das Testprogramm fordert so oft wie möglich Speicherplatz an und speichert einen Zeiger auf den erhaltenen Speicher in einem Buffer. 
// Wenn kein Speicherplatz (mehr) verfügbar ist, dann erhält Test 1 von F-alloc einen Null-pointer und wird beendet.

// Die Funktion "test2" testet die korrekte Funktionsweise der Speicherverwaltungsfunktion "free_mem". 
// Diese Funktion gibt zuvor angeforderten Speicherplatz frei. 
//--------------------------------------------------------------------------


//--------------------  **TEST 1** : Prüfe ob Speicher alloziert wurde 
//                                   und Tabelleneintrag geändert wurde
//
//---------------------->  Initialisiere Register für Testfunktion 1
test1:
	push {r4-r12,lr}
	mov r0, #0
	ldr r1, =buffer
	mov r2, #0
        ldr r3, =0xffffffff          // r3 = NULL 

test1_loop:	
	push {r1-r3}
	bl req_mem
	pop {r1-r3}
	cmp r0, r3		     // Gibt req_mem Null zurück?
	beq end_test1		     // Wenn ja -> beende Test 1
	str r0, [r1, r2]
	add r2, r2, #4
	b test1_loop
end_test1:	
	pop {r4-r12, lr}
	bx lr


//-------------------- **TEST 2** : Prüfe ob free(ptr) funktioniert
//                             und Tabelleneintrag geändert wurde
test2:			             // r1 muss als Offset übergeben werden 
    push {r4-r12,lr}
    ldr r0, =buffer
    //mov r1, #20 // 6.er Eintrag
    ldr r0, [r0,r1]
    push {r2-r3}
    bl free_mem
    pop {r2-r3}
    pop {r4-r12,lr}
    bx lr
    
    
//* ************************************ E O F ***************************************** */

//binsuchbaum
//Kurzbeschreibung:
// Der Zweck des Programms ist es, eine gegebene Zeichenkette in Teilstrings zu zerlegen, 
// diese in alphabetischer Reihenfolge einem binären Suchbaum zu speichern, dabei auch die Häufigkeit der Wörter im Text auszuwerten
// und dann den Baum anschließend zu löschen

// Das Programm wurde auch für diverse fehlerhafte Textvorlagen getestet, darunter:
//	- Strings die nur aus nicht-alphabetischen Zeichen bestehen
//	- Strings die mit nicht-alphabetischen Zeichen beginnen
//	- Strings, die sowohl aus nicht-alphabetischen Zeichen, als auch aus Buchstaben bestehen



.data
.align 4
tabelle:

//  ________________________________________________________
// | TABELLE ZUR SPEICHERVERWALTUNG  
//  ________________________________________________________
// |  Belegungsstatus [eine Wortbreite] | Pointer [eine Wortbreite]| ... 
//  --------------------------------------------------------
// ------------> 100 Einträge
//  Dabei gilt:
//         NULL = 0xffffffff = Belegt  
//                      0x00 = Verfügbar

	.fill 800, 0x00                    //   ---> Größe Tabelle = 
	.space 800                         //    Anzahl Tab-Einträge * 2 * 4 Bytes

//  ________________________________________________________
// |   VERFÜGBARER SPEICHERBEREICH
//  ________________________________________________________
  
//Pro Element 112 Bytes
// Ein Element besteht aus
			// 100 Bytes für Zeichen
			// 4 Bytes für die Häufigkeit
			// 4 Bytes für den Root * ptrlinks
			// 4 Bytes für den Root * ptrrechts
mem:
	.fill 11200, 0x00                   // ----> Größe verfügbarer Speicher =
	.space 11200                        // Anzahl Tab-Einträge * 10 * 4 Bytes
//----------------------------------------------------------
	.align 4

anker: // Anker für Baumstruktur
	.word 0x0
NULL:  // Definiere NULL
	.word 0xffffffff
	
text:	// Textvorlage für Programm
	.ascii "           Lorem ipsum dolor sit amet, consectetur adipiscing elit." 
	.ascii "Sed consequat ipsum ipsum sed." 
	.ascii "Ut aliquam ipsum dolor, sed consectetur consectetur elit." 
	.ascii "Dolor sit amet, sed elit consectetur adipiscing." 
	.asciz "Amet ipsum dolor, consectetur adipiscing elit."
	.align 4




.text
.global _start
_start:
	mov sp, #0 //initialisiere Stackpointer
	
// tabelle für falloc initialisieren
	push {r0-r3}
	bl tab_init
	pop {r0-r3}

//-------------------------------------
//    STRINGFUNKTIONEN
//-------------------------------------

main:	
	bl main_init
	ldr r0, =anker
	ldr r1, =NULL
	ldr r1, [r1]
	str r1, [r0] 	//anker = NULL

	ldr r0, =text
	bl prepstr //returnwert ist Anfangsadresse des Strings
	bl selectwords //Über selectwords werden die Wörter in alphabetischer Reihenfolge nach Häufigkeit Sortiert
	
	bl main_init
	ldr r0, =anker
	ldr r0, [r0]
	bl printroot // Ausgabe der Häufigkeit (nicht implementiert) und löschen der Baumstruktur
	
end: 
	b end      
	
main_init:
	mov r0, #0
	mov r1, #0
	mov r2, #0
	mov r3, #0
	mov r4, r0
	mov r5, r0
	mov r6, r0
	mov r7, r0
	mov r8, r0
	mov r9, r0
	mov r10, r0
	mov r11, r0
	mov r12, r0
	bx lr
  
  
//-------------------------------------
// 	Binärer Suchbaum
//-------------------------------------	
selectwords:  //Wählt Wörter aus einem String aus und fügt sie in einen Baum ein.
	push {lr}
	ldrb r1, [r0]
	cmp r1, #0
	beq selwords_end
	
	// mit r0 adresse von string übergeben!
selectwords_loop:
	bl strtok
	push {r0} // da r0 für insertroot(anker, stringptr) benötigt wird
	// r1 beinhaltet stringptr wg strtok
	ldr r0, =anker
	ldr r0, [r0]
	bl insertroot
	ldr r2, =anker
	str r0, [r2]
	pop {r0}
	ldr r2, =NULL
	ldr r2, [r2]
	cmp r0, r2
	beq selwords_end
	b selectwords_loop

selwords_end:
	pop {pc}
	
insertroot:  //Fügt gegebenenfalls ein Wort in den Baum ein.
			// Dazu vergleicht es das Wort mit den bereits vorhandenen Wörtern im Baum, um es 
			// - sofern noch nícht vorhanden an der entsprechenden Stelle einfügen zu können.

//r1:ptr auf string
//r0:ptr auf root
	push {lr}
	ldr r2, =NULL
	ldr r2, [r2]
	cmp r0, r2
	bne ir_not_null
	bl createroot
	b insroot_end
ir_not_null:
	push {r0,r1}
	bl strcmp
	cmp r0, #2
	beq ir_s1_groesser
	cmp r0, #1
	beq ir_s1_kleiner
ir_s1_s2_ident:
	pop {r0,r1}
	mov r2, #100
	ldr r3, [r0, r2]
	add r3, r3, #1
	str r3, [r0,r2]
	b insroot_end
ir_s1_groesser:
	//rootptr->links = (Root *) insertroot(rootptr->ptrlinks, wort)
	pop {r0,r1}
	push {r0}
	ldr r0, [r0, #104]
	bl insertroot
	mov r3, r0
	pop {r0}
	str r3, [r0, #104]
	b insroot_end
	
ir_s1_kleiner:
	//rootptr->rechts = (Root *) insertroot(rootptr->ptrrechts, wort)
	pop {r0,r1}
	push {r0}
	ldr r0, [r0, #108]
	bl insertroot
	mov r3, r0
	pop {r0}
	str r3, [r0, #108]
	b insroot_end
insroot_end:
	pop {pc}



	
createroot:	//erstellt einen neuen Baumknoten und initialisiert seine Werte
	push {lr}
    ldr r3, =NULL 
	ldr r3, [r3]
	push {r1-r3}
	bl req_mem
	pop {r1-r3}
	
	cmp r0, r3		     // Gibt req_mem Null zurück?
	beq createroot_req_fail
createroot_req_suc:
	push {r0-r3}
	bl strcpy //r0 buffer & r1 string
	pop {r0-r3}
	mov r1, #100
	mov r2, #1
	str r2, [r0,r1]
	ldr r3, =NULL
	ldr r2, [r3]
	mov r1, #104
	str r2, [r0,r1]  //rootptr->ptrlinks = NULL
	add r1, r1, #4
	str r2, [r0, r1] //rootptr->ptrrechts = NULL
	b createroot_end
	
createroot_req_fail:
	mov r0, r3 // returnvalue = NULL

createroot_end:
	pop {pc}




printroot: // Durchläuft den Baum rekursiv und gibt den reservierten Speicher wieder frei
	push {lr}
	bl printroot_check_anker
	bl pr_links
	// Hier könnte man eine Ausgabe implementieren
	bl pr_rechts
	
	push {r0-r3}
    bl free_mem
   	pop {r0-r3}
	
pr_end:
	pop {lr}
	bx lr
	
printroot_check_anker:
	ldr r1, =anker
	ldr r1, [r1]
	ldr r3, =NULL
	ldr r3, [r3]
	cmp r1, r3
	beq pr_ankernull
	bx lr
pr_ankernull:
	mov r0, #2
	ldr lr, =pr_end
	bx lr
	
pr_links:
	ldr r1, [r0, #104]
	cmp r1, r3
	bne pr_links_deeper
	bx lr
	
pr_links_deeper:
	push {r0,lr}
	add r0, r0, #104
	ldr r0, [r0]
	bl printroot
	
	pop {r0, lr}
	ldr r3, =NULL
	ldr r3, [r3]
	str r3, [r0, #104]
	b pr_links
	
pr_rechts:
	ldr r1, [r0, #108]
	cmp r1, r3
	bne pr_rechts_deeper
	bx lr
pr_rechts_deeper:
	push {r0,lr}
	add r0, r0, #108
	ldr r0, [r0]
	bl printroot
	pop {r0, lr}
	ldr r3, =NULL
	ldr r3, [r3]
	str r3, [r0, #104]
	bx lr
  
//-------------------------------------
//    STRINGFUNKTIONEN
//-------------------------------------

prepstr:		// den übergebenen String auf die Verarbeitung vorbereiten 
	push {lr}
	bl str_getfirstletter
	bl str_letter_only
	bl tolower
	pop {pc}
 	
str_getfirstletter: // Falls ein pointer auf den Stringanfang zeigt
					// und der Anfang des Strings nicht aus Buchstaben besteht
					// suche den ersten Buchstaben
	push {r4}
	// r0 beinhaltet string
	mov   r3, #0x20
str_gfl_loop:
	ldrb r4, [r0]
	cmp r4, #0
	beq str_gfl_error
	tst r4, #0x40
	beq str_gfl_loop_inc
	b str_gfl_end
str_gfl_loop_inc:
	add r0, r0, #1
	b str_gfl_loop
str_gfl_error:
	ldr r0, =NULL
	ldr r0, [r0]
str_gfl_end:	// return-value ist die Adresse des ersten gefundenen Buchstabens
	pop {r4}
	bx lr
	
	
str_letter_only: //alle Zeichen, die nicht Buchstaben sind werden mit Leerzeichen ersetzt
	push {r4}
	// r0 beinhaltet string
	mov   r2, #0
	mov   r3, #0x20
str_lo_loop:
	ldrb r4, [r0, r2]
	cmp r4, #0
	beq str_lo_end
	tst r4, #0x40
	bne str_lo_loop_inc
	strb r3, [r0, r2]
str_lo_loop_inc:
	add r2, r2, #1
	b str_lo_loop
str_lo_end:	
	pop {r4}
	bx lr
	
tolower: // alle Buchstaben werden in Kleinbuchstaben umgewandelt
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
	
	

strcpy: // Kopiere 99 Zeichen an Adresse in r0
		// Anschließend wird dieser String im Ziel nullterminiert
	push {r4}
	// r0 beinhaltet zieladresse
	// r1 beinhaltet quelladresse
	mov   r2, #0
	mov   r3, #99
	mov   r4, #0
	push {r4}
strcpy_loop:
	ldrb r4, [r1, r2]
	strb r4, [r0, r2]
	cmp r4, #0
	beq strcpy_end
	cmp r2, r3
	beq strcpy_end
	add r2, #1
	b strcpy_loop
strcpy_end:	
	pop {r4}
	strb r4, [r0, r2]
	pop {r4}
	bx lr
	


strtok: //Zerlege einen String in Teilstrings
		//Bei Leerzeichen wird getrennt
		
	push {r0}
	ldrb r1, [r0]
	cmp r1, #0
	beq strtok_null
strtok_loop:
	ldrb r1, [r0]
	ldr r3, =NULL
	cmp r1, #0   //kein Leerzeichen vor nächster 0 gefunden?
				// ->strtok_null
	beq strtok_null
	cmp r1, #0x20
	beq strtok_xchange
	add r0, r0, #1
	b strtok_loop
strtok_null:   // return NULL in r0
	mov r1, r0
	ldr r3, =NULL
	ldr r0, [r3]
	b end_strtok
strtok_xchange: //wenn mehrere Leerzeichen in Reihe
				//werden diese alle "gelöscht"
	mov r1, #0
	strb r1, [r0]
	add r0, r0, #1
	ldrb r1, [r0]
	cmp r1, #0x20
	beq strtok_xchange
	cmp r1, #0
	beq strtok_null
end_strtok:

		// r1 gibt anfangsadresse des übergebenen Strings zurück
		// r0 gibt anfangsadresse des nächsten Teilstrings zurück
		// -> außer wenn kein nächster Teilstring vor 0 vorhanden ist
		//    dann gibt r0 NULL zurück
	pop {r1}
	bx lr


	
	
strcmp: // Vergleicht Zwei Strings
// r0 = 2 -> string1 erstes ungleiches zeichen größer als bei string 2
// r0 = 1 -> string1 erstes ungleiches zeichen kleiner als bei string 2
// r0 = 0 -> strings sind gleich
//-----------------------------------------------------------
	push {r4}
	mov r4, #0
strcmp_loop:
	ldrb r2, [r0, r4]
	ldrb r3, [r1, r4]
	cmp r2, r3
	bne str_noteq
	cmp r2, #0
	beq strcmp_true
	add r4, r4, #1
	b strcmp_loop
	
str_noteq:	
	bcc strcmp_s1_kleiner
	mov r0, #2
	b strcmp_end
strcmp_s1_kleiner:
	mov r0, #1
	b strcmp_end
strcmp_true:
	mov r0, #0
strcmp_end:
	pop {r4}
	bx lr  
  
  


 
//-------------------------------------
//    Falloc
//-------------------------------------
// Chunk basierte dynamische Speicherverwaltung

//-------------------------------------
// 	Initialisiere Tabelle für "F-alloc"
//-------------------------------------	
tab_init:
	push {r4-r12,lr} 
	ldr r0, =mem
	ldr r1, =tabelle
	mov r2, #0
	add r2, r1, r2
	ldr r3, =11200    // -------------------------> Gesamte allozierbare Speichergröße
	add r3, r0, r3
ti_loop:	
	cmp r0, r3
	bhs quit_tabinit
	str r0, [r2, #4]
	add r2, r2, #8
	add r0, r0, #112
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
        mov r1, r0                  // R1 = ptr x auf freizugebenden Speicherbereich
        ldr r2, =tabelle	  
        add r1, r1, #112		    // R1 = ptr x + 40 -> zeigt auf Ende einer "Struct" 
	                            // 10 * 4 Bytes sollen überschrieben werden
        ldr r3, =NULL        
		ldr r3, [r3]			// Wert mit denen der Bereich in Mem überschrieben wird

        push {r0}			     
fm_overwrite:
        cmp r0, r1	            // Kompletter Bereich überschrieben?
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
        ldr r1, [r2, #4]	    // Lade Ptr y aus Tabelle
        cmp r1, r0		    // Ist ptr x == ptr y ???
        beq change_fm	     	    // Wenn ja -> change_fm: Ändere den Belegungs-Eintrag
        add r2, r2, #8		    // Wenn nein -> gehe die Tabelle weiter durch
        b search_ptr		    //              bis Abbruchbedingung erreicht

//-----------------------  Ändere Belgungs-Status in der Tabelle
change_fm:
        mov r1, #0	            // Belegungsstatus = 0 bedeutet: nicht reserviert	
        str r1, [r2]		
quit_free:    
        pop {r4-r12, lr}
        bx lr

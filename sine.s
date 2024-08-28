.global sine

.data
pi:     .float  3.1415927        @ π
twopi:  .float  6.2831855        @ 2π

@ Tabelle der Koeffizienten für die Taylor-Reihe von sin(x) um den Punkt 0
taylorcoeff_table: 
.float -1.6666666666666667e-01   @ (1/3!)
.float  8.3333333333333333e-03   @ (1/5!)
.float -1.9841269841269841e-04   @ (1/7!)
.float  2.7557319223985893e-06   @ (1/9!)
.float -2.5052108385441717e-08   @ (1/11!)
.float  1.6059043836821613e-10   @ (1/13!)
.float -7.6471637318198164e-13   @ (1/15!)
.float  2.8114572543455206e-15   @ (1/17!)
 
/*

sin(x) = x - (x^3)/(3!) + (x^5)/(5!)  - (x^7)/(7!)  + (x^9)/(9!) - (x^11)/(11!)  + (x^13)/(13!) - (x^15)/(15!)  + (x^17)/(17!) 

*/

.text
sine:                           @ input wert in s0 (f32) ergebnis in s0 [rad]
    vpush {d8-d15}      
    @ Input auf den Bereich [-π,π] mappen
    @ xmod = x - (int(x/2π) * 2π)
    ldr r0, =twopi   
    vldr s2, [r0]    
    vdiv.f32 s1, s0, s2
    vcvt.s32.f32 s1, s1 
    vcvt.f32.s32 s1, s1
    vmul.f32 s1, s1, s2
    vsub.f32 s0, s0, s1
    ldr r0, =pi   
    vldr s2, [r0]  
    vcmp.f32 s2, s0
    VMRS APSR_nzcv, FPSCR
    bpl lesserpi
    ldr r0, =twopi
    vldr s2, [r0] 
    vsub.f32 s0, s0, s2         @ Falls xmod größer als π ist: xmod = xmod - 2π 
lesserpi:
    @ Lade die Koeffizienten
    ldr r0,=taylorcoeff_table
    vld1.32 {q6}, [r0]!
    vld1.32 {q7}, [r0]

    @ Berechnung der Potenzen von x
    vmul.f32 s1,  s0, s0        @ x^2
    vmul.f32 s12, s1 ,s0        @ x^3
    vmul.f32 s13, s1, s12       @ x^5
    vmul.f32 s14, s1, s13       @ x^7
    vmul.f32 s15, s1, s14       @ x^9
    vmul.f32 s16, s1, s15       @ x^11
    vmul.f32 s17, s1, s16       @ x^13  
    vmul.f32 s18, s1, s17       @ x^15
    vmul.f32 s19, s1, s18       @ x^17

    @ Multiplikation mit den Koeffizienten
    vmul.f32 q1, q3, q6 
    vmul.f32 q2, q4, q7 

    @ Summierung der Terme
    vadd.f32 q3, q1, q2
    vadd.f32 d1, d6, d7
    vadd.f32 s1, s2, s3
    vadd.f32 s0, s1, s0
    vpop {d8-d15}   
    mov pc,lr

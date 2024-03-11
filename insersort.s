.data
    .align 4
    .word 0x0000
array:
    .byte 0x5, 0x4, 0x3, 0x2, 0x1
length:
    .byte 0x5
    .align 4
.text
.global _start
_start:

    ldr r1, =array
    ldr r0, =length
    bl insertsort

end: 
    b end

// ----------------
insertsort:
      push {r4,r5}
      mov r3, #1
      ldr r1, =array
loop_o:
      cmp r3, r0
      beq end_loop_o
      ldrb r2, [r1 , r3] 
      sub r4, r3, #1  
loop_i:
      cmp r4, #0
      blt loop_i_end
      ldrb r5, [r1, r4] 
      cmp r5, r2
      ble loop_i_end
      add r4, #1
      strb r5, [r1,r4]
      sub r4, r4, #2
loop_i_end:
      add r4, #1
      strb r2, [r1, r4]
      add r3, #1
      b loop_o
end_loop_o:
      pop {r4, r5}
      bx lr

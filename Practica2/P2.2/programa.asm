# Prog de prueba para Pr�ctica 2. Ej 2

.data 0
num0: .word 1 # posic 0
num1: .word 2 # posic 4
num2: .word 4 # posic 8
num3: .word 8 # posic 12
num4: .word 16 # posic 16
num5: .word 32 # posic 20
num6: .word 0 # posic 24
num7: .word 0 # posic 28
num8: .word 0 # posic 32
num9: .word 0 # posic 36
num10: .word 0 # posic 40
num11: .word 0 # posic 44
.text 0
main:
  # carga num0 a num5 en los registros 9 a 14
  lw $t1, 0($zero) # lw $r9, 0($r0)
  lw $t2, 4($zero) # lw $r10, 4($r0)
  lw $t3, 8($zero) # lw $r11, 8($r0)
  lw $t4, 12($zero) # lw $r12, 12($r0)
  lw $t5, 16($zero) # lw $r13, 16($r0)
  lw $t6, 20($zero) # lw $r14, 20($r0)
  nop
  nop
  nop
  add $t3, $t1, $t2 # en r11 un 3 = 1 + 2
  beq $t3, $t1, saltoA # t3 /= t1 no salta
  nop
  nop
  add $t3, $t3, $t3 # en r11 un 6 = 3 + 3
  beq $t1, $t1, SaltoB #dependencia con la 2� anterior # en r10 un 15 = 7 + 8
  SaltoA: add $t5, $t1, $t2  # en r14 un 3 = 1 + 2
  nop
  nop
  SaltoB: add $t2, $t3, $t5 #dependencia con la 3� anterior  # en r10 un 22 = 6 + 16
  nop
  nop
  nop
  lw $t3, 0($zero) # en r9 un 1
  beq $t3, $t5, SaltoC # t3 /= t5 no salta
  nop
  nop
  nop
  lw $t3, 4($zero) # en r9 un 2
  beq $t3, $t3, SaltoD # t3 = t3 Salta
  SaltoC: lw $t3, 8($zero) # en r9 un 4
  nop
  nop
  SaltoD: add $t4, $t2, $t3 # dependencia con la 3� anterior # en r12 22 = 20 + 2
  nop
  nop
  nop

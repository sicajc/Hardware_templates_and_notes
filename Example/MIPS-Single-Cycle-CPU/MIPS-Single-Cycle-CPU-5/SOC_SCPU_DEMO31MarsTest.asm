			j	start
			add	$zero, $zero, $zero
			add	$zero, $zero, $zero
			add	$zero, $zero, $zero
			add	$zero, $zero, $zero
			add	$zero, $zero, $zero
			add	$zero, $zero, $zero
			add	$zero, $zero, $zero
start:		lui	$v1, 0xf000			#r3=0xF0000000
			lui	$a0, 0xe000			#r4=0xE0000000
			lui	$t0, 0x8000			#r8=0x80000000
			addi $s4, $zero, 0x003f	#r20=0x0000003F
			lui	$a2, 0xf800			#r6=0xf8000000
			nor	$at, $zero, $zero	#r1=0xFFFFFFFF
			slt	$v0, $zero, $at		#r2=0x00000001 unsigned slt
			addi	$t2, $at, -1	#r10=0xFFFFFFFE
			sw	$a2, 0x104($zero)			#�������˿�:F0000004���ͼ�������r6=0xf8000000
			lw	$a1, 0x100($zero)			#��GPIO�˿�F0000000״̬:{counter0_out,counter1_out,counter2_out,led_out[12:0], SW} 
			add	$a1, $a1, $a1		#����
			add	$a1, $a1, $a1		#����2λ��SW��LED���룬ͬʱD1D0��00��ѡ�������ͨ��0
			sw	$a1, 0x100($zero)			#r5�����GPIO�˿�0xF0000000�����ü�����ͨ��counter_set=00�˿ڡ�LED=SW�{{GPIOf0[13:0],LED,counter_set}
			addi	$t1, $t1, 1		#r9=r9+1 
			sw	$t1, 0x200($zero)			#r9��r4=0xE0000000�߶���˿�
			lw	$t5, 20($zero)		#ȡ�洢��20��ԪԤ��������r13(5����),���������ʱ����
Loop:		lw	$a1, 0x100($zero)		#��GPIO�˿�F0000000״̬:{counter0_out,counter1_out,counter2_out,led_out[12:0], SW} 
			add	$a1, $a1, $a1		#����
			add	$a1, $a1, $a1		#����2λ��SW��LED���룬ͬʱD1D0��00��ѡ�������ͨ��0
			sw	$a1, 0x100($zero)			#r5�����GPIO�˿�0xF0000000��������ͨ��counter_set=00�˿ڲ��䡢LED=SW�� {GPIOf0[13:0],LED,counter_set}
			lw	$a1, 0x100($zero)			#�ٶ�GPIO�˿�0xF0000000״̬
			and	$t3,$a1,$t0			#ȡ���λ=out0����������λ��r11
			addi	$t5, $t5,1		#���������ʱ
			bne	$t5, $zero, Disp
			jal	Next
Disp:		lw	$a1, 0x100($zero)			#��GPIO�˿�F0000000״̬:{counter0_out,counter1_out,counter2_out,led_out[12:0], SW} 
			addi	$s2, $zero, 0x0008	#r18=0x00000008
			add	$s6, $s2, $s2		#r22=0x00000010
			add	$s2, $s2, $s6		#r18=0x00000018(00011000b)
			and	$t3, $a1, $s2		#ȡSW[4:3]
			beq	$t3, $zero, L00		#SW[4:3]=00,7����ʾ"��"ѭ����λ��L00��SW0=0
			beq	$t3, $s2, L11		#SW[4:3]=11,7����ʾ��ʾ�߶�ͼ�Σ�L11��SW0=0
			addi	$s2, $zero, 0x0008	#r18=8
			beq	$t3, $s2, L01		#SW[4:3]=01,�߶���ʾԤ�����֣�L01��SW0=1
			sw	$t1, 0x200($zero)			#SW[4:3]=10����ʾr9��SW0=1
			j	Loop
L00:		bne	$t2, $at, L3		#r10��=r1,ת��L3
			nor $t2, $zero, $zero	#r10=0xffffffff
			add $t2, $t2, $t2		#r10=0xfffffffe
L3:			sw	$t2, 0x200($zero)			#SW[4:3]=00,7����ʾ����λ����ʾ
			j	Loop
L11:		lw  $t1, 0x60($s1)		#SW[4:3]=11�����ڴ�ȡԤ���߶�ͼ��
			sw	$t1, 0x200($zero)			#SW[4:3]=11����ʾ�߶�ͼ��
			j	Loop
L01:		lw	$t1, 0x20($s1)		#SW[4:3]=01�����ڴ�ȡԤ������
			sw	$t1, 0x200($zero)			#SW[4:3]=01,�߶���ʾԤ������
			j	Loop
Next:		lw	$t5, 20($zero)		#ȡ�洢��20��ԪԤ��������r13,���������ʱ����
			add	$t2, $t2, $t2		#r10=fffffffc��7��ͼ�ε�����
			ori	$t2, $t2,1		#r10ĩλ��1����Ӧ���Ͻǲ���ʾ
			addi	$s1, $s1,4		#r17=r17+00000004��LEDͼ�ηô��ַ+4
			and	$s1, $s1, $s4		#r17=000000XX�����ε�ַ��λ��ֻȡ6λ
			add	$t1, $t1, $v0		#r9=r9+1
			bne	$t1, $at, L4		#r9=ffffffff,����r9=5
			addi	$t1, $t1, 5
L4:			lw	$a1, 0x100($zero)			#��GPIO�˿�F0000000״̬:{counter0_out,counter1_out,counter2_out,led_out[12:0], SW} 
			add	$t3,$a1,$a1			#����
			add	$t3,$t3,$t3			#����2λ��SW��LED���룬ͬʱD1D0��00��ѡ�������ͨ��0
			sw	$t3, 0x100($zero)			#r5�����GPIO�˿�0xF0000000��������ͨ��counter_set=00�˿ڲ��䡢LED=SW�� {GPIOf0[13:0],LED,counter_set}
			sw	$a2, 0x104($zero)			#�������˿�:F0000004���ͼ�������r6=0xf8000000
			jr	$ra
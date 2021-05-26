	.equ CODE_SEG, 8
	.equ DATA_SEG, gdt_data - gdt_start

	#;Se empieza en modo real, 16 bits
	.code16
	
		#;Desabilitar Interrupciones
		cli 	
		#;Carga de la GDT
		lgdt gdt_descriptor			

		#;Para cambiar a modo protegido, se debe poner en 1 el primer bit de CR0 (PE=1)
	    mov %cr0, %eax
	    orl $0x1, %eax
	    mov %eax, %cr0

	    #;Se salta a un codigo  de 32 bits, para estar finalmente en modo protegido
		#;CODE_SEG tiene un valor de 8, porque el primer descriptor de la GDT es nulo
	    ljmp $CODE_SEG, $protected_mode

		gdt_start:
		gdt_null:
			#;El primer elemento de GDT siempre es nulo
		    .long 0x0
		    .long 0x0
		gdt_code:
			#;Segmento de codigo por ende no se puede escribir, solo lectura (en los atributos se ve esto)					
		    .word 0xffff			#;Limite = FFFF	     		
		    .word 0x0 				#;Base = 0	
		    .byte 0x0 				#;Base = 0
		    .byte 0b10011010		#;Tipo SEGEMENTO de Codigo(E=1), No conformable (C=0), no leible (R=0)
									#;S = 1 Segmento Normal,  DPL =00 AH, P = 1
		    .byte 0b11001111		#;Limit = 1111, AVL= 0, 0, D/B = 1 segmento 32 bits (CORROBORAR)
		    .byte 0x0 				#;
									#;
		gdt_data:
			#; Segmento de datos, donde es imposible ejecutar (esto se define en los atributos)*/ 
		    .word 0xffff
		    .word 0x0
		    .byte 0x0
		    .byte 0b10010000		#;[1:4]tipo normal, no ejecutable, no ED, escribible	
									#;[6:5]presencia = 1 (presente en ram). DPL= 00 (sistema)
		    .byte 0b11001111
		    .byte 0x0
		gdt_end:
		gdt_descriptor:
			#;Este es el descriptor de la DGT. La primer palabra es el tamaño,
			#;la segunda parte es el limite
		    .word gdt_end - gdt_start
		    .long gdt_start
		vga_current_line:
    		.long 10
		
	.code32
		protected_mode:
		    #;Aqui se actualiza la caché de todos los registros de segmentos
		    #;Fijarse que solo falta CS, es porque se actualiza en el salto

		    mov $DATA_SEG, %ax
		    mov %ax, %ds
		    mov %ax, %es
		    mov %ax, %fs
		    mov %ax, %gs
		    mov %ax, %ss

		    #;Direccion de la pila. Es decir, el stack pointer va a appuntar a 0x7000
		    mov $0X7000, %ebp
		    mov %ebp, %esp
		
			#;Para imprimir mensaje con VGA

		    mov $message, %ecx
		    mov vga_current_line, %eax
		    mov $0, %edx
		    #;Number of horizontal lines. 
		    mov $25, %ebx
		    div %ebx
		    mov %edx, %eax
		    #;ancho de linea * bytes por caracter en pantalla
		    mov $160, %edx
		    mul %edx
		    #;0xb8000 == direccion de memoria de video que se muestra en la pantalla
		    lea 0xb8000(%eax), %edx
		    #;color UwU
		    mov $0x0A, %ah
		loop:
		    mov (%ecx), %al
		    cmp $0, %al
		    je end
		    mov %ax, (%edx)
		    add $1, %ecx
		    add $2, %edx
		    jmp loop
		end:
		    hlt
		message:
    		.asciz "Prueba MODO PROTEGIDO"



.data

display: .space 1024

camino: .half 26 27 28 29 33 36 38 39 40 41 42 45 49 50 51 52 53 54 56 58 61 65 69 72 74 75 76 77 78 81 83 84 85 86 87 88 89 90 94 97 99 106
		.half 110 113 115 122 126 129 130 131 132 133 134 135 137 138 139 140 141 142 145 149 153 156 158 161 163 164 165 166 167 168 170 173 175 177
		.half 179 181 185 186 187 188 189 190 193 197 200 201 205 209 210 211 212 213 214 215 216 220 221 225 230 232 236 241 242 243 246 248 249 250 
		.half 251 252 253 254 #hay 114, todas las posiciones en la grid donde hay camino
			
			#0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15
grid:   .byte 1 1 1 1 2 1 1 1 1 1 1 1 1 1 1 1 
		.byte 1 0 0 1 0 1 1 1 1 1 0 0 0 0 1 1 
		.byte 1 0 1 1 0 1 0 0 0 0 0 1 1 0 1 1 
		.byte 1 0 0 0 0 0 0 1 0 1 0 1 1 0 1 1 
		.byte 1 0 1 1 1 0 1 1 0 1 0 0 0 0 0 1 
		.byte 1 0 1 0 0 0 0 0 0 0 0 1 1 1 0 1 
		.byte 1 0 1 0 1 1 1 1 1 1 0 1 1 1 0 1 
		.byte 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
		.byte 1 0 1 1 1 0 1 1 1 0 1 1 0 1 0 1 
		.byte 1 0 1 0 0 0 0 0 1 0 1 1 0 1 0 1
		.byte 1 0 1 0 1 0 1 1 1 0 0 0 0 0 0 1
		.byte 1 0 1 1 1 0 1 1 0 0 1 1 1 0 1 1 
		.byte 1 0 0 0 0 0 0 0 0 1 1 1 0 0 1 1
		.byte 1 0 1 1 1 1 0 1 0 1 1 1 0 1 1 1 
		.byte 1 0 0 0 1 1 0 1 0 0 0 0 0 0 0 1 
		.byte 1 1 1 1 1 1 1 1 5 1 1 1 1 1 1 1
		

colores: .word 0xf6f4d2 0x7e846b 0x94bfbe 0xf4bfdb 0xa44a3f 0x9ee493 0xf7ef99 #fondo pared jugador inicio enemigo final moneda

input: .asciiz " "

you_win: .asciiz "YOU WIN!!"

you_lose: .asciiz "YOU LOSE"

pos_enemigo: .word 0 0 0 0 0

pos_mov: .byte 64 -64 4 -4
	

.macro cambio_color(%posicion)
	blt %posicion, 0, jugando
	lw $t3, display(%posicion)
	beq $t3, 0x7e846b, jugando
	beq $t3, 0x9ee493, ganar
	beq $t3, 0xa44a3f, perder
	bne $t3, 0xf7ef99, seguir
	addi $t4, $t4, 5
	 
	li $a0, 100
	li $a1, 800
	li $a2, 13
	li $a3, 126
	li $v0, 31
	syscall #suma moneda
	seguir:
	lw $t5, colores($s1)
	sw $t5, display($t0)
	lw $t5, colores($s2)
	sw $t5, display(%posicion)
	move $t0, %posicion
	b jugando 
.end_macro

.text

pintarLab:
li $t0, 0 #contador
li $t1, 0 #indice en grid

loopBase:
	
	beq $t0, 1024 , pintarEnemigos #cuando se pinte toda la base se sigue a los enemigos
	lb $t2, grid($t1) #trae lo que debe pintar el el display
	mul $t2, $t2, 4 
	lw $t3, colores($t2) #se trae el color que le corresponde
	sw $t3, display($t0) #pinta el display
	addi $t1, $t1, 1
	add $t0, $t0, 4
	b loopBase
	
pintarEnemigos:

li $t1, 16 #indice del color de los enemigos
li $t3, 0 #contador
li $v0, 42
li $a1, 3
syscall
addi $a0, $a0, 2 #numero al azar entre 2-4
move $t4, $a0 #t4 tiene el numero al azar de enemigos
li $s1, 0 #indice del array de la posicion de los enemigos
	loopPintarEnemigos:
		bge $t3, $t4, pintarMonedas #cuando se tengan todos los enemigos pintados seguir
		li $v0, 42
		li $a1, 114
		syscall
		mul $a0, $a0, 2 #consigue una posicion al azar de las que son camino
		lh $t0, camino($a0) 
		mul $t0, $t0, 4 #se trae la posicion en el display que le corresponde
		lw $t2, display($t0)
		bne $t2, 0xf6f4d2, loopPintarEnemigos #revisa si ya no se ha pintado
		lw $t2, colores($t1)
		sw $t0, pos_enemigo($s1)
		sw $t2, display($t0) #se pinta el enemigo
		addi $t3, $t3, 1
		addi $s1, $s1, 4
		b loopPintarEnemigos
				
pintarMonedas:
subi $s1, $s1, 4
move $t6, $s1
li $t1, 24 #indice de color de las monedar
li $t3, 0 #contador

#funciona igual que el de los enemigos
	loopPintarMonedas:
		bge $t3, 15, iniciar #cuando se pinten todas las monedas seguri
		li $v0, 42
		li $a1, 117
		syscall
		mul $a0, $a0, 2
		lh $t0, camino($a0)
		mul $t0, $t0, 4
		lw $t2, display($t0)
		bne $t2, 0xf6f4d2, loopPintarMonedas
		lw $t2, colores($t1)
		sw $t2, display($t0)
		addi $t3, $t3, 1
		b loopPintarMonedas

iniciar:		
li $t0, 16 #posicion inicial del jugador
li $t4, 0 #puntaje
li $s1, 0 #indice de color del camino
li $s2, 8 #indice de color del jugador

jugando:
la $a0, input 
li $v0, 8
li $a1, 2
syscall

lb $t1, input
li $t7, 0 #contador de enemigos
li $s3, 16
 bucle_mover_enemigos:
 	bgt $t7, $t6,mover_jugador 
 	lw $t8, pos_enemigo($t7)
 	random_mov:
 	li $a1, 5
 	li $v0, 42
 	syscall
 	lb $s4, pos_mov($a0)
 	add $s4, $s4, $t8
 	blt $s4, 0, random_mov
 	lw $s5, display($s4)
 	beq $s5, 0x7e846b, random_mov
 	beq $s5, 0x94bfbe, perder
 	bne $s5, 0x9ee493, seguir
 	subi $s4, $t8, 64
 	seguir:
 	lw $s6, colores($s1)
 	sw $s6, display($t8)
 	lw $s6, colores($s3)
 	sw $s6, display($s4)
 	sw $s4, pos_enemigo($t7)
 	addi $t7, $t7, 4
 	b bucle_mover_enemigos
 	
 	
mover_jugador:
beq $t1, 119, subir
beq $t1, 115, bajar
beq $t1, 97, izquierda
beq $t1, 100, derecha
b jugando

subir:
	
	subi $t2, $t0, 64
	cambio_color($t2)
	

bajar:
	
	addi $t2, $t0, 64
	cambio_color($t2)

	
derecha:
	
	addi $t2, $t0, 4
	cambio_color($t2)
	
izquierda:
	
	subi $t2, $t0, 4
	cambio_color($t2)


		
ganar:
#cantar
li $a0, 75
li $a1, 200
li $a2, 6
li $a3, 126
li $v0, 33
syscall

li $a0, 85
li $a1, 200
li $a2, 6
li $a3, 126
li $v0, 33
syscall
li $a0, 80
li $a1, 100
li $a2, 6
li $a3, 126
li $v0, 33
syscall

li $a0, 85
li $a1, 200
li $a2, 6
li $a3, 126
li $v0, 33
syscall
li $a0, 80
li $a1, 1000
li $a2, 6
li $a3, 126
li $v0, 33
syscall

li $a0, 90
li $a1, 1000
li $a2, 6
li $a3, 126
li $v0, 33
syscall
b exit
perder:
#tocaste un enemigo
li $a0, 70
li $a1, 500
li $a2, 57
li $a3, 126
li $v0, 33
syscall
li $a0, 67
li $a1, 500
li $a2, 57
li $a3, 126
li $v0, 33
syscall
li $a0, 60
li $a1, 750
li $a2, 57
li $a3, 126
li $v0, 33
syscall

exit:
li $v0, 10
syscall

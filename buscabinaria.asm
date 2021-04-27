.data
	# separa 40 bytes de memoria para um vetor de 10 elementos
	Vetor: .space 40 	
	# mensagens a serem exibidas na tela
	Entrada: .asciiz "Digite um valor para compor o vetor: " 
	Busca: .asciiz "\nDigite o valor a ser buscado: " 
	Encontrou: .asciiz "\n>>>>>>>> MSG: O numero buscado esta no vetor! <<<<<<<<" 	
	NaoEncontrou: .asciiz "\n>>>>>>>> MSG: O numero buscado nao esta no vetor! <<<<<<<<" 	
	
.text
	# empilha o registrador s0
	addi $sp, $sp, -4
	sw $s0, 4($sp)
	
	# guarda o Vetor em s0
	la $s0, Vetor
	
	
	li $t0, 0 	# inicializa t0 com 0, t0 sera o indice do vetor
	li $t1, 40 	# limite do loop de 10 x 4 bytes
	li $t2, 1	# limite inferior do vetor
	
	Loop: slt $t3, $t0, $t1 	# se t0 eh menor que t1, t3 recebe 1
	bne $t3, $t2, Exit		#desvia se t3 diferente de t2
	# linhas abaixo responsaveis pela impressao da mensagem na tela
	li $v0, 4			
	la $a0, Entrada
	syscall
	
	li $v0, 5			#le um numero do teclado
	syscall 
	move $t5, $v0			#coloca o numero lido em t5
	sw $t5, 0($s0)
	addi $t0, $t0, 4		#adiciona 4 a t0
	#adiciona 4 ao endereço do vetor para q o proximo indice possa ser inicializado
	addi $s0, $s0, 4		
	
	j Loop				#volta para a label Loop
	Exit:	
	# desempilha s0
	lw $s0, 0($sp)
	addi $sp, $sp, 4
	
	la $a0, Vetor		#Guarda o vetor na variavel de parametro
	li $a1, 10		#tamanho do vetor
	
	
	jal Sort		#procedimento de ordenacao
	
	# linhas abaixo responsaveis pela impressao da mensagem na tela
	li $v0, 4			
	la $a0, Busca
	syscall
	
	li $v0, 5			#le o valor a ser buscado
	syscall 
	move $a2, $v0			#coloca o numero lido em a2
	
	la $a1, Vetor
	
	li $a0, 10
	
	jal buscaBinaria	#procedimento de busca binaria
	li $v0, 10		#encerra o programa
	syscall
	
	Sort: addi $sp, $sp, -20	#guarda espaço na pilha para os registradores
	sw $ra, 16($sp)
	sw $s3, 12($sp)
	sw $s2, 8($sp)
	sw $s1, 4($sp)
	sw $s0, 0($sp)
	
	
	move $s2, $a0		#salva a0 em s2
	move $s3, $a1		#salva a1 em s3
	
	li $s0, 1		#i=1
	
	#se s0 eh menor que s3 (tamanho do vetor), t3 recebe 1
	LoopExterno: slt $t0, $s0, $s3		
	
	beqz $t0, ExitLoopExterno		#desvia se t0 eh igual a 0
	addi $s1, $s0, -1			#j = i-1
	
	LoopInterno: slti $t0, $s1, 0		#Se s1 < 0, t = 1
	bnez $t0, ExitLoopInterno		#desvia se t0 diferente de 0
	sll $t1, $s1, 2				#t1 = s1(j)*4
	add $t2, $s2, $t1			#t2 = s2(Vetor) + t1
	lw $t3, 0($t2)				#t3 = Vetor[j]
	lw $t4, 4($t2)				#t4 = Vetor[j + 1]
	slt $t0, $t4, $t3			#Se Vetor[j + 1] < Vetor[j], t0 = 1
	
	#Se t0 = 0, ou seja, 2 numeros em ordem crescente, volta ao inicio do looping
	beqz $t0, ExitLoopInterno		
	
	#inicializa os 2 parametros da funcao troca
	move $a0, $s2				#coloca s2 em a0
	move $a1, $s1				#coloca s1 em a1
	
	#entra na funcao troca
	jal troca
	
	#j--
	addi $s1, $s1, -1
	
	j LoopInterno 		#volta ao inicio do loop interno
	
	#i++
	ExitLoopInterno: addi $s0, $s0, 1	
	
	j LoopExterno		#volta ao inicio do loop externo
	
	#descarrega a pilha
	ExitLoopExterno: lw $s0, 0($sp)		
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $ra, 16($sp)
	addi $sp, $sp, 20
	jr $ra
	
	#procedimento de troca
	troca: sll $t1, $a1, 2		#t1 = k*4
	add $t1, $a0, $t1		#t1 = Vetor + (k*4)
	lw $t0, 0($t1)			#t0 = Vetor[k]
	lw $t2, 4($t1)			#t2 = Vetor[k + 1]
	sw $t2, 0($t1)			#Vetor[k] = t2
	sw $t0, 4($t1)			#Vetor[k + 1] = t0			
	jr $ra
	
	#Procedimento Busca Binária
	#a0 = Quantidade de posições do vetor
	#a1 = Endereço da primeira posição do vetor
	#a2 = Valor procurado

	buscaBinaria: 
	move $s0, $a1
	li $t9, 0
	li $t0, 0			#Limite inferior da busca
	move $t1, $a0			#Armazena o limite superior no registrador
	li $s3, 2 	
	LoopBB: 
	add $t2, $t0, $t1 		#Numero a ser dividido
	div $t6, $t2, $s3 		#Encontra metade do vetor
	move $t7, $t6			#t7 = t6
	sll $t6, $t6, 2			#t6 = t6*4
	add $t3, $s0, $t6		#t3 recebe o endereço da metade do vetor
	lw $t4, 0($t3)			#Carrega o conteúdo da metade do vetor
	addi $t9, $t9, 1		#Contador++
	beq $t4, $a2, FIM		#Caso seja o valor procurado vai para o fim

	slt $t5, $a2, $t4
	#Se a2 < t4, t5 recebe 1, se t5 eh 1, vai para o proc. Primeira metade
	beq $t5, 1, PrimeiraMetade	
	sle $t8, $t9, 4
	beqz $t8, FIM 			#Caso o numero nao esteja no vetor, vai para o fim
	addi $t0, $t7, 0 		#Atribui o limite inferior a metade do vetor
	j LoopBB
	
	PrimeiraMetade: sle $t8, $t9, 4
	beqz $t8, FIM 		#Caso o numero nao esteja no vetor, vai para o fim
	addi $t1, $t7, 0 		#Atribui o limite superior a metade do vetor
	j LoopBB
	
	FIM: 
	#Se t4 = a2, imprime a mensagem positiva
	beq $t4, $a2, SEncontrou  	
	
	#senao, imprime a mensagem negativa
	NEncontrou:			
	li $v0, 4			
	la $a0, NaoEncontrou
	syscall
	j FimDoPrograma
	
	SEncontrou:
	li $v0, 4	
	la $a0, Encontrou
	syscall
	
	FimDoPrograma:
	jr $ra

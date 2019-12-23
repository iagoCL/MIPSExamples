.data
	direccion:		.asciiz "E:/Escritorio/universidad/organizacion de computadores/practica optativa/Calvo Lista, Iago - OC optativa/grande.txt"
	MostrarOrig:		.asciiz "Mostrando la matriz original:\n"
	MostrarMinimos:		.asciiz "Mostrando la matriz de minimos:\n"
	MostrarPredecesores:	.asciiz "Mostrando la matriz de predecesores:\n"
	.align			2
	tamañoDeArchivo:	.space 4
	tamañoDeFila:		.space 4
	grafo:	
.text 
main:
	jal	CargarArrayEnMemoria		#subrutina que carga el array almacenado en direccion en memoria
	jal	EscribirMatrizConFW		#subrutina que calcula la matriz de minimos y depredecesores	
		
	la	$a0,MostrarOrig			#prepara una llamada al sistema para mostrar el mensaje por consola
	li	$v0,4
	syscall
	li	$a0,0			#desplazamiento de la matri respeto al origen
	jal	MostrarMatriz		#subrutina para mostrar la matriz por pantalla
	
	la	$a0,MostrarMinimos	#prepara una llamada al sistema para mostrar el mensaje por consola
	li	$v0,4
	syscall
	lw	$s2,tamañoDeArchivo	#almacena la separacion entre grafos
	move	$a0,$s2			#desplazamiento de la matriz respeto al origen
	jal	MostrarMatriz		#subrutina para mostrar la matriz por pantalla
	
	la	$a0,MostrarPredecesores	#prepara una llamada al sistema para mostrar el mensaje por consola
	li	$v0,4
	syscall
	add	$a0,$s2,$s2		#desplazamiento de la matri respeto al origen
	jal	MostrarMatriz		#subrutina para mostrar la matriz por pantalla
	
	li	$v0,10
	syscall

MostrarMatriz:
#a0 pasa el desplazamiento respeto al grafo
#for(int i=0;i<Nfilas;i++){
	#for(int j=0;j<Nfilas;j++)
		#std::cout<<Vertice[i][j]+' ';
	#std::cout<<std::endl;
	la	$s0,grafo		#almaceno el comienzo del grafo
	add	$s0,$s0,$a0		#s0 almacena la posicion actaul de nuestro grafo
	lw	$s1,tamañoDeFila	#s1 almacena los elementos por cada fila
	#for(int i=0;i<Nfilas;i++){
	li	$t0,0		#t0 almacena i y lo inicializo a 0
	MostrarFila:	
		#for(int j=0;i<Nfilas;j++){
		li	$t1,0		#t1 almacena j y lo inicializo a 0
		MostrarCol:
			lw 	$a0,0($s0)	#almaceno el caracter a imprimir en a0
			li	$v0,1		#llamada al sistema para imprimir un entero
			syscall	
			addi	$s0,$s0,4	#avanzo el caracter a imprimir					
			li	$v0,11		#llamada al sistema para imprimir un caracter
			li	$a0,9		#indico que haga un tab
			syscall			
			addi	$t1,$t1,1			#incremento j=t1 en 1
			blt	$t1,$s1,MostrarCol		#fin del segundo for	
		li	$v0,11		#llamada al sistema para imprimir un caracter
		li	$a0,10		#indico que haga un enter
		syscall	
		addi	$t0,$t0,1			#incremento i=t0 en 1
		blt	$t0,$s1,MostrarFila		#fin del primer for
	jr	$ra

EscribirMatrizConFW:
#calcula la matriz de caminos minimos usando el algoritmo de Floyd Marshal
#Me he basado en el siguiente codigo en c++
#for(int k = 0; k < Nfilas; k++)
	#for(int i = 0; i < Nfilas; i++)
		#for(int j = 0; j < Nfilas; j++){
			#int peso1 = Vertice[i][k] + Vertice[k][j];
				#if(Vertice[i][j] > peso1){
					#Vertice[i][j] = peso1; 
					#Predecesor[i][j]=k;}}

	move	$t4,$ra			#almacena la direccion de retorno
	lw	$a0,tamañoDeArchivo	#inidica que cree un nuevo array al final del primero
	jal	copiarGrafo		#llama a la subrutina para crear el array en la posicion indicada
	add	$a0,$a0,$a0
	jal	IniciarMatrizPredecesores
	la	$s0,grafo		#almacena el comienzo del grafo orginial
	lw	$s2,tamañoDeArchivo	#s2 es la separacion entre grafos
	add	$s0,$s2,$s0		#s0 almacena el comienzo del grafo con el que trabajamos
	lw	$s1,tamañoDeFila	#almacena en s1 el numero de filas


	move	$ra,$t4
	
	li	$t6,90			#almacena en s2 el maximo valor de un grafo
	#for(int k = 0; k < Nfilas; k++)
	li	$t0,0			#t0 almacena k y lo inicializo a 0
	FWRecorrerDiagonales:
		#for(int i = 0; i < Nfilas; i++){
		li	$t1,0				#t1 almacena i y lo inicializo a 0
		FWRecorrerFilas:
			#for(int j = 0; j < Nfilas; j++){
			li	$t2,0				#t2 almacena j y lo inicializo a 0	
			FWRecorrerColumnas:
				#peso1 = Vertice[i][k] + Vertice[k][j];
				#t4=Vertice[i][k]
				mul  	$t3,$s1,$t1		#t3 almacena Nfila*i, lo reutilizare para [i][j]
				add	$t4,$t3,$t0		#t4 almacena la posicion del elemento = Nfila*i+k
				mul	$t4,$t4,4		#t4 almacena el byte que es el elemento por 4
				add	$t4,$t4,$s0		#t4 almacena la direccion del elemento [i][k]
				lw	$t4,0($t4)		#t4=Vertice[i][k]
				bgt	$t4,$s2,FWCasoElse	#si almacena mas de s2 es que es no se conecta en dicho punto
				#t5=Vertice[k][j]
				mul  	$t5,$s1,$t0		#t5 almacena Nfila*k
				add	$t5,$t5,$t2		#t5 almacena la posicion del elemento = Nfila*k+j
				mul	$t5,$t5,4		#t5 almacena el byte que es el elemento por 4
				add	$t5,$t5,$s0		#t5 almacena la direccion del elemento [k][j]
				lw	$t5,0($t5)		#t5=Vertice[k][j]
				bgt	$t5,$s2,FWCasoElse	#si almacena mas de s2 es que es no se conecta en dicho punto
				#peso1 = Vertice[i][k] + Vertice[k][j]=t4+t5=t4
				add	$t4,$t4,$t5
				#t3=Vertice[i][j];// t3 ya almacena Nfila*i
				add	$t5,$t3,$t2	#t5 almacena la posicion del elemento = Nfila*i+j
				mul	$t5,$t5,4	#t5 almacena el byte que es el elemento por 4
				add	$t5,$t5,$s0	#t5 almacena la direccion del elemento [i][j]; la usare luego para escritura
				lw	$t3,0($t5)	#t3=Vertice[i][j]
				# if(Vertice[i][j] > peso1); saltar si t3<t4
				ble	$t3,$t4,FWCasoElse
				#Vertice[i][j] = peso1; 
				sw	$t4,0($t5)	#almacena t4=peso1 en el Vertice[i][j] cuya posicion almacena t5
				#Predecesor[i][j]=k;]
				add	$t5,$t5,$s2	#al sumarle a t5 la separacion entre grafos ahora t5 almacena la posicion de predesores[i][j]
				sw	$t0,0($t5)	#almacena t0=k en el predecesor[i][j] cuya posicion almacena t5
				FWCasoElse:
				addi	$t2,$t2,1			#incremento j=t2 en 1
				blt	$t2,$s1,FWRecorrerColumnas		#fin del tercer for
			
			addi	$t1,$t1,1			#incremento i=t1 en 1
			blt	$t1,$s1,FWRecorrerFilas		#fin del segundo for
		
		addi	$t0,$t0,1			#incremento k=t0 en 1
		blt	$t0,$s1,FWRecorrerDiagonales	#fin del primer for
	
	
	
	jr	$ra			#retorna al program principal	


				

												
																								
IniciarMatrizPredecesores:
#a0 pasa la el desplazamiento repeto al grafo en iniciarlo	
#for(int i=0;i<Nfilas;i++)
	#for(int j=0;j<Nfilas;j++){
		#Vertice[i][j]=j;
																																																		
	la	$s0,grafo		#almaceno el inicio del grafo
	add	$s0,$s0,$a0		#s0 almacena la posicion actal del grafo
	lw	$s1,tamañoDeFila	#s1 almacena el numero de elementos por fila
	#for(int i=0;i<Nfilas;i++)
	li	$t0,0		#t0 almacena i y lo inicializa a 0
	initMatFilas:
		#for(int j=0;j<Nfilas;j++){
		li	$t1,0		#t1 almacena j y lo inicializa a 0
		initMatCol:
			#Vertice[i][j]=j;
			sw	$t1,0($s0)		#grabo en la matriz de predecesores j
			addi	$s0,$s0,4			#paso al siguiente elemento de la matriz
			addi	$t1,$t1,1		#incremento t1=j en 1
			blt	$t1,$s1,initMatCol	#fin del segundo for	
	addi	$t0,$t0,1		#incremento t0=i
	blt	$t0,$s1,initMatFilas	#fin del primer for
	jr	$ra			#salgo de la subrutina
	
	
	

copiarGrafo:
#copia la matriz grafo, con una separacion pasada por a0
	la	$s0,grafo		#s0 almacena la direccion que copiamos
	add	$s1,$s0,$a0		#s1 almacena la direccion a la que copiamos
	lw	$s2,tamañoDeArchivo	#almacena el numero de bytes del grafo
	add	$s2,$s2,$s0		#s2 almacena el final del grafo	
	
	copiarUnElemento:
		lw	$t0,0($s0)			#copia en t0 un elemento del array
		sw	$t0,0($s1)			#pega t0 en el nuevo array
		addi	$s0,$s0,4			#avanza el elemento que copiamos
		addi	$s1,$s1,4			#avanza donde pegamos el elemento
		blt 	$s0,$s2,copiarUnElemento	#si no se ha llegado al final del array pasa al siguiente elemento	
			
	jr 	$ra			#sale de la subrutina 


CargarArrayEnMemoria:
	li 	$v0,13			#llamada de abrir archivo
	la	$a0,direccion		#inidica la direccion del archivo a leer
	li	$a1,0			#abre para lectura
	li	$a2,0			#modo ignorado
	syscall				#devuelve el descriptor del archivo por vo
	
	move	$a0,$v0			#pasa el decriptor
	
	li 	$v0,14			#llamada para leer archivo
	la	$a1,tamañoDeArchivo	#direccion para almacenarlo
	li	$a2,4			#bytes para leer
	syscall	
	
	#se podria configurar para que lo cargara en una unica llamada al sistema pero así es más claro
	li 	$v0,14			#llamada para leer archivo
	la	$a1,tamañoDeFila	#direccion para almacenarlo
	li	$a2,4			#bytes para leer
	syscall				#llama al sistema
	
					#a0 sigue pasando el decriptor
	li 	$v0,14			#llamada para leer archivo
	la	$a1,grafo		#direccion para almacenarlo
	lw	$a2,tamañoDeArchivo	#bytes para leer
	syscall				#llama al sistema
	
					#a0 sigue pasando el decriptor
	li	$v0,16			#carga el comando de cerrar el archivo
	syscall				#llama al sistema
	
	jr	$ra			#retorna al program principal	

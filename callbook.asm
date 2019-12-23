	.data
nombreagenda:	.asciiz	"agenda.txt"

pregunta:	.byte 10
		.ascii "Introduzca:"
		 .byte 10
		.ascii "1 - Para cargar una Agenda (se carga desde la raiz de mars y de no cargarse usara una en blanco)"
		.byte 10
		.ascii "2 - Para listar la Agenda"
		.byte 10
		.ascii "3 - Para ordenarla AUN NO FUNCIONA(se le preguntara el criterio y esta se guardara en disco en la raiz y luego se volvera a cargar a memoria)"
		.byte 10
		.ascii "4 - Para agregar una nueva entrada a la agenda"
		.byte 10
		.ascii "5 - Para buscar alguna entrada por algun criterio (se le permitira modificar o borrar la entrada seleccionada"
		.byte 10
		.ascii "6 - Para Mostrar el n�mero de entradas"
		.byte 10
		.ascii "7 - Para guardar la agenda en disco (la guarda en la raiz de mars): "
		.byte 10
		.asciiz "8 - Para salir del programa: "
modnom:		.byte 10
		.asciiz "Introduzca el nuevo nombre: "
modnum:		.byte 10
		.asciiz "Introduzca el nuevo numero: "		
moddir:		.byte 10
		.asciiz "Introduzca la nueva direccion: "		
		
noidentificado:	.byte 10
		.asciiz "No se ha identificado ningun campo cuya descripcion coincida "
siidentificado: .byte 10
		.asciiz "Se ha identificado el siguiente campo seleccione M para modificarlo y B para borarlo, no seleccione nada para volver al menu principal: "

CampoBuscar: 	.byte 10
		.asciiz "Presione 1 para buscar por el nombre(por defecto), 2 para el telefono: "
IntroDato:	.byte 10
		.asciiz "Introduzca el dato a buscar: "
MostrarNumEntr:	.byte 10
		.asciiz "El numero de entradas es: "
menmodificar: .byte 10
		.asciiz "Presione 1 para modificar el nombre, 2 para el telefono(por defecto): "
						
innom:		#no entiendo muy bien porque pero si no creo una linea en blanco con .byte 10 esta puede que no se cree, pero al ponerla se puede poner por duplicado
		.byte 10
		.asciiz "Introduzca el nombre y los apellidos: "
innum:		.byte 10
		.asciiz "Introduzca el numero de telefono: "
indir:		.byte 10
		.asciiz "Introduzca la direccion: "

borrar:		.byte 10
		.asciiz "Desea borrar esta entrada (introduzca S para comfirmar): "
modificar:	.byte 10
		.asciiz "Desea modificar esta entrada (introduzca S para comfirmar): "
nom:		.asciiz "Nombre: "
num:		.asciiz "Numero: "
dir:		.byte 10
		.asciiz "Direccion: "

inalm:		.byte 10
		.asciiz "Desea almacenar esta entrada (introduzca S para comfirmar): "

ordenar:	.byte 10
		.asciiz "Seleccione el campo por el que desea ordenar la agenda; 1 nombre, 2 numero: "

.align	2
ComienzoAgenda:
#La agenda tiene los siguientes campos:
#Nombre_y_apellidos:	20 bytes
#Telefonbo:		10 bytes se considera como una cadena de caracteres
#Direcci�n:		30 bytes
#Campo_Valido:		4  bytes; si todos son 0 NO es valido y no se empleara, en caso contrario lo seria; se usa para poder eliminar entradas de forma eficaz
#total:			64 bytes por entrada
#FinDeAgenda se almacena en $s1



	.text
main:
	la	$s0,ComienzoAgenda
#pregunta que opcion se desea hacer
BuclePreguntar:
	la	$a0,pregunta
	li	$v0,4
	syscall
#lee la opcion seleccionada y la almacena en t0
	li	$v0,5
	syscall
	move	$t0,$v0
#1 - Cargar una Agenda del disco
	li	$t1,1
	bne	$t1,$t0,OpcionNo1
	jal	LeerEnDisco	#s0 se actualiza a la direccion final de la agenda nueva
	j	BuclePreguntar
#2 - Listar la Agenda
OpcionNo1:
	li	$t1,2
	bne	$t1,$t0,OpcionNo2
	jal	ListarAgenda
	j	BuclePreguntar
#3 - Ordenarla AUN NO FUNCIONA
OpcionNo2:
	li	$t1,3
	bne	$t1,$t0,OpcionNo3
	jal	ContarEntradas	#Devuelve el n�mero de entradas ocupadas por la agenda por s1
	sw	$s1,0($s0)	#Antes de llamar la subrutina se necesita que se almacene el numero de entradas en memoria
	jal	OrdenarLaAgenda
	jal	LeerEnDisco	
	j	BuclePreguntar
#4 - Agregar una nueva entrada a la agenda
OpcionNo3:
	li	$t1,4
	bne	$t1,$t0,OpcionNo4
	jal	NuevaEntrada
	j	BuclePreguntar
#5 - Selccionar entrada Permite borar o modificar la seleccionada
OpcionNo4:
	li	$t1,5
	bne	$t1,$t0,OpcionNo5
	#Pregunta que campo Buscar
	la	$a0,CampoBuscar
	li	$v0,4
	syscall
	#Lee el campo a Buscar y almacena en t0 el numero que lo identifica
	li	$v0,5
	syscall
	move	$t0,$v0
	#Almacena ahora en t0 el desplazamiento del dato respecto al inicio de la agenda y en t1 su longitud
	li	$t2,3
	bne	$t0,$t2,DirNoEscogido
	li	$t0,32
	li	$t1,28
	j	FinEscogerCampo
DirNoEscogido:
	li	$t2,2
	bne	$t0,$t2,NumNoEscogido
	li	$t0,20
	li	$t1,10
	j	FinEscogerCampo
NumNoEscogido:
	move	$t0,$zero
	li	$t1,20
FinEscogerCampo:
	#Pregunta el dato a buscar 
	la	$a0,IntroDato
	li	$v0,4
	syscall
	#Lo almcena en la direccion de s0 que es el final de la agenda
	move	$a0,$s0
	li	$v0,8
	move	$a1,$t1
	syscall
	#pasa los parametros a la subrutina	
	move	$a0,$t0		#a0 pasa el desplazamiento del campo	
	move	$a1,$t1		#a1 pasa el numero de bytes del campo
	move	$a2,$s0		#a2 almacena la direccion del dato a buscar
	jal	BuscarEnLaAgenda
	j	BuclePreguntar
#6 - Mostrar n�mero de entradas
OpcionNo5:
	li	$t1,6
	bne	$t1,$t0,OpcionNo6
	la	$a0,MostrarNumEntr
	li	$v0,4
	syscall
	jal	ContarEntradas	#almacena en s1 el numero de entradas
	move	$a0,$s1
	li	$v0,1
	syscall
	j	BuclePreguntar
#7 - Guardar la agenda en disco
OpcionNo6:
	li	$t1,7
	bne	$t1,$t0,OpcionNo7
	jal	ContarEntradas	#Devuelve el n�mero de entradas ocupadas por la agenda por s1
	sw	$s1,0($s0)	#Antes de llamar la subrutina se necesita que se almacene el numero de entradas en memoria
	jal	GuardarEnDisco
	j	BuclePreguntar
#8 - Salir del programa
OpcionNo7:
li	$v0,10
syscall



#INTRODUCIR UNA NUEVA ENTRADA
NuevaEntrada:
	move	$s1,$ra
#muestra que introduzca el nombre
	la	$a0,innom
	li	$v0,4
	syscall
#lee nombre y lo almacena en memoria
	move	$a0,$s0
	addiu	$a1,$zero,20
	li	$v0,8
	syscall
#muestra que introduzca el numero
	la	$a0,innum
	li	$v0,4
	syscall
#lee numero y lo almacena en memoria
	addiu	$a0,$s0,20
	addiu	$a1,$zero,10
	li	$v0,8
	syscall
#muestra que introduzca la direccion
	la	$a0,indir
	li	$v0,4
	syscall
#lee la direccion y lo almacena en memoria
	addiu	$a0,$s0,30
	addiu	$a1,$zero,30
	li	$v0,8
	syscall
#muestra la entrada
	move	$a0,$s0
	jal 	MostrarEntrada
#pregunta si almacenar dicha entrada
	la	$a0,inalm
	li	$v0,4
	syscall
	li	$v0,12
	syscall
#si responde S valida el ultimo bit y cambia el final de la agenda; sino no hace nada
	li	$t0,'S'
	beq	$v0,$t0,lecturaS
	li	$t0,'s'
	beq	$v0,$t0,lecturaS
#poner el dato de campo nulo a 0
	sw	$zero,60($s0)
#salir de la subrutina en caso negativo
	jr	$s1	
lecturaS:
	li	$t1,0x00000031
	sw	$t1,60($s0)
	addiu	$s0,$s0,64
	jr	$s1

#MOSTRAR ENTRADA
MostrarEntrada:
#$a0 almacenaria la direccion de la entrada a mostrar
	move	$t0,$a0
	la	$a0,nom
	li	$v0,4
	syscall
	move	$a0,$t0
	li	$v0,4
	syscall
	la	$a0,num
	li	$v0,4
	syscall
	addiu	$a0,$t0,20
	li	$v0,4
	syscall
	la	$a0,dir
	li	$v0,4
	syscall
	addiu	$a0,$t0,30
	li	$v0,4
	syscall
	jr	$ra

#BORRAR ENTRADA
BorrarEntrada:
#$a0 contiene la direccion de la entrada a borrar
	move	$s1,$a0
	move	$s2,$ra
	jal	MostrarEntrada
	la	$a0,borrar
	li	$v0,4
	syscall
	li	$v0,12
	syscall
#si responde S invalida el ultimo bit y cambia el final de la agenda; sino no hace nada
	li	$t0,'S'
	beq	$v0,$t0,lecturaN
	li	$t0,'s'
	beq	$v0,$t0,lecturaN
#salir de la subrutina sin borrar
	jr	$s2
lecturaN:
	sw	$zero,60($s1)
	jr	$s2

#CONTAR NUMERO DE ENTRADAS
ContarEntradas:
#devuelve el numero por $s1
	la	$t0,ComienzoAgenda	#t0 contiene la posicion actual de la agenda se inicializa al comienzo de la agenda
	move	$s1,$zero
buclecontador:
	lw	$t2,60($t0)
	beq 	$t2,$zero,NoSumar
	addiu	$s1,$s1,1
NoSumar:
	addiu	$t0,$t0,64
	blt	$t0,$s0,buclecontador	#s0 contiene el final de la agenda
	jr	$ra
	
#GUARDAR LA AGENDA EN DISCO
GuardarEnDisco:
#se supone que la direccion de memoria donde se almacena el numero de entradas de la agenda es s0
	la	$s1,ComienzoAgenda
	move	$s2,$s0
	la	$s3,0($s0)
# Abrir el fichero
	li	$v0,13		
	la	$a0,nombreagenda	# Nombre
	li	$a1,1			# Acceso: escritura
	li	$a2,0			# Modo: se ignora
	syscall
	move	$t4,$v0		# Salvar el descriptor
#almacenar el n�mero de entradas
	li	$v0,15		# Escribir en fichero
	move	$a0,$t4		# Descriptor
	move	$a1,$s3		#Direccion del dato a escribir
	li	$a2,4		# Tama�o en bytes del dato escrito
	syscall
#Escribir entrada a entrada
buclealmacenar:
#Comprueba si es una entrada valida
	lw	$t5,60($s1)
	beq	$t5,$zero,noalmacenar
	li	$v0,15		# Escribir en fichero
	move	$a0,$t4		# Descriptor
	move	$a1,$s1		#Direccion del dato a escribir
	li	$a2,64		# Tama�o en bytes del dato escrito
	syscall
noalmacenar:
	addiu	$s1,$s1,64
	blt	$s1,$s2,buclealmacenar
#Cierra el archivo
	li	$v0,16
	move	$a0,$t4	
	syscall
#acaba la subrutina
	jr	$ra



#LEER LA AGENDA DEL DISCO
LeerEnDisco:
#s0 devuelve la direccion final de la agenda
	la	$t0,ComienzoAgenda
# Abrir el fichero
	li	$v0,13		# Abrir fichero
	la	$a0,nombreagenda		# Nombre
	li	$a1,0		# Acceso: lectura
	li	$a2,0		# Modo: se ignora
	syscall
	move	$t4,$v0		# Salvar el descriptor
#leer el n�mero de entradas
	li	$v0,14		# Leer en fichero
	move	$a0,$t4		# Descriptor
	move	$a1,$t0		# Puntero al tama�o de una entrada
	li	$a2,4		# Tama�o en bytes del dato le�do
	syscall
#calcula el numero de bytes a leer
	lw	$t2,0($t0)
	#multiplica por 64
	sll	$t2,$t2,6
#lee la agenda
	li	$v0,14		# Leer en fichero
	move	$a0,$t4		# Descriptor
	move	$a1,$t0		# Puntero al tama�o de una entrada
	move	$a2,$t2		# Tama�o en bytes del dato le�do
	syscall
#Cierra el archivo
	li	$v0,16
	move	$a0,$t4	
	syscall
#devuelve el final de la agenda por $s0
	addu	$s0,$t0,$t2
#acaba la subrutina
	jr	$ra


#BUSCAR POR ALGUN CAMPO (solo muestra el primero que coincida
BuscarEnLaAgenda:
#a0 pasa el desplazamiento del campo
#a1 pasa el numero de bytes del campo
#a2 almacena la direccion del dato a buscar
	move	$s1,$ra
	la	$s6,ComienzoAgenda
	move	$s5,$a0		#direccion del dato en agenda
	move	$s3,$a1		#numero de bytes del campo
	move	$s4,$a2		#direccion del dato a buscar
BucleIdCampo1:
	bge	$s6,$s0,FinIdCampoNoResultado
	lw	$t3,60($s6)
	bne	$t3,$zero,BucleIdCampoValido
	addiu	$s6,$s6,64
	j	BucleIdCampo1
BucleIdCampoValido:
	addu	$s2,$s5,$s6
	move	$t3,$s3
	move	$t5,$s2
	move	$t6,$s4
	
BucleIdCampo2:
	lw	$t0,0($t5)
	lw	$t1,0($t6)
	bgt	$t3,4,ContinuarEnBucle2
	beq	$t3,$zero,BucleIdCampo3
	li	$t4,-8
	mul	$t5,$t3,$t4
	addiu	$t5,$t5,32	
	sllv	$t0,$t0,$t5
	sllv	$t1,$t1,$t5
	li	$t4,-1
	mul	$t3,$t3,$t4
	addu	$t3,$s3,$t3
	sub	$s2,$s2,$t3
	sub	$s4,$s4,$t3
BucleIdCampo3:
	beq	$t0,$t1,FinIdCampoSiResultado
	addiu	$s6,$s6,64
	j	BucleIdCampo1
ContinuarEnBucle2:	
	addiu	$t3,$t3,-4
	addiu	$t5,$t5,4
	addiu	$t6,$t6,4
	beq	$t0,$t1,BucleIdCampo2
	addiu	$s6,$s6,64
	j	BucleIdCampo1

FinIdCampoNoResultado:
	la	$a0,noidentificado
	li	$v0,4
	syscall
	li	$v0,12
	syscall
#salir en caso negativo
	jr	$s1
FinIdCampoSiResultado:
#si responde B borrara el bit; si se responde M lo modificara; sino no se hace nada
	move	$a0,$s6	
	jal	MostrarEntrada
	la	$a0,siidentificado
	li	$v0,4
	syscall
	li	$v0,12
	syscall
	move	$t1,$v0
	li	$t0,'m'
	beq	$t1,$t0,lecturaIdM	
	li	$t0,'M'
	beq	$t1,$t0,lecturaIdM
	li	$t0,'b'
	beq	$t1,$t0,lecturaIdB
	li	$t0,'B'
	beq	$t1,$t0,lecturaIdB
	jr	$s1
lecturaIdB:
	move	$a0,$s6
	move	$s4,$s1	#salvaguarda el registro de retorno
	jal	BorrarEntrada
	jr	$s4
lecturaIdM:
	move	$a0,$s6
	jal	ModificarCampo
	jr	$s1


#MODIFICAR ALGUN CAMPO en una entrada
ModificarCampo:
#a0 pasa la direccion de la entrada que se va a modificar
	move	$s2,$a0
	move	$s3,$ra
	la	$a0,menmodificar
	li	$v0,4
	syscall
	li	$v0,5
	syscall
	move	$t1,$v0
	li	$t0,3
	blt	$t1,$t0,NoModDir
	la	$a0,moddir
	li	$v0,4
	syscall
	addiu	$a0,$s2,32
	li	$a1,28
	j	FinMod
NoModDir:	
	li	$t0,2
	blt	$t1,$t0,NoModNum
	la	$a0,modnum
	li	$v0,4
	syscall
	addiu	$a0,$s2,20
	li	$a1,10
	j	FinMod
NoModNum:
	la	$a0,modnom
	li	$v0,4
	syscall
	move	$a0,$s2
	li	$a1,20
FinMod:
	li	$v0,8
	syscall
	move	$a0,$s2
	jal	MostrarEntrada	
#comfirma si almacenar dicha entrada
	la	$a0,inalm
	li	$v0,4
	syscall
	li	$v0,12
	syscall
#si responde S valida el ultimo bit y cambia el final de la agenda; sino no hace nada
	li	$t0,'S'
	beq	$v0,$t0,lecturaS2
	li	$t0,'s'
	beq	$v0,$t0,lecturaS2
#poner el dato de campo nulo a 0
	sw	$zero,60($s2)
#salir de la subrutina en caso negativo
	jr	$s3	
lecturaS2:
	li	$t1,0x00000031
	sw	$t1,60($s2)
	addiu	$s0,$s0,64
	jr	$s3



#ORDENAR LA AGENDA
#Creo que falla porque lee la memoria con los bytes en orden inverso
OrdenarLaAgenda:
#OrdenarEnDisco
#supone que se almaceno el numero de entradas de la agenda en la posicion de memoria de s0 que marca el final de esta
	move	$s1,$ra
#Abrir el fichero
	li	$v0,13		
	la	$a0,nombreagenda	# Nombre
	li	$a1,1			# Acceso: escritura
	li	$a2,0			# Modo: se ignora
	syscall
	move	$s5,$v0		# Salvar el descriptor
#Almacenar el n�mero de entradas
	li	$v0,15		# Escribir en fichero
	move	$a0,$s5		# Descriptor
	la	$a1,0($s0)	#Direccion del dato a escribir
	li	$a2,4		# Tama�o en bytes del dato escrito
	syscall
#pregunta como ordenar
	la	$a0,ordenar
	li	$v0,4
	syscall
	li	$v0,5
	syscall
	move	$t1,$v0
	li	$t0,3
	blt	$t1,$t0,NoOrdDir
	li	$s2,28		#s2 almacena el desplazamiento para empezar a comparar
	j	FinOrd
NoOrdDir:	
	li	$t0,2
	blt	$t1,$t0,NoOrdNum
	li	$s2,20
	j	FinOrd
NoOrdNum:
	li	$s2,0
FinOrd:
#Encuentra la primera entrada valida
buscarVal:
	la	$s4,ComienzoAgenda	#S4 Almacena el lugar de la agenda actual
NoVal:
	lw	$t0,60($s4)
	bge	$s4,$s0,FinComparacion	
	addiu	$s4,$s4,64
	beq	$t0,$zero,NoVal
	addiu	$s3,$s4,-64		#S3 Almacena la entrada de la agenda que estamos comparando		
#Comprueba que la nueva entrada es valida
NoVal2:
	lw	$t0,60($s4)
	bne	$t0,$zero,EnVal
	addiu	$s4,$s4,64
	bgt	$s4,$s0,EscribirEntrada	
	j	NoVal2
	addiu	$s4,$s4,-64
EnVal:	
#comprueba que la primera parte no es igual	
	addu	$t0,$s2,$s4
	addu	$t1,$s2,$s3
Buscardistintos:
	lw	$t2,0($t0)
	lw	$t3,0($t1)
	bne	$t2,$t3,Comparar
	addiu	$t0,$t0,4
	addiu	$t1,$t1,4
	beq	$t0,$t1,NoVal
	j	Buscardistintos
Comparar:
	blt	$t2,$t3,NuevoS3
#s4>s3 nuevo s3=s4
	move	$s3,$s4
	addiu	$s4,$s3,64
	j	NoVal2
#s4<s3 nuevo s4=s4+64
NuevoS3:
	addiu	$s4,$s4,64
	j	NoVal2
EscribirEntrada:	
#Escribir entrada a entrada
	move	$a0,$s3	
	jal	MostrarEntrada
	li	$v0,15		# Escribir en fichero
	move	$a0,$s5		# Descriptor
	move	$a1,$s3		#Direccion del dato a escribir
	li	$a2,64		# Tama�o en bytes del dato escrito
	syscall	
#borra la entrada
	sw	$zero,60($s3)
	j	buscarVal
	
FinComparacion:
	move	$a0,$s3	
	jal	MostrarEntrada
#Comprueba si es una entrada valida
	li	$v0,15		# Escribir en fichero
	move	$a0,$s5		# Descriptor
	move	$a1,$s3		#Direccion del dato a escribir
	li	$a2,64		# Tama�o en bytes del dato escrito
#Cierra el archivo
	li	$v0,16
	move	$a0,$s5	
	syscall
	jr	$s1
	
	
	
#LISTAR LA AGENDA
ListarAgenda:
	move	$s2,$ra
	la	$s1,ComienzoAgenda
BucleListado:
	lw	$t0,60($s1)
	beq	$t0,$zero,NoListar
#dejo 2 reglones en blanco como separacion entre entrada
	li	$a0,10
	li	$v0,11
	syscall
	li	$a0,10
	li	$v0,11
	syscall	
	move	$a0,$s1
	jal	MostrarEntrada
NoListar:
	addiu	$s1,$s1,64
	ble	$s1,$s0,BucleListado
	jr	$s2












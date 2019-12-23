    .data
callbookName:    .asciiz    "callbook.txt"

question:    .byte 10
        .ascii "Introduce:"
        .byte 10
        .ascii "1 - Load a file, from root, if it does not exist it will use a new callbook: "
        .byte 10
        .ascii "2 - List all entries: "
        .byte 10
        .ascii "3 - Order the entries (still buggy): "
        .byte 10
        .ascii "4 - Add a new contact: "
        .byte 10
        .ascii "5 - Search a contact (by name or phone): "
        .byte 10
        .ascii "6 - Show number of contacts: "
        .byte 10
        .ascii "7 - Save the callbook (in the root): "
        .byte 10
        .asciiz "8 - Exit the program: "
modifyNameTxt:      .byte 10
        .asciiz "Introduce a name: "
modifyPhoneTxt:     .byte 10
        .asciiz "Introduce a number: "
modifyDirectionTxt:  .byte 10
        .asciiz "Introduce a direction: "

notIdentifiedTxt:    .byte 10
        .asciiz "We cannot identify any entry which match the criteria "
corectIdentifiedTxt: .byte 10
        .asciiz "Press M to modify the field, B to erase it and nothing to return to the menu: "

SearchingByTxt:      .byte 10
        .asciiz "Press to search by name (defect option) and 2 to use name: "
AskFieldTxt:        .byte 10
        .asciiz "Introduce the search data: "
ShowNumEntriesTxt:  .byte 10
        .asciiz "The number of entries is: "
ModifyFieldTxt:     .byte 10
        .asciiz "Press 1 to modify by name and 2 to modify the phone (defect option): "

introduceNameTxt:
        .byte 10
        .asciiz "Introduce the name and surname: "
introducePhoneTxt:      .byte 10
        .asciiz "Introduce the phone number: "
introduceDirectionTxt:  .byte 10
        .asciiz "Introduce the direction: "

deleteTxt:    .byte 10
        .asciiz "Press S to confirm delete this entry: "
modifyTxt:     .byte 10
        .asciiz "Press S to modify this entry: "
nameTxt:        .asciiz "Name: "
numberTxt:      .asciiz "Phone number: "
directionTxt:   .byte 10
        .asciiz "Direction: "

storeConfirmTxt:    .byte 10
        .asciiz "Press S to confirm saving this entry: "

orderByTxt:    .byte 10
        .asciiz "Select the field to order the callbook; 1 name, 2 phone: "

.align    2
StartCallbook:
#Each entry in the callbook has the following fields
#Name:            20 bytes
#Phone:            10 bytes, works like a text
#Direction:     30 bytes
#Campo_Valido:  4  bytes; If ser to 0 is a invalid entry
#total:         64 bytes by entry
#EndPhoneBook   Store in $s1

    .text
main:
    la    $s0,StartCallbook
#Ask which option do
QuestionLoop:
    la    $a0,question
    li    $v0,4
    syscall
    #reads the selected option and stores it in t0
    li      $v0,5
    syscall
    move    $t0,$v0
#1 - Load a callbook from disk
    li     $t1,1
    bne    $t1,$t0,OptionNum1
    jal    ReadFromDisk    #s0 is updated to the new end of the callbook
    j      QuestionLoop
#2 - Lists all entries
OptionNum1:
    li     $t1,2
    bne    $t1,$t0,OptionNum2
    jal    ListCallbook
    j      QuestionLoop
#3 - Orders the callbook, still in BETA
OptionNum2:
    li     $t1,3
    bne    $t1,$t0,OptionNum3
    jal    CountEntries    #This will store the number of entries in the book in $s1
    sw     $s1,0($s0)      #Before calling the subroutine we store the number of entries in memory
    jal    orderCallbook
    jal    ReadFromDisk    
    j      QuestionLoop
#4 - Add a new entry to the book
OptionNum3:
    li     $t1,4
    bne    $t1,$t0,OptionNum4
    jal    NewEntry
    j      QuestionLoop
#5 - Select an entry to be erased o modified
OptionNum4:
    li    $t1,5
    bne    $t1,$t0,OptionNum5
#Asks for the search field
    la    $a0,SearchingByTxt
    li    $v0,4
    syscall
#Reads the selected field and stores its identifier in t0
    li      $v0,5
    syscall
    move    $t0,$v0
#Stores in t0 the field displacement respect the start of the entry and in t1 the field length
    li    $t2,3
    bne   $t0,$t2,DirectionNotChose
    li    $t0,32
    li    $t1,28
    j     EndChoseField
DirectionNotChose:
    li     $t2,2
    bne    $t0,$t2,NumberNotChose
    li     $t0,20
    li     $t1,10
    j      EndChoseField
NumberNotChose:
    move   $t0,$zero
    li     $t1,20
EndChoseField:
#Asks the field search value
    la    $a0,AskFieldTxt
    li    $v0,4
    syscall
#Stores the value in s0, which stores the callbook end
    move    $a0,$s0
    li      $v0,8
    move    $a1,$t1
    syscall
#Pass the arguments to the subroutine
    move    $a0,$t0        #a0 Field displacement
    move    $a1,$t1        #a1 Number of bytes of the field (field length)
    move    $a2,$s0        #a2 Direction of the field to search
    jal     SearchInThePhoneBook
    j       QuestionLoop
#6 - Show the number of entries
OptionNum5:
    li     $t1,6
    bne    $t1,$t0,OptionNum6
    la     $a0,ShowNumEntriesTxt
    li     $v0,4
    syscall
    jal    CountEntries    #almacena en s1 el numero de entradas
    move   $a0,$s1
    li     $v0,1
    syscall
    j      QuestionLoop
#7 - Saves the phone book to a file in disk
OptionNum6:
    li    $t1,7
    bne    $t1,$t0,OptionNum7
    jal    CountEntries        #Returns the number of entries in the book by s1
    sw    $s1,0($s0)           #We save the number of entries to memory
    jal    SaveInDisk
    j    QuestionLoop
#8 - Exit the program
OptionNum7:
    li    $v0,10
    syscall



#INTRODUCE A NEW ENTRY
NewEntry:
    move    $s1,$ra
#Asks to introduce a new name
    la       $a0,introduceNameTxt
    li       $v0,4
    syscall
#Reads the name and store it in memory
    move     $a0,$s0
    addiu    $a1,$zero,20
    li       $v0,8
    syscall
#Asks to introduce a new phone number
    la       $a0,introducePhoneTxt
    li       $v0,4
    syscall
#Reads the number and stores it in memory
    addiu    $a0,$s0,20
    addiu    $a1,$zero,10
    li       $v0,8
    syscall
#Asks to introduce a direction
    la       $a0,introduceDirectionTxt
    li       $v0,4
    syscall
#Reads the direction and stores it in memory
    addiu    $a0,$s0,30
    addiu    $a1,$zero,30
    li       $v0,8
    syscall
#Shows the entry
    move    $a0,$s0
    jal     ShowEntry
#Ask for confirmation to store the entry
    la      $a0,storeConfirmTxt
    li      $v0,4
    syscall
    li      $v0,12
    syscall
#If S validates the last bit and updates the callbook end; if not it does not anything
    li      $t0,'S'
    beq     $v0,$t0,readS
    li      $t0,'s'
    beq     $v0,$t0,readS
#Sets the null field to 0
    sw      $zero,60($s0)
#In case contrary exist the subroutine
    jr      $s1
readS:
    li      $t1,0x00000031
    sw      $t1,60($s0)
    addiu   $s0,$s0,64
    jr      $s1

#Show entry
ShowEntry:
#$a0 stores search field
    move    $t0,$a0
    la      $a0,nameTxt
    li      $v0,4
    syscall
    move    $a0,$t0
    li      $v0,4
    syscall
    la      $a0,numberTxt
    li      $v0,4
    syscall
    addiu   $a0,$t0,20
    li      $v0,4
    syscall
    la      $a0,directionTxt
    li      $v0,4
    syscall
    addiu   $a0,$t0,30
    li      $v0,4
    syscall
    jr      $ra

#DELETE AN ENTRY
deleteEntry:
    #$a0 stores the direction of the entry to be deleted
    move    $s1,$a0
    move    $s2,$ra
    jal     ShowEntry
    la      $a0,deleteTxt
    li      $v0,4
    syscall
    li      $v0,12
    syscall
#If S will delete the entry, if not id will do nothing
    li    $t0,'S'
    beq    $v0,$t0,readN
    li    $t0,'s'
    beq    $v0,$t0,readN
#Exit the subroutine without deleting the text
    jr    $s2
readN:
    sw    $zero,60($s1)
    jr    $s2

#COUNTS THE NUMEBER OF ENTRIES
CountEntries:
#Use s1 to return the number of entries
    la      $t0,StartCallbook    #t0 stores the actual check entry, initialised at the start of the phone book
    move    $s1,$zero
CountBucle:
    lw      $t2,60($t0)
    beq     $t2,$zero,NotSum
    addiu   $s1,$s1,1
NotSum:
    addiu   $t0,$t0,64
    blt     $t0,$s0,CountBucle    #s0 stores the end of the phone book
    jr      $ra
    
#STORES THE PHONE BOOK TO TEXT
SaveInDisk:
#s0 will stores the memory position where the call book ends
    la      $s1,StartCallbook
    move    $s2,$s0
    la      $s3,0($s0)
# Open a field
    li      $v0,13        
    la      $a0,callbookName    # Name
    li      $a1,1               # Acces (ignored)
    li      $a2,0               # Mode(ignored)
    syscall
    move    $t4,$v0    # Saves the descriptor
#Store the number of entries
    li      $v0,15     # Writes in the field
    move    $a0,$t4    # Descriptor
    move    $a1,$s3    # Field direction to write
    li      $a2,4      # Tama�o en bytes del dato escrito
    syscall
    #Writes entry by entry (only the valid ones)
StoreLoop:
    #Checks if it is a valid entry
    lw      $t5,60($s1)
    beq     $t5,$zero,noalmacenar
    li      $v0,15      # Write in the file
    move    $a0,$t4     # Descriptor
    move    $a1,$s1     # Field to write direction
    li      $a2,64      # Number of bytes of the written field
    syscall
noalmacenar:
    addiu   $s1,$s1,64
    blt     $s1,$s2,StoreLoop
#Closes the file
    li      $v0,16
    move    $a0,$t4
    syscall
#Ends the subroutine
    jr      $ra



#READS THE AGENDA FROM DISK
ReadFromDisk:
#s0 stores the end of the phone book
    la      $t0,StartCallbook
#Open the file from disk
    li      $v0,13             # Open the field
    la      $a0,callbookName   # Name
    li      $a1,0              # Access: read
    li      $a2,0              # Mode: ignored
    syscall
    move    $t4,$v0            # Saves the descriptor
#Read the number  of entries
    li      $v0,14      # Read from file
    move    $a0,$t4     # Descriptor
    move    $a1,$t0     # Pointer to an entry
    li      $a2,4       # Number of bytes to read
    syscall
#Claculates the number of bytes to read
    lw      $t2,0($t0)
#Multiply by 64, the number of bytes of an entry
    sll     $t2,$t2,6
#Reads all the entries form the file
    li      $v0,14      # Read from file
    move    $a0,$t4     # Descriptor
    move    $a1,$t0     # Pointer to an entry
    move    $a2,$t2     # Size in bytes of the read data
#Closes the file
    li      $v0,16
    move    $a0,$t4    
    syscall
#Return the end of the callbook in $s0
    addu    $s0,$t0,$t2
#Finish the subroutine
    jr      $ra


#SEARCH BY SOME FIELD (only shows the first match)
SearchInThePhoneBook:
#a0 Stores the field displacements
#a1 Stores the number of bytes (length) of the field
#a2 Stores the direction of the field value to search
    move     $s1,$ra
    la       $s6,StartCallbook
    move     $s5,$a0        # Entry direction in the phone book
    move     $s3,$a1        # Number of bytes
    move     $s4,$a2        # Search field value direction
LoopIdFieldId1:
    bge      $s6,$s0,EndFieldWithoutResult
    lw       $t3,60($s6)
    bne      $t3,$zero,LoopIdFieldIdCorrect
    addiu    $s6,$s6,64
    j        LoopIdFieldId1
LoopIdFieldIdCorrect:
    addu     $s2,$s5,$s6
    move     $t3,$s3
    move     $t5,$s2
    move     $t6,$s4
LoopIdFieldId2:
    lw       $t0,0($t5)
    lw       $t1,0($t6)
    bgt      $t3,4,ContinueInLoop2
    beq      $t3,$zero,LoopIdFieldId3
    li       $t4,-8
    mul      $t5,$t3,$t4
    addiu    $t5,$t5,32
    sllv     $t0,$t0,$t5
    sllv     $t1,$t1,$t5
    li       $t4,-1
    mul      $t3,$t3,$t4
    addu     $t3,$s3,$t3
    sub      $s2,$s2,$t3
    sub      $s4,$s4,$t3
LoopIdFieldId3:
    beq      $t0,$t1,EndFieldWithResult
    addiu    $s6,$s6,64
    j        LoopIdFieldId1
ContinueInLoop2:    
    addiu    $t3,$t3,-4
    addiu    $t5,$t5,4
    addiu    $t6,$t6,4
    beq      $t0,$t1,LoopIdFieldId2
    addiu    $s6,$s6,64
    j        LoopIdFieldId1
EndFieldWithoutResult:
    la       $a0,notIdentifiedTxt
    li       $v0,4
    syscall
    li       $v0,12
    syscall
#Exit in negative case
    jr       $s1
EndFieldWithResult:
#If answers B deletes the enry, if M it modifies it
    move     $a0,$s6
    jal      ShowEntry
    la       $a0,corectIdentifiedTxt
    li       $v0,4
    syscall
    li       $v0,12
    syscall
    move     $t1,$v0
    li       $t0,'m'
    beq      $t1,$t0,lecturaIdM
    li       $t0,'M'
    beq      $t1,$t0,lecturaIdM
    li       $t0,'b'
    beq      $t1,$t0,lecturaIdB
    li       $t0,'B'
    beq      $t1,$t0,lecturaIdB
    jr       $s1
lecturaIdB:
    move     $a0,$s6
    move     $s4,$s1    #Restores the return register
    jal      deleteEntry
    jr       $s4
lecturaIdM:
    move     $a0,$s6
    jal      ModifyField
    jr       $s1


#MODIFY SOME FIELD OF THE ENTRY
ModifyField:
#a0 stores the direction of the entry to be modified
    move    $s2,$a0
    move    $s3,$ra
    la      $a0,ModifyFieldTxt
    li      $v0,4
    syscall
    li      $v0,5
    syscall
    move    $t1,$v0
    li      $t0,3
    blt     $t1,$t0,NoModifyDirectionTxt
    la      $a0,modifyDirectionTxt
    li      $v0,4
    syscall
    addiu   $a0,$s2,32
    li      $a1,28
    j       EndModify
NoModifyDirectionTxt:
    li      $t0,2
    blt     $t1,$t0,NoModifyPhoneTxt
    la      $a0,modifyPhoneTxt
    li      $v0,4
    syscall
    addiu   $a0,$s2,20
    li      $a1,10
    j       EndModify
NoModifyPhoneTxt:
    la      $a0,modifyNameTxt
    li      $v0,4
    syscall
    move    $a0,$s2
    li      $a1,20
EndModify:
    li      $v0,8
    syscall
    move    $a0,$s2
    jal     ShowEntry
#Confirmation to modify the entry
    la      $a0,storeConfirmTxt
    li      $v0,4
    syscall
    li      $v0,12
    syscall
#If answer S validates the entry and updates the end of the callbook
    li      $t0,'S'
    beq     $v0,$t0,readS2
    li      $t0,'s'
    beq     $v0,$t0,readS2
#Puts the validate field to null
    sw     $zero,60($s2)
#In negative case, exits the subroutine
    jr     $s3    
readS2:
    li     $t1,0x00000031
    sw     $t1,60($s2)
    addiu  $s0,$s0,64
    jr     $s3



#ORDER THE PHONE BOOK (BETA)
#Some times bytes are read in reverse order
orderCallbook:
#The end of the phone book is store in s0
    move    $s1,$ra
#Open the file
    li      $v0,13        
    la      $a0,callbookName    # Name
    li      $a1,1               # Access: write
    li      $a2,0               # Mode: ignore
    syscall
    move    $s5,$v0      # Saves the descriptor
#Stores the number of entries
    li      $v0,15       # Write in file
    move    $a0,$s5      # Descriptor
    la      $a1,0($s0)   # Direction of the field to write
    li      $a2,4        # Number of bytes of the stored data
    syscall
#Asks how to order
    la      $a0,orderByTxt
    li      $v0,4
    syscall
    li      $v0,5
    syscall
    move    $t1,$v0
    li      $t0,3
    blt     $t1,$t0,NoOrdDir
    li      $s2,28     #s2 stores the displacement
    j       FinOrd
NoOrdDir:    
    li      $t0,2
    blt     $t1,$t0,NoOrdNum
    li      $s2,20
    j       FinOrd
NoOrdNum:
    li      $s2,0
FinOrd:
#Stores the first valid entry
buscarVal:
    la      $s4,StartCallbook    #S4 stores the position of the actual book
NoVal:
    lw      $t0,60($s4)
    bge     $s4,$s0,EndComparation
    addiu   $s4,$s4,64
    beq     $t0,$zero,NoVal
    addiu   $s3,$s4,-64        #S3 stores the entry that we are comparing
#Checks if the new entry is valid
NoVal2:
    lw      $t0,60($s4)
    bne     $t0,$zero,EnVal
    addiu   $s4,$s4,64
    bgt     $s4,$s0,WriteEntry
    j       NoVal2
    addiu   $s4,$s4,-64
EnVal:    
#Checks the 
    addu    $t0,$s2,$s4
    addu    $t1,$s2,$s3
SearchDifferent:
    lw      $t2,0($t0)
    lw      $t3,0($t1)
    bne     $t2,$t3,Compare
    addiu   $t0,$t0,4
    addiu   $t1,$t1,4
    beq     $t0,$t1,NoVal
    j       SearchDifferent
Compare:
    blt     $t2,$t3,NewS3
#s4>s3 new s3=s4
    move    $s3,$s4
    addiu   $s4,$s3,64
    j       NoVal2
#s4<s3 new s4=s4+64
NewS3:
    addiu   $s4,$s4,64
    j       NoVal2
WriteEntry:    
#Write entry by entry
    move    $a0,$s3    
    jal     ShowEntry
    li      $v0,15     # Escribir en fichero
    move    $a0,$s5    # Descriptor
    move    $a1,$s3    # Direccion del dato a escribir
    li      $a2,64     # Tama�o en bytes del dato escrito
    syscall
#Erase the entry
    sw    $zero,60($s3)
    j     buscarVal
    
EndComparation:
    move    $a0,$s3    
    jal    ShowEntry
#Checks if an entry is valid
    li      $v0,15     # Write the file
    move    $a0,$s5    # Descriptor
    move    $a1,$s3    # Direction to write
    li      $a2,64     # Number of byte of the written data
#Closes the file
    li      $v0,16
    move    $a0,$s5
    syscall
    jr      $s1



#LISTS THE PHONE BOOK
ListCallbook:
    move     $s2,$ra
    la       $s1,StartCallbook
ListLoop:
    lw       $t0,60($s1)
    beq      $t0,$zero,NotList
#2 blank lines between entries
    li       $a0,10
    li       $v0,11
    syscall
    li       $a0,10
    li       $v0,11
    syscall    
    move     $a0,$s1
    jal      ShowEntry
NotList:
    addiu    $s1,$s1,64
    ble      $s1,$s0,ListLoop
    jr       $s2
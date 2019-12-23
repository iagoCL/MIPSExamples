.data
    matrixFilePath:      .asciiz "path/to/matrix/file.txt"
    showOrigTxt:         .asciiz "Showing the original matrix:\n"
    showMins:            .asciiz "Showing the minimums matrix:\n"
    showPredecessors:    .asciiz "Showing the predecessors matrix:\n"
    .align               2
    totalElements:       .space 4
    elementsPerCol:      .space 4
    graph:
.text
main:
    jal    LoadMatrix             # Subroutine that loads the matrix from disk to memmory
    jal    WriteMatrixes          # Subroutine that computes the minimum and predecessors matixes

    la     $a0,showOrigTxt        # Shows the message of the orginal matrix by console
    li     $v0,4
    syscall
    li     $a0,0                  # Displacement of the original matrix
    jal    ShowMatrix             # Subroutine to show the original matrix by console
    la     $a0,showMins           # Show the minimum matrix message by console
    li     $v0,4
    syscall
    lw     $s2,totalElements      # Stores the separation between graphs
    move   $a0,$s2                # Matrix displacement respect the origin
    jal    ShowMatrix             # Subroutine that shows the matrix by console
    la     $a0,showPredecessors   # Show the predecessor matrix message by console
    li     $v0,4
    syscall
    add    $a0,$s2,$s2             # Predecessors matrix displacement respect the origin
    jal    ShowMatrix              # Subroutine to show the predeccesor matrix by console
    li    $v0,10
    syscall

ShowMatrix:
# a0 Gives the displacement of the start respect graph
# for(int i=0;i<numRows;i++){
    # for(int j=0;j<numRows;j++)
        # std::cout<<Vertix[i][j]+' ';
    # std::cout<<std::endl;
    la     $s0,graph            # stores the begining of the array
    add    $s0,$s0,$a0          # s0 stores the graph actual position
    lw     $s1,elementsPerCol   # s1 stores the elements of each columns
    # for(int i=0;i<numRows;i++){
    li     $t0,0      # t0 stores i, initialised at 0
    ShowRow:
        # for(int j=0;i<numRows;j++){
        li    $t1,0                    # t1 stores j, initialised at 0
        ShowCol:
            lw      $a0,0($s0)         # stores in a0 the number to be print
            li      $v0,1              # Syscall to print an integer
            syscall
            addi    $s0,$s0,4          # Increase the number to be print
            li      $v0,11             # Syscall to print a character
            li      $a0,9              # I set the character to tab
            syscall
            addi    $t1,$t1,1          # Increase j=t1 + 1
            blt     $t1,$s1,ShowCol    # End nested for loop
        li      $v0,11                 # Syscall to print a character
        li      $a0,10                 # I print the new line character
        syscall
        addi    $t0,$t0,1               # Increase i=t0 + 1
        blt     $t0,$s1,ShowRow         # End of the main for
    jr    $ra


WriteMatrixes:
# Uses the Floyd Marshal algorithms to compute the minimum path
# for(int k = 0; k < numRows; k++)
    # for(int i = 0; i < numRows; i++)
        # for(int j = 0; j < numRows; j++){
            # int weight = Vertix[i][k] + Vertix[k][j];
                # if(Vertix[i][j] > weight){
                    # Vertix[i][j] = weight;
                    # Predecessors[i][j]=k;}}
    move    $t4,$ra               # Stores the return direction
    lw      $a0,totalElements     # Creates the new matrix at the end of the first one
    jal     CopyGraph             # Call the subroutine to copy the elements in the indicated position
    add     $a0,$a0,$a0
    jal     InitialisePredeccessorsMatrix
    la      $s0,graph             # Stores the beginning of the original graph
    lw      $s2,totalElements     # s2 is the separation between graphs
    add     $s0,$s2,$s0           # s0 stores the begining of the graph with who we are working
    lw      $s1,elementsPerCol    # Stores the number of rows in s1
    move    $ra,$t4
    li      $t6,90                # stores in s2 the maximum possible value of a graph
    # for(int k = 0; k < numRows; k++)
    li      $t0,0                 # t0 stores k, initialised at 0
    FWLoopDiagonal:
        # for(int i = 0; i < numRows; i++){
        li    $t1,0               # t1 stores i, initialised at 0
        FWLoopRows:
            # for(int j = 0; j < numRows; j++){
            li    $t2,0           # t2 stores j, initialised at 0
            FWLoopColumn:
                # weight = Vertix[i][k] + Vertix[k][j];
                # t4=Vertix[i][k]
                mul     $t3,$s1,$t1            # t3 stores numRows*i, used for [i][k]
                add     $t4,$t3,$t0            # t4 stores the position of the element (numRows*i+k)
                mul     $t4,$t4,4              # t4 stores the byte position (4*element)
                add     $t4,$t4,$s0            # t4 stores the direction [i][k]
                lw      $t4,0($t4)             # t4=Vertix[i][k]
                bgt     $t4,$s2,FWElseCase     # If stores more than s2 it is not connected in that point
                # t5=Vertix[k][j]
                mul     $t5,$s1,$t0            # t5 stores numRows*k, used for [k][j]
                add     $t5,$t5,$t2            # t5 stores the position of the element (numRows*k+j)
                mul     $t5,$t5,4              # t5 stores the byte position (4*element)
                add     $t5,$t5,$s0            # t5 stores the direction [k][j]
                lw      $t5,0($t5)             # t5=Vertix[k][j]
                bgt     $t5,$s2,FWElseCase     # If stores more than s2 it is not connected in that point
                # weight = Vertix[i][k] + Vertix[k][j]=t4+t5=t4
                add     $t4,$t4,$t5
                # t3=Vertix[i][j];// t3 already stores numRows*i
                add     $t5,$t3,$t2            # t5 stores the position of the element = numRows*i+j
                mul     $t5,$t5,4              # t5 stores the byte position (4*element)
                add     $t5,$t5,$s0            # t5 stores the direction [i][j]; used lacter for write
                lw      $t3,0($t5)             # t3=Vertix[i][j]
                # if(Vertix[i][j] > weight); skip if t3<t4
                ble     $t3,$t4,FWElseCase
                # Vertix[i][j] = weight;
                sw      $t4,0($t5)             # Stores t4=weight in Vertix[i][j] whose direction is stores t5
                # Predecessors[i][j]=k;]
                add     $t5,$t5,$s2            # Sum to t5 the separation between graphs now it sotres the direction of Predecessors[i][j]
                sw      $t0,0($t5)             # Stores t0=k in Predecessors[i][j] whose direction is stores t5
                FWElseCase:
                    addi    $t2,$t2,1              # Increment j=t2 by 1
                    blt     $t2,$s1,FWLoopColumn   # End third for
            addi   $t1,$t1,1                       # Increment i=t1 by 1
            blt    $t1,$s1,FWLoopRows              # End Second for
        addi   $t0,$t0,1                           # Increment k=t0 by 1
        blt    $t0,$s1,FWLoopDiagonal              # End first for
    jr    $ra      # retorna al program principal



InitialisePredeccessorsMatrix:
# a0 gives the displacement respect the graph
# for(int i=0;i<numRows;i++)
    # for(int j=0;j<numRows;j++){
        # Vertix[i][j]=j;
    la    $s0,graph             # Stores the beginning of the graph
    add   $s0,$s0,$a0           # s0 almacena la posicion actal del graph
    lw    $s1,elementsPerCol    # s1 stores the number of elements per row
    # for(int i=0;i<numRows;i++)
    li    $t0,0                 # t0 stores i, initialised at 0
    InitialiseRowsMatrix:
        # for(int j=0;j<numRows;j++){
        li    $t1,0             # t1 stores j, initialised at 0
        InitialiseColsMatrix:
            # Vertix[i][j]=j;
            sw     $t1,0($s0)                      # Saves in the predecessors matrix
            addi   $s0,$s0,4                       # Next matrix element
            addi   $t1,$t1,1                       # Increment t1=j by 1
            blt    $t1,$s1,InitialiseColsMatrix    # fin del segundo for
    addi   $t0,$t0,1                               # Increments t0=i by 1
    blt    $t0,$s1,InitialiseRowsMatrix            # End of the first for
    jr     $ra                                     # Exit the subroutine


CopyGraph:
# Copy the graph matrix with the separation given by a0
    la     $s0,graph                     # s0 stores la matrixFilePath que copiamos
    add    $s1,$s0,$a0                   # s1 stores la matrixFilePath a la que copiamos
    lw     $s2,totalElements             # stores el numero de bytes del graph
    add    $s2,$s2,$s0                   # s2 stores el final del graph
    CopyAnElement:
        lw      $t0,0($s0)               # Copy an array element to t0
        sw      $t0,0($s1)               # Write t0 in the new array
        addi    $s0,$s0,4                # Increase the copied element
        addi    $s1,$s1,4                # Increase the write position
        blt     $s0,$s2,CopyAnElement    # Continues uniti reach the end of the array
    jr   $ra                             # Exist the subroutine


LoadMatrix:
    li    $v0,13                # Syscall to open a file
    la    $a0,matrixFilePath    # Indicates the path to the read file
    li    $a1,0                 # Opens the file for lecture
    li    $a2,0                 # Mode ignored
    syscall                     # Returns the file descriptor by vo
    move  $a0,$v0               # Gives the descriptor
    li    $v0,14                # Syscall to read a file
    la    $a1,totalElements     # Direction to store it
    li    $a2,4                 # Number of read bytes
    syscall
    # It can be done in one syscall but this is more clear
    li    $v0,14                # Syscall to read a file
    la    $a1,elementsPerCol    # Direction to store it
    li    $a2,4                 # Number of read bytes
    syscall
    # a0 still gives the decriptor
    li    $v0,14                # Syscall to read a file
    la    $a1,graph             #  Direction to store it
    lw    $a2,totalElements     # Number of read bytes
    syscall
    # a0 still gives the decriptor
    li    $v0,16                # Command to close the file
    syscall
    jr    $ra                   # Return to the main program

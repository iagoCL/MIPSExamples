# MIPSExample
Examples of some basic programs created in assembly language using MIPS.

## Compilation
Both files can be executed using [MARS](http://courses.missouristate.edu/KenVollmar/MARS/index.htm), a MIPS simulator produced by Pete Sanderson and Ken Vollmar from the University of Missouri and licensed with MIT license.

## Graph
This program will load a matrix from a file. This matrix will be symmetric and will store the cost of connecting two nodes. The program will use the Floyd Marshal to output by console the predecessors and the cost matrix obtained.

The program expects to read the matrix from a binary file, one can change the path of the loaded matrix. The file [src/graph.c](src/graph.c) is capable of creating this file, additionally, it will output by console the original and solved matrixes.
```
gcc src/graph.c -o graph
./graph
```

## callbook
This code manages a simple contact list, storing the name, phone and direction of a contact. The assembly code is based on an array list and is capable of creating new contacts, modifying and erasing existing ones, list all the contacts, search by phone or name and store and load the agenda to a disk file.
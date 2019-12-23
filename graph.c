#include "stdio.h"

/*
#define SIZE 5
int graphMatrix[SIZE][SIZE] = {
   -1,      -1,     -1,     -1,     -1,
    3,      -1,     -1,     -1,     -1,
    5,      91,     -1,     -1,     -1,
    1,      91,      7,     -1,     -1,
    91,      9,      7,     -1,     -1,
};//*/
/**/
#define SIZE 15
int graphMatrix[SIZE][SIZE] = {
   -1,      -1,     -1,     -1,     -1,     -1,     -1,     -1,     -1,     -1,     -1,     -1,     -1,     -1,     -1,
    3,      -1,     -1,     -1,     -1,     -1,     -1,     -1,     -1,     -1,     -1,     -1,     -1,     -1,     -1,
    5,      91,     -1,     -1,     -1,     -1,     -1,     -1,     -1,     -1,     -1,     -1,     -1,     -1,     -1,
    1,      91,      7,     -1,     -1,     -1,     -1,     -1,     -1,     -1,     -1,     -1,     -1,     -1,     -1,
    91,      9,      7,     91,     -1,     -1,     -1,     -1,     -1,     -1,     -1,     -1,     -1,     -1,     -1,
    4,      91,      5,      7,      9,     -1,     -1,     -1,     -1,     -1,     -1,     -1,     -1,     -1,     -1,
    8,       4,      6,     91,      1,      5,     -1,     -1,     -1,     -1,     -1,     -1,     -1,     -1,     -1,
    6,       6,      8,      7,      7,      4,      5,     -1,     -1,     -1,     -1,     -1,     -1,     -1,     -1,
    91,      3,     91,      5,     91,      5,      8,      5,     -1,     -1,     -1,     -1,     -1,     -1,     -1,
    6,       4,      5,      7,      7,     91,      6,      6,      5,     -1,     -1,     -1,     -1,     -1,     -1,
    91,      6,      5,      3,      3,      2,     91,     91,      3,      5,     -1,     -1,     -1,     -1,     -1,
    9,       7,      8,      4,      5,      2,     91,      1,      7,      6,      8,     -1,     -1,     -1,     -1,
    5,       9,      7,     91,      4,      5,      3,      9,      6,      5,      3,      1,     -1,     -1,     -1,
    1,       2,      3,      4,      5,      6,      7,      8,      9,     91,      1,      2,      3,     -1,     -1,
    7,       4,      5,      7,      8,      9,      1,     91,      3,      5,     91,      6,      4,      7,     -1,
};  //*/
#define PATH_TO_MATRIX "matrix.txt"
int fileSize, size, numCols, numRows;
int loadedGraph[SIZE][SIZE];
int predecessors[SIZE][SIZE];

int main() {
    //Transform the matrix into a symmetric matrix
    for (int i = 0; i < SIZE; i++) {
        for (int a = 0; a < i; a++) {
            graphMatrix[a][i] = graphMatrix[i][a];//Use a load Matrix
        }
        graphMatrix[i][i] = 0;
    }

    //Save to disk
    size = sizeof(graphMatrix);
    numRows = SIZE;
    FILE *f2;
    f2 = fopen(PATH_TO_MATRIX, "wb");
    fwrite(&size, 4, 1, f2);
    fwrite(&numRows, 4, 1, f2);
    fwrite(&graphMatrix, 1, sizeof(graphMatrix), f2);
    fclose(f2);

    //Reads the file from disk
    f2 = fopen(PATH_TO_MATRIX, "rb");
    fread(&fileSize, 4, 1, f2);
    fread(&numCols, 4, 1, f2);
    fread(&loadedGraph, 1, sizeof(graphMatrix), f2);
    //Shows the file to check it
    printf("Total elements: %i\nElements per column: %i\n", fileSize, numCols);
    for (int i = 0; i < numCols; i++) {
        for (int a = 0; a < numCols; a++) {
            printf("%2i,      ", loadedGraph[i][a]);
        }
        printf("\n");
    }
    //Initialise the predecessors
    for (int i = 0; i < numCols; i++)
        for (int j = 0; j < numCols; j++)
            predecessors[i][j] = j;

    printf("\n\n\n");

    //Compute the matrix
    for (int k = 0; k < numCols; k++)
        for (int i = 0; i < numCols; i++)
            for (int j = 0; j < numCols; j++) {
                int weight = loadedGraph[i][k] + loadedGraph[k][j];
                if (loadedGraph[i][j] > weight) {
                    loadedGraph[i][j] = weight;
                    predecessors[i][j] = k;
                }
            }
    //Shows the computed matrix
    printf("Minimums matrix\n");
    for (int i = 0; i < numCols; i++) {
        for (int a = 0; a < numCols; a++) {
            printf("%2i,      ", loadedGraph[i][a]);
        }
        printf("\n");
    }
    printf("\n\nPredecessors matrix\n");
    for (int i = 0; i < numCols; i++) {
        for (int a = 0; a < numCols; a++) {
            printf("%2i,      ", predecessors[i][a]);
        }
        printf("\n");
    }
    return 0;
}
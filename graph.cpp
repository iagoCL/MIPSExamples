// ConsoleApplication1.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "iostream"
#define TAMAÑO 5
#define TAMAÑO 15
int tamaño;
int NDeFilas;
/*int grafo[TAMAÑO][TAMAÑO]{
	0,		3,		5,		1,		91,	
	3,		0,		91,		91,		9,	
	5,		91,		0,		7,		7,	
	1,		91,		7,		0,		91,	
	91,		9,		7,		91,		0,	
};*/
int grafo[TAMAÑO][TAMAÑO]{
	0,		3,		5,		1,		91,		4,		8,		6,		91,		6,		91,		9,		5,		1,		7,
	3,		0,		91,		91,		9,		91,		4, 		6,		3,		4,		6,		7,		9,		2,		4,
	5,		91,		0,		7,		7,		5,		6,  	8,		91,		5,		5,		8,		7,		3,		5,
	1,		91,		7,		0,		91,		7,		91,  	7,		5,		7,		3,		4,		91,		4,		7,
	91,		9,		7,		91,		0,		9,		1,  	7,		91,		7,		3,		5,		4,		5,		8,
	4,		91,		5,		7,		9,		0,		5,  	4,		5,		91,		2,		2,		5,		6,		9,
	8,		4,		6,		91,		1,		5,		0,		5,		8,		6,		91,		91,		3,		7,		1,
	6,		6,		8,		7,		7,		4,		5,		0,		5,		6,		91,		1,		9,		8,		91,
	91,		3,		91,		5,		91,		5,		8,		5,		0,		5,		3,		7,		6,		9,		3,
	6,		4,		5,		7,		7,		91,		6,		6,		5,		0,		5,		6,		5,		91,		5,
	91,		6,		5,		3,		3,		2,		91,		91,		3,		5,		0,		8,		3,		1,		91,
	9,		7,		8,		4,		5,		2,		91,		1,		7,		6,		8,		0,		1,		3,		6,
	5,		9,		7,		91,		4,		5,		3,		9,		6,		5,		3,		1,		0,		3,		4,
	1,		2,		3,		4,		5,		6,		7,		8,		9,		91,		1,		2,		3,		0,		7,
	7,		4,		5,		7,		8,		9,		1,		91,		3,		5,		91,		6,		4,		7,		0,
};

int tamaño2;
int NDeFilas2;
int grafo2[TAMAÑO][TAMAÑO];
int predecesores[TAMAÑO][TAMAÑO];

int main()
{
	//lo graba en un archivo
	tamaño = sizeof(grafo);
	NDeFilas = TAMAÑO;
	FILE *f2;
	f2 = fopen("array.txt", "wb");
	fwrite(&tamaño,4,1, f2);
	fwrite(&NDeFilas, 4, 1, f2);
	fwrite(&grafo, 1, sizeof(grafo), f2);
	fclose(f2);

	//lee el archivo desde dicho disco
	f2 = fopen("array.txt", "rb");
	fread(&tamaño2, 4, 1, f2);
	fread(&NDeFilas2, 4, 1, f2);
	fread(&grafo2, 1, sizeof(grafo), f2);
	//lo muestra para comprobarlo
	std::cout << tamaño2<<std::endl;
	std::cout << NDeFilas2 << std::endl;
	for (int i = 0; i < NDeFilas2; i++) {
		for (int a = 0; a < NDeFilas2; a++) 
			std::cout << grafo2[i][a] <<"\t";
		std::cout << std::endl;
	}
	//inicializo los predecesores
	for (int i = 0; i < NDeFilas2; i++)
		for (int j = 0; j < NDeFilas2; j++)
			predecesores[i][j] = j;

	std::cout << std::endl << std::endl << std::endl << std::endl;
	//calculo la matriz que buscamos
	for (int k = 0; k < NDeFilas2; k++) 
		for (int i = 0; i < NDeFilas2; i++)
			for (int j = 0; j < NDeFilas2; j++) {
				int peso1 = grafo2[i][k] + grafo2[k][j];
				if (grafo2[i][j] > peso1) {
					grafo2[i][j] = peso1;
					predecesores[i][j] = k;
				}
			
		}
	//la muestra
	std::cout << "Matriz de minimos"<<std::endl;
	for (int i = 0; i < NDeFilas2; i++) {
		for (int a = 0; a < NDeFilas2; a++)
			std::cout << grafo2[i][a] << "\t";
		std::cout << std::endl;
	}
	std::cout << std::endl << std::endl << "Matriz de predecesores" << std::endl;
	for (int i = 0; i < NDeFilas2; i++) {
		for (int a = 0; a < NDeFilas2; a++)
			std::cout << predecesores[i][a] << "\t";
		std::cout << std::endl;
	}
	std::cin >> tamaño2;
    return 0;
}


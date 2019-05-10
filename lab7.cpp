#define ARRAY_LENGTH 5

#include <iostream>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

using namespace std;

int main()
{
	double ar[ARRAY_LENGTH], result[ARRAY_LENGTH], zero = 0;
	cout << "Enter " << ARRAY_LENGTH << " numbers: " << endl;
	for (int i = 0; i<ARRAY_LENGTH; i++)
		cin >> ar[i];
	clock_t start, end;
	start = clock();
	for (int i = 0; i < ARRAY_LENGTH; i++)
	{
		if (ar[i] > 0)
			result[i] = ar[i] * ar[i] * ar[i];
		else
			result[i] = ar[i] * ar[i];
	}
	end = clock();
	cout << "C: ";
	for (int i = 0; i < ARRAY_LENGTH; i++)
	{
		cout << result[i] << "  ";
		result[i] = 0;
	}
	cout << "Time: " << (double)(end - start) / CLK_TCK << "s." << endl;
	start = clock();
	_asm
	{
		finit
		xor esi, esi
		mov ebx, ARRAY_LENGTH

		array_loop:
			fld ar[esi]
			fldz
			fcompp
			fstsw ax
			and ah, 00000001b //8,10,14 - c0, c2, c3, > - 001
			jnz positive

			negative:
				fld ar[esi]
				fmul ar[esi]
				jmp array_loop_end 

			positive:
				fld ar[esi]
				fmul ar[esi]
				fmul ar[esi]
				
			array_loop_end:
				fstp result[esi]

				add esi, 8
				dec ebx
				cmp ebx, 0
				jne array_loop
		fwait
	}
	cout << "FPU: ";
	for (int i = 0; i < ARRAY_LENGTH; i++)
	{
		cout << result[i] << "  ";
	}
	end = clock();
	cout << "Time: " << (double)(end - start) / CLK_TCK << "s." << endl;
	system("pause");
}
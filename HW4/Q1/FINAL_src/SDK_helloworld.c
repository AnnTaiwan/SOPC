/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"

# define MAX_SIZE 13
# define START_REG 508
# define MUL_RST_REG 511
# define FINISH_REG 509

int main()
{
    	init_platform();
    	print("Hello World\n\r");

        int i, j; // index
        volatile int *pointer = (int*)0x43c00000;
        pointer[MUL_RST_REG] = 0; // not reset mul
        pointer[START_REG] = 0; // initialize start to 0
        printf("Initial state:\n(1)MUL_RST:%d\n(2)START:%d\n(3)FINISH:%d\n", pointer[MUL_RST_REG],pointer[START_REG],pointer[FINISH_REG]);


        pointer[MUL_RST_REG] = 1; // reset mul
        printf("Reset the data....\n(1)MUL_RST:%d\n(2)START:%d\n(3)FINISH:%d\n", pointer[MUL_RST_REG],pointer[START_REG],pointer[FINISH_REG]);

        pointer[MUL_RST_REG] = 0; // not reset mul
        printf("Finish reseting the data.\n(1)MUL_RST:%d\n(2)START:%d\n(3)FINISH:%d\n", pointer[MUL_RST_REG],pointer[START_REG],pointer[FINISH_REG]);

        // initialize the mat_A and mat_B
        for(i = 0; i < 169; i++)// matrix A
        {
            pointer[i] = 0;
        }
        for(i = 169; i < 338; i++)// matrix B
        {
             pointer[i] = 0;
        }
        // input the data here, not used space assigned 0
        // assign the data for matrix A and B (use register0~168 and 169~337)
        for(i = 0; i < 169; i++)// matrix A
        {
        	pointer[i] = i;
        }
        for(i = 169; i < 338; i++)// matrix B
        {
            pointer[i] = i;
        }

        // see the input matrix
        printf("Matrix A:\n");
        for(i = 0; i < MAX_SIZE; i++)// matrix B
        {
        	for(j = 0; j < MAX_SIZE; j++)// matrix B
        	{
        		printf("%d ", pointer[i * MAX_SIZE + j]);
        	}
        	printf("\n");
        }
        printf("Matrix B:\n");
        for(i = 0; i < MAX_SIZE; i++)// matrix B
        {
           for(j = 0; j < MAX_SIZE; j++)// matrix B
           {
            	printf("%d ", pointer[(i * MAX_SIZE + j) + 169]);
            }
            printf("\n");
        }
        // test Matrix Multiplication
        // Before start
        printf("Prepare to begin the calculation.\n(1)MUL_RST:%d\n(2)START:%d\n(3)FINISH:%d\n", pointer[MUL_RST_REG],pointer[START_REG],pointer[FINISH_REG]);
        // let start = 1, start to calculate
        pointer[START_REG] = 1;
        printf("Start to calculate.\n(1)MUL_RST:%d\n(2)START:%d\n(3)FINISH:%d\n", pointer[MUL_RST_REG],pointer[START_REG],pointer[FINISH_REG]);
        int ok = 1; // make sure printing result after finish is set to 1.
        while(ok){
        	printf("In the loop.\n(1)MUL_RST:%d\n(2)START:%d\n(3)FINISH:%d\n", pointer[MUL_RST_REG],pointer[START_REG],pointer[FINISH_REG]);
			if(pointer[FINISH_REG] == 1)
			{
				printf("----------------------------------\n");
				printf("Finish the calculation.\nResult matrix:\n");
				for(i = 0; i < MAX_SIZE; i++) // matrix B
				{
					for(j = 0; j < MAX_SIZE; j++)// matrix B
					{
						printf("%d ", pointer[(i * MAX_SIZE + j) + 338]);
					}
					printf("\n");
				}
				printf("Finish calculating.\n");
				printf("----------------------------------\n");
				ok = 0;
			}
        }
		cleanup_platform();
		return 0;
}


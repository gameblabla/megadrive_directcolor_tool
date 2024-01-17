#include <genesis.h>


#define NUM_FILES 7
extern char *fileName[NUM_FILES];
extern int fileSize[NUM_FILES];
extern int filePtr[NUM_FILES];

extern void dma_screen(unsigned short *buffer);

int main()
{
	int curr = 0;
	/*
	VDP_setHilightShadow(1);
	*/

    while(1)
    {
        dma_screen((unsigned short *)filePtr[curr]);
        curr = (curr + 1) % 7;
        //VDP_waitVSync();
    }

    return 0;
}



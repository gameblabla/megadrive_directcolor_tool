/* SEGA MegaDrive support code */
/* by Chilly Willy */

        .text
        .align  2


/* short get_pad(short pad) */
/* return buttons for selected pad */
/* entry: arg = pad index (0 or 1) */
/* exit:  d0 = pad value (0 0 0 1 M X Y Z S A C B R L D U) or (0 0 0 0 0 0 0 0 S A C B R L D U) */
        .global get_pad
get_pad:
        move.l  d2,-(sp)
        move.l  8(sp),d0        /* first arg is pad number */
        cmpi.w  #1,d0
        bhi     no_pad
        add.w   d0,d0
        addi.l  #0xA10003,d0    /* pad control register */
        movea.l d0,a0
        bsr.b   get_input       /* - 0 s a 0 0 d u - 1 c b r l d u */
        move.w  d0,d1
        andi.w  #0x0C00,d0
        bne.b   no_pad
        bsr.b   get_input       /* - 0 s a 0 0 d u - 1 c b r l d u */
        bsr.b   get_input       /* - 0 s a 0 0 0 0 - 1 c b m x y z */
        move.w  d0,d2
        bsr.b   get_input       /* - 0 s a 1 1 1 1 - 1 c b r l d u */
        andi.w  #0x0F00,d0      /* 0 0 0 0 1 1 1 1 0 0 0 0 0 0 0 0 */
        cmpi.w  #0x0F00,d0
        beq.b   common          /* six button pad */
        move.w  #0x010F,d2      /* three button pad */
common:
        lsl.b   #4,d2           /* - 0 s a 0 0 0 0 m x y z 0 0 0 0 */
        lsl.w   #4,d2           /* 0 0 0 0 m x y z 0 0 0 0 0 0 0 0 */
        andi.w  #0x303F,d1      /* 0 0 s a 0 0 0 0 0 0 c b r l d u */
        move.b  d1,d2           /* 0 0 0 0 m x y z 0 0 c b r l d u */
        lsr.w   #6,d1           /* 0 0 0 0 0 0 0 0 s a 0 0 0 0 0 0 */
        or.w    d1,d2           /* 0 0 0 0 m x y z s a c b r l d u */
        eori.w  #0x1FFF,d2      /* 0 0 0 1 M X Y Z S A C B R L D U */
        move.w  d2,d0
        move.l  (sp)+,d2
        rts

/* 3-button/6-button pad not found */
no_pad:
        .ifdef  HAS_SMS_PAD
        move.b  (a0),d0         /* - 1 c b r l d u */
        andi.w  #0x003F,d0      /* 0 0 0 0 0 0 0 0 0 0 c b r l d u */
        eori.w  #0x003F,d0      /* 0 0 0 0 0 0 0 0 0 0 C B R L D U */
        .else
        move.w  #0xF000,d0      /* SEGA_CTRL_NONE */
        .endif
        move.l  (sp)+,d2
        rts

/* read single phase from controller */
get_input:
        move.b  #0x00,(a0)
        nop
        nop
        move.b  (a0),d0
        move.b  #0x40,(a0)
        lsl.w   #8,d0
        move.b  (a0),d0
        rts

/* void clear_screen(void)  */
/* clear the name table for plane B */
        .global clear_screen
clear_screen:
        moveq   #0,d0
        lea     0xC00000,a0
        move.w  #0x8F02,4(a0)           /* set INC to 2 */
        move.l  #0x60000003,d1          /* VDP write VRAM at 0xE000 (scroll plane B) */
        move.l  d1,4(a0)                /* write VRAM at plane B start */
        move.w  #64*32-1,d1
1:
        move.w  d0,(a0)                 /* clear name pattern */
        dbra    d1,1b
        rts

/* Any following functions need to be run from ram */

        .data

        .align  4

/* void dma_screen(short *buffer); */
/* dma buffer to background cmap entry */
/* By Chilly Willy */
        .global dma_screen
dma_screen:
        move.l  4(sp),d0                /* buffer */
        movem.l d2-d7/a2-a6,-(sp)
        move.w  #0x2700,sr

        /* self-modifying code for buffer start */
        lsr.l   #1,d0                   /* word bus */
        move.b  d0,dma_src+3
        lsr.l   #8,d0
        move.b  d0,dma_src+5
        lsr.l   #8,d0
        andi.w  #0x007F,d0
        move.b  d0,dma_src+9

        /* clear palette */
        moveq   #0,d0
        lea     0xC00000,a2
        lea     0xC00004,a3
        moveq   #31,d1
        move.l  #0xC0000000,(a3)        /* write CRAM address 0 */
0:
        move.l  d0,(a2)                 /* clear palette */
        dbra    d1,0b

        /* init VDP regs */
        move.w  #0x8AFF,(a3)            /* HINT value is 255 */
        move.w  #0x8F00,(a3)            /* AutoIncrement is 0 !!! */

        /* loop - turn on display and wait for vblank */
dma_loop:
        move.w  #0x8154,(a3)            /* Turn on Display */
        move.l  #0x40000000,(a3)        /* write to vram */
1:
        btst    #3,1(a3)
        beq.b   1b                      /* wait for VB */
2:
        btst    #3,1(a3)
        bne.b   2b                      /* wait for not VB */

        move.w  d0,(a2)
        move.w  d0,(a2)
        move.w  d0,(a2)
        move.w  d0,(a2)
        move.w  d0,(a2)
        move.w  d0,(a2)
        move.w  d0,(a2)
        move.w  d0,(a2)
        move.w  d0,(a2)
        move.w  d0,(a2)
        move.w  d0,(a2)
        move.w  d0,(a2)
        move.w  d0,(a2)

        nop
        nop
        nop
        nop

        /* Execute DMA */
        move.l  #0x934094ad,(a3)        /* DMALEN LO/HI = 0xAD40 (198*224) */
dma_src:
        move.l  #0x95729603,(a3)        /* DMA SRC LO/MID */
        move.l  #0x97008114,(a3)        /* DMA SRC HI/MODE, Turn off Display */
        move.l  #0xC0000080,(a3)        /* dest = write cram => start DMA */
        /* CPU is halted until DMA is complete */

        /* do other tasks here */
        pea     0.w
        jsr     get_pad
        addq.l  #4,sp
        andi.w  #0x0070,d0
        bne.b   exit_dma
        moveq   #0,d0
        bra.b   dma_loop
exit_dma:
        pea     0.w
        jsr     get_pad
        addq.l  #4,sp
        andi.w  #0x0070,d0
        movem.l (sp)+,d2-d7/a2-a6
        rts


        .text

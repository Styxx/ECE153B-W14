/********************************************************/
/*                                                      */
/*  ECE153B --- Sample Interrupt Overloading Program    */
/*          Z:\Classdocs\sample.c                       */
/*                                                      */
/*  Run via SPX "1) Download & Execute" Command         */
/*                                                      */
/********************************************************/

#include <stdio.h>

#define BRANCH_TO(x) (0x60000000 | (int)(x))
#define at(x,y) printf("\33[%d;%dH",(y),(x))

void c_int99();            /* timer 1 interrupt routine */

int mytime,starttime;      /* 100Hz timecount & startcnt*/
int period;                /* used in timer period setup*/

/* macro to write lower 16-bits of 'x' to LEDs          */
#define LEDS(x) *(volatile int*)0x101000 = (x)

/* address of timer #1 control register array           */
#define TIMER1  ((volatile int*)0x808030)

void set_timer1(int period)   /* to set timer#1 period  */
{
    TIMER1[0] = 0x203; 	 /* hold timer, choose options  */	
    TIMER1[8] = period;	 /* set T1 period in H1/2 cycles*/
    TIMER1[0] = 0x2c3; 	 /* make it run                 */	
}

void c_int99()			/* timer interrupt routine*/
{
    asm("  push dp");
    asm("  ldp _mytime"); /* ensure data addressibility */
    mytime++;

/* whatever you want here ... but no printf() or other std I/O   */
/* The amount of code in an interrupt routine should be minimal. */

    LEDS( mytime );
    asm("  pop dp");
}

main()
{
	int t;
	char line[100];

	mytime  = 0;
	period  = 10000;

	/* set timer to run at 5M/period interrupts per sec	*/
	set_timer1(period);

 	*(int*)0x809fca = BRANCH_TO(c_int99); /* install TINT1 vector */

	*(volatile int*)0x104001=1;	  /* enable bus transceivers   */
    
	fputs("\033[2J",stdout);	  /* erase screen, home cursor */

	at(2,3);                      /* cursor (X,Y) to 2,3       */
	fputs("ECE 153B Experiment #3:", stdout);
	at(2,10);
	fputs("Hit ENTER to return to SPX",stdout);
	fflush(stdout);
	fgets(line,80,stdin);

	*(int*)0x104000 = 1;  		/* disable transceivers     */

    asm(" ldi 0,ie");	        /* mask ALL interrupts      */
	asm(" ldi 1,if");   		/* select proper boot space */
	asm(" br  45h");    		/* enter boot loader        */

	exit(0);	/* not needed .... we are booting back TO SPX */
}

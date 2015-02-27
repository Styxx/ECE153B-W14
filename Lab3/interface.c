// Basic interface for DAC.v

#include <stdio.h>

main () {
	char get;
	int amp;
	int k1,c1,k2,c2;
	int freq;
	
	*(volatile int*) 0x104001 = 0;				// Turn on transceivers
	
	do {
		get = 
		printf("Press S for sine wave\n");
		printf("Press T for triangle wave\n");
		printf("Press A to change wave's amplitude\n");
		printf("Press F to change wave's frequency\n");
		printf("Press E to exit\n");
		scanf(%c,get);
		
		if(get == 'S') {
			*(volatile int*) 0x10a000 = 0;		// Write to h10a - sinewave
		}
		
		else if(get == 'T') {
			*(volatile int*) 0x10b000 = 0;		// Write to h10b - trianglewave
		}
		
		else if(get == 'A') {
			printf("Enter new amplitude (0 <= int <= 5)\n");
			scanf(%i, amp);
			if ((amp < 0) || (amp >= 6)) {
				printf("Invalid amplitude\n");
			}
			else {
				for (c1 = 2; c1 >= 0; c1--) {					          // 3 bit reg
					k1 = amp >> c1;
					if(k1 & 1) { *(volatile int*) 0x10d000 = 0; } // Write to 10d - left shift 1
					else { *(volatile int*) 0x10c000 = 0; }		    // Write to 10c - left shift 0
				}
			}
		}
		
		else if(get == 'F') {
			printf("Enter new frequency (0 < int < 10kHz)\n");
			scanf(%i, freq);
			if ((freq < 0) || (freq > 10000)) {
				printf("Invalid frequency\n");
			}
			else {
				for (c2 = 31; c2 >= 0; c2--) {					         // 32 bit reg
					k2 = freq >> c2;
					if (k2 & 1) { *(volatile int*) 0x10f000 = 0; } // Write to 10f - left shift 1
					else { *(volatile int*) 0x10e000 = 0; }		     // Write to 10e - left shift 0
				}
			}
		}
		
		else if(get == 'E') {
			printf("Exiting\n");	//Do nothing, loop will break
		}
		
		else {
			printf("Invalid choice. Choose again.\n");
		}
		
		
	} while (get != 'E');						      // While not exiting, do loop
	
	*(volatile int*) 0x104000 = 0;				// Turn off transcievers
	exit(0);								            	// Unnecessary, since SPX, but meh.

}

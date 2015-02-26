// Code your design here
/***************************************************************/
/*  DAC verilog												   */
/*  Sahil Bissessur, Vincent "Styxx" Chang, Enrique Gutierrez  */
/*  Given address 0x10dXXX, latch D7-D0 to output (DAC chip)   */
/***************************************************************/


module DAC(add, clk, strobe, WR, Dout);

	input wire [11:0] add;
	input wire clk;
	input wire strobe;
  
	output reg WR;			//Equiv of ready?
	output reg [7:0] Dout;

	//reg [7:0] Din = 8'b10000000;
	//reg [7:0] preDin = 8'b01111111;
	reg [7:0] Din = 8'b00000000;
	reg up = 1;
	reg [31:0] counter = 0;
	reg [7:0] arb = 0;

	reg [7:0] LUT [0:255];
	LUT[0]=128; LUT[1]=131;LUT[2]=134;LUT[3]=137;LUT[4]=141;
	LUT[5]=144;LUT[6]=147;LUT[7]=150;LUT[8]=153;LUT[9]=156;
	LUT[10]=159;LUT[11]=162;LUT[12]=165;LUT[13]=168;LUT[14]=171;
	LUT[15]=174;LUT[16]=177;LUT[17]=180;LUT[18]=183;LUT[19]=186;
	LUT[20]=188;LUT[21]=191;LUT[22]=194;LUT[23]=196;LUT[24]=199;
	LUT[25]=202;LUT[26]=204;LUT[27]=207;LUT[28]=209;LUT[29]=212;
	LUT[30]=214;LUT[31]=216;LUT[32]=219;LUT[33]=221;LUT[34]=223;
	LUT[35]=225;LUT[36]=227;LUT[37]=229;LUT[38]=231;LUT[39]=233;
	LUT[40]=234;LUT[41]=236;LUT[42]=238;LUT[43]=239;LUT[44]=241;
	LUT[45]=242;LUT[46]=244;LUT[47]=245;LUT[48]=246;LUT[49]=247;
	LUT[50]=249;LUT[51]=250;LUT[52]=250;LUT[53]=251;LUT[54]=252;
	LUT[55]=253;LUT[56]=254;LUT[57]=254;LUT[58]=255;LUT[59]=255;
	LUT[60]=255;LUT[61]=256;LUT[62]=256;LUT[63]=256;LUT[64]=256;
	LUT[65]=256;LUT[66]=256;LUT[67]=256;LUT[68]=255;LUT[69]=255;
	LUT[70]=255;LUT[71]=254;LUT[72]=254;LUT[73]=253;LUT[74]=252;
	LUT[75]=251;LUT[76]=250;LUT[77]=250;LUT[78]=249;LUT[79]=247;
	LUT[80]=246;LUT[81]=245;LUT[82]=244;LUT[83]=242;LUT[84]=241;
	LUT[85]=239;LUT[86]=238;LUT[87]=236;LUT[88]=234;LUT[89]=233;
	LUT[90]=231;LUT[91]=229;LUT[92]=227;LUT[93]=225;LUT[94]=223;
	LUT[95]=221;LUT[96]=219;LUT[97]=216;LUT[98]=214;LUT[99]=212;
	LUT[100]=209;LUT[101]=207;LUT[102]=204;LUT[103]=202;LUT[104]=199;
	LUT[105]=196;LUT[106]=194;LUT[107]=191;LUT[108]=188;LUT[109]=186;
	LUT[110]=183;LUT[111]=180;LUT[112]=177;LUT[113]=174;LUT[114]=171;
	LUT[115]=168;LUT[116]=165;LUT[117]=162;LUT[118]=159;LUT[119]=156;
	LUT[120]=153;LUT[121]=150;LUT[122]=147;LUT[123]=144;LUT[124]=141;
	LUT[125]=137;LUT[126]=134;LUT[127]=131;LUT[128]=128;LUT[129]=125;
	LUT[130]=122;LUT[131]=119;LUT[132]=115;LUT[133]=112;LUT[134]=109;
	LUT[135]=106;LUT[136]=103;LUT[137]=100;LUT[138]=97;LUT[139]=94;
	LUT[140]=91;LUT[141]=88;LUT[142]=85;LUT[143]=82;LUT[144]=79;
	LUT[145]=76;LUT[146]=73;LUT[147]=70;LUT[148]=68;LUT[149]=65;
	LUT[150]=62;LUT[151]=60;LUT[152]=57;LUT[153]=54;LUT[154]=52;
	LUT[155]=49;LUT[156]=47;LUT[157]=44;LUT[158]=42;LUT[159]=40;
	LUT[160]=37;LUT[161]=35;LUT[162]=33;LUT[163]=31;LUT[164]=29;
	LUT[165]=27;LUT[166]=25;LUT[167]=23;LUT[168]=22;LUT[169]=20;
	LUT[170]=18;LUT[171]=17;LUT[172]=15;LUT[173]=14;LUT[174]=12;
	LUT[175]=11;LUT[176]=10;LUT[177]=9;LUT[178]=7;LUT[179]=6;
	LUT[180]=6;LUT[181]=5;LUT[182]=4;LUT[183]=3;LUT[184]=2;
	LUT[185]=2;LUT[186]=1;LUT[187]=1;LUT[188]=1;LUT[189]=0;
	LUT[190]=0;LUT[191]=0;LUT[192]=0;LUT[193]=0;LUT[194]=0;
	LUT[195]=0;LUT[196]=1;LUT[197]=1;LUT[198]=1;LUT[199]=2;
	LUT[200]=2;LUT[201]=3;LUT[202]=4;LUT[203]=5;LUT[204]=6;
	LUT[205]=6;LUT[206]=7;LUT[207]=9;LUT[208]=10;LUT[209]=11;
	LUT[210]=12;LUT[211]=14;LUT[212]=15;LUT[213]=17;LUT[214]=18;
	LUT[215]=20;LUT[216]=22;LUT[217]=23;LUT[218]=25;LUT[219]=27;
	LUT[220]=29;LUT[221]=31;LUT[222]=33;LUT[223]=35;LUT[224]=37;
	LUT[225]=40;LUT[226]=42;LUT[227]=44;LUT[228]=47;LUT[229]=49;
	LUT[230]=52;LUT[231]=54;LUT[232]=57;LUT[233]=60;LUT[234]=62;
	LUT[235]=65;LUT[236]=68;LUT[237]=70;LUT[238]=73;LUT[239]=76;
	LUT[240]=79;LUT[241]=82;LUT[242]=85;LUT[243]=88;LUT[244]=91;
	LUT[245]=94;LUT[246]=97;LUT[247]=100;LUT[248]=103;LUT[249]=106;
	LUT[250]=109;LUT[251]=112;LUT[252]=115;LUT[253]=119;LUT[254]=122;
	LUT[255]=125;

	
	parameter starting =	2'b00;
	parameter pre_latch =	2'b01;
	parameter latch =	2'b10;
	parameter post_latch =	2'b11;

	reg [1:0] state = pre_latch;
	
	// Process: Address valid --> WR low --> Data valid
	
	always @ (negedge clk) begin
	
		case (state)
			// Starting idle state
			// Checks for address 0x10d and sends to pre-latch if found.
			starting:
				begin
					// Output
					//Dout <= 7'bz;
					
					// Next State
					//if((add[11:0] == 12'h10d) && (~strobe)) begin
						state <= pre_latch;
						WR <= 1'b0;
					//end
						
				end
			
			// Pre-latch state
			// Prepares Din and sets WR to 0
			pre_latch:
				begin
					// Output
					/*if (counter == 200) begin					// Smaller counter = higher frequency
						counter <= 0;
						if (up == 1) begin
							Din <= Din + 1;
							if (Din == 8'b11111110) begin
								up <= 0;
							end
						end
						else begin
							Din <= Din - 1;
							if (Din == 8'b00000001)	begin
								up <= 1;
							end
						end
						
					end
					else begin
						counter <= counter + 1;
					end*/
					if (counter == 200) begin
						counter <= 0;
						if (up == 1) begin
							Din <= LUT[arb];
							arb <= arb + 1;	
						end
					end
					else begin
						counter <= counter + 1;
					end
					
					// Next State
					state <= latch;
					
				end
		
			// Latch State
			// Latches the value of Din to Dout
			latch:
				begin
					// Output
					Dout <= Din;
					
					// Next State
					state <= post_latch;
				end
			
			// Post-Latch State
			// Sets WR back to 1 before going back to idle.
			post_latch:
				begin
					// Output
					WR <= 1'b1;
					
					// Next State
					state <= pre_latch;
				
				end
				
		endcase
	
	end
	
endmodule

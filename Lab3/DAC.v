/***************************************************************/
/*  DAC verilog				      		      				   */
/*  Sahil Bissessur, Vincent "Styxx" Chang, Enrique Gutierrez  */
/*  Given address 0x10dXXX, latch D7-D0 to output (DAC chip)   */
/***************************************************************/


module DAC(add, clk, strobe, Dout);

	input wire [11:0] add;
	input wire clk;
	input wire strobe;
  
	output reg [7:0] Dout;

	reg [7:0] Din = 8'b00000000;
	
	reg up = 1;						// If increasing or decreasing in tri_latch
	reg [7:0] arb = 0;				// Increment-er through sine LUT
	
	// To change the counter, we left shift into it. This will then change the frequency of the wave.
	// Larger counter = lower frequency.
	// Need to find formula to make this work such that given a frequency,
	// counter changes to correct value (DSP runs on 10Mhz)
	reg [31:0] counter = 0;
	reg [31:0] period = 32'd200;

	
	// To change the amplitude, we left shift into it
	// This will then change the amplitude of the wave (MAX is 5)
	// Make it so that Dout = Din/Amplitude?
	// Or have amplitude be a percentage and we multiply that by Din?
	reg [2:0] amplitude = 3'b001; // this needs to be changeable
	

	//http://jacaheyo.blogspot.com/2012/06/implementing-lut-in-verilog.html
	reg [7:0] LUT [0:255] = {8'd128,8'd131,8'd134,8'd137,8'd141,8'd144,8'd147,
	8'd150,8'd153,8'd156,8'd159,8'd162,8'd165,8'd168,8'd171,8'd174,8'd177,8'd180,
	8'd183,8'd186,8'd188,8'd191,8'd194,8'd196,8'd199,8'd202,8'd204,8'd207,8'd209,
	8'd212,8'd214,8'd216,8'd219,8'd221,8'd223,8'd225,8'd227,8'd229,8'd231,8'd233,
	8'd234,8'd236,8'd238,8'd239,8'd241,8'd242,8'd244,8'd245,8'd246,8'd247,8'd249,
	8'd250,8'd250,8'd251,8'd252,8'd253,8'd254,8'd254,8'd255,8'd255,8'd255,8'd256,
	8'd256,8'd256,8'd256,8'd256,8'd256,8'd256,8'd255,8'd255,8'd255,8'd254,8'd254,
	8'd253,8'd252,8'd251,8'd250,8'd250,8'd249,8'd247,8'd246,8'd245,8'd244,8'd242,
	8'd241,8'd239,8'd238,8'd236,8'd234,8'd233,8'd231,8'd229,8'd227,8'd225,8'd223,
	8'd221,8'd219,8'd216,8'd214,8'd212,8'd209,8'd207,8'd204,8'd202,8'd199,8'd196,
	8'd194,8'd191,8'd188,8'd186,8'd183,8'd180,8'd177,8'd174,8'd171,8'd168,8'd165,
	8'd162,8'd159,8'd156,8'd153,8'd150,8'd147,8'd144,8'd141,8'd137,8'd134,8'd131,
	8'd128,8'd125,8'd122,8'd119,8'd115,8'd112,8'd109,8'd106,8'd103,8'd100,8'd97,
	8'd94,8'd91,8'd88,8'd85,8'd82,8'd79,8'd76,8'd73,8'd70,8'd68,8'd65,8'd62,8'd60,
	8'd57,8'd54,8'd52,8'd49,8'd47,8'd44,8'd42,8'd40,8'd37,8'd35,8'd33,8'd31,8'd29,
	8'd27,8'd25,8'd23,8'd22,8'd20,8'd18,8'd17,8'd15,8'd14,8'd12,8'd11,8'd10,8'd9,
	8'd7,8'd6,8'd6,8'd5,8'd4,8'd3,8'd2,8'd2,8'd1,8'd1,8'd1,8'd0,8'd0,8'd0,8'd0,
	8'd0,8'd0,8'd0,8'd1,8'd1,8'd1,8'd2,8'd2,8'd3,8'd4,8'd5,8'd6,8'd6,8'd7,8'd9,
	8'd10,8'd11,8'd12,8'd14,8'd15,8'd17,8'd18,8'd20,8'd22,8'd23,8'd25,8'd27,8'd29,
	8'd31,8'd33,8'd35,8'd37,8'd40,8'd42,8'd44,8'd47,8'd49,8'd52,8'd54,8'd57,8'd60,
	8'd62,8'd65,8'd68,8'd70,8'd73,8'd76,8'd79,8'd82,8'd85,8'd88,8'd91,8'd94,8'd97,
	8'd100,8'd103,8'd106,8'd109,8'd112,8'd115,8'd119,8'd122,8'd125};
	//reg [7:0] LUT [0:255];
	//LUT[0] = 8'd128;
	
	// Previous LUT work saved in new 1 (see tabs above)

	// If you need to add more states, then don't forget to increase
	// the bit count if necessary
	parameter starting =	2'b00;
	parameter tri_latch =	2'b01;
	parameter sine_latch = 	2'b10;
	parameter latch =		2'b11;

	// If you're only testing a specific latch, set it to that latch
	// Otherwise, if you're testing the entire thing, set it to starting
	reg [1:0] state = tri_latch;
	
	always @ (negedge clk) begin
	
		case (state)
			// Starting idle state
			// Checks for addresses and executes according action
			starting:
				begin
					
					// Next State					
					if ((add[11:0] == 12'h10a) && (~strobe)) begin
						state <= sine_latch;
					end
					if ((add[11:0] == 12'h10b) && (~strobe)) begin
						state <= tri_latch;
					end
					
					if ((add[11:0] == 12'h10c) && (~strobe)) begin
						amplitude <= amplitude << 1;
						amplitude[0] <= 0;
					
					end
					
					if ((add[11:0] == 12'h10d) && (~strobe)) begin
						amplitude <= amplitude << 1;
						amplitude[0] <= 1;
					end
					
					if ((add[11:0] == 12'h10e) && (~strobe)) begin
						period <= period << 1;
						period[0] <= 0;
					end
					/* //Unknown as to why inserting this segment of code ruins the JEDEC file and reins compiliation
					if ((add[11:0] == 12'h10f) && (~strobe)) begin
						period <= period << 1;
						period[0] <= 1;
					end*/
					
				end
			
			// Tri_latch
			// Outputs a triangle wave
			// Currently disregards amplitude changes
			tri_latch:
				begin
					// Output
					if (counter == 200) begin		// Smaller counter = higher frequency
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
					end
					
					
					// Next State
					state <= latch;
					
				end
			
			// Sine latch
			// Outputs a sin wave
			// Currently disregards amplitude changes
			sine_latch:
				begin
					// Sine wave
					if (counter == period) begin
						counter <= 0;
						Din <= LUT[arb];
						arb <= arb + 1;	
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
					// If you're only testing a specific latch, set it to that latch
					// Otherwise, if you're testing the entire thing, set it to starting
					state <= tri_latch;
				end
			
				
		endcase
	
	end
	
endmodule

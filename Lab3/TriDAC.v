// DAC that outputs a triangle wave

/***************************************************************/
/*  Triangle DAC verilog												               */
/*  Sahil Bissessur, Vincent "Styxx" Chang, Enrique Gutierrez  */
/*  Given address 0x10dXXX, latch D7-D0 to output (DAC chip)   */
/***************************************************************/


module DAC(add, clk, strobe, WR, Dout);

	input wire [11:0] add;
	input wire clk;
	input wire strobe;
  
	output reg WR;			//Equiv of ready?
	output reg [7:0] Dout;

	reg [7:0] Din = 8'b00000000;
	reg up = 1;
	reg [31:0] counter = 0;

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
			// CURRENTLY UNUSED
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
			pre_latch:
				begin
					// Output
					if (counter == 200) begin					// Smaller counter = higher frequency
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

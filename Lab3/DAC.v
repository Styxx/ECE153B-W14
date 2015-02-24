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

	reg [7:0] Din = 8'b10000000;
	reg [7:0] preDin = 8'b01111111;

	
	parameter starting =	2'b00;
	parameter pre_latch =	2'b01;
	parameter latch =		2'b10;
	parameter post_latch =	2'b11;

	reg [1:0] state = starting;
	
	// Process: Address valid --> WR low --> Data valid
	
	always @ (negedge clk) begin
	
		case (state)
			// Starting idle state
			// Checks for address 0x10d and sends to pre-latch if found.
			starting:
				begin
					// Output
					Dout <= 7'bz;
					
					// Next State
					if((add[11:0] == 12'h10d) && (~strobe)) begin
						state <= pre_latch;
					end
						
				end
			
			// Pre-latch state
			// Prepares Din and sets WR to 0
			pre_latch:
				begin
					// Output
					WR = 1'b0;
					
					// Change Din to next value
					if (Din == 8'b00000000) begin			// Can only go up
						Din <= 8'b00000001;
						preDin <= 8'b00000000;
					end
					else if (Din == 8'b00000001) begin
						if (preDin == 8'b00000000) begin	// Going up
							Din <= 8'b01111111;
							preDin = 8'b00000001;
						end
						else begin		// Going down
							Din <= 8'b00000000;
							preDin = 8'b00000001;
						end
					end
					else if (Din = 8'b01111111) begin
						if (preDin == 8'b00000001) begin	// Going up
							Din <= 8'b10000000;
							preDin <= 8'b01111111;
						end
						else begin		// Going down
							Din <= 8'b00000001;
							preDin <= 8'b01111111;
						end
					end
					else if (Din = 8'b10000000) begin
						if (preDin == 8'b01111111) begin	// Going up
							Din <= 8'b10000001;
							preDin <= 8'b10000000;
						end
						else begin		// Going down
							Din <= 8'b01111111;
							preDin <= 8'b10000000;
						end
					end
					else if (Din = 8'b10000001) begin
						if (preDin == 8'b10000000) begin	// Going up
							Din <= 8'b11111111;
							preDin <= 8'b10000001;
						end
						else begin		//Going down
							Din <= 8'b10000000;
							preDin <= 8'b10000001;
						end
					end
					else begin	//Din = 8'b11111111			Can only go down
						Din = 8'b10000001;
						preDin = 8'b11111111;
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
					state <= starting;
				
				end
				
		endcase
	
	end
	
endmodule

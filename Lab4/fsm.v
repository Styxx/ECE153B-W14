module fsm(interrupt, pwmout, data, ready, add, clk, strobe, RW, chA, chB);
	input wire [11:0] add;
  	input wire clk;
  	
  	//Handshaking
  	input strobe;
	input RW;
  	output reg ready;
	reg enable;
  	
  	// From the motor
  	input wire chA;
  	input wire chB;
	
	// Output (interrupt)
  	output reg interrupt = 1;
  	output reg redMotorWire;
  	output reg blackMotorWire;
  	output reg data;				// The data bit 10f reads
		
	reg [15:0] counter = 0;
	reg [4:0] last5pos = 0;

	// PWM stuff
	reg [8:0] pwm = 0;
	reg [8:0] pwmcounter = 0;
	output reg pwmout = 1;
 
	// State machines
	// State machine to check motor direction
	parameter pre_starting				=	3'b000;
	parameter state00				=	3'b001;
	parameter state01				=	3'b010;
	parameter state10				=	3'b011;
	parameter state11				=	3'b100;
	reg [2:0] direction = pre_starting;
	
	// State machine for handshaking
	parameter starting 				= 	2'b00;
	parameter strb_low				= 	2'b11;
	parameter rdy_low				=	2'b01;
	parameter rdy_hi				=	2'b10;
	reg [1:0] handshaking = starting;
  	
  	
  	always @ (negedge clk) begin

		interrupt <= 1'b1;
  		
		/* DIRECTION STATE MACHINE */
		case(direction)
			pre_starting: begin
				if((chA == 0) && (chB == 0)) begin
					direction <= state00;
				end
				else if((chA == 0) && (chB == 1)) begin
					direction <= state01;
				end
				else if((chA == 1) && (chB == 0)) begin
					direction <= state10;
				end
				else if((chA == 1) && (chB == 1)) begin
					direction <= state11;
				end
			end

				state00: begin
				if((chA == 0) && (chB == 0)) begin	//NC
					direction <= state00;
				end
				else if((chA == 0) && (chB == 1)) begin	//CW
					interrupt <= 1'b0;
					counter <= counter + 1;
					last5pos <= {last5pos[3:0], 1'b1};
					direction <= state01;
				end
				else if((chA == 1) && (chB == 0)) begin	//cCW
					interrupt <= 1'b0;
					counter <= counter - 1;
					last5pos <= {last5pos[3:0], 1'b0};
					direction <= state10;
				end
				else if((chA == 1) && (chB == 1)) begin	//Err
					direction <= state11;
				end
			end

			state01: begin
				if((chA == 0) && (chB == 0)) begin	//cCW
					interrupt <= 1'b0;
					counter <= counter - 1;
					last5pos <= {last5pos[3:0], 1'b0};
					direction <= state00;
				end
				else if((chA == 0) && (chB == 1)) begin	//NC
					direction <= state01;
				end
				else if((chA == 1) && (chB == 0)) begin //Err
					direction <= state10;
				end
				else if((chA == 1) && (chB == 1)) begin	//CW
					interrupt <= 1'b0;
					counter <= counter + 1;
					last5pos <= {last5pos[3:0], 1'b1};
					direction <= state11;
				end
							
			end
			
			state10: begin
				if((chA == 0) && (chB == 0)) begin	//CW
					interrupt <= 1'b0;
					counter <= counter + 1;
					last5pos <= {last5pos[3:0], 1'b1};
					direction <= state00;
				end
				else if((chA == 0) && (chB == 1)) begin	//Err
					direction <= state01;
				end
				else if((chA == 1) && (chB == 0)) begin //NC
					direction <= state10;
				end
				else if((chA == 1) && (chB == 1)) begin	//cCW
					interrupt <= 1'b0;
					counter <= counter - 1;
					last5pos <= {last5pos[3:0], 1'b0};
					direction <= state11;
				end
			
			end

			state11: begin
				if((chA == 0) && (chB == 0)) begin	//Err
					direction <= state00;
				end
				else if((chA == 0) && (chB == 1)) begin	//cCw
					interrupt <= 1'b0;
					counter <= counter - 1;
					last5pos <= {last5pos[3:0], 1'b0};
					direction <= state01;
				end
				else if((chA == 1) && (chB == 0)) begin //CW
					interrupt <= 1'b0;
					counter <= counter + 1;
					last5pos <= {last5pos[3:0], 1'b1};
					direction <= state10;
				end
				else if((chA == 1) && (chB == 1)) begin	//NC
					direction <= state11;
				end
			end
		endcase
		
		
		/* ADDRESS CHECK */
		if (((add == 12'h10c) || (add == 12'h10d) || (add == 12'h10e) || (add == 12'h10f))
			&& (~strobe)) begin
			
			case(add)
				// Going clockwise
				12'h10c: begin
					// Handshake
					enable <= 1'b1;
				end
				
				// Going counter-clockwise
				12'h10d: begin
					// Handshake
					enable <= 1'b1;			
				end
				
				// Left shift in 0 for PWM
				12'h10e: begin
					if ((handshaking == starting) && (RW == 0)) begin
						pwm <= {pwm[7:0],1'b0}; 				//Left shift bit 0 in here
						pwmcounter <= 0;
						handshaking <= rdy_low;				// Do handshaking
					end
				
				end
				
				
				12'h10f: begin
					if (handshaking == starting) begin
						handshaking <= rdy_low;
					end
					if (RW == 0) begin
						pwm <= {pwm[7:0],1'b1};					// Left shift bit 1 in here
						pwmcounter <= 0;
					end
					
					// Send current rotation of motor to 10f to read
					data <= last5pos[0];
					
				
				end
			
			endcase
			
		end

		/* HANDSHAKING STATE MACHINE */
		case (handshaking)
			starting: begin
				ready <= 1'bz;
				if (enable ==1) begin
					handshaking <= rdy_low;
				end
			end
			/*
			strb_low: begin
				handshaking <= rdy_low;
			end
			*/
			rdy_low: begin
				ready <= 1'b0;
				handshaking <= rdy_hi;
			end
			
			rdy_hi: begin
				enable <= 1'b0;
				ready <= 1'b1;
				handshaking <= starting;
			end	
		endcase


		if (pwmcounter < pwm) begin
			pwmout <= 1;
		end
		else begin pwmout <= 0; end

		if (pwmcounter == 499) begin
			pwmcounter <= 0;
		end
		else	begin
			pwmcounter <= pwmcounter + 1;
		end
  	end
endmodule

module fsm(interrupt, redMotorWire, blackMotorWire, setCW, ready, add, clk, strobe, chA, ChB);
	input wire [11:0] add;
  	input wire clk;
  	
  	
  	//Handshaking
  	input wire strobe;
  	output reg ready;
  	
  	// From the motor
  	input wire chA;
  	input wire chB;
	
	// Output (interrupt)
  	output reg interrupt;
  	output reg redMotorWire;
  	output reg blackMotorWire;
  	output reg setCW;				// The data bit 10f reads
	
	// Interior, changable registers
  	reg [15:0] counter;				// Counts motor position
  	reg prevChA;					// Previous value of ChA
  	reg prevChB;					// Previous value of ChB
  	reg goingCW;					// 1 if motor is going CW; else 0

	
  	parameter starting				=	5'b00001;
  	parameter setTo					=	5'b00010;
  	parameter ready_setTo			=	5'b00011;
  	parameter readDirection			=	5'b00100;
  	parameter ready_readDirection	=	5'b00101;
  	
  	reg [4:0] state = starting;
  	
  	// How2handshake: ready = Z. @ address/~strobe. Do action, ready = 0. Back to starting, ready = 1
  	always @ (negedge clk) begin
  		case(state)
	      	starting: begin
	      		ready <= 1'bz;
	      		counter <= 0;
	      		
	      		if((add[11:0] == 12'h10c)&&(~strobe)) begin				// Set direction to CW
	      			state <= setTo;
	      			setCW <= 1;
	      		end
	      		if((add[11:0] == 12'h10d)&&(~strobe)) begin				// Set direction to CCW
	      			state <= setTo;
	      			setCW <= 0;
	      		end
	      		if((add[11:0] == 12'h10f)&&(~strobe)) begin				// Read back sensed direction of rotation
	      			state <= readDirection;								// Unsure how to implement this
	      		end
	      	end
	      	
	      	setTo: begin
	      		ready <= 1'b0;
	      		state <= ready_setToCW;
	      	end
	      	ready_setTo: begin
	      		ready <= 1'b1;
	      		state <= starting;
	      	end

			readDirection: begin
				ready <= 1'b0;
			end
			
			ready_readDirection: begin
				ready <= 1'b1;
			end
	    endcase
	    
	    
	    /* ** Outside of the state machine ** */
	    if ((prevChA == chA) && (prevChB == chB)) begin
			interrupt = 1;
		end
		else if((prevChA != chA) && (prevChB == chB)) begin
			interrupt <= 0;
			if (setCW == 1) begin
				goingCW <= 1;
			end
			else begin
				goingCW <= 0;
			end
		end	
		else if((prevChA == chA) && (prevChB != chB)) begin
			interrupt <= 0;
			if (setCW == 1) begin
				goingCW <= 1;
			end
			else begin
				goingCW <= 0;
			end
		end
		prevChA <= chA;
		prevChB <= chB;

	    if(goingCW == 1) begin
			counter <= counter + 1;
	    end
	    else begin
	    	counter <= counter - 1;
	    end
	    
	    if(setCW == 1) begin
	    	redMotorWire <= 1;
	    	blackMotorWire <= 0;
	    end
	    else begin
	    	redMotorWire <= 0;
	    	blackMotorWire <= 1;
	    end
	    
  	end
endmodule

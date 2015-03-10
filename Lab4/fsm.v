module fsm(add, chA, chB strobe, ready, clk, interrupt);
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
	
	// Interior, changable registers
  	reg [15:0] counter;
  	reg prevChA;
  	reg prevChB;
	
  	parameter starting	=	5'b00001;
  	reg [4:0] state = starting;
  	
  	// How2handshake: ready = Z. @ address/~strobe. Do action, ready = 0. Back to starting, ready = 1
  	always @ (negedge clk) begin
  		case(state)
	      	starting: begin
	      		ready <= 1'bz;
	      		
	      		out <= 1;
	      		counter <= 0;
	      		
	      		if((add[11:0] == 12'h10d)&&(~strobe)) begin
	      			state <= intr1;
	      		end
	      	end
	      	
	      	nextstate: begin
	      		ready <= 1'b0;
	      		state <= ready_nextstate;
	      	end
	      	
	      	ready_nextstate: begin
	      		ready <= 1'b1;
	      		state <= starting;
	      	end

	    endcase
	    
	    if(enable) begin
	    	counter <= counter + 1;
	    end
	    
	    if(counter == 500) begin
	    	counter <= 0;
	    	interrupt <= 0;
	    end
	    else begin
	    	interrupt <= 1;
	    end
  	end
endmodule

//Programmable interrupt timer - Finite State Machine

module stridyULTIMATE(add, strobe, ready, clk, out);
  input wire [11:0] add;
  input wire clk;
  input wire strobe;
  
  output reg ready;
  output reg out;
  
  reg enable;
  
  reg [15:0] counter;
  reg [15:0] period;

  parameter 	ready_shift1	=	5'b00000;
  parameter		shift1		=	5'b00001;
  parameter		ready_shift0	=	5'b00010;
  parameter		shift0		=	5'b00011;
  parameter		ready_intr0	=	5'b00100;
  parameter		intr0		=	5'b00101;
  parameter		ready_intr1	=	5'b00110;
  parameter		intr1		=	5'b00111;
  parameter		gucci		=	5'b01000;
  parameter		send_intr	=	5'b01001;
  parameter		pre_shift1	=	5'b01010;
  parameter		pre_shift0	=	5'b01011;
  parameter		pre_intr0	=	5'b01100;
  parameter		pre_intr1	=	5'b01101;
  parameter		mid_shift1	=	5'b01110;
  parameter		mid_shift0  	=	5'b01111;
  parameter		mid_intr0	=	5'b10000;
  parameter		mid_intr1	=	5'b10001;

  reg [3:0] state = gucci;
  
  
  always @(negedge clk)begin
    
    case(state)
      gucci:  //IDLE
        begin
          ready <= 1'bz;
		  out <= 1;
		  counter <= 0;
		  
          
			if((add[11:0] == 12'h10d)&&(~strobe)) begin  //enable
				enable <= 1;
				state <= pre_intr1;
			end
			else if((add[11:0] == 12'h10c)&&(~strobe))begin  //disable
				enable <= 0;
				state <= pre_intr0;
			end
			else if((add[11:0] == 12'h10e)&&(~strobe))begin  //shift 0
				period <= period << 1;
				period[0] <= 0;
				state <= pre_shift0;
			end
			else if((add[11:0] == 12'h10f)&&(~strobe)) begin  //shift 1
				period <= period << 1;
				period[0] <= 1;
				state <= pre_shift1;
			end
		end
		
		pre_shift1:
			begin
				state <= mid_shift1;
			end
		mid_shift1:
			begin
				state <= shift1;
			end
		shift1:  
			begin
				ready <= 1'b0;
				state <= ready_shift1;
			end
		ready_shift1:  
			begin
	            		ready <= 1'b1;
				state <= gucci;
			end
      
	  
		pre_shift0:
			begin
				state <= mid_shift0;
			end
		mid_shift0:
			begin
				state <= shift0;
			end
		shift0:  
			begin
				ready <= 1'b0;
				state <= ready_shift0;
			end
		ready_shift0:  
			begin
				ready <= 1'b1;
				state <= gucci;
			end
      
		pre_intr1:
			begin
				//counter <= counter + 1;
				
				//if(counter == period) begin
				//	counter <= 0;
				//	state <= send_intr;
				//end
				//else begin
				state <= mid_intr1;
				//end
			end
		mid_intr1:
			begin
				state <= intr1;
			end
		intr1:  
			begin
				ready <= 1'b0;
				state <= ready_intr1;
			end
		ready_intr1: 
			begin
                		ready <= 1'b1;
				state <= gucci;
			end
		//send_intr:
		//	begin
		//		out <= 0;
		//		//ready <= 1'b1;
		//		//state <= gucci;
		//		state <= intr1;
		//	end
	  
		pre_intr0:
			begin
				
				//enable <= 0;
				//out <= 1;
				state <= intr0;
			end
		//mid_intr0:
		//	begin
		//		state <= intr0;
		//	end
		intr0:
			begin
				ready <= 1'b0;
				state <= ready_intr0;
			end
      
		ready_intr0:
			begin
				ready <= 1'b1;
				state <= gucci;
			end
    endcase
	if(enable) begin
		counter <= counter + 1;
	end
	if(counter == period) begin
		counter <= 0;
		out <= 0;
		//state = gucci;
	end
	else begin
		out <= 1;
	end
  end
endmodule



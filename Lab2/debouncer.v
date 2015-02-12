module debouncer (button,clock,out);
	input wire clock, button;
	output reg out;
	
	reg [7:0] shift;
	
	//reg: wait for stable
	always @ (posedge clock) begin
		shift[7:0] <= {shift[6:0],button}; //shift register
		if(shift[7:0] == 8'b10000000)
	  		out <= 1'b0;
		else if(shift[7:0] == 8'b01111111)
	  		out <= 1'b1;
		else out <= 1'b1;
	end
endmodule

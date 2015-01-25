
module debouncerultimate (button, clock, out);

input clock;
input button;
output out;

wire clock;
wire button;
reg out;

localparam N = 10;

reg[N-1:0]count = 0;
wire tick;

always @ (posedge clock) begin
	count <= count + 1;
end

assign tick = &count;

localparam[4:0]
	first = 5'b00000,
	high1 = 5'b00001,
	high2 = 5'b00010,
	high3 = 5'b00011,
	second = 5'b00100,
	low1 = 5'b00101,
	low2 = 5'b00110,
	low3 = 5'b00111;
	/*high4 = 5'b01000,
	high5 = 5'b01001,
	high6 = 5'b01010,
	high7 = 5'b01011,
	high8 = 5'b01100,
	high9 = 5'b01101,
	high10 = 5'b01110,
	low4 = 5'b01111,
	low5 = 5'b10000,
	low6 = 5'b10001,
	low7 = 5'b10010,
	low8 = 5'b10011,
	low9 = 5'b10100,
	low10 = 5'b10101;*/
	
reg [4:0] state;
reg [4:0] next;


always @ (posedge clock) begin
	state <= next;
end

always @(*) begin
	next <= state;
	out <= 1'b1;
	
	case(state)
		first:
			if(~button)
				next <= high1;
		
		high1:
			if(button)
				next <= first;
			else if (tick)
				next <= high2;
				
		high2:
			if(button)
				next <= first;
			else if (tick)
				next <= high3;
		high3:
			if(button)
				next <= first;
			else if (tick)
				next <= second;
		/*high4:
			if(button)
				next <= first;
			else if (tick)
				next <= high5;

		high5:
			if(button)
				next <= first;
			else if (tick)
				next <= high6;

		high6:
			if(button)
				next <= first;
			else if (tick)
				next <= high7;
		high7:
			if(button)
				next <= first;
			else if (tick)
				next <= high8;

		high8:
			if(button)
				next <= first;
			else if (tick)
				next <= high9;
		high9:
			if(button)
				next <= first;
			else if (tick)
				next <= high10;
				
		high10:
			if(button)
				next <= first;
			else if (tick)
				next <= second;*/
				
		second: begin
			out <= 1'b0;
			if(button)
				next <= low1;
			end
			
		low1:
			if(~button)
				next <= second;
			else if (tick)
				next <= low2;
				
		low2:
			if(~button)
				next <= second;
			else if (tick)
				next <= low3;
		low3:
			if(~button)
				next <= second;
			else if (tick)
				next <= first;
		/*low4:
			if(~button)
				next <= second;
			else if (tick)
				next <= low5;
		low5:
			if(~button)
				next <= second;
			else if (tick)
				next <= low6;
		low6:
			if(~button)
				next <= second;
			else if (tick)
				next <= low7;
		low8:
			if(~button)
				next <= second;
			else if (tick)
				next <= low9;
		low9:
			if(~button)
				next <= second;
			else if (tick)
				next <= low10;	
		low10:
			if(~button)
				next <= second;
			else if (tick)
				next <= first;*/
				
		default next <= first;
		
	endcase
	
end

endmodule

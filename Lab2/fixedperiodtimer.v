module fixedperiodtimer(clock, out);

input clock;
output out;

wire clock;
reg out;

reg[10:0] counter;

always @ (posedge clock) begin
	counter <= counter + 1;
	if(counter == 999) begin
		counter <= 0;
		out <= 1'b0;
	end
	else 
		out <= 1'b1;
end

endmodule

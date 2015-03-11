module counter(clk, pwm_amount, pwm_sig );
   input [8:0] pwm_amount;
   input clk;
   
   output reg pwm_sig=1;
   
   reg [8:0] counter=0;
   
   always @(negedge clk) begin
     
    if (counter == pwm_amount) begin
      pwm_sig <= 0;
    end

    if (counter == 499) begin
	
      pwm_sig <= 1;
      counter <= 0;
    end	



	if(pwm_amount>0)
    counter <= counter + 1;
   end
  
endmodule

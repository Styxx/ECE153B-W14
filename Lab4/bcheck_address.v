module check_address(address,clk, pwm_amount, read, strb,ready, dir,int3,AnB, spin);


	parameter IDLE2=0;
	parameter A0_B0=1;
	parameter A0_B_=2;
	parameter A_B0_=3;
	parameter A_B_=4;
	reg[2:0] state2=IDLE2;

	parameter IDLE=0;
	parameter STRB_LOW=1;
	parameter READY_LOW=2;
	parameter READY_HIGH=3;
	input [11:0] address;
	input  clk;
	input read;
	input strb;
	output reg spin=1;
	input [1:0] AnB;
	//input up;
	reg [3:0] down=0;
	 output reg dir=1;
	output reg int3=1;
	output reg ready=1'bz;
	reg [2:0] state=IDLE;
	//reg [2:0] next=;
    output reg [8:0]pwm_amount=0;
	 reg enable=0;
	reg [16:0] count=0;
	reg tmp=0;
	

	
	 wire addressActive = (address==12'h10c || address==12'h10d ||address==12'h10e ||address==12'h10f);
	 

	//always @(AnB) begin
	//	dir<=AnB[0]; end
	always @ (negedge clk) begin
    
    	

/**************************************************************************************/

tmp<=pwm_amount;

	int3<=1;
		//up<=0;
		
		
		
		case (state2)
			
			IDLE2: begin
			
					if ( AnB==2'b00)
						state2<=A0_B0;
					if ( AnB==2'b01)
						state2<= A0_B_;
					if ( AnB==2'b10)
						state2<= A_B0_;
					if ( AnB==2'b11)
						state2<= A_B_;
				   end 
				   
			A0_B0:begin
			
					if ( AnB==2'b00)
						state2<=A0_B0;
					if ( AnB==2'b01) begin //cw
						state2<= A0_B_;
						down<={down[2:0],1'b0};
						count<=count+1;
						int3<=0; end
					if ( AnB==2'b10)begin //ccw
						state2<= A_B0_;
							count<=count+1;
						down<={down[2:0],1'b1};
						int3<=0; end
					if ( AnB==2'b11)
						state2<= A_B_;
				   end 
			
			
			
			A0_B_:begin
			
					if ( AnB==2'b00) begin
						state2<=A0_B0;
						down<={down[2:0],1'b1};
							count<=count+1;
						int3<=0; end //ccw
					if ( AnB==2'b01)
						state2<= A0_B_;
					if ( AnB==2'b10) 
						state2<= A_B0_;
					if ( AnB==2'b11) begin
						state2<= A_B_;
						down<={down[2:0],1'b0};
							count<=count+1;
						int3<=0; end //cw
				   end 
			
			
			
			
			
			
			A_B0_:begin
			
					if ( AnB==2'b00) begin
						state2<=A0_B0;
						down<={down[2:0],1'b0};
							count<=count+1;
						int3<=0; end //cw
					if ( AnB==2'b01)
						state2<= A0_B_;
					if ( AnB==2'b10)
						state2<= A_B0_;
					if ( AnB==2'b11) begin
						state2<= A_B_;
						down<={down[2:0],1'b1};
							count<=count+1;
						int3<=0; end //ccw
				   end 
			
			
			
			
			A_B_:begin
			
					if ( AnB==2'b00)
						state2<=A0_B0;
					if ( AnB==2'b01)begin
						state2<= A0_B_;
						down<={down[2:0],1'b1};
							count<=count+1;
						int3<=0; end //ccw
					if ( AnB==2'b10) begin
						state2<= A_B0_;
						down<={down[2:0],1'b0};
							count<=count+1;
                     				int3<=0; end //cw
					if ( AnB==2'b11)
						state2<= A_B_;
				   end 
			endcase
/*if(tmp==1)
pwm_amount <= pwm_amount+1;
if(tmp==0)	
pwm_amount <= pwm_amount-1;
if (count==120)
tmp<=0;*/
	 

if(count==220)begin 
	
	
	//tmp<=1;
	//if (pwm_amount==0)
		//pwm_amount<=1;
	spin<=0; end

//if(count==330) begin

//tmp<=0;end
	
	

	
if (count==440)begin
	
	//tmp<=1;
	

//if (pwm_amount==0)
	//	pwm_amount<=1;
	spin<= 1;
	count<=0;	end


/**************************************************************************************/


    	enable<=0;
	
      if (addressActive  && strb==0)  begin
	
    		
				//if (read==0) begin
					
						case (address) 
						12'h10f: begin 
							if (state==IDLE  ) begin
							state<=STRB_LOW;
							if (read==0) begin
							pwm_amount <= {pwm_amount[7:0],1'b1}; end
							//if (read==0)
							//tmp<=pwm_amount[0:8];
								dir<=down[0];	
							end	
           						
        	
						end
						12'h10e: begin
							if (state==IDLE && read==0) begin
							//if (read==0)begin
							pwm_amount <= {pwm_amount[7:0],1'b0};
							//tmp<=pwm_amount[0:8];
							state<=STRB_LOW; end
             						
						end
						12'h10c: begin
							enable<=1;
        						//spin<=1;
						end
						12'h10d: begin
							enable<=1;
							//spin<=0;
        	
						end
						endcase
				end
	//	end
 
    
    







	case (state)
		IDLE: begin
			ready <= 1'bz;
			if (enable==1)
				state<=STRB_LOW;
    		end
    	
    		STRB_LOW: begin
      			state<=READY_LOW;
    		end
		
		
    	
    		READY_LOW: begin
      			ready<=0;
      			state<=READY_HIGH;
  		end
  		READY_HIGH: begin
			enable<=0;
      			ready<=1;
      			state<=IDLE;
  		end
    	endcase




	end









endmodule

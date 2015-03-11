module topmodule( A,B,clk,address,rdy,int3, pwm_sig,read,strb,dir,spin);
  input A,B, clk;
  input read;
  input [11:0] address;
  output dir;
 
  output reg dir_cpy=0;
  input strb;
  output rdy;
  output spin;
  output int3 ;
  output pwm_sig;
  
  wire [1:0] AnB;
  //wire enable;
   wire [8:0]  pwm_amount;
  //wire up;
  //wire down;
  //wire enable_counter;
  
  assign AnB[0]=B;
  assign AnB[1]=A;
  
  //motor_turns test0(clk, AnB, int3,down);
  //genready test1( rdy, enable,clk);
  counter test2(clk, pwm_amount, pwm_sig );
  check_address test3(address, clk, pwm_amount,read, strb,rdy,dir,int3, AnB, spin);
endmodule

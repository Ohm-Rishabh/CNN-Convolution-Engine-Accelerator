`timescale 1ns / 1ps
module convolver_tb;

	reg clk;
	reg ce;
	reg [143:0] weight1;
	reg global_rst;
	reg [15:0] activation;

	wire [31:0] conv_op;
	wire end_conv;
	wire valid_conv;
	integer i;
    //Define the clk_period, feature_size, kernel_size
    parameter clkp = 40;
  	parameter feature_map = 9'h004;
    parameter kernel = 9'h003;

  convolver #(feature_map,kernel,1) uut (
		.clk(clk), 
		.ce(ce), 
		.weight1(weight1), 
		.global_rst(global_rst), 
		.activation(activation), 
		.conv_op(conv_op), 
		.end_conv(end_conv), 
		.valid_conv(valid_conv)
	);

	initial begin
      $dumpfile("dump.vcd");
    	$dumpvars(1, convolver_tb);
      	
		clk = 0;
		ce = 0;
		weight1 = 0;
		global_rst = 0;
		activation = 0;
		#100;
         clk = 0;
		ce = 0;
		weight1 = 0;
		activation = 0;
         global_rst =1;
         #50;
         global_rst =0;	
         #10;	
		ce=1;
    //This is for a 3x3 kernel
		weight1 = 144'h0008_0007_0006_0005_0004_0003_0002_0001_0000; 
      for(i=0;i<feature_map*feature_map+1;i=i+1) begin
        $display(i,conv_op," ",valid_conv," ",end_conv);
		activation = i;
		#clkp;
		end
      	#100 $stop;
	end 
      always #(clkp/2) clk=~clk;      
endmodule

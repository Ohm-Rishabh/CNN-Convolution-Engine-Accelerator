`timescale 1ns / 1ps

module pooler #(
    parameter m = 9'h00c,
    parameter p = 9'h003,
    parameter N = 16,
    parameter Q = 12,
    )(
    input clk,
    input ce,
    input master_rst,
    input [N-1:0] data_in,
    output [N-1:0] data_out,
    output valid_op,           
    output end_op            
                                
    );
   
    wire rst_m,load_sr,global_rst;
    wire [1:0] sel;
    wire [N-1:0] comp_op;
    wire [N-1:0] sr_op;
    wire [N-1:0] max_reg_op;
    wire [N-1:0] div_op;
    wire ovr;
    wire [N-1:0] mux_out;
  
    control_logic2 #(m) log(     
	    clk,
	    master_rst,
	    ce,
	    sel,
	    rst_m,
	    valid_op,
	    load_sr,
	    global_rst,
	    end_op
      );
    
    comparator2 #(.N(N),.ptype(ptype)) cmp(
        ce,         
	    data_in,
	    mux_out,
	    comp_op
      );
  
    max_reg #(.N(N)) m1(               
    	clk,
    	ce,
	    comp_op,
	    rst_m,
	    master_rst,
	    max_reg_op
      );
 
    variable_shift_reg #(.WIDTH(N),.SIZE((m/p))) SR (
         .d(comp_op),                 
         .clk(clk),                 
         .ce(load_sr),                 
         .rst(global_rst && master_rst),         
         .out(sr_op)             
         );

   input_mux #(.N(N)) mux(sr_op,max_reg_op,sel,mux_out);
   
   qmult #(N,Q) mul (clk,rst_m,max_reg_op,p_sqr_inv,div_op,ovr); 
    
   assign data_out = ptype ? max_reg_op : div_op; //for average pooling, we output the sum divided by p**2 
endmodule

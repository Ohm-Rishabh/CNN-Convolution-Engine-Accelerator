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



	always @(ce || data_in || mux_out) begin
		if (data_in > mux_out) begin
			comp_op <= data_in;
		end else begin
			comp_op <= mux_out;
		end
	end

	always @(posedge clk) begin
		if (ce)  begin
			reg_op <= comp_op;
		end
	end

	reg [WIDTH-1:0] sr [SIZE-1:0];
	generate
	genvar i;
	for(i=0;i<m/p;i=i+1)
	begin
	    always@(posedge clk or posedge master_rst)
	    begin
	    if(rst)
	    begin
	        sr[i] <= 'd0;
	    end
	    else if(ce)
	        begin
	            if(i == 'd0)
	            begin
	                sr[i] <= d;
	            end
	            else
	            begin
	                sr[i] <= sr[i-1];
	            end
	        end
	    end
	end

	assign sr_op = sr[SIZE-1];

	assign mux_out = (sel == 2'b01) ? sr_op : ((sel == 2'b00) ? reg_op: 0);
    
   assign data_out = reg_op; 
endmodule

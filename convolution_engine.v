`timescale 1ns / 1ps

module mac #(
	  parameter n = 16
    )(
    input clk,rst,ce,
    input [n-1:0] a,
    input [n-1:0] b,
    input [n-1:0] c,
    output reg [n-1:0] p
    );

always@(posedge clk,posedge rst)
 begin
    if(rst)
    begin
        p<=0;
    end
    else if(ce)
    begin
        p <= (a*b+c);                  
    end
 end
endmodule

module variable_shift_reg #(parameter width = 8, parameter size = 3) ( 
input clk,                                 
input ce,                                                
input rst,                                 
input [width-1:0] data_in,                  
output [width-1:0] data_out                 
);
    
reg [width-1:0] sr [size-1:0];          

generate
genvar i;
for(i = 0;i < size;i = i + 1)
begin
    always@(posedge clk or posedge rst)
    begin
        if(rst)                          
        begin
            sr[i] <= 'd0;
        end
        else
        begin
            if(ce)                            
            begin
                if(i == 'd0)
                begin
                    sr[i] <= data_in;
                end
                else
                begin
                    sr[i] <= sr[i-1];
                end
            end
        end
    end
end
endgenerate
assign data_out = sr[size-1];
endmodule

module convolver #(
parameter n = 9'h00a,     
parameter k = 9'h003,     
parameter s = 1,          
parameter n = 16    
)(
input clk,
input ce,
input global_rst,
input [n-1:0] activation,
input [(k*k)*16-1:0] weight1,
output[n-1:0] conv_op,
output valid_conv,
output end_conv
);
    
reg [31:0] count,count2,count3,row_count;
reg en1,en2,en3;
    
wire [15:0] tmp [k*k+1:0];
wire [15:0] weight [0:k*k-1];

generate
	genvar l;
	for(l=0;l<k*k;l=l+1)
	begin
      assign weight [l][n-1:0] = weight1[n*l +: n]; 		
	end	
endgenerate

assign tmp[0] = 32'h0000000;
    
generate
genvar i;
  for(i = 0;i<k*k;i=i+1)
  begin: MAC
    if((i+1)%k ==0)                     
    begin
      if(i==k*k-1)                        
      begin
      (* use_dsp = "yes" *)             
      mac #(.n(n)) mac(      
        .clk(clk),                      
        .ce(ce),                       
        .rst(global_rst),                
        .a(activation),                   
        .b(weight[i]),                   
        .c(tmp[i]),                   
        .p(conv_op)                      
        );
      end
      else
      begin
      wire [n-1:0] tmp2;
      mac #(.n(n)) mac(                   
        .clk(clk), 
        .ce(ce), 
        .rst(global_rst), 
        .a(activation), 
        .b(weight[i]), 
        .c(tmp[i]), 
        .p(tmp2) 
        );
      
      variable_shift_reg #(.width(32),.size(n-k)) SR (
          .clk(clk),               
          .ce(ce),                  
          .rst(global_rst),          
          .data_in(tmp2),
          .data_out(tmp[i+1])             
          );
      end
    end
    else
    begin
    (* use_dsp = "yes" *)               
   mac #(.n(n)) mac2(                    
      .clk(clk), 
      .ce(ce),
      .rst(global_rst),
      .a(activation),
      .b(weight[i]),
      .c(tmp[i]), 
      .p(tmp[i+1])
      );
    end 
  end 
endgenerate

always@(posedge clk) 
begin
  if(global_rst)
  begin
    count <=0;                     
    count2<=0;                     
    count3<=0;                     
    row_count <= 0;     
    en1<=0;
    en2<=1;
    en3<=0;
  end
  else if(ce)
  begin
    if(count == (k-1)*n+k-1)        
    begin
      en1 <= 1'b1;
      count <= count+1'b1;
    end
    else
    begin 
      count<= count+1'b1;
    end
  end
  if(en1 && en2) 
  begin
    if(count2 == n-k)
    begin
      count2 <= 0;
      en2 <= 0 ;
      row_count <= row_count + 1'b1;
    end
    else 
    begin
      count2 <= count2 + 1'b1;
    end
  end
  
  if(~en2) 
  begin
  if(count3 == k-2)
  begin
    count3<=0;
    en2 <= 1'b1;
  end
  else
    count3 <= count3 + 1'b1;
  end
  if((((count2 + 1) % s == 0) && (row_count % s == 0))||(count3 == k-2)&&(row_count % s == 0)||(count == (k-1)*n+k-1))
  begin                                                                                                                        
    en3 <= 1;                                                                                                                             
  end
  else 
    en3 <= 0;
end
	assign end_conv = (count>= n*n+2) ? 1'b1 : 1'b0;
	assign valid_conv = (en1&&en2&&en3);
endmodule




`timescale 1ns/10ps
module CS(Y, X, reset, clk);

input clk, reset; 
input 	[7:0] X;
output 	reg[9:0] Y;
reg [71:0]XS;
reg [11:0]sum;
reg [7:0]xappro;
reg [11:0]tmp;
reg [7:0]xavg;
reg [20:0]tmp_xavg;
reg [7:0]min;
integer i;
always @(posedge clk) begin
  XS = {XS[63:0],X};
	sum = (XS[71:64]+XS[63:56])+(XS[55:48] + XS[47:40])+(XS[39:32] + XS[31:24])+(XS[23:16] + XS[15:8])+ XS[7:0];
	tmp_xavg  = ({sum, sum[11:3]} - {2'b0, sum, 6'b0} + {5'b0, sum, sum[11:9]} - {8'b0, sum});
	
	xavg=tmp_xavg[19:12];
	
	min=8'b11111111;
	xappro=XS[7:0];
	for(i=0;i<9;i=i+1) begin
		if(xavg>=XS[i*8+:8])
		  if(xavg-XS[i*8+:8]<min) begin
		    xappro=XS[i*8+:8];
			  min=xavg-XS[i*8+:8];
		  end
	end
	
	tmp={4'b0,xappro};
	Y=((sum+tmp)+(tmp<<3))>>3;
		
	
end

endmodule



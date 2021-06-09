`timescale 1ns / 10ps
module div(out, in1, in2, dbz);
parameter width = 8;
input  	[width-1:0] in1; // Dividend
input  	[width-1:0] in2; // Divisor
output [width-1:0] out; // Quotient
output dbz;
reg dbz;

//reg [7:0] out;
reg [15:0] rem_quo;
integer shift;

/********************************

You need to write your code at here

********************************/
assign out=rem_quo[7:0];
always @(in1 or in2)
begin	
	if(in2==0)
		dbz=1;
	else
		begin
			rem_quo={8'b00000000,in1};
			//out=rem_quo[7:0];
			rem_quo=rem_quo<<1;			
			for(shift=0;shift<8;shift=shift+1)
			begin
				//rem_quo[15:8]=rem_quo[15:8]-in2;
				if(rem_quo[15:8]<in2)
				begin
					//rem_quo[15:8]=rem_quo[15:8]+in2;
					rem_quo=rem_quo<<1;
					rem_quo[0]=0;
				end
				else
				begin
					rem_quo[15:8]=rem_quo[15:8]-in2;
					rem_quo=rem_quo<<1;
					rem_quo[0]=1;
				end
			end
			rem_quo[15:8]=rem_quo[15:8]>>1;
		end
end
endmodule
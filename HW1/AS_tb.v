`timescale 10ns / 1ps
`define CYCLE 5
`define A_dat "./A.txt"
`define B_dat "./B.txt"
`define O_dat "./O.txt"
`define SUM_dat "./SUM.txt"
module AS_tb;

integer num = 1;
integer i, j;
integer err = 0;

reg [3:0]A, B;
reg sel;
wire [3:0]S;
wire O;

reg [3:0] A_in [0:511];
reg [3:0] B_in [0:511];
reg [3:0] SUM [0:511];
reg o_ans[0:511];

AS as(.sel(sel), .A(A), .B(B), .S(S), .O(O));

initial 
begin

    $readmemb (`A_dat,A_in);
    $readmemb (`B_dat,B_in);
    $readmemb (`O_dat,o_ans);
	$readmemb (`SUM_dat,SUM);
    
end

initial 
begin
	for(i=0; i<512; i=i+1)begin
		
		A=A_in[i];
		B=B_in[i];
		
		if(i>255)
			sel=1;
		else
			sel=0;
		#`CYCLE;
		if(S == SUM[i] && O == o_ans[i])
			$display("%d data is correct", num);
		else begin
			$display("%d data is error %b, correct is %b, sel=%b, A=%d, B=%d, overflow=%b", num, {O,S}, {o_ans[i],SUM[i]}, sel, A, B, O);
			err = err + 1;
		end
		num=num+1;
	end
	if(err == 0) begin
    $display("-------------------PASS-------------------");
    $display("All data have been generated successfully!");    
  end else begin
    $display("-------------------ERROR-------------------");
    $display("There are %d errors!", err);
  end
    
  #10 $finish;
end

endmodule
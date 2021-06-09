`timescale 1ns / 10ps
`define CYCLE 100 // can be modified
module div_tb;
parameter width = 8;
  
wire [width-1:0] out;
wire dbz;
reg [width-1:0] in1;
reg [width-1:0] in2;

//reg unsigned [width-1:0] in1;
//reg unsigned [width-1:0] in2;
  
  
integer num = 1;
integer i;
integer j;
integer ans;
integer err = 0;
  

/*
  integer unsigned num = 1;
  integer unsigned i;
  integer unsigned j;
  integer unsigned ans;
  integer unsigned err = 0;
*/

div div(.out(out), .in1(in1), .in2(in2), .dbz(dbz));
  
initial begin
  //for(i = (-(1<<width-1)+1); i < (1<<width-1); i = i+1) begin
  //for(j = (-(1<<width-1)); j < (1<<width-1); j = j+1) begin
  for(i = 0; i < (1<<width); i = i+1) begin
    for(j = 0; j < (1<<width); j = j+1) begin
      in1 = i[width-1:0];
      in2 = j[width-1:0];
      #`CYCLE;
      ans = i / j;
      if(in2 == 0 && dbz == 1'b1)
        $display("%d data is divided by zero", num);
      else if(out == ans[width-1:0])
        $display("%d data is correct", num);
      else begin
        $display("%d data is error %b, correct is %b, in1=%d, in2=%d", num, out, ans[width-1:0], in1, in2);
        err = err + 1;
      end
      num = num + 1;
    end
  end
    
  if(err == 0) begin
    $display("-------------------PASS-------------------");
    $display("All data have been generated successfully!");    
  end 
  else begin
    $display("-------------------ERROR-------------------");
    $display("There are %d errors!", err);
  end
    
  #10 $finish;
end 

always@(err) begin
	if (err == 10) begin
	$display("============================================================================");
     	$display("\n (>_<) FAIL!! The simulation FAIL result is too many ! Please check your code @@ \n");
	$display("============================================================================");
	$finish;
	end
end
endmodule
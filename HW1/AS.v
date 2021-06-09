module AS(sel, A, B, S, O);
input [3:0] A, B;
input sel;
output [3:0] S;
output O;
wire [3:0] B2;
wire c_in2,c_in3,c_in4;
  // adder or subtractor
  xor (B2[0],B[0],sel);
  xor (B2[1],B[1],sel);
  xor (B2[2],B[2],sel);
  xor (B2[3],B[3],sel);
  Add_full FA1(S[0],c_in1,A[0],B2[0],sel);
  Add_full FA2(S[1],c_in2,A[1],B2[1],c_in1);
  Add_full FA3(S[2],c_in3,A[2],B2[2],c_in2);
  Add_full FA4(S[3],c_in4,A[3],B2[3],c_in3);
  // detect overflow
  xor(O,c_in3,c_in4);
endmodule

module Add_half(sum,c_out,a,b);
input a,b;
output sum,c_out;
  assign {c_out,sum}=a+b;
endmodule
	
module Add_full(sum,c_out,a,b,c_in);
  input a,b,c_in;
  output sum,c_out;
  wire w1,w2,w3;
  
  Add_half M1(w1,w2,a,b);
  Add_half M2(sum,w3,c_in,w1);
  or (c_out,w2,w3);
endmodule




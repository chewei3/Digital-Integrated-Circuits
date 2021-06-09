`timescale 1ns/10ps
module RC4(clk,rst,key_valid,key_in,plain_read,plain_in_valid,plain_in,plain_write,plain_out,cipher_write,cipher_out,cipher_read,cipher_in,cipher_in_valid,done);
    input clk,rst;
    input key_valid,plain_in_valid,cipher_in_valid;
    input [7:0] key_in,cipher_in,plain_in;
    output reg done;
    output reg plain_write,cipher_write,plain_read,cipher_read;
    output reg [7:0] cipher_out,plain_out;
	reg [7:0] key[31:0];
	reg [5:0] index;
	reg first;
	reg [5:0] sbox[63:0];
	integer it;
	reg [5:0] i,j;
	reg [5:0] temp;
	reg flag;
	reg [7:0] counter;
	reg set_sbox;
	reg [1:0]state;

initial
begin
	done=0;
	plain_write=0;
	cipher_write=0;
	plain_read=0;
	cipher_read=0;
	cipher_out=8'b00000000;
	plain_out=8'b00000000;
	first=0;
	index=6'b00000;
	i=6'b000000;
	j=6'b000000;
	temp=6'b000000;
	flag=0;
	counter=7'b0000000;
	set_sbox=0;
	state=0;
end

always @(posedge clk)
begin
/*
	if(flag) done=1;
	if(cipher_read)
	begin
		if(cipher_in_valid)
		begin
			i=(i+1)%64;
			j=j+sbox[i]%64;
			temp=sbox[i];
			sbox[i]=sbox[j];
			sbox[j]=temp;
			plain_out=cipher_in ^ sbox[(sbox[i]+sbox[j])%64];
			plain_write=1;			
			//$display("%h",plain_out);
		end
		else
		begin
			plain_write=0;
			cipher_read=0;
			//flag=1;
		end
	end
	if(plain_read)
	begin
		if(plain_in_valid)
		begin
			i=(i+1)%64;
			j=j+sbox[i]%64;
			temp=sbox[i];
			sbox[i]=sbox[j];
			sbox[j]=temp;	
			cipher_out=plain_in ^ sbox[(sbox[i]+sbox[j])%64];	
			cipher_write=1;
			$display("%h",cipher_out);			
		end
		else
		begin
			set_sbox=1;
		end
	end
*/
	if(key_valid)
	begin
		if(first==0) first=first+1;
		else
		begin
			key[index]=key_in;
			index=index+1;
			if(index==6'b100000) 
			begin
				set_sbox=1;
				index=6'b000000;
				counter=7'b0000000;
			end
		end
	end
	
	if(set_sbox)
	begin
		if(counter<64) 
		begin
			sbox[index]=index;
			//$display("sbox[%d]%h",counter,sbox[counter]);
			index=index+1;
			counter=counter+1;
		end
		else if(counter<128) 
		begin
			//sbox_swap
			j=(j+sbox[index]+key[index%32])%64;
			temp=sbox[index];
			sbox[index]=sbox[j];
			sbox[j]=temp;
			counter=counter+1;
			
		end
		else 
		begin
			index=6'b000000;
			set_sbox=0;
			counter=7'b0000000;		
			state=state+1;
		end
		if(index==6'b111111) index=6'b000000;

	end
	
	if(state==1)
	begin
		plain_read=1; // plain_read in next cycle
		plain_write=0;
		i=6'b000000;
		j=6'b000000;
		for(it=0;it<64;it=it+1) $display("sbox[%d]%h",it,sbox[it]);
	end
	else if(state==2)
	begin
		cipher_write=0;
		plain_read=0;
		cipher_read=1;
		i=6'b000000;
		j=6'b000000;
	end
	else state=0;
end
endmodule
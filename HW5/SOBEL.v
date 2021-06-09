
`timescale 1ns/10ps

module  SOBEL(clk,reset,busy,ready,iaddr,idata,cdata_rd,cdata_wr,caddr_rd,caddr_wr,cwr,crd,csel	);
	input				clk;
	input				reset;
	output				busy;	
	input				ready;	
	output 	reg[16:0]		iaddr;
	input  	[7:0]		idata;	
	input	[7:0]		cdata_rd;
	output	reg[7:0]		cdata_wr;
	output 	[15:0]		caddr_rd;
	output 	reg[15:0]		caddr_wr;
	output	reg			cwr,crd;
	output 	reg[1:0]		csel;
	
	reg		[16:0]		round;
	reg		[16:0]		count;
	reg 	[7:0]		Pixel[8:0];
	integer		tempx;
	integer		tempy;
	reg 	[3:0]		idx;
	reg 				busy;
	reg					sobel_ready;
	
	// state 
	parameter  state_bit = 3;
	localparam [ state_bit - 1 : 0 ]    start   		= 0;
	localparam [ state_bit - 1 : 0 ]    waitPixel   	= 1;
	localparam [ state_bit - 1 : 0 ]    getPixel   		= 2;
    localparam [ state_bit - 1 : 0 ]    sobelx     		= 3;
    localparam [ state_bit - 1 : 0 ]    sobely     		= 4;
	localparam [ state_bit - 1 : 0 ]    sobelcombine    = 5;
	localparam [ state_bit - 1 : 0 ]	Done			= 6;
	localparam [ state_bit - 1 : 0 ]	Show			= 7;
    reg [ state_bit - 1 : 0 ] cur_state,next_state;

	integer i;
initial
begin
	cur_state 	= start;
	idx   		= 0;
	iaddr 		= 0;
	round 		= 0;
	tempx 		= 0;
	tempy 		= 0;
	sobel_ready = 0;
	count		= 0;
	busy		= 0;
	for ( i = 0 ; i < 9 ; i = i + 1 ) begin
		Pixel[i] = 0;
	end

end
	
	always @ ( * ) begin
        case ( cur_state ) 
			start : begin
				if(busy && !ready) begin
					next_state = waitPixel;
					
				end
				else next_state = start;
			end
			waitPixel : next_state = getPixel;
			getPixel : begin
				if(sobel_ready)
				begin
					next_state = sobelx;
				end
				else
					next_state = getPixel;
			end
			sobelx :
				next_state = sobely;
			sobely : 
				next_state = sobelcombine;
			sobelcombine : begin
				if(round < 65536) begin
					//$stop;
					next_state = getPixel;
				end
				else 
					next_state = Done;
			end
			Done : begin	
				next_state = Show;
			end

			default : begin
				next_state = start;
			end
        endcase
    end
	
	// read
	always @ ( posedge clk) begin  
	cur_state = next_state;
		if(ready) busy =1;
        else begin
            case ( cur_state )
				getPixel : begin
					Pixel[idx] = idata;
					//$display("%d : %h\n", iaddr, idata);
					//$display("%d %h\n", iaddr, idata);
									
					if(idx==2 || idx==5) iaddr=iaddr+256;
					else iaddr=iaddr+1;
					
					if(idx==8) begin
						idx =0;		
						if(count%258==255) count=count+3;	
						else count=count+1;
						iaddr = count;
						sobel_ready = 1;	
					end	
					else idx=idx+1;					
				end
				sobelx : sobel_ready=0;
				Show : busy = 0;
            endcase
        end
    end
	
	// write
	always @ ( negedge clk) begin
		case ( cur_state )	
			sobelx: begin
				cwr=1;
				csel=2'b01;
				tempx = Pixel[0] - Pixel[2] + (Pixel[3]<<1) - ( Pixel[5]<<1) + Pixel[6] - Pixel[8];
				
				caddr_wr= round;
				if(tempx>255) tempx=255;
				else if(tempx<0) tempx=0;
				//$display("--------------\n");
				//$display("%d:%h\n",caddr_wr,tempx);
				
				cdata_wr = tempx;
			end
			sobely: begin
				cwr=1;
				csel=2'b10;
				
				tempy = Pixel[0] + (Pixel[1]<<1) + Pixel[2] - Pixel[6] - (Pixel[7]<<1) - Pixel[8];
				caddr_wr = round;
				if(tempy>255) tempy=255;
				else if(tempy<0) tempy=0;
				//$display("%h\n",cdata_wr);
				
				cdata_wr = tempy;
			end
			sobelcombine: begin
				cwr=1;
				csel=2'b11;
				
				tempx = (tempx + tempy + 1) >>1;
				caddr_wr = round;
				if(tempx>255) cdata_wr=255;
				else if(tempx<0) cdata_wr=0;
				else cdata_wr = tempx;
				
				round = round+1;	
			end			
			
		endcase
    end
endmodule






`timescale 1ns/10ps

module  SOBEL(clk,reset,busy,ready,iaddr,idata,cdata_rd,cdata_wr,caddr_rd,caddr_wr,cwr,crd,csel	);
	input				clk;
	input				reset;
	output				busy;	
	input				ready;	
	output 	[16:0]		iaddr;
	input  	[7:0]		idata;	
	input	[7:0]		cdata_rd;
	output	[7:0]		cdata_wr;
	output 	[15:0]		caddr_rd;
	output 	[15:0]		caddr_wr;
	output				cwr,crd;
	output 	[1:0]		csel;
	
	reg		[16:0]		round;
	reg 	[7:0]		Pixel[8:0];
	reg		[10:0]		tempx;
	reg		[10:0]		tempy;
	reg 	[3:0]		idx;
	reg 				busy;
	wire	[10:0]		w_tempx;
	wire	[10:0]		w_tempy;
	wire	[10:0]		w_combine;
	// state 
	parameter  state_bit = 3;
	localparam [ state_bit - 1 : 0 ]    waitPixel   	= 0;
	localparam [ state_bit - 1 : 0 ]    getPixel   		= 1;
	localparam [ state_bit - 1 : 0 ]	sobel_ready		= 2
    localparam [ state_bit - 1 : 0 ]    sobelx     		= 3;
    localparam [ state_bit - 1 : 0 ]    sobely     		= 4;
	localparam [ state_bit - 1 : 0 ]    sobelcombine    = 5;
	localparam [ state_bit - 1 : 0 ]	Done			= 6;
    reg [ state_bit - 1 : 0 ] cur_state,next_state;


	assign w_tempx = Pixel[0] - Pixel[2] + (Pixel[3]<<1) - ( Pixel[5]<<1) + Pixel[6] - Pixel[8];
	assign w_tempy = Pixel[0] + (Pixel[1]<<1) + Pixel[2] - Pixel[6] - (Pixel[7]<<1) - Pixel[8];
	assign w_combine = (tempx + tempy +1)>>1;
	
	// FSM
	always @ ( * ) begin
        case ( cur_state ) 
            waitPixel : begin
				if( ready )	begin
					next_state = getPixel;
					busy =1;
				end
				else
					next_state = waitPixel;
			end
			getPixel : 
				if(sobel_ready)
					next_state = sobelx;
				else
					next_state = getPixel;
			end
			sobelx :
				next_state = sobely;
			sobely : 
				next_state = sobelcombine;
			sobelcombine : begin
				if(round<65536)
					next_state = getPixel;
				else 
					next_state = Done;
			end
			default : begin
				next_state = Done;
			end
        endcase
    end
	
	// read
	always @ ( posedge clk or posedge reset ) begin
        if (reset) begin
		    cur_state <= waitPixel;
		    idx   <= 0;
			iaddr <=0;
			round <=0;
			tempx <=0;
			tempy <=0;
			
		    for ( i = 0 ; i < 9 ; i = i + 1 ) begin
                Pixel[i] <= 0;
            end
        end
        else begin
            cur_state <= next_state;
            case ( cur_state )
				getPixel: begin					
					Pixel[idx] <= idata;
					if(idx==2 || idx==5) iaddr=iaddr+256;
					else iaddr=iaddr+1;	
					
					if(idx==8)begin
						idx =0;							
						iaddr = round+1;	
						sobel_ready=1;
					end
					else idx=idx+1;

				end			
            endcase
        end
    end
	
	// write
	always @ ( negedge clk) begin
		cur_state <= next_state;
		case ( cur_state )	
			sobelx: begin
				cwr=1;
				csel=2'b01;
				
				tempx = w_tempx;
				if(tempx>255) tempx=255;
				else if(tempx<0) tempx=0;
				caddr_wr= round;
				cdata_wr= tempx;
			end
			sobely: begin
				cwr=1;
				csel=2'b10;
				
				tempy = w_tempy;
				if(tempy>255) tempy=255;
				else if(tempy<0) tempy=0;
				
				caddr_wr = round;
				cdata_wr = tempy;
			end
			sobelcombine: begin
				cwr=1;
				csel=2'b11;
				
				tempx = 
				tempx = tempx >>1;
				
				if(tempx>255) tempx=255;
				else if(tempx<0) tempx=0;
				
				caddr_wr = round;
				cdata_wr = tempx;
				round = round+1;
			end			
			Done: begin
				cwr=0;
				busy=0;
			end
		endcase
    end
endmodule





`timescale 1ns/10ps
`define CYCLE      19.0          	  // Modify your clock period here
`define End_CYCLE  100000000              // Modify cycle times once your design need more cycle times!
`define PAT         "img.dat"
`define L0_EXP0     "img_X.dat"     
`define L0_EXP1     "img_Y.dat"     
`define L0_EXP2	    "img_Combine.dat" 
module testfixture;
    reg	[7:0]	PAT	[0:66563];
    reg	[7:0]	L0_EXP0	[0:65535];  
    reg	[7:0]	L0_EXP1	[0:65535]; 
    reg	[7:0]	L0_MEM0	[0:65535]; 
    reg	[7:0]	L0_MEM1	[0:65535]; 
    reg	[7:0]	L0_EXP2	[0:65535]; 
    reg	[7:0]	L0_MEM2	[0:65535]; 
    reg		reset = 0;
    reg		clk = 0;
    reg		ready = 0;
    wire	[16:0]	iaddr;
    reg		[7:0]	idata;
    wire	[1:0]	csel;
    wire	[7:0]	cdata_wr;
    reg		[7:0]	cdata_rd;
    wire	[15:0]	caddr_rd;
    wire	[15:0]	caddr_wr;
    wire		cwr;
    wire		crd;
    reg		check0=0, check1=0, check2=0;

    integer		p0, p1, p2;
    integer		err00, err01, err10;
    integer		pat_num;

    SOBEL u_sobel(
        .clk(clk),
		.reset(reset),
		.busy(busy),	
		.ready(ready),	
		.iaddr(iaddr),
		.idata(idata),
        .cdata_rd(cdata_rd),
        .cdata_wr(cdata_wr),
        .caddr_rd(caddr_rd),
        .caddr_wr(caddr_wr),
        .cwr(cwr),
        .crd(crd),
        .csel(csel)
    );

    always begin #(`CYCLE/2) clk = ~clk; end
        initial begin  // global control
	    $display("-----------------------------------------------------\n");
 	    $display("START!!! Simulation Start .....\n");
 	    $display("-----------------------------------------------------\n");
	    @(negedge clk); #1; reset = 1'b1;  ready = 1'b1;
   	    #(`CYCLE*3);  #1;   reset = 1'b0;  
   	    wait(busy == 1); #(`CYCLE/4); ready = 1'b0;
    end

    initial begin // initial pattern and expected result
	    wait(reset==1);
	    wait ((ready==1) && (busy ==0) ) begin
		    $readmemh(`PAT, PAT);
            $readmemh(`L0_EXP0, L0_EXP0);
		    $readmemh(`L0_EXP1, L0_EXP1);
		    $readmemh(`L0_EXP2, L0_EXP2);
	    end	
    end
    
    always@(negedge clk) begin // generate the stimulus input data
	#1;
	if ((ready == 0) & (busy == 1)) idata <= PAT[iaddr];
	else idata <= 'hx;
	end
    always@(negedge clk) begin
	    if (crd == 1) begin
		    case(csel)
			    2'b01:cdata_rd <= L0_MEM0[caddr_rd] ;
			    2'b10:cdata_rd <= L0_MEM1[caddr_rd] ;
			    2'b11:cdata_rd <= L0_MEM2[caddr_rd] ;
		    endcase
	    end
    end

    always@(posedge clk) begin 
	    if (cwr == 1) begin
		    case(csel)
			    2'b01: begin check0 <= 1; L0_MEM0[caddr_wr] <= cdata_wr; end
			    2'b10: begin check1 <= 1; L0_MEM1[caddr_wr] <= cdata_wr; end
			    2'b11: begin check2 <= 1; L0_MEM2[caddr_wr] <= cdata_wr; end 
		    endcase
	    end
    end
    initial  begin
        #`End_CYCLE ;
 	    $display("-----------------------------------------------------\n");
 	    $display("Error!!! The simulation can't be terminated under normal operation!\n");
 	    $display("-------------------------FAIL------------------------\n");
 	    $display("-----------------------------------------------------\n");
 	    $finish;
    end
    //-------------------------------------------------------------------------------------------------------------------
    initial begin  	// Sobel_x
    check0<= 0;
    wait(busy==1); wait(busy==0);
    if (check0 == 1) begin 
    	err00 = 0;
    	for (p0=0; p0<=65535; p0=p0+1) begin
    		if (L0_MEM0[p0] == L0_EXP0[p0]) ;
    		/*else if ( (L0_MEM0[p0]+20'h1) == L0_EXP0[p0]) ;
    		else if ( (L0_MEM0[p0]-20'h1) == L0_EXP0[p0]) ;
    		else if ( (L0_MEM0[p0]+20'h2) == L0_EXP0[p0]) ;
    		else if ( (L0_MEM0[p0]-20'h2) == L0_EXP0[p0]) ;
    		else if ( (L0_MEM0[p0]+20'h3) == L0_EXP0[p0]) ;
    		else if ( (L0_MEM0[p0]-20'h3) == L0_EXP0[p0]) ;*/
    		else begin
    			err00 = err00 + 1;
    			begin 
    				$display("WRONG! Sobel X has error , Pixel %d is wrong!", p0);
    				$display("               The output data is %h, but the expected data is %h ", L0_MEM0[p0], L0_EXP0[p0]);
    			end
    		end
    	end
    	if (err00 == 0) $display(" Sobel X  is correct !");
    	else		 $display(" Sobel X be found %d error !", err00);
    end
    end

    //-------------------------------------------------------------------------------------------------------------------
    initial begin  	// Sobel Y
    check1<= 0;
    wait(busy==1); wait(busy==0);
    if (check1 == 1) begin 
    	err01 = 0;
    	for (p1=0; p1<=65535; p1=p1+1) begin
    		if (L0_MEM1[p1] == L0_EXP1[p1]) ;
    		/*else if ( (L0_MEM0[p0]+20'h1) == L0_EXP0[p0]) ;
    		else if ( (L0_MEM0[p0]-20'h1) == L0_EXP0[p0]) ;
    		else if ( (L0_MEM0[p0]+20'h2) == L0_EXP0[p0]) ;
    		else if ( (L0_MEM0[p0]-20'h2) == L0_EXP0[p0]) ;
    		else if ( (L0_MEM0[p0]+20'h3) == L0_EXP0[p0]) ;
    		else if ( (L0_MEM0[p0]-20'h3) == L0_EXP0[p0]) ;*/
    		else begin
    			err01 = err01 + 1;
    			begin 
    				$display("WRONG! Sobel Y has error , Pixel %d is wrong!", p1);
    				$display("               The output data is %h, but the expected data is %h ", L0_MEM1[p1], L0_EXP1[p1]);
    			end
    		end
    	end
    	if (err01 == 0) $display(" Sobel Y  is correct !");
    	else		 $display(" Sobel Y be found %d error !", err01);
    end
    end
        //-------------------------------------------------------------------------------------------------------------------
    initial begin  	//Sobel Combine
    check2<= 0;
    wait(busy==1); wait(busy==0);
    if (check2 == 1) begin 
    	err10 = 0;
    	for (p2=0; p2<=65535; p2=p2+1) begin
    		if (L0_MEM2[p2] == L0_EXP2[p2]) ;
    		/*else if ( (L0_MEM0[p0]+20'h1) == L0_EXP0[p0]) ;
    		else if ( (L0_MEM0[p0]-20'h1) == L0_EXP0[p0]) ;
    		else if ( (L0_MEM0[p0]+20'h2) == L0_EXP0[p0]) ;
    		else if ( (L0_MEM0[p0]-20'h2) == L0_EXP0[p0]) ;
    		else if ( (L0_MEM0[p0]+20'h3) == L0_EXP0[p0]) ;
    		else if ( (L0_MEM0[p0]-20'h3) == L0_EXP0[p0]) ;*/
    		else begin
    			err10 = err10 + 1;
    			begin 
    				$display("WRONG! Sobel combine has error , Pixel %d is wrong!", p2);
    				$display("               The output data is %h, but the expected data is %h ", L0_MEM2[p2], L0_EXP2[p2]);
    			end
    		end
    	end
    	if (err10 == 0) $display(" Sobel combine is correct !");
    	else		 $display(" Sobel combine be found %d error !", err10);
    end
    end
    initial begin
      wait(busy == 1);
      wait(busy == 0);      
    $display(" ");
	$display("-----------------------------------------------------\n");
	$display("--------------------- S U M M A R Y -----------------\n");
	    if( (check0==1)&(err00==0) ) $display("Congratulations! Sobel X data have been generated successfully! The result is PASS!!\n");
		else if (check0 == 0) $display("Sobel X output was fail! \n");
		else $display("FAIL!!!  There are %d errors! in Sobel X \n", err00);
	    if( (check1==1)&(err01==0) ) $display("Congratulations! Sobel Y data have been generated successfully! The result is PASS!!\n");
		else if (check1 == 0) $display("Sobel Y output was fail! \n");
		else $display("FAIL!!!  There are %d errors! in Sobel Y \n", err01);
	    if( (check2==1)&(err10==0)) $display("Congratulations! Sobel combine data have been generated successfully! The result is PASS!!\n");
		else if (check2 == 0) $display("Sobel combine output was fail! \n");
		else $display("FAIL!!!  There are %d errors! in Sobel combine \n", err10);
	    if ((check0|check1|check2) == 0) $display("FAIL!!! No output data was found!! \n");
	    $display("-----------------------------------------------------\n");
        #(`CYCLE/2); $finish;
    end
endmodule
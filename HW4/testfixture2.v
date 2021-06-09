`timescale 1ns/10ps
`define CYCLE      10.0          	  // Modify your clock period here
`define End_CYCLE  100000              // Modify cycle times once your design need more cycle times!
`define KEY         "Key_2.dat"
`define PLAIN       "Plain_2.dat"
`define CIPHER      "Cipher_2.dat"
module testfixture2;
    reg [7:0]       Plain[0:2047];
    reg [7:0]       Key[0:31];
    reg [7:0]       Cipher[0:2047];
    reg [7:0]       Plain_User[0:2047];
    reg [7:0]       Cipher_User[0:2047];
    reg             clk = 0;
    reg             rst = 0;
    reg             key_valid;
    reg [6:0]       key_count;
    reg [12:0]      plain_count;
    reg [12:0]      cipher_count;
    integer         file_key;
    integer         scan_sizes_key;
    integer         file_plain;
    integer         file_cipher;
    integer         scan_sizes_plain;
    integer         scan_sizes_cipher;
    reg [23:0]      data_key;
    reg [15:0]      data_plain;
    reg [15:0]      data_cipher;

    reg [7:0]       data_out;
    reg [7:0]       data_out2;
    reg [7:0]       data_out3;
    reg flag_plain;
    reg [12:0]      plain_out_count;
    integer i;
    integer j;
    wire plain_read,plain_write,cipher_write,cipher_read,done;
    reg plain_in_valid,cipher_in_valid;
    wire [7:0] plain_out,cipher_out;
    reg key_done;
    reg [12:0]      plain_write_count;
    reg [12:0]      cipher_write_count;
    reg [12:0]      plain_read_count;
    reg [12:0]      cipher_read_count;
    reg plain_out_done;

    integer		p0, p1;
    integer		err00, err01;

    RC4 rc4(.clk(clk),
    .rst(rst),
    .key_valid(key_valid),
    .key_in(data_out),
    .plain_read(plain_read),
    .plain_in_valid(plain_in_valid),
    .plain_in(data_out2),
    .plain_write(plain_write),
    .plain_out(plain_out),
    .cipher_write(cipher_write),
    .cipher_out(cipher_out),
    .cipher_read(cipher_read),
    .cipher_in(data_out3),
    .cipher_in_valid(cipher_in_valid),
    .done(done));

    always begin #(`CYCLE/2) clk = ~clk; end
    
    initial begin  // global control
	    $display("-----------------------------------------------------\n");
 	    $display("START!!! Simulation Start .....\n");
 	    $display("-----------------------------------------------------\n");
	    @(posedge clk); #1; rst = 1'b1; 
   	    #(`CYCLE*3);  #1;   rst = 1'b0;  
    end
    reg [22:0] cycle=0;

    always @(posedge clk) begin
        cycle=cycle+1;
        if (cycle > `End_CYCLE) begin
            $display("--------------------------------------------------");
            $display("-- Failed waiting done signal , Simulation STOP --");
            $display("--------------------------------------------------");
            $finish;
        end
    end
    initial begin
        for ( i = 0 ; i < 2048 ; i = i + 1) begin
            Plain_User[i] <= 0;
            Cipher_User[i] <= 0;
        end
    end

    initial begin
        file_key = $fopen(`KEY, "r");
        key_count = 0;
        while (!$feof(file_key)) begin
            scan_sizes_key = $fgets(data_key, file_key);
            if ( scan_sizes_key == 3 )
                key_count = key_count + 1;
        end
        $display("Key count = %d",key_count);
        $fclose(file_key);
    end

    initial begin
        file_plain = $fopen(`PLAIN, "r");
        plain_count = 0;
        while (!$feof(file_plain)) begin
            scan_sizes_plain = $fgets(data_plain, file_plain);
            if ( scan_sizes_plain == 2 )
                plain_count = plain_count + 1;
        end
        $display("Plain count = %d",plain_count);
        $fclose(file_plain);
    end

    initial begin
        file_cipher = $fopen(`CIPHER, "r");
        cipher_count = 0;
        while (!$feof(file_cipher)) begin
            scan_sizes_cipher = $fgets(data_cipher, file_cipher);
            if ( scan_sizes_cipher == 2 )
                cipher_count = cipher_count + 1;
        end
        $display("Cipher count = %d",cipher_count);
        $fclose(file_cipher);
    end

    initial begin // initial pattern and expected result
	    wait(rst==1);
		$readmemh(`KEY, Key);
        $readmemh(`PLAIN, Plain);
        $readmemh(`CIPHER, Cipher);
    end

    initial begin
        key_valid = 0; 
        flag_plain = 0;
        key_done = 0;
        #(`CYCLE*4);
        key_valid = 1; //key data
        #(`CYCLE);
        #(`CYCLE*key_count);
        key_done = 1;
        key_valid = 0; 
    end

    initial begin
        #(`CYCLE*5);
        for (i=0;i<key_count;i=i+1)
            @(negedge clk) data_out = Key[i];
        #(`CYCLE*2);
        if(~key_valid)
            data_out = 'hx;
    end

    initial begin
        plain_write_count = 0;
    end
    always@(posedge clk) begin 
	    if (plain_write == 1 ) begin
			Plain_User[plain_write_count] <= plain_out;
            plain_write_count = plain_write_count + 1;
	    end
    end
    initial begin
        cipher_write_count = 0;
    end
    always@(posedge clk) begin 
	    if ( cipher_write == 1 ) begin
			Cipher_User[cipher_write_count] <= cipher_out;
            cipher_write_count = cipher_write_count + 1;
	    end
    end
    initial begin
        plain_read_count = 0;
    end
    always@(negedge clk) begin 
	        if (plain_write == 0 && plain_read == 1 && key_done) begin
			    data_out2 = Plain[plain_read_count];
                if (plain_read_count < plain_count) begin
                    plain_in_valid = 1;
                    plain_out_done = 0;
                end
                else begin
                    plain_in_valid = 0;
                    plain_out_done = 1;
                end
                plain_read_count = plain_read_count + 1; 
	        end
        end

    initial begin
        cipher_read_count = 0;
        
    end
    always@(negedge clk) begin 
	    if (cipher_write == 0 && cipher_read == 1 && plain_out_done==1) begin
			data_out3 = Cipher_User[cipher_read_count];
            if (cipher_read_count < cipher_count)
                cipher_in_valid = 1;
            else 
                cipher_in_valid = 0;
            cipher_read_count = cipher_read_count + 1; 
	    end
    end
    initial begin
        err00 = 0;
        err01 = 0;
        wait(done == 1) begin
            for ( p0 = 0 ; p0 < cipher_count ; p0 = p0 + 1) begin
                if (Cipher_User[p0] == Cipher[p0]) begin
                end
                else begin
                    err00 = err00 + 1;
                    $display("WRONG! Cipher has error , No. %d is wrong!", p0);
    				$display("The output data is %h, but the expected data is %h ", Cipher_User[p0], Cipher[p0]);
                end
            end
            if (err00 == 0) $display(" ---------------- Cipher is correct ! ---------------- ");
    	    else		 $display(" Cipher be found %d error !", err00);

            for ( p1 = 0 ; p1 < plain_count ; p1 = p1 + 1) begin
                if (Plain_User[p1] == Plain[p1]) begin
                end
                else begin
                    err01 = err01 + 1;
                    $display("WRONG! Plain has error , No. %d is wrong!", p1);
    				$display("The output data is %h, but the expected data is %h ", Plain_User[p1], Plain[p1]);
                end
            end
            if (err01 == 0) $display(" ----------------- Plain is correct ! ----------------- ");
    	    else		 $display(" Plain be found %d error !", err01);
        end
        $display("-------------------------------------------------------------\n");
	    $display("--------------------- T B 2 - S U M M A R Y -----------------\n");
        if ( err00 == 0 )
            $display("Congratulations! Cipher data have been generated successfully! The result is PASS!!\n");
        else
            $display("FAIL!!!  There are %d errors! in Cipher \n", err00);
        if ( err01 == 0 )
            $display("Congratulations! Plain data have been generated successfully! The result is PASS!!\n");
        else
            $display("FAIL!!!  There are %d errors! in Plain \n", err01);
        $finish;
    end
endmodule
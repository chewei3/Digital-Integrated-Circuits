library verilog;
use verilog.vl_types.all;
entity Add_full is
    port(
        sum             : out    vl_logic;
        c_out           : out    vl_logic;
        a               : in     vl_logic;
        b               : in     vl_logic;
        c_in            : in     vl_logic
    );
end Add_full;

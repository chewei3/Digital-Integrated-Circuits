library verilog;
use verilog.vl_types.all;
entity div_tb is
    generic(
        width           : integer := 8
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of width : constant is 1;
end div_tb;

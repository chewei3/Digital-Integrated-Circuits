library verilog;
use verilog.vl_types.all;
entity div is
    generic(
        width           : integer := 8
    );
    port(
        \out\           : out    vl_logic_vector;
        in1             : in     vl_logic_vector;
        in2             : in     vl_logic_vector;
        dbz             : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of width : constant is 1;
end div;

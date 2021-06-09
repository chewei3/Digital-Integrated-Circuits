library verilog;
use verilog.vl_types.all;
entity AS is
    port(
        sel             : in     vl_logic;
        A               : in     vl_logic_vector(3 downto 0);
        B               : in     vl_logic_vector(3 downto 0);
        S               : out    vl_logic_vector(3 downto 0);
        O               : out    vl_logic
    );
end AS;

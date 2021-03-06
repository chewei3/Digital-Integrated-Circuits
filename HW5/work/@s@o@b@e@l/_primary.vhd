library verilog;
use verilog.vl_types.all;
entity SOBEL is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        busy            : out    vl_logic;
        ready           : in     vl_logic;
        iaddr           : out    vl_logic_vector(16 downto 0);
        idata           : in     vl_logic_vector(7 downto 0);
        cdata_rd        : in     vl_logic_vector(7 downto 0);
        cdata_wr        : out    vl_logic_vector(7 downto 0);
        caddr_rd        : out    vl_logic_vector(15 downto 0);
        caddr_wr        : out    vl_logic_vector(15 downto 0);
        cwr             : out    vl_logic;
        crd             : out    vl_logic;
        csel            : out    vl_logic_vector(1 downto 0)
    );
end SOBEL;

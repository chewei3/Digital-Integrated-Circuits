library verilog;
use verilog.vl_types.all;
entity RC4 is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        key_valid       : in     vl_logic;
        key_in          : in     vl_logic_vector(7 downto 0);
        plain_read      : out    vl_logic;
        plain_in_valid  : in     vl_logic;
        plain_in        : in     vl_logic_vector(7 downto 0);
        plain_write     : out    vl_logic;
        plain_out       : out    vl_logic_vector(7 downto 0);
        cipher_write    : out    vl_logic;
        cipher_out      : out    vl_logic_vector(7 downto 0);
        cipher_read     : out    vl_logic;
        cipher_in       : in     vl_logic_vector(7 downto 0);
        cipher_in_valid : in     vl_logic;
        done            : out    vl_logic
    );
end RC4;

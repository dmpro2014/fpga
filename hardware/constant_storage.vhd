library ieee;
use ieee.std_logic_1164.all;
use work.defines.all;

entity constant_storage is
 generic( 
          MEMORY_DEPTH_BITS: integer := 4
  );
  port(
        clk: in std_logic;
        write_constant_in: in word_t;
        write_enable_in : in std_logic;
        write_address_in: in std_logic_vector(MEMORY_DEPTH_BITS -1 downto 0);
        constant_value_out: out word_t;
        constant_select_in: in std_logic_vector(MEMORY_DEPTH_BITS -1 downto 0)
  );

end constant_storage;

architecture rtl of constant_storage is
begin


end rtl;


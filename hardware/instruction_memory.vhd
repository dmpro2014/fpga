library ieee;
use ieee.std_logic_1164.all;
use work.defines.all;

entity instruction_memory is
    port ( clk : in std_logic;
           reset : in std_logic;
           write_enable : in std_logic;
           address_in : in  instruction_address_t;
           data_in : in instruction_t;
           data_out : out instruction_t);
end instruction_memory;

architecture behavioral of instruction_memory is

begin


end behavioral;
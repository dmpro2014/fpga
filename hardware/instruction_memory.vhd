library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.defines.all;

entity instruction_memory is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           write_enable : in STD_LOGIC;
           address_in : in  STD_LOGIC_VECTOR (15 downto 0);
           data_in : in instruction_t;
           data_out : out instruction_t);
end instruction_memory;

architecture Behavioral of instruction_memory is

begin


end Behavioral;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.defines.all;

entity pc is
    Port ( clk : in std_logic;
           reset: in std_logic;
           write_enable : in std_logic;
           pc_in : in instruction_address_t;
					 pc_input_select_in: in std_logic;
           pc_out : out instruction_address_t
           );
end pc;

architecture Behavioral of pc is

begin


end Behavioral;
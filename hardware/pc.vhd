library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pc is
    Port ( clk : in std_logic;
           write_enable : in std_logic;
           pc_in : in std_logic_vector (15 downto 0);
           pc_out : out std_logic_vector (15 downto 0));
end pc;

architecture Behavioral of pc is

begin


end Behavioral;
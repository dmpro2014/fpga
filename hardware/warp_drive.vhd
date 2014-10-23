library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.defines.all;

entity warp_drive is
    Port (  clk : in std_logic;
					  pc_write_enable_out: out std_logic;
						active_barrel_row_out: out std_logic_vector(BARREL_HEIGHT_BIT_WIDTH -1 downto 0)
		);
		
end warp_drive;

architecture rtl of warp_drive is
begin
end rtl;
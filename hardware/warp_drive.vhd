library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity warp_drive is
    generic(
      BARREL_BIT_WIDTH: integer 
    );
    port (  tick: in std_logic;
            reset: in std_logic;
					  pc_write_enable_out: out std_logic;
						active_barrel_row_out: out std_logic_vector(BARREL_BIT_WIDTH -1 downto 0)
		);
		
end warp_drive;

architecture rtl of warp_drive is
begin
end rtl;
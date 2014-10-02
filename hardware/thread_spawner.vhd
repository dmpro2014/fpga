library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity thread_spawner is
    Port ( control_dead : in  STD_LOGIC;
           complete_out : out STD_LOGIC;
           pc_out : out STD_LOGIC_VECTOR (15 downto 0);
           pc_write_enable_out : out STD_LOGIC;
           thread_ids_out : out STD_LOGIC_VECTOR (15 downto 0));
end thread_spawner;

architecture Behavioral of thread_spawner is

begin


end Behavioral;
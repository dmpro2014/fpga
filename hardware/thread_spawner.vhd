library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.defines.all;

entity thread_spawner is
    Port ( clk : in std_logic;
					thread_done_in: in std_logic;
					--Engage signal
					kernel_start_in: in std_logic;
					kernel_addr_in: in instruction_address_t;
					kernel_complete_out: out std_logic;
					
					num_threads_in: in thread_id_t;
					pc_start_out: out instruction_address_t;
					pc_input_select_out: out std_logic;
					thread_id_out : out thread_id_t;
					id_write_enable_out: out std_logic);
			
end thread_spawner;

architecture Behavioral of thread_spawner is

begin


end Behavioral;
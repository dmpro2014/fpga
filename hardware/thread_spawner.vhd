library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.defines.all;
use IEEE.NUMERIC_STD.ALL;

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
  signal kernel_addr_reg  : instruction_address_t;
  signal thread_number_reg: thread_id_t;
  signal next_id_reg      : thread_id_t;
  signal next_id_in       : thread_id_t;
  signal num_minus_next_id : thread_id_t;
  signal kernels_left     : thread_id_t;
  signal spawn_new_threads: std_logic;
  signal last_spawned     : std_logic;
  signal reset_pc        : std_logic;
begin

  spawn_new_threads <= kernel_start_in or thread_done_in;
  
  pc_start_out <= kernel_addr_reg;
  
  thread_id_out <= next_id_reg;
  
  num_minus_next_id <= std_logic_vector(signed(thread_number_reg) - signed(next_id_reg));
  
  kernels_left <= std_logic_vector(signed(num_minus_next_id) 
                + to_signed(BARREL_HEIGHT * NUMBER_OF_STREAMING_PROCESSORS, ID_WIDTH));
                
  kernel_complete_out <= '1' when signed(kernels_left) <= 0
                    else '0';

  last_spawned <= '1' when signed(num_minus_next_id) <= 0
             else '0';
  
  reset_pc  <= spawn_new_threads and not last_spawned;
  
  pc_input_select_out <= reset_pc;
  id_write_enable_out <= reset_pc;
  
  next_id_in <= next_id_reg when spawn_new_threads = '1'
           else std_logic_vector(unsigned(next_id_reg) + to_unsigned(BARREL_HEIGHT, ID_WIDTH)); 

  process(kernel_start_in, kernel_addr_in) is
  begin
    if kernel_start_in = '1' then
      kernel_addr_reg <= kernel_addr_in;
    end if;
  end process;
  
  process(kernel_start_in, num_threads_in) is
  begin
    if kernel_start_in = '1' then
      thread_number_reg <= num_threads_in;
    end if;
  end process;
  
  process(kernel_start_in, clk) is
  begin
    if kernel_start_in = '1' then
      next_id_reg <= (others => '0');
    elsif rising_edge(clk) then
      next_id_reg <= next_id_in;
    end if;
  end process;
  
  
  


end Behavioral;
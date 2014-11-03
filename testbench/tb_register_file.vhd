

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_register_file is
end tb_register_file;

architecture behavior of tb_register_file is 
  -- General registers
  signal clk: std_logic;
  signal read_register_1_in: std_logic_vector(REGISTER_COUNT_BIT_WIDTH -1 downto 0);
  signal read_register_2_in: std_logic_vector(REGISTER_COUNT_BIT_WIDTH -1 downto 0);
  signal write_register_in: std_logic_vector(REGISTER_COUNT_BIT_WIDTH -1 downto 0);
  signal write_data_in: word_t;
  signal register_write_enable_in: std_logic;
  signal read_data_1: word_t;
  signal read_data_2: word_t;
  
  -- ID register
  signal id_register_write_enable_in: std_logic;
  signal id_register_in: thread_id_t;
  
  -- Return Registers
  signal return_register_write_enable_in: std_logic;
  signal return_data_in : word_t;
  signal lsu_write_data_out: word_t;
  
  constant clk_period: time := 10 ns;
begin

-- component instantiation
        register_file: entity work.register_file
        port map(
              clk => clk,
              read_register_1_in => read_register_1_in,
              read_register_2_in => read_register_2_in,
              write_register_in => write_register_in,
              write_data_in => write_data_in,
              register_write_enable_in => register_write_enable_in,
              read_data_1 => read_data_1,
              read_data_2 => read_data_2,
              id_register_write_enable_in => id_register_write_enable_in,
              id_register_in => id_register_in,
              return_register_write_enable_in => return_register_write_enable_in,
              return_data_in => return_data_in,
              lsu_write_data_out => lsu_write_data_out     
        );


--  test bench statements
   tb : process
   begin

      wait for 100 ns; -- wait until global set/reset completes

      -- add user defined stimulus here

      wait; -- will wait forever
   end process tb;
--  end test bench 

end;

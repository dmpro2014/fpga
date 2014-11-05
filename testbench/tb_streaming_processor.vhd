-- testbench template 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defines.all;
use work.utils.all;
use work.test_utils.all;

entity tb_streaming_processor is
end tb_streaming_processor;

architecture behavior of tb_streaming_processor is 

  signal clk                : std_logic := '0';
  signal read_reg_1_in        : register_address_t := (others => '0');
  signal read_reg_2_in        : register_address_t := (others => '0');
  signal write_reg_in         : register_address_t := (others => '0');
  signal immediate_in         : immediate_value_t := (others => '0');
  signal immediate_enable_in  : std_logic := '0';
  signal shamt_in             : std_logic_vector(4 downto 0) := (others => '0');
  signal reg_write_enable_in  : std_logic := '0';
  signal mask_enable_in       : std_logic := '0';
  signal alu_function_in      : alu_funct_t := (others => '0');
  signal id_data_in           : thread_id_t := (others => '0');
  signal id_write_enable_in   : std_logic := '0';
  signal barrel_select_in     : barrel_row_t := (others => '0');
  signal return_write_enable_in : std_logic := '0';
  signal return_barrel_select_in : barrel_row_t := (others => '0');
  signal return_data_in       : word_t := (others => '0');
  signal lsu_write_data_out   : word_t := (others => '0');
  signal lsu_address_out      : memory_address_t := (others => '0');
  signal constant_write_enable_in : std_logic := '0';
  signal constant_value_in    : word_t := (others => '0');

  constant clk_period : time := 10 ns;
  function get_reg_addr(reg:integer) return std_logic_vector is
   begin
    return make_reg_addr(reg, REGISTER_COUNT_BIT_WIDTH);
   end;

begin

    uut: entity work.streaming_processor 
    port map(
              clock => clk,
              read_reg_1_in => read_reg_1_in,
              read_reg_2_in => read_reg_2_in,
              write_reg_in => write_reg_in,
              immediate_in => immediate_in,
              immediate_enable_in => immediate_enable_in,
              shamt_in => shamt_in,
              reg_write_enable_in => reg_write_enable_in,
              mask_enable_in => mask_enable_in,
              alu_function_in => alu_function_in,
              id_data_in => id_data_in,
              id_write_enable_in => id_write_enable_in,
              barrel_select_in => barrel_select_in,
              return_write_enable_in => return_write_enable_in,
              return_barrel_select_in => return_barrel_select_in,
              return_data_in => return_data_in,
              lsu_write_data_out => lsu_write_data_out,
              lsu_address_out => lsu_address_out,
              constant_write_enable_in => constant_write_enable_in,
              constant_value_in =>  constant_value_in
    );

  clk_process :process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

--  test bench statements
   tb : process
   begin
      -- Begin by loading registers with immediate values 
      write_reg_in <= get_reg_addr(register_address_lo);
      immediate_in <= make_word(31457);
      immediate_enable_in <= '1';
      wait for clk_period;
      assert_equals(immediate_in, lsu_address_out(WORD_WIDTH -1 downto 0), "blablabla");
      wait for 100 ns; 

      -- add user defined stimulus here

      wait; -- will wait forever
   end process tb;
--  end test bench 

end;

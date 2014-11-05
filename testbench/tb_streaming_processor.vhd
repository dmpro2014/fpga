-- testbench template 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defines.all;
use work.utils.all;
use work.test_utils.all;
use work.alu_defines.all;

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
    procedure load_immediate_to(reg:integer; value:integer) is
     begin
      read_reg_1_in <= get_reg_addr(register_zero);
      write_reg_in <= get_reg_addr(reg);
      immediate_in <= make_word(value);
      immediate_enable_in <= '1';
      reg_write_enable_in <= '1';
      alu_function_in <= ALU_FUNCTION_ADD;
      wait for clk_period;
      immediate_enable_in <= '0';
      reg_write_enable_in <= '0';
    end procedure load_immediate_to;
   procedure execute_arithmetic_op(op: alu_funct_t; read_reg_1: integer; read_reg_2: integer; write_reg: integer) is
    begin
     read_reg_1_in <= get_reg_addr(read_reg_1);
     read_reg_2_in <= get_reg_addr(read_reg_2);
     write_reg_in <= get_reg_addr(write_reg);
     alu_function_in <= op;
     reg_write_enable_in <= '1';
     wait for clk_period;
     reg_write_enable_in <= '0';
     
   end procedure execute_arithmetic_op;
   procedure assert_special_registers is
    begin
      for row in 0 to BARREL_HEIGHT -1 loop
       barrel_select_in <= make_row(row);
       load_immediate_to(register_address_lo, 31457 + row);       
      end loop;

      for row in 0 to BARREL_HEIGHT -1 loop
        barrel_select_in <= make_row(row);
        load_immediate_to(register_address_hi, row);       
      end loop;
      
      for row in 0 to BARREL_HEIGHT -1 loop
        barrel_select_in <= make_row(row);
        wait for 1 ns;
        assert_equals(make_word(31457 + row), lsu_address_out(WORD_WIDTH -1 downto 0), "Address low should contain the value loaded using add imm.");
        assert_equals(to_logic_vector(row, 3), lsu_address_out(DATA_ADDRESS_WIDTH-1 downto WORD_WIDTH), "Address high should contain the value loaded using add imm.");
      end loop;
      
      -- "Move" register address into data
      for row in 0 to BARREL_HEIGHT -1 loop
       barrel_select_in <= make_row(row);
       execute_arithmetic_op(ALU_FUNCTION_ADD, 0, register_address_lo, register_lsu_data);
      end loop;
      
      for row in 0 to BARREL_HEIGHT -1 loop
       barrel_select_in <= make_row(row);
       wait for 1 ns;
       assert_equals(make_word(31457 + row), lsu_write_data_out, "Address low should have been moved into lsu data out.");
      end loop;

      for row in 0 to BARREL_HEIGHT -1 loop
       barrel_select_in <= make_row(row);
       execute_arithmetic_op(ALU_FUNCTION_ADD, 0, register_address_hi, register_lsu_data);
      end loop;
      
      for row in 0 to BARREL_HEIGHT -1 loop
       barrel_select_in <= make_row(row);
       wait for 1 ns;
       assert_equals(make_word(row), lsu_write_data_out, "Address hi should have been moved into lsu data out.");
      end loop;
      
 
   end procedure assert_special_registers;
   begin
      -- Begin by loading registers with immediate values 
      -- Simluate barrel rolls
      assert_special_registers;
      wait for 100 ns; 

      -- add user defined stimulus here

      wait; -- will wait forever
   end process tb;
--  end test bench 

end;

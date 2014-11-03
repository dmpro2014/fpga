library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defines.all;
use work.test_utils.all;

entity tb_register_file is
end tb_register_file;

architecture behavior of tb_register_file is 

  constant reg_addr_bits: integer := 4;
  constant num_registers: integer := 16;
  -- General registers
  signal clk: std_logic;
  signal read_register_1_in: std_logic_vector(reg_addr_bits -1 downto 0);
  signal read_register_2_in: std_logic_vector(reg_addr_bits -1 downto 0);
  signal write_register_in: std_logic_vector(reg_addr_bits -1 downto 0);
  signal write_data_in: word_t;
  signal register_write_enable_in: std_logic;
  signal read_data_1_out: word_t;
  signal read_data_2_out: word_t;
  
  -- ID register
  signal id_register_write_enable_in: std_logic;
  signal id_register_in: thread_id_t;
  signal lsu_address_out: memory_address_t;
  
  -- Return Registers
  signal lsu_data_inout: word_t;
  signal return_register_write_enable_in: std_logic;
  
  -- Masking
  signal predicate_out: std_logic;
  constant clk_period: time := 10 ns;
  
  -- Constant storage
  signal constant_value_in: word_t;
  signal constant_write_enable_in: std_logic;
  function get_reg_addr(reg: integer) return std_logic_vector is
    begin
      return std_logic_vector(to_unsigned(reg, reg_addr_bits));
   end;
   
  function make_word(word: integer) return std_logic_vector is
   begin
    return std_logic_vector(to_unsigned(word, WORD_WIDTH));
 end;

 begin

-- component instantiation
        register_file: entity work.register_file
        generic map(
              DEPTH => num_registers,
              LOG_DEPTH => reg_addr_bits
        )
        port map(
              clk => clk,
              read_register_1_in => read_register_1_in,
              read_register_2_in => read_register_2_in,
              write_register_in => write_register_in,
              write_data_in => write_data_in,
              register_write_enable_in => register_write_enable_in,
              read_data_1_out => read_data_1_out,
              read_data_2_out => read_data_2_out,
              id_register_write_enable_in => id_register_write_enable_in,
              id_register_in => id_register_in,
              return_register_write_enable_in => return_register_write_enable_in,
              lsu_data_inout => lsu_data_inout,
              lsu_address_out => lsu_address_out,
              constant_value_in => constant_value_in,
              predicate_out => predicate_out,
              constant_write_enable_in => constant_write_enable_in
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
     constant ALL_BITS_HIGH: memory_address_t := (others => '1');
    begin

      -- Test special registers first
      -- Register $0
      read_register_1_in <= get_reg_addr(0);
      read_register_2_in <= get_reg_addr(0);
      wait for clk_period;
      assert_equals(make_word(0), read_data_1_out, "Register $0 should be zero.");
      assert_equals(make_word(0), read_data_2_out, "Register $0 should be zero.");
      write_register_in <= get_reg_addr(0);
      write_data_in <= make_word(1);
      wait for clk_period;
      assert_equals(make_word(0), read_data_1_out, "Register $0 should be write only.");
      assert_equals(make_word(0), read_data_2_out, "Register $0 should be write only.");
      

      -- Register $1,$2 ID HI,LOW      
      id_register_write_enable_in <= '1';
      id_register_in <= "1111111111111111111"; 
      read_register_1_in <= get_reg_addr(1);
      read_register_2_in <= get_reg_addr(2);
      wait for clk_period;
      assert_equals(make_word(7), read_data_1_out, "ID value should be split into high and low registers.");
      assert_equals("1111111111111111", read_data_2_out, "ID value should be split into high and low registers.");
      write_register_in <= get_reg_addr(1);
      write_data_in <= make_word(4);
      register_write_enable_in <= '1';
      wait for clk_period;
      write_register_in <= get_reg_addr(2);
      wait for clk_period;
      assert_equals(make_word(7), read_data_1_out, "ID should be readonly.");
      assert_equals("1111111111111111", read_data_2_out, "ID should be readonly.");
        
      -- Address high/low can be treaded as general purpose registers.
      -- Only difference is that their out should also be in lsu_data.
      -- Register $3 address high
      -- Test general purpose first
      -- add user defined stimulus here
      register_write_enable_in <= '1';
      read_register_1_in <= get_reg_addr(3);
      read_register_2_in <= get_reg_addr(4);
      write_register_in <= get_reg_addr(3);
      write_data_in <= (others => '1');
      wait for clk_period;
      write_register_in <= get_reg_addr(4);
      -- Write to both registers
      wait for clk_period;
      assert_equals(write_data_in, read_data_1_out, "Should be treated as a general purpose register.");
      assert_equals(write_data_in, read_data_2_out, "Should be treated as a general purpose register.");
      -- Test special feature
      assert_equals(ALL_BITS_HIGH, lsu_address_out, "LSU address should consist of Address low and high bits from address high."); 
    
     --Return register($5) is also a general purpose register
     --Test general purpose first
     read_register_1_in <= get_reg_addr(5);
     write_register_in <= get_reg_addr(5);
     write_data_in <= make_word(23648912);
     
     wait for clk_period;
     assert_equals(make_word(23648912), read_data_1_out, "Should be treated as a general purpose register..");
     --Test write from lsu
     write_register_in <= get_reg_addr(0);
     register_write_enable_in <= '0';
     return_register_write_enable_in <= '1';
     lsu_data_inout <= make_word(9);
     wait for clk_period;
     assert_equals(make_word(9), read_data_1_out, "LSU should be able to write result");
      
     --Mask register
     read_register_1_in <= get_reg_addr(6);
     register_write_enable_in <= '1';
     write_data_in <= make_word(1);
     wait for clk_period;
     assert_equals('1', predicate_out, "Predicate should be writable.");
     
     register_write_enable_in <= '1';
     --Test other general registers
      for i in 6 to num_registers loop
        read_register_1_in <= get_reg_addr(i);
        read_register_2_in <= get_reg_addr(i);
        write_register_in <= get_reg_addr(i);
        write_data_in <= make_word(30 + i);
        wait for clk_period;
        assert_equals(make_word(30 + i), read_data_1_out, "Should be able to read/write general purpose register.");
        assert_equals(make_word(30 + i), read_data_2_out, "Should be able to read/write general purpose register.");
      end loop;
      wait; -- will wait forever
   end process tb;
  --  end test bench 

end;

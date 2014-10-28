  library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.test_utils.all;
  use work.defines.all;
  
  entity tb_constant_storage is
  end tb_constant_storage;

  architecture behavior of tb_constant_storage is 
    
  signal clk : std_logic;

  

  signal write_constant_in: word_t;
  signal write_enable_in : std_logic;
  signal write_address_in: std_logic_vector(1 downto 0);
  signal constant_value_out: word_t;
  signal constant_select_in: std_logic_vector(1 downto 0);
  
  constant clk_period: time := 10 ns;
  begin

  -- component instantiation
      uut: entity work.constant_storage 
      generic map(
        MEMORY_DEPTH_BITS => 2
      )
      port map(
            clk => clk,
            write_constant_in => write_constant_in,
            write_enable_in => write_enable_in,
            write_address_in => write_address_in,
            constant_value_out => constant_value_out,
            constant_select_in => constant_select_in

      );

   -- Clock process definitions
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
          write_constant_in <= "01";
          write_address_in  <= "10";
          constant_select_in <= "10";
          write_enable_in <= '1';
          wait for 1 ns;
          
          assert_equals("01", constant_value_out, "Memory should contain 01 at address 10");
          write_constant_in <= "11";
          write_address_in  <= "11";
          constant_select_in <= "11";      
          wait for 1 ns;
          
          assert_equals("11", constant_value_out, "Memory should contain 11 at address 11");
          write_enable_in <= '0';
          write_constant_in <= "10";
          wait for 1 ns;
          assert_equals("11", constant_value_out, "Memory should only write when write enable is high");
          
          wait;
       end process tb;
  --  end test bench 

  end;

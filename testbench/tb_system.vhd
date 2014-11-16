LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.defines.all;
USE work.test_utils.all;

ENTITY tb_system IS
END tb_system;

ARCHITECTURE behavior OF tb_system IS 

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal clk_sys_out : std_logic := '0';
   signal hdmi_bus_control_in : sram_bus_control_t;
   signal vga_bus_control_in : sram_bus_control_t;
   signal ebi_control_in : ebi_control_t;
   signal mc_sram_flip_in : std_logic := '0';

   --BiDirs
   signal sram_bus_data_1_inout : sram_bus_data_t;
   signal sram_bus_data_2_inout : sram_bus_data_t;
   signal hdmi_bus_data_inout : sram_bus_data_t;
   signal vga_bus_data_inout : sram_bus_data_t;
   signal ebi_data_inout : ebi_data_t;
   signal mc_spi_bus : spi_bus_t;

   --Outputs
   signal sram_bus_control_1_out : sram_bus_control_t;
   signal sram_bus_control_2_out : sram_bus_control_t;
   signal mc_kernel_complete_out : std_logic;
   signal led_1_out : std_logic;
   signal led_2_out : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;

   -- Memory
   type mem_t is array(30000 - 1 downto 0) of word_t;
   signal sram_a : mem_t := (others => (others => '0'));
   signal sram_b : mem_t := (others => (others => '0'));

BEGIN

  -- Instantiate the Unit Under Test (UUT)
  uut: entity work.System
  PORT MAP (
             clk => clk,
             reset => reset,
             clk_sys_out => clk_sys_out,
             sram_bus_data_1_inout => sram_bus_data_1_inout,
             sram_bus_control_1_out => sram_bus_control_1_out,
             sram_bus_data_2_inout => sram_bus_data_2_inout,
             sram_bus_control_2_out => sram_bus_control_2_out,
             ebi_data_inout => ebi_data_inout,
             ebi_control_in => ebi_control_in,
             mc_kernel_complete_out => mc_kernel_complete_out,
             mc_frame_buffer_select_in => mc_sram_flip_in,
             mc_spi_bus => mc_spi_bus,
             led_1_out => led_1_out,
             led_2_out => led_2_out
           );

   -- Clock process definitions
  clk_process :process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

  mem_proc: process (clk) is
  begin

    if rising_edge(clk) then
      sram_bus_data_1_inout <= (others => 'Z');
      sram_bus_data_2_inout <= (others => 'Z');

      if sram_bus_control_1_out.write_enable_n = '0' then
        sram_a(to_integer(unsigned(sram_bus_control_1_out.address))) <= sram_bus_data_1_inout;
      else
        sram_bus_data_1_inout <= sram_a(to_integer(unsigned(sram_bus_control_1_out.address)));
      end if;

      if sram_bus_control_2_out.write_enable_n = '0' then
        sram_b(to_integer(unsigned(sram_bus_control_2_out.address))) <= sram_bus_data_2_inout;
      else
        sram_bus_data_2_inout <=  sram_b(to_integer(unsigned(sram_bus_control_2_out.address)));
      end if;
    end if;
  end process;


   -- Stimulus process
  stim_proc: process

     procedure write_instruction(instruction : in instruction_t
                                ;address     : in instruction_address_t
                                ) is begin
       ebi_data_inout <= instruction(31 downto 16);
       ebi_control_in.address <= "001" & address & '0';
       ebi_control_in.write_enable_n <= '0';
       ebi_control_in.read_enable_n <= '1';
       ebi_control_in.chip_select_fpga_n <= '0';
       wait on clk_sys_out until rising_edge(clk_sys_out);

       ebi_data_inout <= instruction(15 downto 0);
       ebi_control_in.address <= "001" & address & '1';
       ebi_control_in.write_enable_n <= '0';
       ebi_control_in.chip_select_fpga_n <= '0';
       wait on clk_sys_out until rising_edge(clk_sys_out);

       ebi_control_in.write_enable_n <= '1';
       ebi_control_in.chip_select_fpga_n <= '1';
     end procedure;

     procedure check_memory(data : in word_t
                           ;address : in integer
                           ) is begin
       if address mod 2 = 0 then
          assert_equals(data, sram_a(address/2), "Data memory check");
       else
          assert_equals(data, sram_b(address/2), "Data memory check");
       end if;
     end procedure;

     type InstrData is array (natural range<>) of instruction_t;

     procedure fill_instruction_memory(instruction_data : in InstrData) is
     begin
       for i in 0 to instruction_data'LENGTH-1 loop
         write_instruction(instruction_data(i), std_logic_vector(to_unsigned(i, INSTRUCTION_ADDRESS_WIDTH)));
       end loop;
     end fill_instruction_memory;

     constant KERNEL_SRL : InstrData := (
       X"00000000", -- nop
       X"00022801", -- srl $5, $2, 0
       X"00011820", -- add $3, $0, $1
       X"00022020", -- add $4, $0, $2
       X"10000000", -- sw
       X"00000000", -- nop
       X"00000000", -- nop
       X"00000000", -- nop
       X"00000000", -- nop
       X"00000000", -- nop
       X"00000000", -- nop
       X"00000000", -- nop
       X"00000000", -- nop
       X"00000000", -- nop
       X"00000000", -- nop
       X"00000000", -- nop
       X"00000000", -- nop
       X"00000000", -- nop
       X"00000000", -- nop
       X"00000000", -- nop
       X"00000000", -- nop
       X"40000000" --finished
     );
     constant BATCHES_SRL : integer := 100;

   begin
      -- hold reset state for 100 ns.
      wait for 100 ns;

      ebi_control_in.write_enable_n <= '1';
      ebi_control_in.chip_select_fpga_n <= '1';
      ebi_control_in.chip_select_sram_n <= '1';

      fill_instruction_memory(KERNEL_SRL);

      wait for clk_period*30;

      --Start kernel
      ebi_data_inout <= std_logic_vector(to_unsigned(BATCHES_SRL, WORD_WIDTH)); -- Number of batches
      ebi_control_in.address <= "010000000000000000000"; -- Start at instruction mem 0. Bit 18 1 means start kernel
      ebi_control_in.write_enable_n <= '0';
      ebi_control_in.chip_select_fpga_n <= '0';
      wait on clk_sys_out until rising_edge(clk_sys_out);
      ebi_control_in.write_enable_n <= '1';

      --Wait
      wait on mc_kernel_complete_out until mc_kernel_complete_out = '1';

      --Check memory
      for i in 0 to BATCHES_SRL * BARREL_HEIGHT * NUMBER_OF_STREAMING_PROCESSORS - 1 loop
        check_memory(std_logic_vector(to_unsigned(i,16)), i);
      end loop;


      report "TEST SUCCESS!" severity failure;
      wait;
   end process;

END;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.defines.all;
USE work.test_utils.all;
 
ENTITY tb_system IS
END tb_system;
 
ARCHITECTURE behavior OF tb_system IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT System
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         sram_bus_data_1_inout : INOUT  sram_bus_data_t;
         sram_bus_control_1_out : OUT  sram_bus_control_t;
         sram_bus_data_2_inout : INOUT  sram_bus_data_t;
         sram_bus_control_2_out : OUT  sram_bus_control_t;
         hdmi_bus_data_inout : INOUT  sram_bus_data_t;
         hdmi_bus_control_in : IN  sram_bus_control_t;
         vga_bus_data_inout : INOUT  sram_bus_data_t;
         vga_bus_control_in : IN  sram_bus_control_t;
         ebi_data_inout : INOUT  ebi_data_t;
         ebi_control_in : IN  ebi_control_t;
         mc_kernel_complete_out : OUT  std_logic;
         mc_sram_flip_in : IN  std_logic;
         mc_spi_bus : INOUT  spi_bus_t;
         led_1_out : OUT  std_logic;
         led_2_out : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
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
   type mem_t is array(1024 - 1 downto 0) of word_t;
   signal sram_a : mem_t := (others => (others => 'U'));
   signal sram_b : mem_t := (others => (others => 'U'));

BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: System PORT MAP (
          clk => clk,
          reset => reset,
          sram_bus_data_1_inout => sram_bus_data_1_inout,
          sram_bus_control_1_out => sram_bus_control_1_out,
          sram_bus_data_2_inout => sram_bus_data_2_inout,
          sram_bus_control_2_out => sram_bus_control_2_out,
          hdmi_bus_data_inout => hdmi_bus_data_inout,
          hdmi_bus_control_in => hdmi_bus_control_in,
          vga_bus_data_inout => vga_bus_data_inout,
          vga_bus_control_in => vga_bus_control_in,
          ebi_data_inout => ebi_data_inout,
          ebi_control_in => ebi_control_in,
          mc_kernel_complete_out => mc_kernel_complete_out,
          mc_sram_flip_in => mc_sram_flip_in,
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
       if sram_bus_control_1_out.write_enable_n = '0' then
         sram_a(to_integer(unsigned(sram_bus_control_1_out.address))) <= sram_bus_data_1_inout.data;
       end if;
       
       if sram_bus_control_2_out.write_enable_n = '0' then
         sram_b(to_integer(unsigned(sram_bus_control_2_out.address))) <= sram_bus_data_2_inout.data;
       end if;
     end if;
   end process;
 

   -- Stimulus process
   stim_proc: process
   
     procedure write_instruction(instruction : in instruction_t
                                ;address     : in instruction_address_t
                                ) is begin
       ebi_data_inout <= instruction(31 downto 16);
       ebi_control_in.address <= "01" & address & '0';
       ebi_control_in.write_enable_n <= '0';
       ebi_control_in.read_enable_n <= '1';
       ebi_control_in.chip_select_fpga_n <= '0';
       wait until rising_edge(clk);
       
       ebi_data_inout <= instruction(15 downto 0);
       ebi_control_in.address <= "01" & address & '1';
       ebi_control_in.write_enable_n <= '0';
       ebi_control_in.chip_select_fpga_n <= '0';
       wait until rising_edge(clk);
       
       ebi_control_in.write_enable_n <= '1';
       ebi_control_in.chip_select_fpga_n <= '1';
     end procedure;
     
     procedure check_memory(data : in word_t
                           ;address : in integer
                           ) is begin
       assert_equals(data, sram_a(address), "Data memory check");
     end procedure;
     
     
     procedure FillInstructionMemory is
			constant TEST_INSTRS : integer := 22;
			type InstrData is array (0 to TEST_INSTRS-1) of instruction_t;
			variable TestInstrData : InstrData := (
                    X"00000000", -- nop
				X"000228c1", -- srl $5, $2, 3
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
				X"40021820" --finished
				);
		begin
			for i in 0 to TEST_INSTRS-1 loop
				write_instruction(TestInstrData(i), std_logic_vector(to_unsigned(i, INSTRUCTION_ADDRESS_WIDTH)));
			end loop;
		end FillInstructionMemory;
   
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;

      ebi_control_in.write_enable_n <= '1';
      ebi_control_in.chip_select_fpga_n <= '1';
      ebi_control_in.chip_select_sram_n <= '1';

      FillInstructionMemory;

      wait for clk_period*10;

      --Start kernel
      ebi_data_inout <= std_logic_vector(to_unsigned(2, WORD_WIDTH)); -- Number of batches
      ebi_control_in.address <= "1000000000000000000"; -- Start at instruction mem 0. The MSB 1 means start kernel
      ebi_control_in.write_enable_n <= '0';
      ebi_control_in.chip_select_fpga_n <= '0';

      -- As the implementation is now, we need to hold the start-
      -- signal for exactly barrel-height plus one number of cycles. 
      -- TODO: This should not be nessesary in this test.
      wait for clk_period*(BARREL_HEIGHT+1);
      ebi_control_in.write_enable_n <= '1';

      --Wait
      wait for clk_period*300;

      --Check memory

      check_memory(x"0000", 0);
      check_memory(x"0001", 8);
      check_memory(x"000C", 100);
      
      

      wait;
   end process;

END;

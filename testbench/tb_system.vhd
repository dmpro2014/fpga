LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
--USE ieee.numeric_std.ALL;
 
ENTITY tb_system IS
END tb_system;
 
ARCHITECTURE behavior OF tb_system IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT System
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         sram_bus_data_1_inout : INOUT  std_logic;
         sram_bus_control_1_out : OUT  std_logic;
         sram_bus_data_2_inout : INOUT  std_logic;
         sram_bus_control_2_out : OUT  std_logic;
         hdmi_bus_data_inout : INOUT  std_logic;
         hdmi_bus_control_in : IN  std_logic;
         vga_bus_data_inout : INOUT  std_logic;
         vga_bus_control_in : IN  std_logic;
         ebi_data_inout : INOUT  std_logic_vector(15 downto 0);
         ebi_control_in : IN  std_logic;
         mc_kernel_complete_out : OUT  std_logic;
         mc_sram_flip_in : IN  std_logic;
         mc_spi_bus : INOUT  std_logic_vector(4 downto 0);
         led_1_out : OUT  std_logic;
         led_2_out : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal hdmi_bus_control_in : std_logic := '0';
   signal vga_bus_control_in : std_logic := '0';
   signal ebi_control_in : std_logic := '0';
   signal mc_sram_flip_in : std_logic := '0';

	--BiDirs
   signal sram_bus_data_1_inout : std_logic;
   signal sram_bus_data_2_inout : std_logic;
   signal hdmi_bus_data_inout : std_logic;
   signal vga_bus_data_inout : std_logic;
   signal ebi_data_inout : std_logic_vector(15 downto 0);
   signal mc_spi_bus : std_logic_vector(4 downto 0);

 	--Outputs
   signal sram_bus_control_1_out : std_logic;
   signal sram_bus_control_2_out : std_logic;
   signal mc_kernel_complete_out : std_logic;
   signal led_1_out : std_logic;
   signal led_2_out : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
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
 

   -- Stimulus process
   stim_proc: process
   
    procedure write_instruction(instruction : in instruction_t
                                ;address     : in instruction_address_t
                                ) is begin
             
     end procedure;
     
     procedure FillInstructionMemory is
			constant TEST_INSTRS : integer := 30;
			type InstrData is array (0 to TEST_INSTRS-1) of instruction_t;
			variable TestInstrData : InstrData := (
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"40221820" --finished
				);
		begin
			for i in 0 to TEST_INSTRS-1 loop
				write_instruction(TestInstrData(i), std_logic_vector(to_unsigned(i, INSTRUCTION_ADDRESS_WIDTH)));
			end loop;
		end FillInstructionMemory;
   
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
      FillInstructionMemory;
      
      wait for clk_period*10;
      
      --Start kernel
      --Wait
      --Check memory
      
      wait;
   end process;

END;

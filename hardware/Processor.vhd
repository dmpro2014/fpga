library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.defines.all;
--use IEEE.NUMERIC_STD.ALL;

entity Processor is
  Port ( -- Stuff
         clk : in STD_LOGIC;

         -- SRAM
         sram_1_data : inout sram_bus_data_t;
         sram_1_control : out sram_bus_control_t;

         sram_2_data : inout sram_bus_data_t;
         sram_2_control : out sram_bus_control_t;

         -- HDMI && VGA
         hdmi_out : out STD_LOGIC_VECTOR (18 downto 0);
         vga_out : out STD_LOGIC_VECTOR (15 downto 0);

         -- MC
         mc_ebi_bus : inout ebi_bus_t;
         mc_spi_bus : inout spi_bus_t;

         -- Generic IO
         led_1_out : out STD_LOGIC;
         led_2_out : out STD_LOGIC);

end Processor;

architecture Behavioral of Processor is

  -- PC
  signal pc_out : std_logic_vector (15 downto 0);

  -- Communication unit
  signal comm_sram_override_out : STD_LOGIC;
  signal comm_sram_flip_out : STD_LOGIC;

  signal comm_sram_bus_data_out : sram_bus_data_t;
  signal comm_sram_bus_control_out : sram_bus_control_t;

  signal comm_instruction_data_out : word_t;
  signal comm_instruction_address_out : STD_LOGIC_VECTOR(15 downto 0);
  signal comm_instruction_write_enable_out : STD_LOGIC;

  signal comm_reset_system_out : STD_LOGIC;

  -- Thread spawner
  signal kernel_completed_out : STD_LOGIC;
  signal pc_write_enable_out : STD_LOGIC;

  -- MUX units
  signal mux_pc_in_out : STD_LOGIC_VECTOR(15 downto 0);
  signal mux_instruction_memory_address_in_out : STD_LOGIC_VECTOR(15 downto 0);

  -- Instruction memory
  signal instruction_data_out : STD_LOGIC_VECTOR(15 downto 0);

begin

  -- Normal components

  communication_unit : entity work.communication_unit
  port map(
            clk => clk,
            ebi_bus_in => mc_ebi_bus,
            spi_bus_in => mc_spi_bus,
            kernel_completed_in => kernel_completed_out,

            command_sram_override_out => comm_sram_override_out,
            command_sram_flip_out => comm_sram_flip_out,

            instruction_data_out => comm_instruction_data_out,
            instruction_address_out => comm_instruction_address_out,
            instruction_write_enable_out => comm_instruction_write_enable_out,

            sram_bus_data_inout => comm_sram_bus_data_out,
            sram_bus_control_out => comm_sram_bus_control_out,

            comm_reset_system_out => comm_reset_system_out
          );

  pc : entity work.pc
  port map(
            clk => clk,
            write_enable => pc_write_enable_out,
            pc_in => mux_pc_in_out,
            pc_out => pc_out);

  instruction_memory : entity work.instruction_memory
  port map(
            clk => clk, reset => comm_reset_system_out,
            write_enable => comm_instruction_write_enable_out,
            address_in => mux_instruction_memory_address_in_out,
            data_in => comm_instruction_data_out,
            data_out => instruction_data_out);

  -- MUX units
  mux_instruction_address : entity work.mux_2
  port map(
            a_in => pc_out,
            b_in => comm_instruction_address_out,
            select_in => comm_instruction_write_enable_out,
            data_out => mux_instruction_memory_address_in_out);


end Behavioral;


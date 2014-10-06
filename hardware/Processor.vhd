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
  -- Communication unit
  signal comm_sram_override_out : STD_LOGIC;
  signal comm_sram_flip_out : STD_LOGIC;

  signal comm_sram_bus_data_out : sram_bus_data_t;
  signal comm_sram_bus_control_out : sram_bus_control_t;

  signal comm_instruction_data_out : word_t;
  signal comm_instruction_address_out : STD_LOGIC_VECTOR(15 downto 0);
  signal comm_instruction_write_enable_out : STD_LOGIC;

  -- Thread spawner
  signal kernel_completed_out : STD_LOGIC;
begin

  communication_unit : entity work.communication_unit
  port map(
            clk => clk, -- Reset ?
            ebi_bus_in => mc_ebi_bus,
            spi_bus_in => mc_spi_bus,
            kernel_completed_in => kernel_completed_out,

            command_sram_override_out => comm_sram_override_out,
            command_sram_flip_out => comm_sram_flip_out,

            instruction_data_out => comm_instruction_data_out,
            instruction_address_out => comm_instruction_address_out,
            instruction_write_enable_out => comm_instruction_write_enable_out,

            sram_bus_data_inout => comm_sram_bus_data_out,
            sram_bus_control_out => comm_sram_bus_control_out
          );


end Behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.defines.all;
--use IEEE.NUMERIC_STD.ALL;

entity Processor is
  Port ( -- SRAM
         sram_1_data : inout sram_bus_data_t;
         sram_1_control : out sram_bus_control_t;

         sram_2_data : inout sram_bus_data_t;
         sram_2_control : out sram_bus_control_t;

         -- HDMI && VGA
         hdmi_out : out STD_LOGIC_VECTOR (18 downto 0);
         vga_out : out STD_LOGIC_VECTOR (15 downto 0);

         -- MC
         mc_ebi_bus : inout STD_LOGIC_VECTOR (49 downto 0);
         mc_spi_bus : inout STD_LOGIC_VECTOR (4 downto 0);

         -- Generic IO
         led_1_out : out STD_LOGIC;
         led_2_out : out STD_LOGIC);
end Processor;

architecture Behavioral of Processor is

begin


end Behavioral;


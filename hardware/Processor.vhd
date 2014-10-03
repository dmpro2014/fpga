library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--use IEEE.NUMERIC_STD.ALL;

entity Processor is
    Port ( -- SRAM
           sram_1_address_out : out  STD_LOGIC_VECTOR (18 downto 0);
           sram_1_control_out : out STD_LOGIC_VECTOR (2 downto 0);
           sram_1_data_inout : inout  STD_LOGIC_VECTOR (15 downto 0);

           sram_2_control_out : out STD_LOGIC_VECTOR (2 downto 0);
           sram_2_address_out : out  STD_LOGIC_VECTOR (18 downto 0);
           sram_2_data_inout : inout  STD_LOGIC_VECTOR (15 downto 0);

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


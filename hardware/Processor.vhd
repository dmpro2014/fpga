library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--use IEEE.NUMERIC_STD.ALL;

entity Processor is
    Port ( -- SRAM
           sram_1_address_out : out  STD_LOGIC_VECTOR (18 downto 0);
           sram_1_data_inout : inout  STD_LOGIC_VECTOR (15 downto 0);
           sram_2_address_out : out  STD_LOGIC_VECTOR (18 downto 0);
           sram_2_data_inout : inout  STD_LOGIC_VECTOR (15 downto 0);
           
           -- MPU
           mpu_data_inout : inout  STD_LOGIC_VECTOR (19 downto 0));
end Processor;

architecture Behavioral of Processor is

begin


end Behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.defines.all;

entity communication_unit is
  Port ( clk : in  STD_LOGIC;
         kernel_completed : in  STD_LOGIC;

         -- MC busses
         ebi_bus_in : in  STD_LOGIC_VECTOR (49 downto 0);
         spi_bus_in : in  STD_LOGIC_VECTOR (4 downto 0);

         -- Instruction memory
         instruction_data_out : out word_t;
         instruction_address_out : out  STD_LOGIC_VECTOR (15 downto 0);
         instruction_write_enable_out : out  STD_LOGIC;

         -- SRAM
         command_sram_override : out  STD_LOGIC;
         command_sram_flip : out  STD_LOGIC;
         sram_bus_data : inout sram_bus_data_t;
         sram_bus_control: out sram_control_t

       );
end communication_unit;

architecture Behavioral of communication_unit is

begin


end Behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity command_unit is
    Port ( clk : in  STD_LOGIC;
           kernel_completed : in  STD_LOGIC;

           -- MC busses
           ebi_bus_in : in  STD_LOGIC_VECTOR (49 downto 0);
           spi_bus_in : in  STD_LOGIC_VECTOR (4 downto 0);

           -- Instruction memory
           instruction_data_out : out  STD_LOGIC_VECTOR (15 downto 0);
           instruction_address_out : out  STD_LOGIC_VECTOR (15 downto 0);
           instruction_write_enable_out : out  STD_LOGIC;

           -- SRAM
           command_sram_override : out  STD_LOGIC;
           command_sram_flip : out  STD_LOGIC;
           sram_data_inout : inout  STD_LOGIC_VECTOR (15 downto 0);
           sram_address : out  STD_LOGIC_VECTOR (18 downto 0);
           sram_write_enable : out  STD_LOGIC);
end command_unit;

architecture Behavioral of command_unit is

begin


end Behavioral;


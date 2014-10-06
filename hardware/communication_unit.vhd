library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.defines.all;

entity communication_unit is
  Port ( clk : in  STD_LOGIC;
         kernel_completed_in : in  STD_LOGIC;
         comm_reset_system_out : out STD_LOGIC;

         -- MC busses
         ebi_bus_in : in  ebi_bus_t;
         spi_bus_in : in  spi_bus_t;

         -- Instruction memory
         instruction_data_out : out word_t;
         instruction_address_out : out  STD_LOGIC_VECTOR (15 downto 0);
         instruction_write_enable_out : out  STD_LOGIC;

         -- SRAM
         command_sram_override_out : out  STD_LOGIC;
         command_sram_flip_out : out  STD_LOGIC;
         sram_bus_data_inout : inout sram_bus_data_t;
         sram_bus_control_out: out sram_bus_control_t

       );
end communication_unit;

architecture Behavioral of communication_unit is

begin


end Behavioral;


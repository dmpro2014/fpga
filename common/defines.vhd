library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package defines is

	constant INSTRUCTION_ADDRESS_WIDTH: integer := 16;
	constant DATA_WIDTH: integer := 19;
	constant WORD_WIDTH: integer := 16;
	
  type sram_bus_control_t is
    record
      address : std_logic_vector(18 downto 0);
      read : std_logic;
      write : std_logic;
      chip_select : std_logic;
    end record;

  type sram_bus_data_t is
    record
      data : std_logic_vector(15 downto 0);
    end record;

  subtype word_t is std_logic_vector(WORD_WIDTH -1 downto 0);
  subtype ebi_bus_t is std_logic_vector(49 downto 0);
  subtype spi_bus_t is std_logic_vector(4 downto 0);
	subtype instruction_address_t is std_logic_vector(INSTRUCTION_ADDRESS_WIDTH -1 downto 0);
	subtype thread_id_t is std_logic_vector(DATA_WIDTH -1 downto 0);
	
end package defines;

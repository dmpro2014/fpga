library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package defines is

  constant REGISTER_COUNT_BIT_WIDTH: integer := 4;

  constant INSTRUCTION_ADDRESS_WIDTH: integer := 16;
  constant DATA_ADDRESS_WIDTH: integer := 20;
  constant DATA_WIDTH: integer := 19;
  constant WORD_WIDTH: integer := 16;

  constant NUMBER_OF_STREAMING_PROCESSORS: integer := 1;
  -- Barell
  constant BARREL_HEIGHT: integer := 1;
  constant BARREL_HEIGHT_BIT_WIDTH: integer := 1;


  subtype word_t is std_logic_vector(WORD_WIDTH -1 downto 0);
  subtype ebi_bus_t is std_logic_vector(49 downto 0);
  subtype spi_bus_t is std_logic_vector(4 downto 0);
  subtype instruction_address_t is std_logic_vector(INSTRUCTION_ADDRESS_WIDTH -1 downto 0);
  subtype memory_address_t is std_logic_vector(DATA_ADDRESS_WIDTH -1 downto 0);
  subtype thread_id_t is std_logic_vector(DATA_WIDTH -1 downto 0);
  subtype register_address_t is std_logic_vector(REGISTER_COUNT_BIT_WIDTH - 1 downto 0);

  type sp_sram_addresses_t is array(NUMBER_OF_STREAMING_PROCESSORS - 1 downto 0) of instruction_address_t;
  type sp_sram_datas_t is array(NUMBER_OF_STREAMING_PROCESSORS - 1 downto 0) of word_t;
  type register_directory_ids_t is array(BARREL_HEIGHT-1 downto 0) of  thread_id_t;

  subtype barrel_row_t is std_logic_vector(BARREL_HEIGHT_BIT_WIDTH -1 downto 0);

  subtype opcode_t is std_logic_vector(6 downto 0); -- Placeholder
  subtype alu_op_t is std_logic_vector(4 downto 0); -- Placeholder
  

  type sram_bus_control_t is
    record
      address : instruction_address_t;
      lbub : std_logic_vector(1 downto 0);
      write_enable : std_logic;
      chip_select : std_logic;
    end record;

  type sram_bus_data_t is
    record
      data : std_logic_vector(15 downto 0);
    end record;

end package defines;

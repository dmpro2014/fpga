library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.defines.all;

entity load_store_unit is
  Port ( -- Input wires
         request_memory_read_in : in  std_logic;
         request_memory_write_in : in  std_logic;
         register_file_select_in : in std_logic_vector(BARREL_HEIGHT_BIT_WIDTH -1 downto 0);
         sp_memory_addresses_in : in  sp_memory_addresses_t;
         sp_memory_datas_in : in sp_memory_datas_t;

         -- Memory wires
         memory_address_out : out instruction_address_t;
         memory_data_inout : inout word_t;
         memory_lbub_out : out std_logic_vector (1 downto 0);
         memory_write_enable_out : out std_logic;
         memory_chip_enable_out : out std_logic;

         -- Streaming processor wires
         registers_file_select_out : out  std_logic_vector (BARREL_HEIGHT_BIT_WIDTH - 1 downto 0);
         registers_write_enable_out : out  std_logic;
         sp_memory_data_out : out sp_memory_datas_t );
end load_store_unit;

architecture Behavioral of load_store_unit is

begin


end Behavioral;


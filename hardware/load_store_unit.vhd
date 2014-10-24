library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.defines.all;

entity load_store_unit is
  Port ( -- Input wires
         request_sram_bus_read_in : in  std_logic;
         request_sram_bus_write_in : in  std_logic;
         register_file_select_in : in barrel_row_t;
         sp_sram_bus_addresses_in : in memory_address_t;
         sp_sram_bus_datas_in : in word_t;

         -- Memory wires
         sram_bus_data_1_inout : inout sram_bus_data_t;
         sram_bus_control_1_out : out sram_bus_control_t;
         sram_bus_data_2_inout : inout sram_bus_data_t;
         sram_bus_control_2_out : out sram_bus_control_t;

         -- Streaming processor wires
         registers_file_select_out : out barrel_row_t;
         registers_write_enable_out : out  std_logic;
         sp_sram_bus_data_out : out word_t );
end load_store_unit;

architecture Behavioral of load_store_unit is

begin


end Behavioral;


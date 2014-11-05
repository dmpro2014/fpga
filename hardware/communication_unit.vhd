library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.defines.all;

entity communication_unit is
  generic ( 
            CONSTANT_ADDRESS_WIDTH: integer := 4
  );
  Port ( clk : in  STD_LOGIC;
         system_reset_out: out STD_LOGIC;
         comm_reset_system_out : out STD_LOGIC;

         -- Thread Spawner signals
         kernel_start_out: out std_logic;
         kernel_address_out: out instruction_address_t;
         kernel_number_of_threads_out: out thread_id_t;

         -- MC busses
         ebi_data_inout : inout ebi_data_t;
         ebi_control_in : in ebi_control_t;

         -- Instruction memory
         instruction_data_out : out instruction_t;
         instruction_address_out : out  STD_LOGIC_VECTOR (15 downto 0);
         instruction_write_enable_out : out  STD_LOGIC;

         -- SRAM
         command_sram_override_out : out  STD_LOGIC;
         command_sram_flip_out : out  STD_LOGIC;
         sram_bus_data_inout : inout sram_bus_data_t;
         sram_bus_control_out: out sram_bus_control_t;
         
         -- Constant_storage
         constant_address_out: out std_logic_vector(CONSTANT_ADDRESS_WIDTH -1 downto 0);
         constant_write_enable_out: out std_logic;
         constant_out: out word_t
       );
end communication_unit;

architecture Behavioral of communication_unit is

begin


end Behavioral;


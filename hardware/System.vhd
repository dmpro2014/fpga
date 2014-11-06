library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.defines.all;

entity System is
  Port ( -- Stuff
         clk : in std_logic;
         reset : in std_logic;

         -- SRAM
         sram_bus_data_1_inout : inout sram_bus_data_t;
         sram_bus_control_1_out : out sram_bus_control_t;

         sram_bus_data_2_inout : inout sram_bus_data_t;
         sram_bus_control_2_out : out sram_bus_control_t;

         -- HDMI && VGA
         hdmi_bus_data_inout : inout sram_bus_data_t;
         hdmi_bus_control_in : in sram_bus_control_t;

         vga_bus_data_inout : inout sram_bus_control_t;
         vga_bus_control_in : in sram_bus_data_t;

         -- MC EBI
         ebi_data_inout : inout ebi_data_t;
         ebi_control_in : in ebi_control_t;
         
         -- MC Special kernel complete flag
         mc_kernel_complete_out : out std_logic;
         
         mc_sram_flip_in : in std_logic;
         
         -- MC SPI
         mc_spi_bus : inout spi_bus_t;

         -- Generic IO
         led_1_out : out STD_LOGIC;
         led_2_out : out STD_LOGIC);
end System;

architecture Behavioral of System is

  -- Communication unit
  signal comm_sram_bus_data_inout : sram_bus_data_t;
  signal comm_sram_bus_control_out : sram_bus_control_t;

  signal comm_instruction_data_out : word_t;
  signal comm_instruction_address_out : std_logic_vector(INSTRUCTION_ADDRESS_WIDTH - 1 downto 0);
  signal comm_instruction_write_enable_out : std_logic;
  signal comm_instruction_address_hi_select_out : std_logic;

  signal comm_kernel_start_out: std_logic;
  signal comm_kernel_address_out: instruction_address_t;
  signal comm_kernel_number_of_threads_out: thread_id_t;
  
  signal comm_constant_address_out: std_logic_vector(CONSTANT_MEM_LOG_SIZE - 1 downto 0);
  signal comm_constant_write_enable_out: std_logic;
  signal comm_constant_out: word_t;
  
  -- LSU
  signal load_store_sram_bus_data_1_inout : sram_bus_data_t;
  signal load_store_sram_bus_control_1_out : sram_bus_control_t;
  signal load_store_sram_bus_data_2_inout : sram_bus_data_t;
  signal load_store_sram_bus_control_2_out : sram_bus_control_t;

begin

  ghettocuda : entity work.ghettocuda
  port map ( -- Stuff
            clk => clk,
            reset => reset,

            -- Constant memory
            constant_write_data_in => comm_constant_out,
            constant_write_enable_in => comm_constant_write_enable_out,
            constant_write_address_in => comm_constant_address_out,
            
            -- Instruction memory
            instruction_memory_data_in => comm_instruction_data_out,
            instruction_memory_address_in => comm_instruction_address_out,
            instruction_memory_write_enable_in => comm_instruction_write_enable_out,
            instruction_memory_address_hi_select_in => comm_instruction_address_hi_select_out,
            
            -- Thread spawner
            ts_kernel_start_in => comm_kernel_start_out,
            ts_kernel_address_in => comm_kernel_address_out,
            ts_num_threads_in => comm_kernel_number_of_threads_out,
            ts_kernel_complete_out => mc_kernel_complete_out,
            
            -- LSU
            load_store_sram_bus_data_1_inout => load_store_sram_bus_data_1_inout,
            load_store_sram_bus_control_1_out => load_store_sram_bus_control_1_out,
            load_store_sram_bus_data_2_inout => load_store_sram_bus_data_2_inout,
            load_store_sram_bus_control_2_out => load_store_sram_bus_control_2_out,

            -- Generic IO
            led_1_out => led_1_out,
            led_2_out => led_2_out);

  communication_unit : entity work.communication_unit
  generic map(
               CONSTANT_ADDRESS_WIDTH => CONSTANT_MEM_LOG_SIZE
  )
  port map(
            clk => clk,
            
            ebi_data_inout => ebi_data_inout,
            ebi_control_in => ebi_control_in,

            instruction_data_out => comm_instruction_data_out,
            instruction_address_out => comm_instruction_address_out,
            instruction_write_enable_out => comm_instruction_write_enable_out,
            instruction_address_hi_select_out => comm_instruction_address_hi_select_out,

            sram_bus_data_inout => comm_sram_bus_data_inout,
            sram_bus_control_out => comm_sram_bus_control_out,

            kernel_number_of_threads_out => comm_kernel_number_of_threads_out,
            kernel_start_out => comm_kernel_start_out,
            kernel_address_out => comm_kernel_address_out,
            
            constant_address_out => comm_constant_address_out,
            constant_write_enable_out => comm_constant_write_enable_out,
            constant_out => comm_constant_out 
          );
          
  sram_arbiter : entity work.sram_arbiter
  port map( -- LSU wires
            lsu_sram_bus_control_1_in => load_store_sram_bus_control_1_out,
            lsu_sram_bus_data_1_inout => load_store_sram_bus_data_1_inout,
            lsu_sram_bus_control_2_in => load_store_sram_bus_control_2_out,
            lsu_sram_bus_data_2_inout => load_store_sram_bus_data_2_inout,

            -- VGA / HDMI wires
            vga_hdmi_sram_bus_control_in => hdmi_bus_control_in,
            vga_hdmi_sram_bus_data_inout => hdmi_bus_data_inout,

            -- Communication unit wires
            comm_sram_bus_control_in => comm_sram_bus_control_out,
            comm_sram_bus_data_inout => comm_sram_bus_data_inout,
            comm_sram_flip_in => mc_sram_flip_in,

            -- SRAM wires
            sram_bus_control_1_out => sram_bus_control_1_out,
            sram_bus_data_1_inout => sram_bus_data_1_inout,
            sram_bus_control_2_out => sram_bus_control_2_out,
            sram_bus_data_2_inout => sram_bus_data_2_inout
          );

end Behavioral;

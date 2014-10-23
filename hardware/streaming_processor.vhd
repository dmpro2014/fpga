library ieee;
use ieee.std_logic_1164.all;
use work.defines.all;

entity streaming_processor is
    port ( clock_in             : in  std_logic;
           read_reg_1_in        : in  register_address_t;
           read_reg_2_in        : in  register_address_t;
           write_reg_in         : in  register_address_t;
           reg_write_enable_in  : in  std_logic;
           mask_enable_in       : in  std_logic;
           alu_function_in      : in  std_logic;
           id_data_in           : in thread_id_t;
           id_write_enable_in   : in  std_logic;
           barrel_select_in     : in  barrel_row_t;
           return_write_enable_in : in  std_logic;
           return_barrel_select_in : in  barrel_row_t;
           return_data_in       : in word_t;
           lsu_write_data_out   : out  word_t;
           lsu_address_out      : out  memory_address_t
           );
end streaming_processor;

architecture rtl of streaming_processor is

begin

    --do gpu
end rtl;


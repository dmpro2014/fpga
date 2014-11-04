
library ieee;
use ieee.std_logic_1164.all;
use work.defines.all;


entity instruction_decode is
  port(
         instruction_in : in instruction_t;
         operand_rs_out: out register_address_t; --Read register 1
         operand_rt_out: out register_address_t; --Read register 2
         operand_rd_out: out register_address_t; --Write register
         shamt_out: out std_logic_vector(4 downto 0); --Shift amount
         immediate_operand_out: out immediate_value_t;
         mask_enable_out: out std_logic;
         register_write_enable_out: out std_logic;
         alu_funct_out: out alu_funct_t;
         lsu_load_enable_out: out std_logic;
         lsu_write_enable_out: out std_logic;
         thread_done_out: out std_logic
  );
end instruction_decode;

architecture rtl of instruction_decode is
  
begin
end rtl;


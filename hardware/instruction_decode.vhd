
library ieee;
use ieee.std_logic_1164.all;
use work.defines.all;


entity instruction_decode is
  port(
         instruction_in : in word_t;
         opcode_out: out opcode_t;
         operand_1_out: out register_address_t;
         operand_2_out: out register_address_t;
         operand_3_out: out register_address_t;
         immediate_operand_out: out std_logic_vector(DECODE_OPERAND_OPERAND_3_BIT_WIDTH -1 downto 0)
  );
end instruction_decode;

architecture rtl of instruction_decode is
  
begin


end rtl;


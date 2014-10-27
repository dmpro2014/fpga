library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.defines.all;


entity alu is
    Port ( operand_a_in : in  word_t
         ; operand_b_in : in  word_t
         ; funct_in     : in  alu_funct_t
         ; result_out   : out word_t
         );
end alu;

architecture Behavioral of alu is

begin


end Behavioral;


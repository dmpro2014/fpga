library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.defines.all;
package utils is
  function make_row(row: integer) return std_logic_vector;
  function make_reg_addr(reg: integer; reg_addr_bits: integer) return std_logic_vector;
  function make_word(word: integer) return std_logic_vector;
end;

package body utils is

  function make_reg_addr(reg: integer; reg_addr_bits: integer) return std_logic_vector is
    begin
      return std_logic_vector(to_unsigned(reg, reg_addr_bits));
   end;
   
  function make_word(word: integer) return std_logic_vector is
   begin
    return std_logic_vector(to_unsigned(word, WORD_WIDTH));
 end;

  function make_row(row: integer) return std_logic_vector is
   begin
     return std_logic_vector(to_unsigned(row, BARREL_HEIGHT_BIT_WIDTH));
  end;

  end;

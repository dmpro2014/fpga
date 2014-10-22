library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.constants.all;
package types is
end;

package body types is
	type instruction_address_t is std_logic_vector(INSTRUCTION_ADDRESS_WIDTH downto 0);
	type word_t is std_logic_vector(WORD_WIDTH downto 0);
end;

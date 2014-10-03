library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package defines is

  type sram_bus_t is
    record
      address : std_logic_vector(18 downto 0);
      data : std_logic_vector(15 downto 0);
      read : std_logic;
      write : std_logic;
      chip_select : std_logic;
    end record;
    
  subtype word_t is std_logic_vector(15 downto 0);

end package defines;
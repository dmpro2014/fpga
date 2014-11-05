library ieee;
use ieee.std_logic_1164.all;

entity gearbox_10to5 is

    port
        ( clock   : in   std_logic
        ; input   : in   std_logic_vector(9 downto 0)
        ; output  : out  std_logic_vector(4 downto 0)
        );

end gearbox_10to5;


architecture Behavioral of gearbox_10to5 is

    signal upper : boolean := false;

begin

    upper <= not upper when rising_edge(clock);

    with upper
    select output <=
        input(9 downto 5) when true,
        input(4 downto 0) when false;

end Behavioral;

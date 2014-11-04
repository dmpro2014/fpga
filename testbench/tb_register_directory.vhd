library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end testbench;

architecture behavior of testbench is        
  constant clk_period: time = 10 ns;

begin

-- component instantiation
        uut: <component name> port map(
                <port1> => <signal1>,
                <port3> => <signal2>
        );




--  test bench statements
   tb : process
   begin

      wait for 100 ns; -- wait until global set/reset completes

      -- add user defined stimulus here

      wait; -- will wait forever
   end process tb;
--  end test bench 

end;

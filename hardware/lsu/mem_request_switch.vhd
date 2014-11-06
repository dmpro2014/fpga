library ieee;
use ieee.std_logic_1164.all;
use work.lsu_defs.all;

entity mem_request_switch is

    port
        ( clock         : in  std_logic
        ; requests_all  : in  request_batch_t
        ; requests_even : out request_batch_part_t
        ; requests_odd  : out request_batch_part_t
        );

end mem_request_switch;

architecture Behavioral of mem_request_switch is

begin


end Behavioral;

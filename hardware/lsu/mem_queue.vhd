library ieee;
use ieee.std_logic_1164.all;
use work.lsu_defs.all;

entity mem_queue is

    port
        ( clock        : in  std_logic
        ; accept       : in  std_logic
        ; requests     : in  request_batch_part_t
        ; top_request  : out request_t
        );

end mem_queue;

architecture Behavioral of mem_queue is

begin


end Behavioral;

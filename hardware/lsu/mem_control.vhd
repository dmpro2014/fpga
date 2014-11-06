library ieee;
use ieee.std_logic_1164.all;
use work.defines.all;
use work.lsu_defs.all;

entity mem_control is

    port
        ( clock          : in  std_logic
        ; ram_control    : out sram_bus_control_t
        ; ram_data       : out sram_bus_data_t
        ; request_packet : in  request_t
        ; read_response  : out read_response_t
        );

end mem_control;

architecture Behavioral of mem_control is

begin


end Behavioral;

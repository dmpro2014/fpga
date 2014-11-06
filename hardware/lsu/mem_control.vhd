library ieee;
use ieee.std_logic_1164.all;
use work.defines.all;
use work.lsu_defs.all;

entity mem_control is

    port
        ( clock          : in    std_logic
        ; ram_control    : out   sram_bus_control_t
        ; ram_data       : inout sram_bus_data_t
        ; request_packet : in    request_t
        ; read_response  : out   read_response_t
        );

end mem_control;

architecture Behavioral of mem_control is

    signal delayed_valid       : std_logic     := '0';
    signal delayed_barrel_line : barrel_row_t;
    signal delayed_sp          : sp_number;

begin

    process (clock) begin
        if rising_edge(clock) then

            ram_control.address      <= request_packet.address;
            ram_control.write_enable <= request_packet.write_enable;

            delayed_valid       <= request_packet.valid;
            delayed_barrel_line <= request_packet.barrel_line;
            delayed_sp          <= request_packet.sp;

            read_response.valid       <= delayed_valid;
            read_response.barrel_line <= delayed_barrel_line;
            read_response.sp          <= delayed_sp;

            if request_packet.write_enable = '1' then
                ram_data.data <= request_packet.write_data;
            else
                ram_data.data <= (others => 'Z');
            end if;

            read_response.data <= ram_data.data;

        end if;
    end process;

end Behavioral;

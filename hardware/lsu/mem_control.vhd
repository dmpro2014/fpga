library ieee;
use ieee.std_logic_1164.all;
use work.defines.all;
use work.lsu_defs.all;

entity mem_control is

    port
        ( clock          : in    std_logic

        ; request_packet : in    request_t
        ; write_enable   : in    std_logic
        ; read_response  : out   read_response_t

        ; ram_control    : out   sram_bus_control_t
        ; ram_data       : inout sram_bus_data_t
        );

end mem_control;

-- On clock-rise, latch a request. If it's valid, let it go
-- to ram. Output the response from ram. The reponse is
-- combinatoric, and valid only till the next cycle.
architecture Behavioral of mem_control is begin

    -- Output the response from ram immediately.
    read_response.data <= ram_data;

    process (clock) begin
        if rising_edge(clock) then

            -- Setup ram-bus. `ram_control.write_enable` is active-low.
            ram_control.address      <= request_packet.address;
            ram_control.write_enable_n <= not (request_packet.valid and write_enable);

            -- Handle the half-duplex data-bus to ram.
            -- When write_enable is low, disconnect it from load using a BUFT.
            if write_enable = '1' then
                ram_data <= request_packet.write_data;
            else
                ram_data <= (others => 'Z');
            end if;


            -- Outputs to response-handler.
            read_response.valid <= request_packet.valid and not write_enable;

        end if;
    end process;

end Behavioral;

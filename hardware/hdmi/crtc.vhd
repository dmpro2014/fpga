library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defines.all;
use work.hdmi_definitions.all;

entity crtc is
    generic
        ( buffer_0_address    : memory_address_t
        ; buffer_1_address    : memory_address_t
        );
    port
        -- clock_ram should be at least 25MHz + some.
        ( clock_ram           : in      std_logic
        ; clock_25MHz         : in      std_logic
        ; clock_50MHz         : in      std_logic
        ; clock_250MHz        : in      std_logic

        ; front_buffer_select : in      std_logic         := '0'

        ; ram_read_address    : buffer  memory_address_t  := buffer_0_address
        ; ram_read_data       : in      sram_bus_data_t
        
        ; hdmi_connector      : out     hdmi_connector_t
        );

end crtc;

architecture Behavioral of crtc is
    alias video_mode : video_mode_t is video_640x480_60Hz;

    alias clock_pixel : std_logic is clock_25MHz;
    alias clock_5bit  : std_logic is clock_50MHz;
    alias clock_bit   : std_logic is clock_250MHz;

    constant video_size : integer := video_mode.h.resolution * video_mode.v.resolution;

    signal start_address : memory_address_t;
    signal end_address : memory_address_t;
    signal want_data : std_logic := '1';
    
    signal scanout_pixel : video_pixel_t;
begin
    -- todo: handle blit and vsync.
    
    start_address <= 
    end_address <= start_address + video_size;

    ram_address_select:
        process (clock_ram) begin
            if rising_edge(clock_ram)
            and want_data = '1' then
                -- todo: handle end of buffer.
                ram_read_address_i <= ram_read_address + 1;
            end if;
        end process;

    video_fifo:
        entity work.video_fifo
            port map
                ( clock_write  => clock_ram
                , clock_read   => clock_pixel
                
                , write_accept => want_data
                , write_enable => ram_read_data.data_valid
                , write_data   => ram_read_data.data
                
                , read_data    => scanout_pixel
                );

    hdmi_output:
        entity work.hdmi_output
            port map
                ( clock_pixel    => clock_pixel
                , clock_5bit     => clock_5bit
                , clock_bit      => clock_bit
                , control        => video_control
                , pixel_data     => scanout_pixel
                , hdmi_connector => hdmi_connector
                );

    timing_generator:
        entity work.video_timing_generator
            generic map
                ( video_mode => video_mode
                )
            port map
                ( clock        => pixel_clock
                , control      => video_control
                , buffer_index => relative_address
                );
end Behavioral;

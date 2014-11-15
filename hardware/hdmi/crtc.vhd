library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defines.all;
use work.hdmi_definitions.all;

entity crtc is
    port
        -- clock_sys should be at least 25MHz + some.
        ( clock_sys           : in      std_logic
        ; clock_25MHz         : in      std_logic
        ; clock_50MHz         : in      std_logic
        ; clock_250MHz        : in      std_logic
        ; reset               : in      std_logic
        ; strobe_serdes       : in      std_logic

        ; front_buffer_select : in      std_logic         := '0'

        ; ram_request_accepted  : in      std_logic
        ; ram_0_read_address    : out     memory_address_t
        ; ram_0_read_data       : in      sram_bus_data_t
        ; ram_1_read_address    : out     memory_address_t
        ; ram_1_read_data       : in      sram_bus_data_t
        
        ; hdmi_connector      : out     hdmi_connector_t
        );

end crtc;

architecture Behavioral of crtc is
    alias video_mode : video_mode_t is video_640x480_60Hz;

    alias clock_pixel : std_logic is clock_25MHz;
    alias clock_5bit  : std_logic is clock_50MHz;
    alias clock_bit   : std_logic is clock_250MHz;

    constant video_size : natural := video_mode.h.resolution * video_mode.v.resolution;

    signal buffer_start_address : unsigned(DATA_ADDRESS_WIDTH - 2 downto 0);
    signal buffer_end_address : unsigned(DATA_ADDRESS_WIDTH - 2 downto 0);
    signal ram_read_address_i : unsigned(DATA_ADDRESS_WIDTH - 2 downto 0);

    signal fifo_full : std_logic;

    signal scanout_pixel : video_pixel_t;
    signal scanout_pixel_raw : word_t;

    signal blank_n : std_logic;
    
    constant buffer_0_address_top : unsigned(DATA_ADDRESS_WIDTH - 2 downto 0) := to_unsigned(0, DATA_ADDRESS_WIDTH - 1);
    constant buffer_1_address_top : unsigned(DATA_ADDRESS_WIDTH - 2 downto 0) := to_unsigned(65536, DATA_ADDRESS_WIDTH - 1);
    constant buffer_0_address_end_top : unsigned(DATA_ADDRESS_WIDTH - 2 downto 0) := to_unsigned(65536, DATA_ADDRESS_WIDTH - 1);
    constant buffer_1_address_end_top : unsigned(DATA_ADDRESS_WIDTH - 2 downto 0) := to_unsigned(131072, DATA_ADDRESS_WIDTH - 1);
    
    signal fifo_din : std_logic_vector(WORD_WIDTH*2-1 downto 0);
    
    signal video_control : video_control_t;
begin
    
    with front_buffer_select
    select
        buffer_start_address
            <= buffer_0_address_top when '0'
             , buffer_1_address_top when '1';

    with front_buffer_select
    select
        buffer_end_address
            <= buffer_0_address_end_top when '0'
             , buffer_1_address_end_top when '1';

    ram_address_counter:
        process (clock_sys) begin
            if rising_edge(clock_sys) then
                if ram_read_address_i = buffer_end_address then
                    ram_read_address_i <= buffer_start_address;
                else
                    -- Pause counter while fifo is full.
                    if fifo_full = '0' then
                        ram_read_address_i <= ram_read_address_i + 1;
                    end if;
                end if;
            end if;
        end process;

    ram_0_read_address <= std_logic_vector(ram_read_address_i) & "0";
    ram_1_read_address <= std_logic_vector(ram_read_address_i) & "1";

    fifo_din <= ram_0_read_data.data & ram_1_read_data.data;

    -- The video-fifo is first-word-fall-trough. This means we don't need to delay the signals from
    -- the video-timing-generator.
    video_fifo:
        entity work.video_fifo
           port map
                ( rst    => reset
                , wr_clk => clock_sys
                , rd_clk => clock_pixel

                , full   => fifo_full
                , wr_en  => ram_request_accepted
                -- Not sure how the 32 to 16 conversion takes place. Maybe these should change places.
                , din    => fifo_din

                , rd_en  => blank_n
                , dout   => scanout_pixel_raw
                );

    scanout_pixel <= to_video_pixel(scanout_pixel_raw);

    blank_n <= not video_control.blank;

    timing_generator:
        entity work.video_timing_generator
            port map
                ( clock        => clock_pixel
                , reset        => reset
                , launch       => fifo_full
                , control      => video_control
                );

    hdmi_output:
        entity work.hdmi_output
            port map
                ( clock_pixel    => clock_pixel
                , clock_5bit     => clock_5bit
                , clock_bit      => clock_bit
                , strobe_serdes  => strobe_serdes
                , control        => video_control
                , pixel_data     => scanout_pixel
                , hdmi_connector => hdmi_connector
                );


end Behavioral;

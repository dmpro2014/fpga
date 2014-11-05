library ieee;
library unisim;
use ieee.std_logic_1164.all;
use unisim.vcomponents.all;
use work.defines.all;
use work.hdmi_definitions.all;

entity tdms_encoder is

    port
        ( clock_pixel         : in std_logic
        ; clock_5bit          : in std_logic
        ; clock_bit           : in std_logic
        ; blank               : in std_logic
        ; control_bits        : in std_logic_vector(1 downto 0)
        ; data                : in std_logic_vector(7 downto 0)
        ; tdms_signal         : out ds_pair
        );

end tdms_encoder;

architecture Behavioral of tdms_encoder is

    signal encoded_color   : tm_data_t;
    signal encoded_control : tm_data_t;
    signal data_to_send    : tm_data_t;
    
    signal double_rate_data : std_logic_vector(4 downto 0);

    signal serial_data : std_logic;

begin

    encoded_color   <= tm_encode_color(data);
    encoded_control <= tm_encode_control(control_bits);

    with blank
    select data_to_send
        <= encoded_color   when '1'
         , encoded_control when '0'
         ;

    gearbox_10to5:
        entity work.gearbox_10to5
            port map
                ( clock  => clock_5bit
                , input  => data_to_send
                , output => double_rate_data
                );

    serializer:
        oserdes
            generic map
                ( data_width   => 8
                , data_rate_oq => "SDR"
                , data_rate_ot => "SDR"
                , serdes_mode  => "MASTER"
                , output_mode  => "DIFFERENTIAL"
                )
            port map
                ( clk0 => clock_bit
                , 

    differential_buffer:
        obufds
            port map
                ( i  => serial_data
                , o  => tdms_signal.p
                , ob => tdms_signal.n
                );

end Behavioral;

library ieee;
use ieee.std_logic_1164.all;
use work.defines.all;

entity sram_arbiter is
  Port ( -- LSU wires
         lsu_sram_bus_control_in : in sram_bus_control_t;
         lsu_sram_bus_data_in    : in sram_bus_data_t;
         lsu_sram_bus_data_out   : out sram_bus_data_t;
         lsu_mem_request_in      : in std_logic;

         -- VGA / HDMI wires
         vga_hdmi_sram_bus_control_in  : in sram_bus_control_t;
         vga_hdmi_sram_bus_data_out    : out sram_bus_data_t;
         vga_hdmi_request_accepted_out : out std_logic;

         -- Communication unit wires
         comm_sram_bus_control_in : in sram_bus_control_t;
         comm_sram_bus_data_in    : in sram_bus_data_t;
         comm_sram_bus_data_out   : out sram_bus_data_t;
         comm_mem_request_in      : in std_logic;

         -- SRAM wires
         sram_bus_control_out : out sram_bus_control_t;
         sram_bus_data_inout  : inout sram_bus_data_t);

end sram_arbiter;

architecture Behavioral of sram_arbiter is

    signal outputing_to_sram : std_logic;
    signal sram_bus_data_out : word_t;

begin

    -- Passtrough appropriate control-signals:
    sram_bus_control_out <= comm_sram_bus_control_in when comm_mem_request_in = '1'
                       else lsu_sram_bus_control_in  when lsu_mem_request_in = '1'
                       else vga_hdmi_sram_bus_control_in;

    -- Select candidate for data-output:
    sram_bus_data_out <= comm_sram_bus_data_in when comm_mem_request_in = '1'
                    else lsu_sram_bus_data_in;

    -- Output if required:
    outputing_to_sram <= (comm_mem_request_in and not comm_sram_bus_control_in.write_enable_n)
                      or (lsu_mem_request_in and not lsu_sram_bus_control_in.write_enable_n);
    
    -- Tri-state-buffer for inout
    with outputing_to_sram
    select sram_bus_data_inout <= sram_bus_data_out when '1'
                                , (others => 'Z')   when others;

    -- Distribute incoming data:
    lsu_sram_bus_data_out      <= sram_bus_data_inout;
    vga_hdmi_sram_bus_data_out <= sram_bus_data_inout;
    comm_sram_bus_data_out     <= sram_bus_data_inout;

    -- Notify video-unit of available data:
    vga_hdmi_request_accepted_out <= not comm_mem_request_in and not lsu_mem_request_in;

end Behavioral;

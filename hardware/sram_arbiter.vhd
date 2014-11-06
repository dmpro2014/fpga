library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.defines.all;

entity sram_arbiter is
  Port ( -- LSU wires
         lsu_sram_bus_control_1_in : in sram_bus_control_t;
         lsu_sram_bus_data_1_inout : inout sram_bus_data_t;
         lsu_sram_bus_control_2_in : in sram_bus_control_t;
         lsu_sram_bus_data_2_inout : inout sram_bus_data_t;

         -- VGA / HDMI wires
         vga_hdmi_sram_bus_control_in : in sram_bus_control_t;
         vga_hdmi_sram_bus_data_inout : inout sram_bus_data_t;

         -- Communication unit wires
         comm_sram_bus_control_in : in sram_bus_control_t;
         comm_sram_bus_data_inout : inout sram_bus_data_t;
         comm_sram_override : in std_logic;
         comm_sram_flip_in : in std_logic;

         -- SRAM wires
         sram_bus_control_1_out : out sram_bus_control_t;
         sram_bus_data_1_inout : inout sram_bus_data_t;
         sram_bus_control_2_out : out sram_bus_control_t;
         sram_bus_data_2_inout : inout sram_bus_data_t);
end sram_arbiter;

architecture Behavioral of sram_arbiter is
begin

sram_bus_control_1_out <= lsu_sram_bus_control_1_in;
sram_bus_data_1_inout <= lsu_sram_bus_data_1_inout;
sram_bus_control_2_out <= lsu_sram_bus_control_2_in;
sram_bus_data_2_inout <= lsu_sram_bus_data_2_inout;

end Behavioral;


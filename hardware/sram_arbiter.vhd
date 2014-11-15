library ieee;
use ieee.std_logic_1164.all;
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
sram_bus_control_2_out <= lsu_sram_bus_control_2_in;

--process (lsu_sram_bus_control_1_in.write_enable_n
--        ,lsu_sram_bus_control_2_in.write_enable_n
--        ,sram_bus_data_1_inout
--        ,sram_bus_data_2_inout
--        ,lsu_sram_bus_data_1_inout
--        ,lsu_sram_bus_data_2_inout)
--begin
--  sram_bus_data_1_inout <= (others => 'Z');
--  sram_bus_data_2_inout <= (others => 'Z');
--
--  if lsu_sram_bus_control_1_in.write_enable_n = '0' then
--    sram_bus_data_1_inout <= lsu_sram_bus_data_1_inout;
----  else
----    lsu_sram_bus_data_1_inout <= lsu_sram_bus_data_1_inout;
--  end if;
--  
--  if lsu_sram_bus_control_2_in.write_enable_n = '0' then
--    sram_bus_data_2_inout <= lsu_sram_bus_data_2_inout;
----  else
----    lsu_sram_bus_data_2_inout <= lsu_sram_bus_data_2_inout;
--  end if;
--end process;
--
    sram_bus_data_1_inout <= lsu_sram_bus_data_1_inout when lsu_sram_bus_control_1_in.write_enable_n = '0' 
                          else (others=>'Z');
                          
   lsu_sram_bus_data_1_inout <= sram_bus_data_1_inout when lsu_sram_bus_control_1_in.write_enable_n = '1' 
                          else (others=>'Z');
                          
   sram_bus_data_2_inout <= lsu_sram_bus_data_2_inout when lsu_sram_bus_control_2_in.write_enable_n = '0' 
                          else (others=>'Z');
                          
   lsu_sram_bus_data_2_inout <= sram_bus_data_2_inout when lsu_sram_bus_control_2_in.write_enable_n = '1' 
                          else (others=>'Z');

                     
end Behavioral;


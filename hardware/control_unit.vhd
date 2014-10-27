library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.defines.all;

entity control_unit is
  Port (  clk : in std_logic;
          reset: in std_logic;
          opcode_in: in opcode_t;
          register_write_enable_out: out std_logic;
          read_register_1_out: out register_address_t;
          read_register_2_out: out register_address_t;
          write_register_out : out register_address_t;
          mask_enable_out: out std_logic;
          alu_op_out: out alu_funct_t;
          pc_write_enable_out: out std_logic;
          active_barrel_row_out: out barrel_row_t;
          thread_done_out: out std_logic;
          lsu_load_enable_out: out std_logic;
          lsu_write_enable: out std_logic
        );

end control_unit;

architecture rtl of control_unit is
begin

  warp_drive: entity work.warp_drive
  generic map( barrel_bit_width => BARREL_HEIGHT_BIT_WIDTH)
  port map(
            tick => clk,
            reset => reset,
            pc_write_enable_out => pc_write_enable_out,
            active_barrel_row_out => active_barrel_row_out
          );

end rtl;

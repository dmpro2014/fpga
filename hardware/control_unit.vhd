library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.defines.all;

entity control_unit is
  Port (  clk : in std_logic;
          opcode_in: in opcode_t;
          register_write_enable_out: out std_logic;
          read_register_1_out: out std_logic;
          read_register_2_out: out std_logic;
          mask_enable_out: out std_logic;
          alu_op_out: out alu_op_t;
          pc_write_enable_out: out std_logic;
          active_barrel_row_out: out std_logic_vector(BARREL_HEIGHT_BIT_WIDTH -1 downto 0);
          thread_done_out: out std_logic;
          lsu_load_enable_out: out std_logic;
          lsu_write_enable: out std_logic
        );

end control_unit;

architecture rtl of control_unit is
begin

  warp_drive: entity work.warp_drive
  port map(
            clk => clk,
            pc_write_enable_out => pc_write_enable_out,
            active_barrel_row_out => active_barrel_row_out
          );

end rtl;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.test_utils.all;
use work.defines.all;

entity tb_instruction_decode is
end tb_instruction_decode;

architecture behavior of tb_instruction_decode is 
  
  signal instruction_in: instruction_t;
  signal opcode_out: opcode_t;
  signal operand_rs_out: register_address_t;
  signal operand_rt_out: register_address_t;
  signal immediate_operand_out:  std_logic_vector(INSTRUCTION_DECODE_IMMEDIATE_BIT_WIDTH -1 downto 0);

  --Test signals
  signal tb_opcode: opcode_t := (others => '0');
  signal tb_operand_rs: register_address_t := (others => '0');
  signal tb_operand_rt: register_address_t := (others => '0');
  signal tb_immediate_operand : std_logic_vector(INSTRUCTION_DECODE_IMMEDIATE_BIT_WIDTH -1 downto 0) := (others => '0');

begin

  -- component instantiation
      uut: entity work.instruction_decode port map(
          instruction_in => instruction_in,
          opcode_out => opcode_out,
          operand_rs_out => operand_rs_out,
          operand_rt_out => operand_rt_out,
          immediate_operand_out => immediate_operand_out
      );

  --  test bench statements
       tb : process
          variable instruction_length: integer := 0;
          begin
           tb_opcode(3 downto 0) <= "0001";
           tb_operand_rs(3 downto 0) <= "0010";
           tb_operand_rt(3 downto 0) <= "0100";
           tb_immediate_operand(3 downto 0) <= "1100";
           instruction_in <= tb_opcode & tb_operand_rs & tb_operand_rt & tb_immediate_operand;
           wait for 1 ns;
           -- Make sure the instruction length constants are correct.
           instruction_length := opcode_out'length + operand_rs_out'length + operand_rt_out'length + immediate_operand_out'length;
           assert_equals(INSTRUCTION_WIDTH, instruction_length, "The length of instruction decode out signals should sum to instruction width");
           wait for 1 ns;
           assert_equals(tb_opcode, opcode_out, "");
           assert_equals(tb_operand_rs, operand_rs_out, "");
           assert_equals(tb_operand_rt, operand_rt_out, "");
           assert_equals(tb_immediate_operand, immediate_operand_out, "");  
       end process tb;
  --  end test bench 

  end;

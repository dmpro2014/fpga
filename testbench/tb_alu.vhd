LIBRARY ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.defines.all;
use work.alu_defines.all;
use work.test_utils.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY tb_alu IS
  END tb_alu; 
ARCHITECTURE behavior OF tb_alu IS

  --Inputs
  signal operand_a_in : word_t := (others => '0');
  signal operand_b_in : word_t := (others => '0');
  signal shamt_in : shamt_t := (others => '0');
  signal alu_function_in : alu_funct_t := (others => '0');

  --Outputs
  signal result_out : word_t;

  constant clock_period : time := 10 ns;

BEGIN

  -- Instantiate the Unit Under Test (UUT)
  uut: entity work.alu PORT MAP (
                      operand_a_in => operand_a_in,
                      operand_b_in => operand_b_in,
                      shamt_in => shamt_in,
                      alu_function_in => alu_function_in,
                      result_out => result_out
                    );

  -- Stimulus process
  stim_proc: process
    procedure test_op(
                       alu_function: in alu_funct_t;
                       operand_a: integer;
                       operand_b: integer;
                       shamt: in integer;
                       expected_result: in integer;
                       message: string) is
    begin
      operand_a_in <= std_logic_vector(to_signed(operand_a, WORD_WIDTH));
      operand_b_in <= std_logic_vector(to_signed(operand_b, WORD_WIDTH));
      shamt_in <= std_logic_vector(to_signed(shamt, ALU_SHAMT_WIDTH));
      alu_function_in <= alu_function;
      wait for clock_period/2;
      assert_equals(
                     std_logic_vector(to_signed(expected_result, WORD_WIDTH)),
                     result_out,
                     message);
    end test_op;

  begin
    wait for 100 ns;
    test_op(ALU_FUNCTION_ADD, 0, 0, 0, 0, "0+0 should be 0");
    test_op(ALU_FUNCTION_ADD, 30, 20, 10, 50, "SHAMT should be ignored for adds");

    wait;
  end process;

END;

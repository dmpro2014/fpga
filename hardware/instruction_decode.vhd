
library ieee;
use ieee.std_logic_1164.all;
use work.defines.all;


entity instruction_decode is
  port(
         instruction_in : in instruction_t;
         operand_rs_out: out register_address_t; --Read register 1
         operand_rt_out: out register_address_t; --Read register 2
         operand_rd_out: out register_address_t; --Write register
         alu_shamt_out: out std_logic_vector(ALU_SHAMT_WIDTH -1 downto 0); --Shift amount
         alu_funct_out: out alu_funct_t;
         immediate_operand_out: out immediate_value_t;
         mask_enable_out: out std_logic;
         register_write_enable_out: out std_logic;
         lsu_load_enable_out: out std_logic;
         lsu_write_enable_out: out std_logic;
         constant_write_enable_out: out std_logic;
         thread_done_out: out std_logic
  );
end instruction_decode;

architecture rtl of instruction_decode is
  alias opcode is instruction_in(30 downto 26);
  
  constant r_opcode : std_logic_vector(4 downto 0) 
                    := "00000";
                    
  constant start_end_opcode : std_logic_vector(4 downto 0) 
                            := "00001";
                            
  constant load_opcode : std_logic_vector(4 downto 0) 
                            := "00010";
                            
  constant store_opcode : std_logic_vector(4 downto 0) 
                            := "00011";
  constant constant_load_opcode : std_logic_vector(4 downto 0)
                                := "01001";
  
begin
  operand_rs_out <= instruction_in(21 + REGISTER_COUNT_BIT_WIDTH - 1 downto 21);
  operand_rt_out <= instruction_in(16 + REGISTER_COUNT_BIT_WIDTH - 1 downto 16);
  
  operand_rd_out <= instruction_in(11 + REGISTER_COUNT_BIT_WIDTH - 1 downto 11)  when opcode = r_opcode
               else instruction_in(16 + REGISTER_COUNT_BIT_WIDTH - 1 downto 16);
               
  alu_funct_out <= instruction_in(ALU_FUNCT_WIDTH -1 downto 0);
  alu_shamt_out <= instruction_in(6 + ALU_SHAMT_WIDTH -1 downto 6);
  
  immediate_operand_out <= instruction_in(15 downto 0);
  
  mask_enable_out <= instruction_in(31);
  
  register_write_enable_out <= '1' when opcode = r_opcode
                          else '0';
  
  lsu_load_enable_out <= '1' when opcode = load_opcode
                          else '0';
  lsu_write_enable_out <= '1' when opcode = store_opcode
                          else '0';
  
  constant_write_enable_out <= '1' when opcode = constant_load_opcode
                                else '0';
                                
  thread_done_out <= '1' when opcode = start_end_opcode
                else '0';

end rtl;


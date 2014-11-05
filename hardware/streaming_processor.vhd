library ieee;
use ieee.std_logic_1164.all;
use work.defines.all;

entity streaming_processor is
    port ( clock                : in  std_logic
         ; read_reg_1_in        : in  register_address_t
         ; read_reg_2_in        : in  register_address_t
         ; write_reg_in         : in  register_address_t
         ; immediate_in         : in  immediate_value_t
         ; shamt_in             : in  std_logic_vector(4 downto 0)
         ; reg_write_enable_in  : in  std_logic
         ; mask_enable_in       : in  std_logic
         ; alu_function_in      : in  alu_funct_t
         ; id_data_in           : in thread_id_t
         ; id_write_enable_in   : in  std_logic
         ; barrel_select_in     : in  barrel_row_t
         ; return_write_enable_in : in  std_logic
         ; return_barrel_select_in : in  barrel_row_t
         ; return_data_in       : in word_t
         ; lsu_write_data_out   : out  word_t
         ; lsu_address_out      : out  memory_address_t
         ; constant_write_enable_in : in std_logic
         ; constant_value_in    : in word_t
         );
end streaming_processor;

architecture rtl of streaming_processor is
    
    --Register directory out
    signal reg_dir_read_data_1_i      : word_t;
    signal reg_dir_read_data_2_i      : word_t;
    signal reg_dir_predicate_i        : std_logic;
    
    --Register directory in
    signal reg_dir_write_enable_i     : std_logic;
    
    
    -- ALU out
    signal alu_result_i               : word_t;


begin

  reg_dir : entity work.register_directory
  port map( clk => clock
          , read_register_1_in  => read_reg_1_in
          , read_register_2_in  => read_reg_2_in
          , write_register_in   => write_reg_in
          , write_data_in       => alu_result_i
          , register_write_enable_in => reg_dir_write_enable_i

            
          , id_register_write_enable_in => id_write_enable_in
          , id_in               => id_data_in
            
          , read_data_1         => reg_dir_read_data_1_i
          , read_data_2         => reg_dir_read_data_2_i
          , return_register_write_enable_in => return_write_enable_in
          , return_register_file_in => return_barrel_select_in
          , return_data_in      => return_data_in
          , barrel_row_select_in => barrel_select_in
          , lsu_address_out     => lsu_address_out
          , lsu_write_data_out  => lsu_write_data_out
          
          , predicate_out  => reg_dir_predicate_i
          , constant_write_enable_in => constant_write_enable_in
          , constant_value_in => constant_value_in
          );
          
alu : entity work.alu
  port map( operand_a_in    => reg_dir_read_data_1_i
          , operand_b_in    => reg_dir_read_data_2_i
          , funct_in        => alu_function_in
          , result_out      => alu_result_i
          );
          
          
 reg_dir_write_enable_i <= reg_write_enable_in 
                      and (not mask_enable_in 
                           or (mask_enable_in and reg_dir_predicate_i)
                      );
            
            
end rtl;


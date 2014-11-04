library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.defines.all;
--use IEEE.NUMERIC_STD.ALL;

entity ghettocuda is
  Port ( -- Stuff
         clk : in std_logic;
         reset : in std_logic;

         -- SRAM
         sram_bus_data_1_inout : inout sram_bus_data_t;
         sram_bus_control_1_out : out sram_bus_control_t;

         sram_bus_data_2_inout : inout sram_bus_data_t;
         sram_bus_control_2_out : out sram_bus_control_t;
         
         -- Constant memory
         constant_write_data_in : in word_t;
         constant_write_enable_in : in std_logic;
         constant_write_address_in : in std_logic_vector(CONSTANT_ADDRESS_BIT_WIDTH - 1 downto 0);
         
         -- Instruction memory
         instruction_memory_data_in : in instruction_t;
         instruction_memory_address_in : in std_logic_vector(INSTRUCTION_ADDRESS_WIDTH - 1 downto 0);
         instruction_memory_write_enable_in : in std_logic;
         
         -- Thread spawner
         ts_kernel_start_in : in std_logic;
         ts_kernel_address_in : in instruction_address_t;
         ts_num_threads_in : in thread_id_t;
         ts_kernel_complete_out : out std_logic;
         
         -- LSU
         load_store_sram_bus_data_1_inout : inout sram_bus_data_t;
         load_store_sram_bus_control_1_out : out sram_bus_control_t;
         load_store_sram_bus_data_2_inout : inout sram_bus_data_t;
         load_store_sram_bus_control_2_out : out sram_bus_control_t;

         -- Generic IO
         led_1_out : out STD_LOGIC;
         led_2_out : out STD_LOGIC);

end ghettocuda;

architecture Behavioral of ghettocuda is

  -- PC
  signal pc_out : std_logic_vector (15 downto 0);

  -- Thread spawner(TS)
  signal ts_pc_input_select_out : std_logic;
  signal ts_pc_out: instruction_address_t;
  signal ts_thread_id_out: thread_id_t;
  signal ts_id_write_enable_out : std_logic;

  signal ts_thread_done_in : std_logic;

  -- Streaming processor (SP)
  signal sp_sram_bus_addresses_out : sp_sram_addresses_t;
  signal sp_sram_bus_data_out : sp_sram_datas_t;

  -- MUX units
  signal mux_pc_in_out : STD_LOGIC_VECTOR(15 downto 0);
  signal mux_instruction_memory_address_in_out : STD_LOGIC_VECTOR(15 downto 0);

  -- Instruction memory
  signal instruction_data_out : instruction_t;

  -- Control(CTRL)
  signal ctrl_pc_write_enable_out: std_logic;
  signal ctrl_opcode_in: opcode_t;
  signal ctrl_register_write_enable_out: std_logic;
  signal ctrl_mask_enable_out: std_logic;
  signal ctrl_alu_op_out: alu_funct_t;
  signal ctrl_active_barrel_row_out: barrel_row_t;
  signal ctrl_thread_done_out: std_logic;
  signal ctrl_lsu_load_enable_out: std_logic;
  signal ctrl_lsu_write_enable_out: std_logic;
  signal ctrl_constant_write_enable_out: std_logic;

  -- Load / Store unit
  signal load_store_registers_file_select_out : barrel_row_t;
  signal load_store_registers_write_enable_out : std_logic;
  signal load_store_sp_sram_data_out : sp_sram_datas_t;
  

  -- Instruction decode
  signal instruction_decode_opcode_out: opcode_t;
  signal instruction_decode_operand_rs_out: register_address_t;
  signal instruction_decode_operand_rt_out: register_address_t;
  signal instruction_decode_immediate_operand_out: immediate_value_t; 
  alias instruction_decode_operand_rd_out: register_address_t is 
  instruction_decode_immediate_operand_out(INSTRUCTION_DECODE_IMMEDIATE_BIT_WIDTH -1 downto  INSTRUCTION_DECODE_IMMEDIATE_BIT_WIDTH -REGISTER_COUNT_BIT_WIDTH);


  -- Constant storage
  signal constant_storage_value_out: word_t;
  
  -- Instruction decode
  signal instruction_decode_constant_select_in:  std_logic_vector(CONSTANT_ADDRESS_BIT_WIDTH -1 downto 0);

begin

  -- Instruction decode
  instruction_decode: entity work.instruction_decode
  port map(
      instruction_in => instruction_data_out,
      opcode_out => instruction_decode_opcode_out,
      operand_rs_out => instruction_decode_operand_rs_out,
      operand_rt_out => instruction_decode_operand_rt_out,
      immediate_operand_out => instruction_decode_immediate_operand_out
  );

  -- Constant storage
  constant_storage: entity work.constant_storage
  generic map(
               DEPTH => 8,
               LOG_DEPTH => CONSTANT_ADDRESS_BIT_WIDTH
              )
  port map(
            clk => clk,
            write_constant_in => constant_write_data_in,
            write_enable_in => constant_write_enable_in,
            write_address_in => constant_write_address_in,
            constant_value_out => constant_storage_value_out,
            constant_select_in => instruction_decode_constant_select_in
  );


  -- Control unit
  control_unit : entity work.control_unit
  port map(
            clk => clk,
            reset => reset,
            opcode_in => instruction_decode_opcode_out,
            register_write_enable_out => ctrl_register_write_enable_out,
            mask_enable_out => ctrl_mask_enable_out,
            alu_op_out => ctrl_alu_op_out,
            pc_write_enable_out => ctrl_pc_write_enable_out,
            active_barrel_row_out =>ctrl_active_barrel_row_out,
            thread_done_out => ctrl_thread_done_out,
            lsu_load_enable_out => ctrl_lsu_load_enable_out,
            lsu_write_enable => ctrl_lsu_write_enable_out
          );
          
          
          -- Replace with array of SPs
  streaming_processors : entity work.sp_block
  port map(
            clock => clk,
            read_reg_1_in => instruction_decode_operand_rs_out,
            read_reg_2_in => instruction_decode_operand_rt_out,
            write_reg_in  => instruction_decode_operand_rd_out,
            immediate_in => instruction_decode_immediate_operand_out,
            reg_write_enable_in => ctrl_register_write_enable_out,
            mask_enable_in => ctrl_mask_enable_out,
            alu_function_in => ctrl_alu_op_out,
            id_data_in => TS_thread_id_out,
            id_write_enable_in => TS_id_write_enable_out,
            barrel_select_in =>  ctrl_active_barrel_row_out,
            return_write_enable_in => load_store_registers_write_enable_out,
            return_barrel_select_in => load_store_registers_file_select_out,
            return_data_in => load_store_sp_sram_data_out,
            lsu_write_data_out => sp_sram_bus_data_out,
            lsu_address_out     => sp_sram_bus_addresses_out,
            constant_write_enable_in => ctrl_constant_write_enable_out,
            constant_value_in => constant_storage_value_out
           );

  -- Thread Spawner
  thread_spawner : entity work.thread_spawner
  port map(
            clk => clk,
            kernel_start_in => ts_kernel_start_in,
            kernel_addr_in => ts_kernel_address_in,
            num_threads_in => ts_num_threads_in,
            thread_done_in => ctrl_thread_done_out,
            pc_start_out => TS_pc_out,
            pc_input_select_out => TS_pc_input_select_out,
            thread_id_out => TS_thread_id_out,
            id_write_enable_out => TS_id_write_enable_out,
            kernel_complete_out => TS_kernel_complete_out
          );

  load_store_unit : entity work.load_store_unit
  port map(
            -- Input wires
            request_sram_bus_read_in => ctrl_lsu_load_enable_out,
            request_sram_bus_write_in => ctrl_lsu_write_enable_out,
            register_file_select_in => ctrl_active_barrel_row_out,
            sp_sram_bus_addresses_in => sp_sram_bus_addresses_out,
            sp_sram_bus_datas_in => sp_sram_bus_data_out,

            --Memory wires
            sram_bus_data_1_inout => load_store_sram_bus_data_1_inout,
            sram_bus_control_1_out => load_store_sram_bus_control_1_out,
            sram_bus_data_2_inout => load_store_sram_bus_data_2_inout,
            sram_bus_control_2_out => load_store_sram_bus_control_2_out,

            --Streaming processor wires
            registers_file_select_out => load_store_registers_file_select_out,
            registers_write_enable_out => load_store_registers_write_enable_out,
            sp_sram_bus_data_out => load_store_sp_sram_data_out
          );

  pc : entity work.pc
  port map(
            clk => clk,
            reset => reset,
            write_enable => CTRL_pc_write_enable_out,
            pc_in => TS_pc_out,
						pc_input_select_in => TS_pc_input_select_out,
            pc_out => pc_out);

  instruction_memory : entity work.instruction_memory
  port map(
            clk => clk, reset => reset,
            write_enable => instruction_memory_write_enable_in,
            address_in => mux_instruction_memory_address_in_out,
            data_in => instruction_memory_data_in,
            data_out => instruction_data_out);

  -- MUX units
  mux_instruction_address : entity work.mux_2
  port map(
            a_in => pc_out,
            b_in => instruction_memory_address_in,
            select_in => instruction_memory_write_enable_in,
            data_out => mux_instruction_memory_address_in_out);
            
 


end Behavioral;


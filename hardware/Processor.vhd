library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.defines.all;
--use IEEE.NUMERIC_STD.ALL;

entity Processor is
  Port ( -- Stuff
         clk : in STD_LOGIC;

         -- SRAM
         sram_1_data : inout sram_bus_data_t;
         sram_1_control : out sram_bus_control_t;

         sram_2_data : inout sram_bus_data_t;
         sram_2_control : out sram_bus_control_t;

         -- HDMI && VGA
         hdmi_out : out STD_LOGIC_VECTOR (18 downto 0);
         vga_out : out STD_LOGIC_VECTOR (15 downto 0);

         -- MC
         mc_ebi_bus : inout ebi_bus_t;
         mc_spi_bus : inout spi_bus_t;

         -- Generic IO
         led_1_out : out STD_LOGIC;
         led_2_out : out STD_LOGIC);

end Processor;

architecture Behavioral of Processor is

  -- PC
  signal pc_out : std_logic_vector (15 downto 0);

  -- Communication unit
  signal comm_sram_override_out : STD_LOGIC;
  signal comm_sram_flip_out : STD_LOGIC;

  signal comm_sram_bus_data_out : sram_bus_data_t;
  signal comm_sram_bus_control_out : sram_bus_control_t;

  signal comm_instruction_data_out : word_t;
  signal comm_instruction_address_out : STD_LOGIC_VECTOR(15 downto 0);
  signal comm_instruction_write_enable_out : STD_LOGIC;

  signal comm_reset_system_out : STD_LOGIC;
  signal comm_kernel_start_out: std_logic;
  signal comm_kernel_address_out: instruction_address_t;
  signal comm_kernel_number_of_threads_out: thread_id_t;

  -- Thread spawner(TS)
  signal ts_kernel_complete_out : std_logic;
  signal ts_pc_input_select_out : std_logic_vector(1 downto 0);
  signal ts_pc_out: instruction_address_t;
  signal ts_thread_id_out: thread_id_t;
  signal ts_id_write_enable_out : std_logic;

  signal ts_thread_done_in : std_logic;

  -- Streaming processor (SP)
  signal sp_memory_addresses_out : sp_memory_addresses_t;
  signal sp_memory_datas_out : sp_memory_datas_t;

  -- MUX units
  signal mux_pc_in_out : STD_LOGIC_VECTOR(15 downto 0);
  signal mux_instruction_memory_address_in_out : STD_LOGIC_VECTOR(15 downto 0);

  -- Instruction memory
  signal instruction_data_out : std_logic_vector(15 downto 0);

  -- Control(CTRL)
  signal ctrl_pc_write_enable_out: std_logic;
  signal ctrl_opcode_in: opcode_t;
  signal ctrl_register_write_enable_out: std_logic;
  signal ctrl_read_register_1_out: std_logic;
  signal ctrl_read_register_2_out: std_logic;
  signal ctrl_mask_enable_out: std_logic;
  signal ctrl_alu_op_out: alu_op_t;
  signal ctrl_active_barrel_row_out: barrel_row_t;
  signal ctrl_thread_done_out: std_logic;
  signal ctrl_lsu_load_enable_out: std_logic;
  signal ctrl_lsu_write_enable_out: std_logic;

  -- Load / Store unit
  signal load_store_memory_address_out : instruction_address_t;
  signal load_store_memory_data_inout : word_t;
  signal load_store_memory_lbub_out : std_logic_vector(1 downto 0);
  signal load_store_memory_write_enable_out : std_logic;
  signal load_store_memory_chip_enable_out : std_logic;

  signal load_store_registers_file_select_out : barrel_row_t;
  signal load_store_registers_write_enable_out : std_logic;
  signal load_store_sp_memory_data_out : sp_memory_datas_t;

begin

  -- Control unit
  control_unit : entity work.control_unit
  port map(
            clk => clk,
            opcode_in => ctrl_opcode_in,
            register_write_enable_out => ctrl_register_write_enable_out,
            read_register_1_out => ctrl_read_register_1_out,
            read_register_2_out => ctrl_read_register_2_out,
            mask_enable_out => ctrl_mask_enable_out,
            alu_op_out => ctrl_alu_op_out,
            pc_write_enable_out => ctrl_pc_write_enable_out,
            active_barrel_row_out =>ctrl_active_barrel_row_out,
            thread_done_out => ctrl_thread_done_out,
            lsu_load_enable_out => ctrl_lsu_load_enable_out,
            lsu_write_enable => ctrl_lsu_write_enable_out
          );

  -- Thread Spawner
  thread_spawner : entity work.thread_spawner
  port map(
            clk => clk,
            kernel_start_in => comm_kernel_start_out,
            kernel_addr_in => comm_kernel_address_out,
            num_threads_in => comm_kernel_number_of_threads_out,
            thread_done_in => ctrl_thread_done_out,
            pc_start_out => TS_pc_out,
            pc_input_select_out => TS_pc_input_select_out,
            thread_id_out => TS_thread_id_out,
            id_write_enable_out => TS_id_write_enable_out
          );

  communication_unit : entity work.communication_unit
  port map(
            clk => clk,
            ebi_bus_in => mc_ebi_bus,
            spi_bus_in => mc_spi_bus,
            kernel_completed_in => TS_kernel_complete_out,

            command_sram_override_out => comm_sram_override_out,
            command_sram_flip_out => comm_sram_flip_out,

            instruction_data_out => comm_instruction_data_out,
            instruction_address_out => comm_instruction_address_out,
            instruction_write_enable_out => comm_instruction_write_enable_out,

            sram_bus_data_inout => comm_sram_bus_data_out,
            sram_bus_control_out => comm_sram_bus_control_out,

            kernel_number_of_threads_out => comm_kernel_number_of_threads_out,
            kernel_start_out => comm_kernel_start_out,
            kernel_address_out => comm_kernel_address_out,
            comm_reset_system_out => comm_reset_system_out
          );

  load_store_unit : entity work.load_store_unit
  port map(
            -- Input wires
            request_memory_read_in => ctrl_lsu_load_enable_out,
            request_memory_write_in => ctrl_lsu_write_enable_out,
            register_file_select_in => ctrl_active_barrel_row_out,
            sp_memory_addresses_in => sp_memory_addresses_out,
            sp_memory_datas_in => sp_memory_datas_out,

            --Memory wires
            memory_address_out => load_store_memory_address_out,
            memory_data_inout => load_store_memory_data_inout,
            memory_lbub_out => load_store_memory_lbub_out,
            memory_write_enable_out => load_store_memory_write_enable_out,
            memory_chip_enable_out => load_store_memory_chip_enable_out,

            --Streaming processor wires
            registers_file_select_out => load_store_registers_file_select_out,
            registers_write_enable_out => load_store_registers_write_enable_out,
            sp_memory_data_out => load_store_sp_memory_data_out
          );

  pc : entity work.pc
  port map(
            clk => clk,
            write_enable => CTRL_pc_write_enable_out,
            pc_in => mux_pc_in_out,
            pc_out => pc_out);

  instruction_memory : entity work.instruction_memory
  port map(
            clk => clk, reset => comm_reset_system_out,
            write_enable => comm_instruction_write_enable_out,
            address_in => mux_instruction_memory_address_in_out,
            data_in => comm_instruction_data_out,
            data_out => instruction_data_out);

  -- MUX units
  mux_instruction_address : entity work.mux_2
  port map(
            a_in => pc_out,
            b_in => comm_instruction_address_out,
            select_in => comm_instruction_write_enable_out,
            data_out => mux_instruction_memory_address_in_out);


end Behavioral;


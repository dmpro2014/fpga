LIBRARY ieee;
USE ieee.std_logic_1164.ALL; 
USE ieee.numeric_std.ALL;
use work.defines.all;
--use IEEE.NUMERIC_STD.ALL;
 
ENTITY tb_ghettocuda IS
END tb_ghettocuda;
 
ARCHITECTURE behavior OF tb_ghettocuda IS 


   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal constant_write_data_in : std_logic_vector(15 downto 0) := (others => '0');
   signal constant_write_enable_in : std_logic := '0';
   signal constant_write_address_in : std_logic_vector(CONSTANT_MEM_LOG_SIZE - 1 downto 0) := (others => '0');
   signal instruction_memory_data_in : std_logic_vector(31 downto 0) := (others => '0');
   signal instruction_memory_address_in : std_logic_vector(15 downto 0) := (others => '0');
   signal instruction_memory_write_enable_in : std_logic := '0';
   signal ts_kernel_start_in : std_logic := '0';
   signal ts_kernel_address_in : std_logic_vector(15 downto 0) := (others => '0');
   signal ts_num_threads_in : std_logic_vector(18 downto 0) := (others => '0');

	--BiDirs
   signal sram_bus_data_1_inout : sram_bus_data_t;
   signal sram_bus_data_2_inout : sram_bus_data_t;
   signal load_store_sram_bus_data_1_inout : sram_bus_data_t;
   signal load_store_sram_bus_data_2_inout : sram_bus_data_t;

 	--Outputs
   signal sram_bus_control_1_out : std_logic;
   signal sram_bus_control_2_out : std_logic;
   signal ts_kernel_complete_out : std_logic;
   signal load_store_sram_bus_control_1_out : sram_bus_control_t;
   signal load_store_sram_bus_control_2_out : sram_bus_control_t;
   signal led_1_out : std_logic;
   signal led_2_out : std_logic;
   
   
   
   
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



  -- Load / Store unit
  signal load_store_registers_file_select_out : barrel_row_t;
  signal load_store_registers_write_enable_out : std_logic;
  signal load_store_sp_sram_data_out : sp_sram_datas_t;
  

  -- Instruction decode
  signal decode_opcode_out: opcode_t;
  signal decode_operand_rs_out: register_address_t;
  signal decode_operand_rt_out: register_address_t;
  signal decode_operand_rd_out: register_address_t;
  signal decode_shamt_out: std_logic_vector(4 downto 0);
  signal decode_immediate_operand_out: immediate_value_t; 
  signal decode_immediate_enable_out: std_logic; 
  signal decode_lsu_load_enable_out: std_logic;
  signal decode_lsu_write_enable_out: std_logic;
  signal decode_constant_write_enable_out: std_logic;
  signal decode_register_write_enable_out: std_logic;
  signal decode_mask_enable_out: std_logic;
  signal decode_alu_funct_out: alu_funct_t;
  signal decode_thread_done_out: std_logic;


  -- Warp Drve(CTRL)
  signal warp_drive_pc_write_enable_out: std_logic;
  signal warp_drive_active_barrel_row_out: barrel_row_t;

  -- Constant storage
  signal constant_storage_value_out: word_t;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
-- Instruction decode
  instruction_decode: entity work.instruction_decode
  port map(
      instruction_in => instruction_data_out,
      operand_rs_out => decode_operand_rs_out,
      operand_rt_out => decode_operand_rt_out,
      operand_rd_out => decode_operand_rd_out,
      alu_funct_out => decode_alu_funct_out,
      register_write_enable_out => decode_register_write_enable_out,
      lsu_load_enable_out => decode_lsu_load_enable_out,
      lsu_write_enable_out => decode_lsu_write_enable_out,
      mask_enable_out => decode_mask_enable_out,
      thread_done_out => decode_thread_done_out,
      alu_shamt_out => decode_shamt_out,
      constant_write_enable_out => decode_constant_write_enable_out,
      immediate_operand_out => decode_immediate_operand_out,
      immediate_enable_out => decode_immediate_enable_out
  );

  -- Constant storage
  constant_storage: entity work.constant_storage
  generic map(
               DEPTH => CONSTANT_MEM_SIZE,
               LOG_DEPTH => CONSTANT_MEM_LOG_SIZE
              )
  port map(
            clk => clk,
            write_constant_in => constant_write_data_in,
            write_enable_in => constant_write_enable_in,
            write_address_in => constant_write_address_in,
            constant_value_out => constant_storage_value_out,
            constant_select_in => decode_immediate_operand_out
  );



  warp_drive: entity work.warp_drive
  generic map( barrel_bit_width => BARREL_HEIGHT_BIT_WIDTH)
  port map(
            tick => clk,
            reset => reset,
            pc_write_enable_out => warp_drive_pc_write_enable_out,
            active_barrel_row_out => warp_drive_active_barrel_row_out
          );
          -- Replace with array of SPs
  streaming_processors : entity work.sp_block
  port map(
            clock => clk,
            read_reg_1_in => decode_operand_rs_out,
            read_reg_2_in => decode_operand_rt_out,
            write_reg_in  => decode_operand_rd_out,
            immediate_in => decode_immediate_operand_out,
            immediate_enable_in => decode_immediate_enable_out,
            shamt_in => decode_shamt_out,
            reg_write_enable_in => decode_register_write_enable_out,
            mask_enable_in => decode_mask_enable_out,
            alu_function_in => decode_alu_funct_out,
            id_data_in => TS_thread_id_out,
            id_write_enable_in => TS_id_write_enable_out,
            barrel_select_in =>  warp_drive_active_barrel_row_out,
            return_write_enable_in => load_store_registers_write_enable_out,
            return_barrel_select_in => load_store_registers_file_select_out,
            return_data_in => load_store_sp_sram_data_out,
            lsu_write_data_out => sp_sram_bus_data_out,
            lsu_address_out     => sp_sram_bus_addresses_out,
            constant_write_enable_in => decode_constant_write_enable_out,
            constant_value_in => constant_storage_value_out
           );

  -- Thread Spawner
  thread_spawner : entity work.thread_spawner
  port map(
            clk => clk,
            kernel_start_in => ts_kernel_start_in,
            kernel_addr_in => ts_kernel_address_in,
            num_threads_in => ts_num_threads_in,
            thread_done_in => decode_thread_done_out,
            pc_start_out => TS_pc_out,
            pc_input_select_out => TS_pc_input_select_out,
            thread_id_out => TS_thread_id_out,
            id_write_enable_out => TS_id_write_enable_out,
            kernel_complete_out => TS_kernel_complete_out
          );

  load_store_unit : entity work.load_store_unit
  port map(
            clock => clk,
            -- Input wires
            request_sram_bus_read_in => decode_lsu_load_enable_out,
            request_sram_bus_write_in => decode_lsu_write_enable_out,
            register_file_select_in => warp_drive_active_barrel_row_out,
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
            write_enable => warp_drive_pc_write_enable_out,
            pc_in => TS_pc_out,
						pc_input_select_in => TS_pc_input_select_out,
            pc_out => pc_out);

  instruction_memory : entity work.instruction_memory
  port map(
            clk => clk, reset => reset,
            write_enable_in => instruction_memory_write_enable_in,
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
            
 
           
   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
     procedure write_instruction(instruction : in instruction_t
                                ;address     : in instruction_address_t
                                ) is begin
                                
       instruction_memory_data_in <= address;
       instruction_memory_data_in <= instruction;
       instruction_memory_write_enable_in <= '1';
       wait until rising_edge(clk);
       instruction_memory_write_enable_in <= '0';
       
     end procedure;
     
     procedure FillInstructionMemory is
			constant TEST_INSTRS : integer := 30;
			type InstrData is array (0 to TEST_INSTRS-1) of instruction_t;
			variable TestInstrData : InstrData := (
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"00221820", --add $3, $1, $2	   /$3 = 12
				X"40221820" --finished
				);
		begin
			for i in 0 to TEST_INSTRS-1 loop
				write_instruction(TestInstrData(i), std_logic_vector(to_unsigned(i, INSTRUCTION_ADDRESS_WIDTH)));
			end loop;
		end FillInstructionMemory;
   
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;
      
      wait for clk_period*10;
      
      FillInstructionMemory;
      
      wait for clk_period;
      
      ts_kernel_start_in <= '1';
      ts_kernel_address_in <= std_logic_vector(to_unsigned(0, 19));
      ts_num_threads_in <= std_logic_vector(to_unsigned(512, 19));
      
      wait for BARREL_HEIGHT * clk_period;
      
      ts_kernel_start_in <= '0';

   end process;

END;

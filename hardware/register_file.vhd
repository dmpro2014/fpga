library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.defines.all;

entity register_file is
    Port (  clk : in std_logic;
						-- General registers
					  read_register_1_in: in std_logic_vector(REGISTER_COUNT_BIT_WIDTH -1 downto 0);
						read_register_2_in: in std_logic_vector(REGISTER_COUNT_BIT_WIDTH -1 downto 0);
						write_register_in: in std_logic_vector(REGISTER_COUNT_BIT_WIDTH -1 downto 0);
						write_data_in: in word_t;
						register_write_enable_in: in std_logic;
						read_data_1: out word_t;
						read_data_2: out word_t;
						
						-- ID registers
						id_register_write_enable_in:in std_logic;
						id_register_in: in thread_id_t;
						
						--Return registers
						return_register_write_enable_in: in std_logic;
						return_data_in : in word_t;
												
						--LSU
						lsu_address_out: out memory_address_t;
						lsu_write_data_out: out word_t
						
		);
		
end register_file;

architecture rtl of register_file is
begin
end rtl;
library ieee;
use ieee.std_logic_1164.all;
use work.defines.all;
use ieee.numeric_std.all;


entity instruction_memory is
    port ( clk : in std_logic;
           reset : in std_logic;
           write_enable_in : in std_logic;
           address_in : in  instruction_address_t;
           address_hi_select_in : in  std_logic;
           data_in : in word_t;
           data_out : out instruction_t
           );
end instruction_memory;

architecture behavioral of instruction_memory is

  type mem_t is array(INSTRUCTION_MEM_SIZE - 1 downto 0) of word_t;
  signal inst_mem_hi : mem_t := ( (10) => X"4000", others => (others => '0') );
--                               (0) => X"0000" -- ldc $lsu_data, 0
--                               ,(1) => X"0000" -- ldc $lsu_data, 0
--                               ,(2) => X"0000" -- ldc $lsu_data, 0
--                               ,(3) => X"0000" -- ldc $lsu_data, 0
--                               ,(4) => X"0805" -- 
--                               ,(5) => X"0001" -- add $address_hi, $zero, $id_hi
--                               ,(6) => X"0002" -- add $address_lo, $zero, $id_lo
--                               ,(7) => X"1000" -- sw
--                               ,(8) => X"0000" -- nop
--                               ,(9) => X"0000" -- nop
--                               ,(10) => X"0000" -- nop
--                               ,(11) => X"4000" -- thread_finished
--                               ,(12) => X"0000" -- thread_finished
--                               ,(13) => X"0000" -- thread_finished
--                               ,(14) => X"0000" -- thread_finished
--                               ,(15) => X"0000" -- thread_finished
--                                , others => (others => '0')
--                                );

--                                (3) => X"0002" 
--                                , (4) => X"0001"
--                                , (5) => X"0002"
--                                , (6) => X"1000"
--                                , (7) => X"0000"
--                                , (8) => X"4000"

  signal inst_mem_lo : mem_t := ( others => (others => '0'));
--                               (0) => X"0000" -- ldc $lsu_data, 0
--                               ,(1) => X"0000" -- ldc $lsu_data, 0
--                               ,(2) => X"0000" -- ldc $lsu_data, 0
--                               ,(3) => X"0000" -- ldc $lsu_data, 0
--                               ,(4) => X"0000" -- ldc $lsu_data, 0
--                               ,(5) => X"1820" -- add $address_hi, $zero, $id_hi
--                               ,(6) => X"2020" -- add $address_lo, $zero, $id_lo
--                               ,(7) => X"0000" -- sw
--                               ,(8) => X"0000" -- nop
--                               ,(9) => X"0000" -- nop
--                               ,(10) => X"0000" -- nop
--                               ,(11) => X"0000" -- thread_finished
--                               ,(12) => X"0000" -- thread_finished
--                               ,(13) => X"0000" -- thread_finished
--                               ,(14) => X"0000" -- thread_finished
--                               ,(15) => X"0000" -- thread_finished
--                                , others => (others => '0')
--                                );

begin

  registers: process (clk) is
  begin

    if rising_edge(clk) then
      if write_enable_in = '0' then
        data_out <= inst_mem_hi(to_integer(unsigned(address_in))) & inst_mem_lo(to_integer(unsigned(address_in)));
      elsif write_enable_in = '1' then
        if address_hi_select_in = '1' then
          inst_mem_hi(to_integer(unsigned(address_in))) <= data_in;
        else
          inst_mem_lo(to_integer(unsigned(address_in))) <= data_in;
        end if;
      end if;
    end if;

  end process;

end behavioral;

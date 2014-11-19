library ieee;
use ieee.std_logic_1164.all;
use work.defines.all;
use ieee.numeric_std.all;

entity fake_ram is
  generic ( init_value : std_logic );
  port ( clk : in std_logic;
           reset : in std_logic;
           write_enable_n_in : in std_logic;
           address_in : in  std_logic_vector(18 downto 0);
           data_inout : inout word_t
           );
end fake_ram;

architecture Behavioral of fake_ram is

  type mem_t is array(8192 - 1 downto 0) of word_t;
  signal fake_mem : mem_t := (others => (others => init_value));
  
  attribute ram_style:string;
  attribute ram_style of fake_mem: signal is "block";
  
  
  signal data_in_i : word_t; --Data in to the sram
  signal data_out_i : word_t; --Data out of the sram

begin

  --Write
  data_in_i <= data_inout;
  --Read
  data_inout <= data_out_i when write_enable_n_in = '1' else (others => 'Z');

  mem: process (clk) is
  begin
    if rising_edge(clk) then
      if write_enable_n_in = '0' then
          fake_mem(to_integer(unsigned(address_in(12 downto 0)))) <= data_in_i;
      end if;
          data_out_i <= fake_mem(to_integer(unsigned(address_in(12 downto 0))));
    end if;
  end process;

end Behavioral;


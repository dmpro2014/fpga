library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.defines.all;
use work.lsu_defs.all;

entity load_store_unit is
  Port ( -- Input wires
         clock : in std_logic;
         request_sram_bus_read_in : in  std_logic;
         request_sram_bus_write_in : in  std_logic;
         register_file_select_in : in barrel_row_t;
         sp_sram_bus_addresses_in : in sp_sram_addresses_t;
         sp_sram_bus_datas_in : in sp_sram_datas_t;

         -- Memory wires
         sram_bus_data_1_inout : inout sram_bus_data_t;
         sram_bus_control_1_out : out sram_bus_control_t;
         sram_bus_data_2_inout : inout sram_bus_data_t;
         sram_bus_control_2_out : out sram_bus_control_t;

         -- Streaming processor wires
         registers_file_select_out : out barrel_row_t;
         registers_write_enable_out : out  std_logic;
         sp_sram_bus_data_out : out sp_sram_datas_t );
end load_store_unit;

architecture Behavioral of load_store_unit is

    signal requests_all     : request_batch_t;

    signal requests_1       : request_batch_part_t;
    signal mem_queue_top_1  : request_t;
    signal read_response_1  : read_response_t;

    signal requests_2       : request_batch_part_t;
    signal mem_queue_top_2  : request_t;
    signal read_response_2  : read_response_t;

    signal mem_queue_accept : std_logic;

    signal sp_sram_bus_data_out_even : sp_sram_datas_t;
    signal sp_sram_bus_data_out_odd  : sp_sram_datas_t;

    function to_request_batch_t
        ( read_flag    : std_logic
        ; write_flag   : std_logic
        ; barrel_line  : barrel_row_t
        ; addresses    : sp_sram_addresses_t
        ; write_data   : sp_sram_datas_t
        )
        return request_batch_t
        is
            variable requests : request_batch_t;
        begin
            for i in sp_sram_addresses_t'range loop
                requests(i) :=
                    ( valid        => (read_flag or write_flag)
                    , sp           => i
                    , write_enable => write_flag
                    , barrel_line  => barrel_line
                    , address      => addresses(i)
                    , write_data   => write_data(i)
                    );
            end loop;
            return requests;
    end function;

begin

    -- Enable both rams. We don't like polar bears.
    sram_bus_control_1_out.chip_select <= '0';
    sram_bus_control_2_out.chip_select <= '0';

    -- We want both the upper and lower byte. Polar-bear-stuff again?
    sram_bus_control_1_out.lbub <= "00";
    sram_bus_control_2_out.lbub <= "00";

    -- Set output enable. It's overrided automatically when writing.
    -- (Cannot. Output-enable is not exposed.)

    -- Serialize data into a record
    requests_all <= to_request_batch_t ( request_sram_bus_read_in
                                       , request_sram_bus_write_in
                                       , register_file_select_in
                                       , sp_sram_bus_addresses_in
                                       , sp_sram_bus_datas_in
                                       );

    clock_enable_memory_queue:
        process (clock) begin
            if rising_edge(clock) then
                mem_queue_accept <= request_sram_bus_read_in or request_sram_bus_write_in;
            end if;
        end process;

    mem_request_switch:
        entity work.mem_request_switch
            port map
                ( clock         => clock
                , requests_all  => requests_all
                , requests_even => requests_1
                , requests_odd  => requests_2
                );


    mem_queue_1:
        entity work.mem_queue
            port map
                ( clock       => clock
                , accept      => mem_queue_accept
                , requests    => requests_1
                , top_request => mem_queue_top_1
                );


    mem_queue_2:
        entity work.mem_queue
            port map
                ( clock       => clock
                , accept      => mem_queue_accept
                , requests    => requests_2
                , top_request => mem_queue_top_2
                );


    mem_control_1:
        entity work.mem_control
            port map
                ( clock          => clock
                , ram_control    => sram_bus_control_1_out
                , ram_data       => sram_bus_data_1_inout
                , request_packet => mem_queue_top_1
                , read_response  => read_response_1
                );


    mem_control_2:
        entity work.mem_control
            port map
                ( clock          => clock
                , ram_control    => sram_bus_control_2_out
                , ram_data       => sram_bus_data_2_inout
                , request_packet => mem_queue_top_2
                , read_response  => read_response_2
                );

    -- Deserialize record for output.
    readback_handler:
        process (clock) begin
            if rising_edge(clock) then
                registers_write_enable_out <= read_response_1.valid or read_response_1.valid;

                if read_response_1.valid = '1' then
                    registers_file_select_out <= read_response_1.barrel_line;
                else
                    registers_file_select_out <= read_response_2.barrel_line;
                end if;
            end if;
        end process;
        
        process (clock) begin
            if rising_edge(clock) then
                sp_sram_bus_data_out(read_response_1.sp) <= read_response_1.data;
                sp_sram_bus_data_out(read_response_2.sp) <= read_response_2.data;
            end if;
        end process;


end Behavioral;


library ieee;
use ieee.std_logic_1164.all;
use work.defines.all;

package lsu_defs is

    subtype sp_number is integer range 0 to NUMBER_OF_STREAMING_PROCESSORS;

    type request_t is record
        valid        : std_logic;
        barrel_line  : barrel_row_t;
        sp           : sp_number;
        write_enable : std_logic;
        address      : memory_address_t;
        write_data   : word_t;
    end record;

    type read_response_t is record
        valid        : std_logic;
        barrel_line  : barrel_row_t;
        sp           : sp_number;
        data         : word_t;
    end record;

    type request_batch_t is array(0 to sp_number'high) of request_t;
    type request_batch_part_t is array(0 to (sp_number'high/2)) of request_t;

end lsu_defs;
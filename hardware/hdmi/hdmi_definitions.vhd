library ieee;
use ieee.std_logic_1164.all;

package hdmi_definitions is

    type ds_pair is record
        p : std_logic;
        n : std_logic;
    end record;

    type hdmi_connector_t is record
        clock     : ds_pair;
        channel_0 : ds_pair;
        channel_1 : ds_pair;
        channel_2 : ds_pair;
    end record;

    type video_mode_sync_spec_t is record
        start  : natural;
        width  : natural;
        active : std_logic;
    end record;

    type video_mode_dimension_t is record
        total      : natural;
        resoultion : natural;
        sync       : video_mode_sync_spec_t;
    end record;

    type video_mode_t is record
        h : video_mode_dimension_t;
        v : video_mode_dimension_t;
    end record;

    constant video_640x480_60Hz : video_mode_t :=
        ( h => (total => 800, resolution => 640, sync => (start => 16, width => 96, active => '0'))
        , v => (total => 490, resolution => 480, sync => (start => 10, width => 2,  active => '0'))
        );

end hdmi_definitions;

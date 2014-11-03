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
        stop   : natural;
        active : std_logic;
    end record;

    type video_mode_dimension_t is record
        total      : natural;
        resolution : natural;
        sync       : video_mode_sync_spec_t;
    end record;

    type video_mode_t is record
        h : video_mode_dimension_t;
        v : video_mode_dimension_t;
    end record;

    type video_control_t is record
        blank : std_logic;
        vsync : std_logic;
        hsync : std_logic;
    end record;

    -- These timings where gathered from CEA-861-D.
    constant video_640x480_60Hz : video_mode_t :=
        ( h => (total => 800, resolution => 640, sync => (start => 656, stop => 752, active => '0'))
        , v => (total => 490, resolution => 480, sync => (start => 490, stop => 492, active => '0'))
        );

    function to_std_logic(p: boolean) return std_logic;

end hdmi_definitions;

package body hdmi_definitions is

    function to_std_logic(p: boolean)
        return std_logic
    is begin
        if p then
            return '1';
        else
            return '0';
        end if;
    end;

end hdmi_definitions;
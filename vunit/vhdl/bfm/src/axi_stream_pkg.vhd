-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this file,
-- You can obtain one at http://mozilla.org/MPL/2.0/.
--
-- Copyright (c) 2017, Lars Asplund lars.anders.asplund@gmail.com

library ieee;
use ieee.std_logic_1164.all;

use work.stream_pkg.all;
context work.com_context;
context work.data_types_context;
use work.message_types_pkg.all;
use work.fail_pkg.all;

package axi_stream_pkg is

  type axi_stream_master_t is record
    p_actor : actor_t;
    p_data_length : natural;
  end record;

  type axi_stream_slave_t is record
    p_actor : actor_t;
    p_data_length : natural;
    p_fail_log : fail_log_t;
  end record;

  impure function new_axi_stream_master(data_length : natural) return axi_stream_master_t;
  impure function new_axi_stream_slave(data_length : natural) return axi_stream_slave_t;
  impure function data_length(master : axi_stream_master_t) return natural;
  impure function data_length(master : axi_stream_slave_t) return natural;
  impure function as_stream(master : axi_stream_master_t) return stream_master_t;
  impure function as_stream(slave : axi_stream_slave_t) return stream_slave_t;

  constant write_axi_stream_msg : message_type_t := new_message_type("write axi stream");

  procedure write_axi_stream(signal event : inout event_t;
                             axi_stream : axi_stream_master_t;
                             tdata : std_logic_vector;
                             tlast : std_logic := '1');

end package;

package body axi_stream_pkg is

  impure function new_axi_stream_master(data_length : natural) return axi_stream_master_t is
  begin
    return (p_actor => create,
            p_data_length => data_length);
  end;

  impure function new_axi_stream_slave(data_length : natural) return axi_stream_slave_t is
  begin
    return (p_actor => create,
            p_data_length => data_length,
            p_fail_log => new_fail_log);
  end;

  impure function data_length(master : axi_stream_master_t) return natural is
  begin
    return master.p_data_length;
  end;

  impure function data_length(master : axi_stream_slave_t) return natural is
  begin
    return master.p_data_length;
  end;

  impure function as_stream(master : axi_stream_master_t) return stream_master_t is
  begin
    return (p_actor => master.p_actor);
  end;

  impure function as_stream(slave : axi_stream_slave_t) return stream_slave_t is
  begin
    return (p_actor => slave.p_actor);
  end;

  procedure write_axi_stream(signal event : inout event_t;
                             axi_stream : axi_stream_master_t;
                             tdata : std_logic_vector;
                             tlast : std_logic := '1') is
    variable msg : msg_t := create;
    constant normalized_data : std_logic_vector(tdata'length-1 downto 0) := tdata;
  begin
    push_message_type(msg.data, write_axi_stream_msg);
    push_std_ulogic_vector(msg.data, normalized_data);
    push_std_ulogic(msg.data, tlast);
    send(event, axi_stream.p_actor, msg);
  end;

end package body;

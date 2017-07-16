-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this file,
-- You can obtain one at http://mozilla.org/MPL/2.0/.
--
-- Copyright (c) 2017, Lars Asplund lars.anders.asplund@gmail.com

library ieee;
use ieee.std_logic_1164.all;

use work.stream_pkg.all;
context work.com_context;

package axi_stream_pkg is

  type axi_stream_master_t is record
    p_actor : actor_t;
    p_data_length : natural;
  end record;

  type axi_stream_slave_t is record
    p_actor : actor_t;
    p_data_length : natural;
  end record;

  impure function new_axi_stream_master(data_length : natural) return axi_stream_master_t;
  impure function new_axi_stream_slave(data_length : natural) return axi_stream_slave_t;
  impure function data_length(master : axi_stream_master_t) return natural;
  impure function data_length(master : axi_stream_slave_t) return natural;
  impure function as_stream(master : axi_stream_master_t) return stream_master_t;
  impure function as_stream(slave : axi_stream_slave_t) return stream_slave_t;
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
            p_data_length => data_length);
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

end package body;

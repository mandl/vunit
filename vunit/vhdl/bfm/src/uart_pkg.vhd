-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this file,
-- You can obtain one at http://mozilla.org/MPL/2.0/.
--
-- Copyright (c) 2017, Lars Asplund lars.anders.asplund@gmail.com

library ieee;
use ieee.std_logic_1164.all;

context work.com_context;
use work.stream_pkg.all;
use work.integer_vector_ptr_pkg.all;
use work.queue_pkg.all;
use work.message_types_pkg.all;

package uart_pkg is
  type uart_master_t is record
    stream : stream_master_t;
    p_baud_rate : natural;
    p_idle_state : std_logic;
  end record;

  type uart_slave_t is record
    stream : stream_slave_t;
    p_baud_rate : natural;
    p_idle_state : std_logic;
  end record;

  -- Set the baud rate [bits/s]
  procedure set_baud_rate(signal event : inout event_t;
                          uart_master : uart_master_t;
                          baud_rate : natural);

  procedure set_baud_rate(signal event : inout event_t;
                          uart_slave : uart_slave_t;
                          baud_rate : natural);

  constant default_baud_rate : natural := 115200;
  constant default_idle_state : std_logic := '1';
  impure function new_uart_master(initial_baud_rate : natural := default_baud_rate;
                                  idle_state : std_logic := default_idle_state) return uart_master_t;
  impure function new_uart_slave(initial_baud_rate : natural := default_baud_rate;
                                 idle_state : std_logic := default_idle_state) return uart_slave_t;

  impure function as_stream(uart_master : uart_master_t) return stream_master_t;
  impure function as_stream(uart_slave : uart_slave_t) return stream_slave_t;

  constant uart_set_baud_rate_msg : natural := new_message_type("uart set baud rate");
end package;

package body uart_pkg is

  impure function new_uart_master(initial_baud_rate : natural := default_baud_rate;
                                  idle_state : std_logic := default_idle_state) return uart_master_t is
  begin
    return (stream => new_stream_master,
            p_baud_rate => initial_baud_rate,
            p_idle_state => idle_state);
  end;

  impure function new_uart_slave(initial_baud_rate : natural := default_baud_rate;
                                 idle_state : std_logic := default_idle_state) return uart_slave_t is
  begin
    return (stream => new_stream_slave,
            p_baud_rate => initial_baud_rate,
            p_idle_state => idle_state);
  end;

  impure function as_stream(uart_master : uart_master_t) return stream_master_t is
  begin
    return uart_master.stream;
  end;

  impure function as_stream(uart_slave : uart_slave_t) return stream_slave_t is
  begin
    return uart_slave.stream;
  end;

  procedure set_baud_rate(signal event : inout event_t;
                          actor : actor_t;
                          baud_rate : natural) is
    variable msg : msg_t := create;
  begin
    push(msg.data, uart_set_baud_rate_msg);
    push(msg.data, baud_rate);
    send(event, actor, msg);
  end;

  procedure set_baud_rate(signal event : inout event_t;
                          uart_master : uart_master_t;
                          baud_rate : natural) is
  begin
    set_baud_rate(event, uart_master.stream.p_actor, baud_rate);
  end;

  procedure set_baud_rate(signal event : inout event_t;
                          uart_slave : uart_slave_t;
                          baud_rate : natural) is
  begin
    set_baud_rate(event, uart_slave.stream.p_actor, baud_rate);
  end;
end package body;

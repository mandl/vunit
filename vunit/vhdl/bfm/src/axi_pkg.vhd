-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this file,
-- You can obtain one at http://mozilla.org/MPL/2.0/.
--
-- Copyright (c) 2017, Lars Asplund lars.anders.asplund@gmail.com

library ieee;
use ieee.std_logic_1164.all;

use work.queue_pkg.all;
use work.message_types_pkg.all;
context work.com_context;

package axi_pkg is
  subtype axi_resp_t is std_logic_vector(1 downto 0);
  constant axi_resp_okay : axi_resp_t := "00";
  constant axi_resp_exokay : axi_resp_t := "01";
  constant axi_resp_slverr : axi_resp_t := "10";
  constant axi_resp_decerr : axi_resp_t := "11";

  subtype axi_burst_type_t is std_logic_vector(1 downto 0);
  constant axi_burst_type_fixed : axi_burst_type_t := "00";
  constant axi_burst_type_incr : axi_burst_type_t := "01";
  constant axi_burst_type_wrap : axi_burst_type_t := "10";

  subtype axi4_len_t is std_logic_vector(7 downto 0);
  subtype axi4_size_t is std_logic_vector(2 downto 0);

  type axi_slave_t is record
    p_actor : actor_t;
  end record;

  impure function new_axi_slave return axi_slave_t;

  -- Disables failure on internal errors that are instead pushed to an error queue
  -- Used for testing the BFM error messages
  procedure disable_fail_on_error(signal event : inout event_t; axi_slave : axi_slave_t; variable error_queue : inout queue_t);

  -- Set the maximum number address channel tokens that can be queued
  procedure set_address_channel_fifo_depth(signal event : inout event_t; axi_slave : axi_slave_t; depth : positive);

  -- Set the maximum number write responses that can be queued
  procedure set_write_response_fifo_depth(signal event : inout event_t; axi_slave : axi_slave_t; depth : positive);

  -- Set the address channel stall probability
  procedure set_address_channel_stall_probability(signal event : inout event_t; axi_slave : axi_slave_t; probability : real);

  -- Check that bursts are well behaved, that is that data channel traffic is
  -- as compact as possible

  -- For write:
  -- 1. awvalid never high without wvalid
  -- 2. wvalid never goes low during active burst
  -- 3. uses max awsize supported by data width
  -- 4. bready never low during active burst

  -- For read:
  -- 1. rready never low during active burst
  -- 2. uses max arsize supported by data width
  procedure enable_well_behaved_check(signal event : inout event_t; axi_slave : axi_slave_t);

  constant axi_slave_disable_fail_on_error_msg : message_type_t := new_message_type("axi slave disable fail on error");
  constant axi_slave_set_address_channel_fifo_depth_msg : message_type_t := new_message_type("axi slave set address channel fifo depth");
  constant axi_slave_set_write_response_fifo_depth_msg : message_type_t := new_message_type("set write response fifo depth");
  constant axi_slave_set_address_channel_stall_probability_msg : message_type_t := new_message_type("axi slave set address channel stall probability");
  constant axi_slave_enable_well_behaved_check_msg : message_type_t := new_message_type("axi slave enable well behaved check");

end package;

package body axi_pkg is
  impure function new_axi_slave return axi_slave_t is
  begin
    return (p_actor => create);
  end;

  procedure disable_fail_on_error(signal event : inout event_t; axi_slave : axi_slave_t; variable error_queue : inout queue_t) is
    variable request_msg, reply_msg : msg_t;
  begin
    request_msg := create;
    push_message_type(request_msg.data, axi_slave_disable_fail_on_error_msg);
    request(event, axi_slave.p_actor, request_msg, reply_msg);
    error_queue := pop_queue_ref(reply_msg.data);
    delete(reply_msg);
  end;

  procedure set_address_channel_fifo_depth(signal event : inout event_t; axi_slave : axi_slave_t; depth : positive) is
    variable request_msg : msg_t;
    variable ack : boolean;
  begin
    request_msg := create;
    push_message_type(request_msg.data, axi_slave_set_address_channel_fifo_depth_msg);
    push(request_msg.data, depth);
    request(event, axi_slave.p_actor, request_msg, ack);
    assert ack report "Failed on disable_fail_on_error command";
  end;

  procedure set_write_response_fifo_depth(signal event : inout event_t; axi_slave : axi_slave_t; depth : positive) is
    variable request_msg : msg_t;
    variable ack : boolean;
  begin
    request_msg := create;
    push_message_type(request_msg.data, axi_slave_set_write_response_fifo_depth_msg);
    push(request_msg.data, depth);
    request(event, axi_slave.p_actor, request_msg, ack);
    assert ack report "Failed on set_write_response_fifo_depth command";
  end;

  procedure set_address_channel_stall_probability(signal event : inout event_t; axi_slave : axi_slave_t; probability : real) is
    variable request_msg : msg_t;
    variable ack : boolean;
  begin
    request_msg := create;
    push_message_type(request_msg.data, axi_slave_set_address_channel_stall_probability_msg);
    push_real(request_msg.data, probability);
    request(event, axi_slave.p_actor, request_msg, ack);
    assert ack report "Failed on set_address_channel_stall_probability command";
  end;

  procedure enable_well_behaved_check(signal event : inout event_t; axi_slave : axi_slave_t) is
    variable request_msg : msg_t;
    variable ack : boolean;
  begin
    request_msg := create;
    push_message_type(request_msg.data, axi_slave_enable_well_behaved_check_msg);
    request(event, axi_slave.p_actor, request_msg, ack);
    assert ack report "Failed on msg_enable_well_behaved_check command";
  end;
end package body;

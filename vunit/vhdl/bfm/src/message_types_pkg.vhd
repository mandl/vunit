-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this file,
-- You can obtain one at http://mozilla.org/MPL/2.0/.
--
-- Copyright (c) 2017, Lars Asplund lars.anders.asplund@gmail.com


use work.integer_vector_ptr_pkg.all;
use work.string_ptr_pkg.all;
use work.queue_pkg.all;
use work.fail_pkg.all;

package message_types_pkg is
  type message_types_t is record
    p_name_ptrs : integer_vector_ptr_t;
    p_fail_log : fail_log_t;
  end record;

  constant p_message_types : message_types_t := (
    p_name_ptrs => allocate,
    p_fail_log => new_fail_log);

  type message_type_t is record
    p_code : integer;
  end record;

  impure function new_message_type(name : string) return message_type_t;
  procedure unexpected_message_type(message_type : message_type_t);

  procedure push_message_type(queue : queue_t; message_type : message_type_t);
  impure function pop_message_type(queue : queue_t) return message_type_t;

  constant message_handled : message_type_t := new_message_type("message already handled");
end package;

package body message_types_pkg is

  impure function new_message_type(name : string) return message_type_t is
    variable code : integer := length(p_message_types.p_name_ptrs);
  begin
    resize(p_message_types.p_name_ptrs, code+1);
    set(p_message_types.p_name_ptrs, code, to_integer(allocate(name)));
    return (p_code => code);
  end function;

  impure function is_valid(code : integer) return boolean is
  begin
    return 0 <= code and code < length(p_message_types.p_name_ptrs);
  end;

  procedure unexpected_message_type(message_type : message_type_t) is
    constant code : integer := message_type.p_code;
  begin
    if message_type = message_handled then
      null;
    elsif is_valid(code) then
      fail(p_message_types.p_fail_log,
           "Got unexpected message " & to_string(to_string_ptr(get(p_message_types.p_name_ptrs, code))));
    else
      fail(p_message_types.p_fail_log,
           "Got invalid message with code " & to_string(code));
    end if;
  end procedure;

  procedure push_message_type(queue : queue_t; message_type : message_type_t) is
  begin
    push(queue, message_type.p_code);
  end;

  impure function pop_message_type(queue : queue_t) return message_type_t is
    constant code : integer := pop(queue);
  begin
    if not is_valid(code) then
      fail(p_message_types.p_fail_log, "Got invalid message with code " & to_string(code));
    end if;
    return (p_code => code);
  end;
end package body;

-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this file,
-- You can obtain one at http://mozilla.org/MPL/2.0/.
--
-- Copyright (c) 2017, Lars Asplund lars.anders.asplund@gmail.com

use work.integer_vector_ptr_pkg.all;
use work.string_ptr_pkg.all;
use work.com_pkg.all;
use work.com_types_pkg.all;
use work.log_pkg.all;
use work.logger_pkg.all;

package message_types_pkg is
  type message_types_t is record
    p_name_ptrs : integer_vector_ptr_t;
  end record;

  constant p_message_types : message_types_t := (
    p_name_ptrs => allocate);

  type message_type_t is record
    p_code : integer;
  end record;

  constant message_types_logger : logger_t := new_logger("vunit_lib.message_types_pkg");

  impure function new_message_type(name : string) return message_type_t;
  procedure unexpected_message_type(message_type : message_type_t;
                                    logger : logger_t := message_types_logger);

  procedure push_message_type(msg : msg_t;
                              message_type : message_type_t;
                              logger : logger_t := message_types_logger);

  impure function pop_message_type(msg : msg_t;
                                   logger : logger_t := message_types_logger) return message_type_t;

  procedure handle_message(variable message_type : inout message_type_t);
  impure function is_already_handled(message_type : message_type_t) return boolean;

end package;

package body message_types_pkg is
  impure function new_message_type(name : string) return message_type_t is
    variable code : integer := length(p_message_types.p_name_ptrs);
  begin
    resize(p_message_types.p_name_ptrs, code+1);
    set(p_message_types.p_name_ptrs, code, to_integer(allocate(name)));
    return (p_code => code);
  end function;

  constant message_handled : message_type_t := new_message_type("message handled");

  impure function is_valid(code : integer) return boolean is
  begin
    return 0 <= code and code < length(p_message_types.p_name_ptrs);
  end;

  procedure handle_message(variable message_type : inout message_type_t) is
  begin
    message_type := message_handled;
  end;

  impure function is_already_handled(message_type : message_type_t) return boolean is
  begin
    return message_type = message_handled;
  end;

  procedure unexpected_message_type(message_type : message_type_t;
                                    logger : logger_t := message_types_logger) is
    constant code : integer := message_type.p_code;
  begin
    if is_already_handled(message_type) then
      null;
    elsif is_valid(code) then
      failure(logger, "Got unexpected message " & to_string(to_string_ptr(get(p_message_types.p_name_ptrs, code))));
    else
      failure(logger, "Got invalid message with code " & to_string(code));
    end if;
  end procedure;

  procedure push_message_type(msg : msg_t;
                              message_type : message_type_t;
                              logger : logger_t := message_types_logger) is
  begin
    push(msg, message_type.p_code);
  end;

  impure function pop_message_type(msg : msg_t;
                                   logger : logger_t := message_types_logger) return message_type_t is
    constant code : integer := pop(msg);
  begin
    if not is_valid(code) then
      failure(logger, "Got invalid message with code " & to_string(code));
    end if;
    return (p_code => code);
  end;
end package body;

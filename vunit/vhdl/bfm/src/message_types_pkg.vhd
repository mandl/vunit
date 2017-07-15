-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this file,
-- You can obtain one at http://mozilla.org/MPL/2.0/.
--
-- Copyright (c) 2017, Lars Asplund lars.anders.asplund@gmail.com


use work.integer_vector_ptr_pkg.all;
use work.string_ptr_pkg.all;
use work.fail_pkg.all;

package message_types_pkg is
  type message_types_t is record
    p_name_ptrs : integer_vector_ptr_t;
  end record;

  constant message_types : message_types_t := (
    p_name_ptrs => allocate);

  impure function new_message_type(name : string) return natural;
  procedure unexpected_message_type(fail_log : fail_log_t; code : natural);
end package;

package body message_types_pkg is

  impure function new_message_type(name : string) return natural is
    variable code : natural := length(message_types.p_name_ptrs);
  begin
    resize(message_types.p_name_ptrs, code+1);
    set(message_types.p_name_ptrs, code, to_integer(allocate(name)));
    return code;
  end function;

  procedure unexpected_message_type(fail_log : fail_log_t; code : natural) is
  begin
    if code < length(message_types.p_name_ptrs) then
      fail(fail_log, "Got unexpected message " & to_string(get(message_types.p_name_ptrs, code)));
    else
      fail(fail_log, "Got unexpected message with code " & to_string(code));
    end if;
  end procedure;

end package body;

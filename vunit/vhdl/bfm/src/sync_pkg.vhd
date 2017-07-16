-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this file,
-- You can obtain one at http://mozilla.org/MPL/2.0/.
--
-- Copyright (c) 2017, Lars Asplund lars.anders.asplund@gmail.com

library ieee;
use ieee.std_logic_1164.all;

context work.vunit_context;
context work.com_context;
use work.queue_pkg.all;
use work.message_types_pkg.all;

package sync_pkg is
  constant await_completion_msg : message_type_t := new_message_type("await completion");
  procedure await_completion(signal event : inout event_t;
                             actor : actor_t);

  procedure handle_sync_message(signal event : inout event_t;
                                variable message_type : inout message_type_t;
                                variable msg : inout msg_t);
end package;

package body sync_pkg is
  procedure await_completion(signal event : inout event_t;
                             actor : actor_t) is
    variable msg, reply_msg : msg_t;
  begin
    msg := create;
    push_message_type(msg.data, await_completion_msg);
    send(event, actor, msg);
    receive_reply(event, msg, reply_msg);
    delete(reply_msg);
  end;

  procedure handle_sync_message(signal event : inout event_t;
                                variable message_type : inout message_type_t;
                                variable msg : inout msg_t) is
    variable reply_msg : msg_t;
  begin
    if message_type = await_completion_msg then
      message_type := message_handled;
      reply_msg := create;
      reply(event, msg, reply_msg);
    end if;
  end;

end package body;

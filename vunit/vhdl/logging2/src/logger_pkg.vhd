-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this file,
-- You can obtain one at http://mozilla.org/MPL/2.0/.
--
-- Copyright (c) 2017, Lars Asplund lars.anders.asplund@gmail.com

use work.string_ptr_pkg.all;
use work.integer_vector_ptr_pkg.all;
use work.queue_pkg.all;
use work.core_pkg.core_failure;

package logger_pkg is
  type log_level_config_t is (no_level,
                              verbose,
                              debug,
                              info,
                              warning,
                              error,
                              failure,
                              all_levels);

  subtype log_level_or_default_t is log_level_config_t range no_level to failure;
  subtype log_level_t is log_level_config_t range verbose to failure;

  type logger_t is record
    p_data : integer_vector_ptr_t;
  end record;

  constant null_logger : logger_t := (p_data => null_ptr);

  impure function new_logger(id : natural;
                             name : string;
                             parent : logger_t) return logger_t;
  impure function get_id(logger : logger_t) return natural;
  impure function get_name(logger : logger_t) return string;
  impure function get_full_name(logger : logger_t) return string;
  impure function get_max_name_length(logger : logger_t) return natural;
  impure function get_parent(logger : logger_t) return logger_t;
  impure function num_children(logger : logger_t) return natural;
  impure function get_child(logger : logger_t; idx : natural) return logger_t;

  -- Stop simulation for all levels >= level
  procedure set_stop_level(logger : logger_t; log_level : log_level_config_t);

  -- Disable stopping simulation
  -- Equivalent with set_stop_level(all_levels)
  procedure disable_stop(logger : logger_t);

  -- Get number of logs to a specific level or all levels when level = no_level
  impure function get_log_count(logger : logger_t; log_level : log_level_or_default_t := no_level) return natural;
  procedure count_log(logger : logger_t; log_level : log_level_t);

  -- To enable unit testing of code performing logging
  procedure mock(logger : logger_t);
  impure function is_mocked(logger : logger_t) return boolean;
  procedure mock_log(logger : logger_t;
                     msg : string;
                     log_level : log_level_t;
                     log_time : time;
                     line_num : natural := 0;
                     file_name : string := "");
  procedure unmock(logger : logger_t);

  constant no_time_check : time := -1 ns;
  impure function get_mock_log_count(logger : logger_t; log_level : log_level_or_default_t := no_level) return natural;
  procedure check_log(logger : logger_t;
                      msg : string;
                      log_level : log_level_t;
                      log_time : time := no_time_check;
                      line_num : natural := 0;
                      file_name : string := "");

  procedure check_only_log(logger : logger_t;
                           msg : string;
                           log_level : log_level_t;
                           log_time : time := no_time_check;
                           line_num : natural := 0;
                           file_name : string := "");

  procedure check_no_log(logger : logger_t);
end package;

package body logger_pkg is

  constant id_idx : natural := 0;
  constant name_idx : natural := 1;
  constant parent_idx : natural := 2;
  constant children_idx : natural := 3;
  constant log_count_idx : natural := 4;
  constant stop_level_idx : natural := 5;
  constant is_mocked_idx : natural := 6;
  constant mock_log_count_idx : natural := 7;
  constant mocked_log_queue_meta_idx : natural := 8;
  constant mocked_log_queue_data_idx : natural := 9;
  constant logger_length : natural := 10;

  impure function to_integer(logger : logger_t) return integer is
  begin
    return to_integer(logger.p_data);
  end;

  impure function new_logger(id : natural; name : string; parent : logger_t) return logger_t is
    variable logger : logger_t := (p_data => allocate(logger_length));
    variable children : integer_vector_ptr_t;
    variable mocked_log_queue : queue_t := allocate;
  begin
    set(logger.p_data, id_idx, id);
    set(logger.p_data, name_idx, to_integer(allocate(name)));
    set(logger.p_data, parent_idx, to_integer(parent));
    set(logger.p_data, children_idx, to_integer(integer_vector_ptr_t'(allocate)));
    set(logger.p_data, log_count_idx, to_integer(allocate(log_level_t'pos(log_level_t'high)+1, value => 0)));
    set(logger.p_data, mock_log_count_idx, to_integer(allocate(log_level_t'pos(log_level_t'high)+1, value => 0)));
    set(logger.p_data, stop_level_idx, log_level_config_t'pos(failure));
    set(logger.p_data, is_mocked_idx, 0);
    set(logger.p_data, mocked_log_queue_meta_idx, to_integer(mocked_log_queue.p_meta));
    set(logger.p_data, mocked_log_queue_data_idx, to_integer(mocked_log_queue.data));

    if parent /= null_logger then
      children := to_integer_vector_ptr(get(parent.p_data, children_idx));
      resize(children, length(children)+1);
      set(children, length(children)-1, to_integer(logger));
    end if;

    return logger;
  end;

  impure function get_full_name(logger : logger_t) return string is
    variable parent : logger_t := get_parent(logger);
  begin
    if parent = null_logger or get_id(parent) = 0 then
      -- Null or root logger
      return get_name(logger);
    else
      return get_full_name(parent) & "." & get_name(logger);
    end if;
  end;

  impure function get_max_name_length(logger : logger_t) return natural is
    variable result : natural := 0;
    variable child_result : natural;
  begin
    if num_children(logger) = 0 then
      return get_full_name(logger)'length;
    end if;

    for i in 0 to num_children(logger)-1 loop
      child_result := get_max_name_length(get_child(logger, i));
      if child_result > result then
        result := child_result;
      end if;
    end loop;

    return result;
  end;

  impure function get_name(logger : logger_t) return string is
  begin
    return to_string(to_string_ptr(get(logger.p_data, name_idx)));
  end;

  impure function get_id(logger : logger_t) return natural is
  begin
    return get(logger.p_data, id_idx);
  end;

  impure function get_parent(logger : logger_t) return logger_t is
  begin
    return (p_data => to_integer_vector_ptr(get(logger.p_data, parent_idx)));
  end;

  impure function is_mocked(logger : logger_t) return boolean is
  begin
    return get(logger.p_data, is_mocked_idx) = 1;
  end;

  impure function num_children(logger : logger_t) return natural is
    constant children : integer_vector_ptr_t := to_integer_vector_ptr(get(logger.p_data, children_idx));
  begin
    return length(children);
  end;

  impure function get_child(logger : logger_t; idx : natural) return logger_t is
    constant children : integer_vector_ptr_t := to_integer_vector_ptr(get(logger.p_data, children_idx));
  begin
    return (p_data => to_integer_vector_ptr(get(children, idx)));
  end;

  -- Stop simulation for all levels >= level
  procedure set_stop_level(logger : logger_t; log_level : log_level_config_t) is
  begin
    set(logger.p_data, stop_level_idx, log_level_config_t'pos(log_level));
    for i in 0 to num_children(logger)-1 loop
      set_stop_level(get_child(logger, i), log_level);
    end loop;
  end;

  -- Disable stopping simulation
  -- Equivalent with set_stop_level(all_levels)
  procedure disable_stop(logger : logger_t) is
  begin
    set_stop_level(logger, all_levels);
  end;

  procedure clear_log_count(logger : logger_t; idx : natural) is
    constant log_counts : integer_vector_ptr_t := to_integer_vector_ptr(get(logger.p_data, idx));
  begin
    for lvl in log_level_t'low to log_level_t'high loop
      set(log_counts, log_level_t'pos(lvl), 0);
    end loop;
  end;

  impure function get_log_count(logger : logger_t;
                                idx : natural;
                                log_level : log_level_or_default_t := no_level) return natural is
    constant log_counts : integer_vector_ptr_t := to_integer_vector_ptr(get(logger.p_data, idx));
    variable result : natural;
  begin
    if log_level = no_level then
      result := 0;
      for lvl in log_level_t'low to log_level_t'high loop
        result := result + get(log_counts, log_level_t'pos(lvl));
      end loop;
    else
      result := get(log_counts, log_level_t'pos(log_level));
    end if;

    return result;
  end;

  impure function get_log_count(logger : logger_t; log_level : log_level_or_default_t := no_level) return natural is
  begin
    return get_log_count(logger, log_count_idx, log_level);
  end;

  procedure count_log(logger : logger_t; idx : natural; log_level : log_level_t) is
    constant log_counts : integer_vector_ptr_t := to_integer_vector_ptr(get(logger.p_data, idx));
  begin
    set(log_counts, log_level_t'pos(log_level), get(log_counts, log_level_t'pos(log_level)) + 1);
  end;

  procedure count_log(logger : logger_t; log_level : log_level_t) is
    constant stop_level : log_level_config_t := log_level_config_t'val(get(logger.p_data, stop_level_idx));
  begin
    count_log(logger, log_count_idx, log_level);
    if log_level >= stop_level then
      core_failure("Log level " & log_level_config_t'image(log_level) &
                   " >= stop level " & log_level_config_t'image(stop_level));
    end if;
  end;

  procedure mock(logger : logger_t) is
  begin
    set(logger.p_data, is_mocked_idx, 1);
  end;

  impure function get_mocked_log_queue(logger : logger_t) return queue_t is
  begin
    return (p_meta => to_integer_vector_ptr(get(logger.p_data, mocked_log_queue_meta_idx)),
            data => to_string_ptr(get(logger.p_data, mocked_log_queue_data_idx)));
  end;

  impure function make_string(msg : string;
                              log_level : log_level_t;
                              log_time : time;
                              line_num : natural;
                              file_name : string;
                              check_time : boolean) return string is
    constant without_time : string := ("   log_level = " & log_level_t'image(log_level) & LF &
                                       "   msg = " & msg & LF &
                                       "   file_name:line_num = " & file_name & ":" & integer'image(line_num));
  begin
    if check_time then
      return "   time = " & time'image(log_time) & LF & without_time;
    else
      return without_time;
    end if;
  end;

  impure function pop_log_item_string(logger : logger_t; check_time : boolean) return string is
    constant queue : queue_t := get_mocked_log_queue(logger);
    constant got_level : log_level_t := log_level_t'val(pop_byte(queue));
    constant got_msg : string := pop_string(queue);
    constant got_log_time : time := pop_time(queue);
    constant got_line_num : natural := pop_integer(queue);
    constant got_file_name : string := pop_string(queue);
  begin
    return make_string(got_msg, got_level, got_log_time, got_line_num, got_file_name, check_time);
  end;

  impure function get_mock_log_count(logger : logger_t; log_level : log_level_or_default_t := no_level) return natural is
  begin
    return get_log_count(logger, mock_log_count_idx, log_level);
  end;

  procedure check_log(logger : logger_t;
                      msg : string;
                      log_level : log_level_t;
                      log_time : time := no_time_check;
                      line_num : natural := 0;
                      file_name : string := "") is

    constant expected_item : string := make_string(msg, log_level, log_time, line_num, file_name,
                                                   log_time /= no_time_check);

    constant queue : queue_t := get_mocked_log_queue(logger);

    procedure check_log_when_not_empty is
      constant got_item : string := pop_log_item_string(logger, log_time /= no_time_check);
    begin
      if expected_item /= got_item then
        core_failure("log item mismatch:" & LF & LF & "Got:" & LF & got_item & LF & LF & "expected:" & LF & expected_item & LF);
      end if;
    end;
  begin
    if length(queue) > 0 then
      check_log_when_not_empty;
    else
      core_failure("log item mismatch - Got no log item " & LF & LF & "expected" & LF & expected_item & LF);
    end if;
  end;

  procedure check_only_log(logger : logger_t;
                           msg : string;
                           log_level : log_level_t;
                           log_time : time := no_time_check;
                           line_num : natural := 0;
                           file_name : string := "") is
  begin
    check_log(logger, msg, log_level, log_time, line_num, file_name);
    check_no_log(logger);
  end;

  procedure check_no_log(logger : logger_t) is
    constant queue : queue_t := get_mocked_log_queue(logger);
    variable fail : boolean := length(queue) > 0;
  begin
    while length(queue) > 0 loop
      report "Got unexpected log item " & LF & LF & pop_log_item_string(logger, true) & LF;
    end loop;

    if fail then
      core_failure("Got unexpected log items");
    end if;
  end;

  procedure unmock(logger : logger_t) is
  begin
    check_no_log(logger);
    set(logger.p_data, is_mocked_idx, 0);
    clear_log_count(logger, mock_log_count_idx);
  end;

  procedure mock_log(logger : logger_t;
                     msg : string;
                     log_level : log_level_t;
                     log_time : time;
                     line_num : natural := 0;
                     file_name : string := "") is
    constant queue : queue_t := get_mocked_log_queue(logger);
  begin
    report ("Got mocked log item to (" & get_full_name(logger) & ")" & LF &
            make_string(msg, log_level, log_time, line_num, file_name, check_time => true)
            & LF);
    count_log(logger, mock_log_count_idx, log_level);

    push_byte(queue, log_level_t'pos(log_level));
    push_string(queue, msg);
    push_time(queue, log_time);
    push_integer(queue, line_num);
    push_string(queue, file_name);
  end;

end package body;
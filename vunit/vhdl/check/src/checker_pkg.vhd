-- This package provides fundamental types used by the check package.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this file,
-- You can obtain one at http://mozilla.org/MPL/2.0/.
--
-- Copyright (c) 2017, Lars Asplund lars.anders.asplund@gmail.com

library ieee;
use ieee.std_logic_1164.all;
use work.logger_pkg.all;
use work.log2_pkg.all;
use work.integer_vector_ptr_pkg.all;

package checker_pkg is
  type edge_t is (rising_edge, falling_edge, both_edges);
  type trigger_event_t is (first_pipe, first_no_pipe, penultimate);

  type checker_stat_t is record
    n_checks : natural;
    n_failed : natural;
    n_passed : natural;
  end record;

  type checker_t is record
    p_data : integer_vector_ptr_t;
  end record;

  impure function new_checker(name              : string;
                              default_log_level : log_level_t := error) return checker_t;

  impure function new_checker(logger            : logger_t;
                              default_log_level : log_level_t := error) return checker_t;

  impure function get_logger(checker : checker_t) return logger_t;
  impure function get_default_log_level(checker : checker_t) return log_level_t;

  impure function get_stat(checker : checker_t) return checker_stat_t;
  procedure reset_stat(checker : checker_t);
  procedure get_stat(checker : checker_t;
                     variable stat : out checker_stat_t);

  -- Legacy aliases
  alias get_checker_stat is get_stat[checker_t return checker_stat_t];
  alias get_checker_stat is get_stat[checker_t, checker_stat_t];
  alias reset_checker_stat is reset_stat[checker_t];

  constant null_checker : checker_t := (p_data => null_ptr);

  impure function is_passing_check_msg_enabled(checker : checker_t) return boolean;

  procedure passing_check(checker : checker_t);

  procedure passing_check(
    checker   : checker_t;
    msg       : string;
    line_num  : natural := 0;
    file_name : string  := "");

  procedure failing_check(
    checker   : checker_t;
    msg       : string;
    level     : log_level_or_default_t := no_level;
    line_num  : natural                := 0;
    file_name : string                 := "");

end package;

package body checker_pkg is

  constant logger_idx            : natural := 0;
  constant default_log_level_idx : natural := 1;
  constant stat_checks_idx       : natural := 2;
  constant stat_failed_idx       : natural := 3;
  constant stat_passed_idx       : natural := 4;
  constant checker_length        : natural := stat_passed_idx + 1;

  impure function new_checker(logger            : logger_t;
                              default_log_level : log_level_t := error) return checker_t is
    variable checker : checker_t;
  begin
    checker := (p_data => allocate(checker_length));
    set(checker.p_data, logger_idx, to_integer(logger.p_data));
    set(checker.p_data, default_log_level_idx, log_level_t'pos(default_log_level));
    reset_stat(checker);
    return checker;
  end;

  impure function new_checker(name              : string;
                              default_log_level : log_level_t := error) return checker_t is
  begin
    return new_checker(new_logger(name), default_log_level);
  end;

  impure function get_logger(checker : checker_t) return logger_t is
  begin
    return (p_data => to_integer_vector_ptr(get(checker.p_data, logger_idx)));
  end;

  impure function get_default_log_level(checker : checker_t) return log_level_t is
  begin
    return log_level_t'val(get(checker.p_data, default_log_level_idx));
  end;

  procedure reset_stat(checker : checker_t) is
  begin
    set(checker.p_data, stat_checks_idx, 0);
    set(checker.p_data, stat_failed_idx, 0);
    set(checker.p_data, stat_passed_idx, 0);
  end;

  impure function get_stat(checker : checker_t) return checker_stat_t is
  begin
    return (n_checks => get(checker.p_data, stat_checks_idx),
            n_failed => get(checker.p_data, stat_failed_idx),
            n_passed => get(checker.p_data, stat_passed_idx));

  end;

  procedure get_stat(checker : checker_t;
                     variable stat : out checker_stat_t) is
  begin
    stat := get_stat(checker);
  end;

  impure function is_passing_check_msg_enabled(checker : checker_t) return boolean is
  begin
    return is_enabled(get_logger(checker), debug);
  end;

  procedure passing_check(checker : checker_t) is
  begin
    set(checker.p_data, stat_checks_idx, get(checker.p_data, stat_checks_idx) + 1);
    set(checker.p_data, stat_passed_idx, get(checker.p_data, stat_passed_idx) + 1);
  end;

  procedure passing_check(
    checker   : checker_t;
    msg       : string;
    line_num  : natural := 0;
    file_name : string  := "") is
    constant logger : logger_t := get_logger(checker);
  begin
    -- pragma translate_off
    passing_check(checker);

    if is_enabled(logger, debug) then
      log(logger, msg, debug, line_num, file_name);
    end if;

  -- pragma translate_on
  end;

  procedure failing_check(
    checker   : checker_t;
    msg       : string;
    level     : log_level_or_default_t := no_level;
    line_num  : natural                := 0;
    file_name : string                 := "") is
  begin
    -- pragma translate_off
    set(checker.p_data, stat_checks_idx, get(checker.p_data, stat_checks_idx) + 1);
    set(checker.p_data, stat_failed_idx, get(checker.p_data, stat_failed_idx) + 1);

    if level = no_level then
      log(get_logger(checker), msg, get_default_log_level(checker), line_num, file_name);
    else
      log(get_logger(checker), msg, level, line_num, file_name);
    end if;
  -- pragma translate_on
  end;

end package body;

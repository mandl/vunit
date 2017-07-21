-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this file,
-- You can obtain one at http://mozilla.org/MPL/2.0/.
--
-- Copyright (c) 2017, Lars Asplund lars.anders.asplund@gmail.com

use std.textio.all;

library vunit_lib;
use vunit_lib.run_pkg.all;
use vunit_lib.run_base_pkg.all;
use vunit_lib.dict_pkg.all;

use work.logger_pkg.all;
use work.log_handler_pkg.all;
use work.log2_pkg.all;

entity tb_log is
  generic (
    runner_cfg : string);
end entity;

architecture a of tb_log is
begin
  main : process

    procedure check_no_log_file(constant file_name : in string) is
      file fptr : text;
      variable status : file_open_status;
    begin
      file_open(status, fptr, file_name, read_mode);
      assert status = name_error report "Expected no such file " & file_name severity failure;
      file_close(fptr);
    end;

    impure function msg_suffix(msg : string) return string is
    begin
      if msg = "" then
        return "";
      else
        return " - " & msg;
      end if;
    end;

    -- @TODO move to assert_pkg as a bootstraping test package when not using check
    procedure assert_true(value : boolean; msg : string := "") is
    begin
      assert value report "assert_true failed" & msg_suffix(msg) severity failure;
    end;

    procedure assert_false(value : boolean; msg : string := "") is
    begin
      assert not value report "assert_false failed" & msg_suffix(msg) severity failure;
    end;

    procedure assert_equal(got, expected, msg : string := "") is
    begin
      assert got = expected report "Got " & got & " expected " & expected & msg_suffix(msg) severity failure;
    end;

    procedure check_log_file (
      constant file_name : in string;
      constant entries   : in dict_t) is
      file fptr : text;
      variable l : line;
      variable status : file_open_status;
    begin
      file_open(status, fptr, file_name, read_mode);
      assert status = open_ok
        report "Failed opening " & file_name & " (" & file_open_status'image(status) & ")."
        severity failure;

      if status = open_ok then
        for i in 0 to num_keys(entries)-1 loop
          readline(fptr, l);
          assert l.all = get(entries, integer'image(i))
            report "(" & integer'image(i) & ") Got " & l.all & " expected " & get(entries, integer'image(i))
            severity failure;
        end loop;
      end if;
    end;

    constant log_file_name : string := output_path(runner_cfg) & "my_log.csv";
    variable logger : logger_t := new_logger("logger");
    variable nested_logger : logger_t := new_logger("nested", parent => logger);
    variable other_logger : logger_t := new_logger("other");
    variable tmp_logger : logger_t;
    variable entries : dict_t := new_dict;

    procedure perform_logging(logger : logger_t) is
    begin
      debug(logger, "message 1");
      wait for 1 ns;
      verbose(logger, "message 2");
      wait for 1 ns;
      info(logger, "message 3");
      wait for 1 ns;
      warning(logger, "message 4");
      wait for 1 ns;
      error(logger, "message 5");
      wait for 1 ns;
      failure(logger, "message 6");
      wait for 1 ns;
    end procedure;

    constant max_time_length : natural := time'image(1 sec)'length;
    impure function format_time(t : time) return string is
      constant time_str : string := time'image(t);
    begin
      return (1 to (max_time_length - time_str'length) => ' ') & time_str;
    end function;
  begin

    test_runner_setup(runner, runner_cfg);

    if run("raw format") then
      init_display_handler(format => raw);
      init_file_handler(file_name => log_file_name, format => raw);
      disable_stop;
      perform_logging(logger);
      set(entries, "0", "message 1");
      set(entries, "1", "message 2");
      set(entries, "2", "message 3");
      set(entries, "3", "message 4");
      set(entries, "4", "message 5");
      set(entries, "5", "message 6");
      check_log_file(log_file_name, entries);

    elsif run("level format") then
      init_display_handler(format => level);
      init_file_handler(file_name => log_file_name, format => level);
      disable_stop;
      perform_logging(logger);
      set(entries, "0", "  DEBUG - message 1");
      set(entries, "1", "VERBOSE - message 2");
      set(entries, "2", "   INFO - message 3");
      set(entries, "3", "WARNING - message 4");
      set(entries, "4", "  ERROR - message 5");
      set(entries, "5", "FAILURE - message 6");
      check_log_file(log_file_name, entries);

    elsif run("csv format") then
      init_display_handler(format => csv);
      init_file_handler(file_name => log_file_name, format => csv);
      disable_stop;
      perform_logging(logger);
      set(entries, "0", time'image(0 ns) & ",logger,DEBUG,message 1");
      set(entries, "1", time'image(1 ns) & ",logger,VERBOSE,message 2");
      set(entries, "2", time'image(2 ns) & ",logger,INFO,message 3");
      set(entries, "3", time'image(3 ns) & ",logger,WARNING,message 4");
      set(entries, "4", time'image(4 ns) & ",logger,ERROR,message 5");
      set(entries, "5", time'image(5 ns) & ",logger,FAILURE,message 6");
      check_log_file(log_file_name, entries);

    elsif run("verbose format") then
      init_display_handler(format => verbose);
      init_file_handler(file_name => log_file_name, format => verbose);
      disable_stop;
      perform_logging(logger);
      set(entries, "0", format_time(0 ns) & " - logger        -   DEBUG - message 1");
      set(entries, "1", format_time(1 ns) & " - logger        - VERBOSE - message 2");
      set(entries, "2", format_time(2 ns) & " - logger        -    INFO - message 3");
      set(entries, "3", format_time(3 ns) & " - logger        - WARNING - message 4");
      set(entries, "4", format_time(4 ns) & " - logger        -   ERROR - message 5");
      set(entries, "5", format_time(5 ns) & " - logger        - FAILURE - message 6");
      check_log_file(log_file_name, entries);

    elsif run("hierarchical format") then
      init_display_handler(format => verbose);
      init_file_handler(file_name => log_file_name, format => verbose);
      disable_stop;
      perform_logging(nested_logger);
      set(entries, "0", format_time(0 ns) & " - logger.nested -   DEBUG - message 1");
      set(entries, "1", format_time(1 ns) & " - logger.nested - VERBOSE - message 2");
      set(entries, "2", format_time(2 ns) & " - logger.nested -    INFO - message 3");
      set(entries, "3", format_time(3 ns) & " - logger.nested - WARNING - message 4");
      set(entries, "4", format_time(4 ns) & " - logger.nested -   ERROR - message 5");
      set(entries, "5", format_time(5 ns) & " - logger.nested - FAILURE - message 6");
      check_log_file(log_file_name, entries);

    elsif run("can log to default logger") then
      init_file_handler(file_name => log_file_name, format => csv);

      disable_stop;
      debug("message 1");
      wait for 1 ns;
      verbose("message 2");
      wait for 1 ns;
      info("message 3");
      wait for 1 ns;
      warning("message 4");
      wait for 1 ns;
      error("message 5");
      wait for 1 ns;
      failure("message 6");

      set(entries, "0", time'image(0 ns) & ",default,DEBUG,message 1");
      set(entries, "1", time'image(1 ns) & ",default,VERBOSE,message 2");
      set(entries, "2", time'image(2 ns) & ",default,INFO,message 3");
      set(entries, "3", time'image(3 ns) & ",default,WARNING,message 4");
      set(entries, "4", time'image(4 ns) & ",default,ERROR,message 5");
      set(entries, "5", time'image(5 ns) & ",default,FAILURE,message 6");
      check_log_file(log_file_name, entries);

    elsif run("can enable and disable handler") then
      init_file_handler(file_name => log_file_name, format => csv);
      disable_stop;

      disable_all(file_handler);
      for log_level in log_level_t'low to log_level_t'high loop
        assert_false(is_enabled(file_handler, default_logger, log_level));
        assert_false(is_enabled(file_handler, logger, log_level));
        assert_false(is_enabled(file_handler, nested_logger, log_level));
      end loop;

      perform_logging(logger);
      check_no_log_file(log_file_name);

      enable_all(file_handler);
      for log_level in log_level_t'low to log_level_t'high loop
        assert_true(is_enabled(file_handler, default_logger, log_level));
        assert_true(is_enabled(file_handler, logger, log_level));
        assert_true(is_enabled(file_handler, nested_logger, log_level));
      end loop;

      perform_logging(logger);
      set(entries, "0", time'image(6 ns) & ",logger,DEBUG,message 1");
      set(entries, "1", time'image(7 ns) & ",logger,VERBOSE,message 2");
      set(entries, "2", time'image(8 ns) & ",logger,INFO,message 3");
      set(entries, "3", time'image(9 ns) & ",logger,WARNING,message 4");
      set(entries, "4", time'image(10 ns) & ",logger,ERROR,message 5");
      set(entries, "5", time'image(11 ns) & ",logger,FAILURE,message 6");
      check_log_file(log_file_name, entries);

    elsif run("can set log level") then
      init_file_handler(file_name => log_file_name, format => csv);
      set_log_level(file_handler, warning);
      disable_stop;
      perform_logging(logger);
      set(entries, "0", time'image(3 ns) & ",logger,WARNING,message 4");
      set(entries, "1", time'image(4 ns) & ",logger,ERROR,message 5");
      set(entries, "2", time'image(5 ns) & ",logger,FAILURE,message 6");
      check_log_file(log_file_name, entries);

    elsif run("can enable and disable source") then
      init_file_handler(file_name => log_file_name, format => csv);
      disable_all(file_handler, logger);

      for log_level in log_level_t'low to log_level_t'high loop
        assert_true(is_enabled(file_handler, default_logger, log_level));
        assert_false(is_enabled(file_handler, logger, log_level));
        assert_false(is_enabled(file_handler, nested_logger, log_level));
      end loop;

      info(logger, "message");
      info(nested_logger, "message");
      info("message");
      set(entries, "0", time'image(0 ns) & ",default,INFO,message");
      check_log_file(log_file_name, entries);

      init_file_handler(file_name => log_file_name, format => csv);
      enable_all(file_handler, logger);
      for log_level in log_level_t'low to log_level_t'high loop
        assert_true(is_enabled(file_handler, default_logger, log_level));
        assert_true(is_enabled(file_handler, logger, log_level));
        assert_true(is_enabled(file_handler, nested_logger, log_level));
      end loop;

      info(logger, "message");
      info(nested_logger, "message");
      info("message");
      set(entries, "0", time'image(0 ns) & ",logger,INFO,message");
      set(entries, "1", time'image(0 ns) & ",logger.nested,INFO,message");
      set(entries, "2", time'image(0 ns) & ",default,INFO,message");
      check_log_file(log_file_name, entries);

    elsif run("mock and unmock") then
      mock(logger);
      unmock(logger);

    elsif run("mock check_only_log") then
      mock(logger);
      warning(logger, "message");
      check_only_log(logger, "message", warning, 0 ns);
      unmock(logger);

    elsif run("mocked logger does not stop simulation") then
      mock(logger);
      failure(logger, "message");
      check_only_log(logger, "message", failure, 0 ns);
      unmock(logger);

    elsif run("mocked logger is always enabled") then
      assert_true(is_enabled(logger, failure));

      disable_all(display_handler, logger);
      disable_all(file_handler, logger);
      assert_false(is_enabled(logger, failure));

      mock(logger);
      assert_true(is_enabled(logger, failure));

      unmock(logger);
      assert_false(is_enabled(logger, failure));

    elsif run("mock check_log") then
      mock(logger);
      warning(logger, "message");
      wait for 1 ns;
      info(logger, "another message");
      check_log(logger, "message", warning, 0 ns);
      check_log(logger, "another message", info, 1 ns);
      unmock(logger);

    elsif run("Expected to fail: unmock with unchecked log") then
      mock(logger);
      warning(logger, "message");
      unmock(logger);

    elsif run("Expected to fail: check_only_log when no log") then
      mock(logger);
      check_only_log(logger, "message", warning, 0 ns);
      unmock(logger);

    elsif run("Expected to fail: check_log when wrong level") then
      mock(logger);
      debug(logger, "message");
      check_log(logger, "message", warning, 0 ns);
      unmock(logger);

    elsif run("Expected to fail: check_log when wrong message") then
      mock(logger);
      warning(logger, "another message");
      check_log(logger, "message", warning, 0 ns);
      unmock(logger);

    elsif run("Expected to fail: check_log when wrong time") then
      mock(logger);
      wait for 1 ns;
      warning(logger, "message");
      check_log(logger, "message", warning, 0 ns);
      unmock(logger);

    elsif run("log below stop level") then
      set_stop_level(warning);
      info(logger, "message");

    elsif run("Expected to fail: log above stop level") then
      set_stop_level(warning);
      warning(logger, "message");

    elsif run("Get logger") then
      tmp_logger := get_logger("logger.child");
      assert_true(tmp_logger = null_logger, "null");

      tmp_logger := get_logger("default");
      assert_true(tmp_logger = default_logger);
      assert_false(tmp_logger = null_logger, "not null");

      tmp_logger := get_logger("logger.nested");
      assert_true(tmp_logger = nested_logger);
      assert_false(tmp_logger = null_logger, "not null");

      tmp_logger := get_logger("nested", parent => logger);
      assert_true(tmp_logger = nested_logger);
      assert_false(tmp_logger = null_logger, "not null");

    elsif run("Create hierarchical logger") then
      tmp_logger := new_logger("logger.child");
      assert_false(tmp_logger = null_logger, "logger not null");
      assert_equal(get_name(tmp_logger), "child", "nested logger name");
      assert_true(get_parent(tmp_logger) = logger, "parent logger");
    end if;

    test_runner_cleanup(runner);
  end process;
end architecture;

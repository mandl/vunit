-- This test suite verifies basic check functionality.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this file,
-- You can obtain one at http://mozilla.org/MPL/2.0/.
--
-- Copyright (c) 2014-2016, Lars Asplund lars.anders.asplund@gmail.com

library vunit_lib;
use vunit_lib.string_ops.all;
use vunit_lib.logger_pkg.all;
use vunit_lib.checker_pkg.all;
use vunit_lib.check_pkg.all;
use vunit_lib.run_types_pkg.all;
use vunit_lib.run_pkg.all;
use work.test_support.all;
use std.textio.all;

use vunit_lib.logger_pkg.all;

entity tb_basic_check_functionality is
  generic (
    runner_cfg : string := "";
    output_path : string);
end entity tb_basic_check_functionality;

architecture test_fixture of tb_basic_check_functionality is
begin
  test_runner : process
    constant punctuation_marks_not_preceeded_by_space_c : string := ".,:;?!";

    variable my_checker : checker_t := new_checker("my_checker");
    variable my_logger : logger_t := get_logger(my_checker);
    variable stat, stat1, stat2 : checker_stat_t;
    variable stat_before, stat_after : checker_stat_t;
  begin
    test_runner_setup(runner, runner_cfg);

    while test_suite loop
      if run("Verify default checker basic functionality") then
        stat_before := get_checker_stat;
        mock(check_logger);

        passing_check(default_checker, "Check true");
        check_only_log(check_logger, "Check true", debug);

        failing_check(default_checker, "Custom error message");
        check_only_log(check_logger, "Custom error message", error);

        failing_check(default_checker, "Custom level", info);
        check_only_log(check_logger, "Custom level", info);

        failing_check(default_checker, "Line and file name", info, 377, "some_file.vhd");
        check_only_log(check_logger, "Line and file name", info,
                       line_num => 377, file_name => "some_file.vhd");
        unmock(check_logger);

        stat_after := get_checker_stat;
        counting_assert(stat_after = stat_before + (4, 3, 1), "Expected 4 checks, 3 fail, and 1 pass but got " & to_string(stat_after - stat_before));

      elsif run("Verify custom checker basic functionality") then
        get_checker_stat(my_checker, stat_before);

        mock(my_logger);
        passing_check(my_checker, "Check true");
        check_only_log(my_logger, "Check true", debug);

        failing_check(my_checker, "Custom error message");
        check_only_log(my_logger, "Custom error message", error);

        failing_check(my_checker, "Custom level", info);
        check_only_log(my_logger, "Custom level", info);

        failing_check(my_checker, "Line and file name", info, 377, "some_file.vhd");
        check_only_log(my_logger, "Line and file name", info,
                       line_num => 377, file_name => "some_file.vhd");
        unmock(my_logger);

        get_checker_stat(my_checker, stat_after);
        counting_assert(stat_after = stat_before + (4, 3, 1), "Expected 4 checks, 3 fail, and 1 pass but got " & to_string(stat_after - stat_before));

      elsif run("Verify checker_stat_t functions and operators") then
        counting_assert(stat1 = (0, 0, 0), "Expected initial stat value = (0, 0, 0)");
        stat1 := (20, 13, 7);
        stat2 := (11, 3, 8);
        counting_assert(stat1 + stat2 = (31, 16, 15), "Expected sum = (31, 16, 15)");
        counting_assert(to_string(stat1) = "Checks: 20" & LF &
                        "Passed:  7" & LF &
                        "Failed: 13",
                        "Format error of checker_stat_t. Got:" & to_string(stat1));

      elsif run("Test that result returns result tag by default") then
        counting_assert(result = check_result_tag_c);

      elsif run("Test that result returns result tag on empty message") then
        counting_assert(result("") = check_result_tag_c);

      elsif run("Test that result returns result tag + message if the message starts with a punctuation mark") then
        for i in punctuation_marks_not_preceeded_by_space_c'range loop
          counting_assert(result(punctuation_marks_not_preceeded_by_space_c(i) & "Foo") =
                          check_result_tag_c & punctuation_marks_not_preceeded_by_space_c(i) & "Foo");
        end loop;

      elsif run("Test that result returns result tag + space + message if the message doesn't start with a punctuation mark") then
        for c in character'left to character'right loop
          if find(punctuation_marks_not_preceeded_by_space_c, c) = 0 then
            counting_assert(result(c & "Foo") =
                            check_result_tag_c & " " & c & "Foo");
          end if;
        end loop;
      end if;
    end loop;

    get_and_print_test_result(stat);
    test_runner_cleanup(runner, stat);
    wait;
  end process;

  test_runner_watchdog(runner, 2 us);

end test_fixture;

-- vunit_pragma run_all_in_same_sim

-- This test suite verifies the check_equal checker.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this file,
-- You can obtain one at http://mozilla.org/MPL/2.0/.
--
-- Copyright (c) 2014-2016, Lars Asplund lars.anders.asplund@gmail.com

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library vunit_lib;
use vunit_lib.checker_pkg.all;
use vunit_lib.check_pkg.all;
use vunit_lib.run_types_pkg.all;
use vunit_lib.run_pkg.all;
use work.test_support.all;
use work.test_count.all;

use vunit_lib.logger_pkg.all;

entity tb_check_equal is
  generic (
    runner_cfg : string);
end entity tb_check_equal;

architecture test_fixture of tb_check_equal is
begin
  check_equal_runner : process
    variable stat : checker_stat_t;
    variable my_checker : checker_t := new_checker("my_checker");
    variable my_logger : logger_t := get_logger(my_checker);
    variable pass : boolean;
    constant pass_level : log_level_t := debug;
    constant default_level : log_level_t := error;

  begin
    test_runner_setup(runner, runner_cfg);

    while test_suite loop
      if run("Test should handle comparison of vectors longer than 32 bits") then
        get_checker_stat(stat);
        check_equal(unsigned'(X"A5A5A5A5A"), unsigned'(X"A5A5A5A5A"));
        check_equal(std_logic_vector'(X"A5A5A5A5A"), unsigned'(X"A5A5A5A5A"));
        check_equal(unsigned'(X"A5A5A5A5A"), std_logic_vector'(X"A5A5A5A5A"));
        check_equal(std_logic_vector'(X"A5A5A5A5A"), std_logic_vector'(X"A5A5A5A5A"));
        verify_passed_checks(stat, 4);

        mock(check_logger);
        check_equal(unsigned'(X"A5A5A5A5A"), unsigned'(X"B5A5A5A5A"));
        check_only_log(check_logger, "Equality check failed - Got 1010_0101_1010_0101_1010_0101_1010_0101_1010 (44465543770). Expected 1011_0101_1010_0101_1010_0101_1010_0101_1010 (48760511066).", default_level);

        check_equal(std_logic_vector'(X"A5A5A5A5A"), unsigned'(X"B5A5A5A5A"));
        check_only_log(check_logger, "Equality check failed - Got 1010_0101_1010_0101_1010_0101_1010_0101_1010 (44465543770). Expected 1011_0101_1010_0101_1010_0101_1010_0101_1010 (48760511066).", default_level);

        check_equal(unsigned'(X"A5A5A5A5A"), std_logic_vector'(X"B5A5A5A5A"));
        check_only_log(check_logger, "Equality check failed - Got 1010_0101_1010_0101_1010_0101_1010_0101_1010 (44465543770). Expected 1011_0101_1010_0101_1010_0101_1010_0101_1010 (48760511066).", default_level);

        check_equal(std_logic_vector'(X"A5A5A5A5A"), std_logic_vector'(X"B5A5A5A5A"));
        check_only_log(check_logger, "Equality check failed - Got 1010_0101_1010_0101_1010_0101_1010_0101_1010 (44465543770). Expected 1011_0101_1010_0101_1010_0101_1010_0101_1010 (48760511066).", default_level);
        unmock(check_logger);

      elsif run("Test print full integer vector when fail on comparison with to short vector") then

        mock(check_logger);
        check_equal(unsigned'(X"A5"), natural'(256));
        check_only_log(check_logger, "Equality check failed - Got 1010_0101 (165). Expected 256 (1_0000_0000).", default_level);

        check_equal(natural'(256), unsigned'(X"A5"));
        check_only_log(check_logger, "Equality check failed - Got 256 (1_0000_0000). Expected 1010_0101 (165).", default_level);

        check_equal(unsigned'(X"A5"), natural'(2147483647));
        check_only_log(check_logger, "Equality check failed - Got 1010_0101 (165). Expected 2147483647 (111_1111_1111_1111_1111_1111_1111_1111).", default_level);

        check_equal(signed'(X"A5"), integer'(-256));
        check_only_log(check_logger, "Equality check failed - Got 1010_0101 (-91). Expected -256 (1_0000_0000).", default_level);

        check_equal(integer'(-256), signed'(X"A5"));
        check_only_log(check_logger, "Equality check failed - Got -256 (1_0000_0000). Expected 1010_0101 (-91).", default_level);

        check_equal(signed'(X"05"), integer'(256));
        check_only_log(check_logger, "Equality check failed - Got 0000_0101 (5). Expected 256 (01_0000_0000).", default_level);

        check_equal(signed'(X"A5"), integer'(-2147483648));
        check_only_log(check_logger, "Equality check failed - Got 1010_0101 (-91). Expected -2147483648 (1000_0000_0000_0000_0000_0000_0000_0000).", default_level);
        unmock(check_logger);

      elsif run("Test should pass on unsigned equal unsigned") then
        get_checker_stat(stat);
        check_equal(unsigned'(X"A5"), unsigned'(X"A5"));
        check_equal(pass, unsigned'(X"A5"), unsigned'(X"A5"));
        counting_assert(pass, "Should return pass = true on passing check");
        pass := check_equal(unsigned'(X"A5"), unsigned'(X"A5"));
        counting_assert(pass, "Should return pass = true on passing check");
        check_equal(to_unsigned(natural'left,31), to_unsigned(natural'left,31));
        check_equal(to_unsigned(natural'right,31), to_unsigned(natural'right,31));
        verify_passed_checks(stat, 5);

        get_checker_stat(my_checker, stat);
        check_equal(my_checker, unsigned'(X"A5"), unsigned'(X"A5"));
        check_equal(my_checker, pass, unsigned'(X"A5"), unsigned'(X"A5"));
        counting_assert(pass, "Should return pass = true on passing check");
        verify_passed_checks(my_checker, stat, 2);

      elsif run("Test pass message on unsigned equal unsigned") then
        mock(check_logger);
        check_equal(unsigned'(X"A5"), unsigned'(X"A5"));
        check_only_log(check_logger, "Equality check passed - Got 1010_0101 (165).", pass_level);

        check_equal(unsigned'(X"A5"), unsigned'(X"A5"), "");
        check_only_log(check_logger, "Got 1010_0101 (165).", pass_level);

        check_equal(unsigned'(X"A5"), unsigned'(X"A5"), "Checking my data");
        check_only_log(check_logger, "Checking my data - Got 1010_0101 (165).", pass_level);

        check_equal(unsigned'(X"A5"), unsigned'(X"A5"), result("for my data"));
        check_only_log(check_logger, "Equality check passed for my data - Got 1010_0101 (165).", pass_level);
        unmock(check_logger);

      elsif run("Test should fail on unsigned not equal unsigned") then
        mock(check_logger);
        check_equal(unsigned'(X"A5"), unsigned'(X"5A"));
        check_only_log(check_logger, "Equality check failed - Got 1010_0101 (165). Expected 0101_1010 (90).", default_level);

        check_equal(unsigned'(X"A5"), unsigned'(X"5A"), "");
        check_only_log(check_logger, "Got 1010_0101 (165). Expected 0101_1010 (90).", default_level);

        check_equal(unsigned'(X"A5"), unsigned'(X"5A"), "Checking my data");
        check_only_log(check_logger, "Checking my data - Got 1010_0101 (165). Expected 0101_1010 (90).", default_level);

        check_equal(unsigned'(X"A5"), unsigned'(X"5A"), result("for my data"));
        check_only_log(check_logger, "Equality check failed for my data - Got 1010_0101 (165). Expected 0101_1010 (90).", default_level);

        check_equal(pass, unsigned'(X"A5"), unsigned'(X"5A"));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(check_logger, "Equality check failed - Got 1010_0101 (165). Expected 0101_1010 (90).", default_level);

        pass := check_equal(unsigned'(X"A5"), unsigned'(X"5A"));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(check_logger, "Equality check failed - Got 1010_0101 (165). Expected 0101_1010 (90).", default_level);
        unmock(check_logger);

        mock(my_logger);
        check_equal(my_checker, unsigned'(X"A5"), unsigned'(X"5A"));
        check_only_log(my_logger, "Equality check failed - Got 1010_0101 (165). Expected 0101_1010 (90).", default_level);

        check_equal(my_checker, pass, unsigned'(X"A5"), unsigned'(X"5A"));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(my_logger, "Equality check failed - Got 1010_0101 (165). Expected 0101_1010 (90).", default_level);
        unmock(my_logger);

      elsif run("Test should pass on unsigned equal natural") then
        get_checker_stat(stat);
        check_equal(unsigned'(X"A5"), natural'(165));
        check_equal(pass, unsigned'(X"A5"), natural'(165));
        counting_assert(pass, "Should return pass = true on passing check");
        pass := check_equal(unsigned'(X"A5"), natural'(165));
        counting_assert(pass, "Should return pass = true on passing check");
        check_equal(to_unsigned(natural'left,31), natural'left);
        check_equal(to_unsigned(natural'right,31), natural'right);
        verify_passed_checks(stat, 5);

        get_checker_stat(my_checker, stat);
        check_equal(my_checker, unsigned'(X"A5"), natural'(165));
        check_equal(my_checker, pass, unsigned'(X"A5"), natural'(165));
        counting_assert(pass, "Should return pass = true on passing check");
        verify_passed_checks(my_checker,stat, 2);

      elsif run("Test pass message on unsigned equal natural") then
        mock(check_logger);
        check_equal(unsigned'(X"A5"), natural'(165));
        check_only_log(check_logger, "Equality check passed - Got 1010_0101 (165).", pass_level);

        check_equal(unsigned'(X"A5"), natural'(165), "");
        check_only_log(check_logger, "Got 1010_0101 (165).", pass_level);

        check_equal(unsigned'(X"A5"), natural'(165), "Checking my data");
        check_only_log(check_logger, "Checking my data - Got 1010_0101 (165).", pass_level);

        check_equal(unsigned'(X"A5"), natural'(165), result("for my data"));
        check_only_log(check_logger, "Equality check passed for my data - Got 1010_0101 (165).", pass_level);
        unmock(check_logger);

      elsif run("Test should fail on unsigned not equal natural") then
        mock(check_logger);
        check_equal(unsigned'(X"A5"), natural'(90));
        check_only_log(check_logger, "Equality check failed - Got 1010_0101 (165). Expected 90 (0101_1010).", default_level);

        check_equal(unsigned'(X"A5"), natural'(90), "");
        check_only_log(check_logger, "Got 1010_0101 (165). Expected 90 (0101_1010).", default_level);

        check_equal(unsigned'(X"A5"), natural'(90), "Checking my data");
        check_only_log(check_logger, "Checking my data - Got 1010_0101 (165). Expected 90 (0101_1010).", default_level);

        check_equal(unsigned'(X"A5"), natural'(90), result("for my data"));
        check_only_log(check_logger, "Equality check failed for my data - Got 1010_0101 (165). Expected 90 (0101_1010).", default_level);

        check_equal(pass, unsigned'(X"A5"), natural'(90));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(check_logger, "Equality check failed - Got 1010_0101 (165). Expected 90 (0101_1010).", default_level);

        pass := check_equal(unsigned'(X"A5"), natural'(90));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(check_logger, "Equality check failed - Got 1010_0101 (165). Expected 90 (0101_1010).", default_level);
        unmock(check_logger);

        mock(my_logger);
        check_equal(my_checker, unsigned'(X"A5"), natural'(90));
        check_only_log(my_logger, "Equality check failed - Got 1010_0101 (165). Expected 90 (0101_1010).", default_level);

        check_equal(my_checker, pass, unsigned'(X"A5"), natural'(90));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(my_logger, "Equality check failed - Got 1010_0101 (165). Expected 90 (0101_1010).", default_level);
        unmock(my_logger);

      elsif run("Test should pass on natural equal unsigned") then
        get_checker_stat(stat);
        check_equal(natural'(165), unsigned'(X"A5"));
        check_equal(pass, natural'(165), unsigned'(X"A5"));
        counting_assert(pass, "Should return pass = true on passing check");
        pass := check_equal(natural'(165), unsigned'(X"A5"));
        counting_assert(pass, "Should return pass = true on passing check");
        check_equal(natural'left, to_unsigned(natural'left,31));
        check_equal(natural'right, to_unsigned(natural'right,31));
        verify_passed_checks(stat, 5);

        get_checker_stat(my_checker, stat);
        check_equal(my_checker, natural'(165), unsigned'(X"A5"));
        check_equal(my_checker, pass, natural'(165), unsigned'(X"A5"));
        counting_assert(pass, "Should return pass = true on passing check");
        verify_passed_checks(my_checker,stat, 2);

      elsif run("Test pass message on natural equal unsigned") then
        mock(check_logger);
        check_equal(natural'(165), unsigned'(X"A5"));
        check_only_log(check_logger, "Equality check passed - Got 165 (1010_0101).", pass_level);

        check_equal(natural'(165), unsigned'(X"A5"), "");
        check_only_log(check_logger, "Got 165 (1010_0101).", pass_level);

        check_equal(natural'(165), unsigned'(X"A5"), "Checking my data");
        check_only_log(check_logger, "Checking my data - Got 165 (1010_0101).", pass_level);

        check_equal(natural'(165), unsigned'(X"A5"), result("for my data"));
        check_only_log(check_logger, "Equality check passed for my data - Got 165 (1010_0101).", pass_level);
        unmock(check_logger);

      elsif run("Test should fail on natural not equal unsigned") then
        mock(check_logger);
        check_equal(natural'(165), unsigned'(X"5A"));
        check_only_log(check_logger, "Equality check failed - Got 165 (1010_0101). Expected 0101_1010 (90).", default_level);

        check_equal(natural'(165), unsigned'(X"5A"), "");
        check_only_log(check_logger, "Got 165 (1010_0101). Expected 0101_1010 (90).", default_level);

        check_equal(natural'(165), unsigned'(X"5A"), "Checking my data");
        check_only_log(check_logger, "Checking my data - Got 165 (1010_0101). Expected 0101_1010 (90).", default_level);

        check_equal(natural'(165), unsigned'(X"5A"), result("for my data"));
        check_only_log(check_logger, "Equality check failed for my data - Got 165 (1010_0101). Expected 0101_1010 (90).", default_level);

        check_equal(pass, natural'(165), unsigned'(X"5A"));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(check_logger, "Equality check failed - Got 165 (1010_0101). Expected 0101_1010 (90).", default_level);

        pass := check_equal(natural'(165), unsigned'(X"5A"));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(check_logger, "Equality check failed - Got 165 (1010_0101). Expected 0101_1010 (90).", default_level);
        unmock(check_logger);

        mock(my_logger);
        check_equal(my_checker, natural'(165), unsigned'(X"5A"));
        check_only_log(my_logger, "Equality check failed - Got 165 (1010_0101). Expected 0101_1010 (90).", default_level);

        check_equal(my_checker, pass, natural'(165), unsigned'(X"5A"));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(my_logger, "Equality check failed - Got 165 (1010_0101). Expected 0101_1010 (90).", default_level);
        unmock(my_logger);

      elsif run("Test should pass on unsigned equal std_logic_vector") then
        get_checker_stat(stat);
        check_equal(unsigned'(X"A5"), std_logic_vector'(X"A5"));
        check_equal(pass, unsigned'(X"A5"), std_logic_vector'(X"A5"));
        counting_assert(pass, "Should return pass = true on passing check");
        pass := check_equal(unsigned'(X"A5"), std_logic_vector'(X"A5"));
        counting_assert(pass, "Should return pass = true on passing check");
        check_equal(to_unsigned(natural'left,31), std_logic_vector(to_unsigned(natural'left,31)));
        check_equal(to_unsigned(natural'right,31), std_logic_vector(to_unsigned(natural'right,31)));
        verify_passed_checks(stat, 5);

        get_checker_stat(my_checker, stat);
        check_equal(my_checker, unsigned'(X"A5"), std_logic_vector'(X"A5"));
        check_equal(my_checker, pass, unsigned'(X"A5"), std_logic_vector'(X"A5"));
        counting_assert(pass, "Should return pass = true on passing check");
        verify_passed_checks(my_checker,stat, 2);

      elsif run("Test pass message on unsigned equal std_logic_vector") then
        mock(check_logger);
        check_equal(unsigned'(X"A5"), std_logic_vector'(X"A5"));
        check_only_log(check_logger, "Equality check passed - Got 1010_0101 (165).", pass_level);

        check_equal(unsigned'(X"A5"), std_logic_vector'(X"A5"), "");
        check_only_log(check_logger, "Got 1010_0101 (165).", pass_level);

        check_equal(unsigned'(X"A5"), std_logic_vector'(X"A5"), "Checking my data");
        check_only_log(check_logger, "Checking my data - Got 1010_0101 (165).", pass_level);

        check_equal(unsigned'(X"A5"), std_logic_vector'(X"A5"), result("for my data"));
        check_only_log(check_logger, "Equality check passed for my data - Got 1010_0101 (165).", pass_level);
        unmock(check_logger);

      elsif run("Test should fail on unsigned not equal std_logic_vector") then
        mock(check_logger);
        check_equal(unsigned'(X"A5"), std_logic_vector'(X"5A"));
        check_only_log(check_logger, "Equality check failed - Got 1010_0101 (165). Expected 0101_1010 (90).", default_level);

        check_equal(unsigned'(X"A5"), std_logic_vector'(X"5A"), "");
        check_only_log(check_logger, "Got 1010_0101 (165). Expected 0101_1010 (90).", default_level);

        check_equal(unsigned'(X"A5"), std_logic_vector'(X"5A"), "Checking my data");
        check_only_log(check_logger, "Checking my data - Got 1010_0101 (165). Expected 0101_1010 (90).", default_level);

        check_equal(unsigned'(X"A5"), std_logic_vector'(X"5A"), result("for my data"));
        check_only_log(check_logger, "Equality check failed for my data - Got 1010_0101 (165). Expected 0101_1010 (90).", default_level);

        check_equal(pass, unsigned'(X"A5"), std_logic_vector'(X"5A"));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(check_logger, "Equality check failed - Got 1010_0101 (165). Expected 0101_1010 (90).", default_level);

        pass := check_equal(unsigned'(X"A5"), std_logic_vector'(X"5A"));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(check_logger, "Equality check failed - Got 1010_0101 (165). Expected 0101_1010 (90).", default_level);
        unmock(check_logger);

        mock(my_logger);
        check_equal(my_checker, unsigned'(X"A5"), std_logic_vector'(X"5A"));
        check_only_log(my_logger, "Equality check failed - Got 1010_0101 (165). Expected 0101_1010 (90).", default_level);

        check_equal(my_checker, pass, unsigned'(X"A5"), std_logic_vector'(X"5A"));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(my_logger, "Equality check failed - Got 1010_0101 (165). Expected 0101_1010 (90).", default_level);
        unmock(my_logger);

      elsif run("Test should pass on std_logic_vector equal unsigned") then
        get_checker_stat(stat);
        check_equal(std_logic_vector'(X"A5"), unsigned'(X"A5"));
        check_equal(pass, std_logic_vector'(X"A5"), unsigned'(X"A5"));
        counting_assert(pass, "Should return pass = true on passing check");
        pass := check_equal(std_logic_vector'(X"A5"), unsigned'(X"A5"));
        counting_assert(pass, "Should return pass = true on passing check");
        check_equal(std_logic_vector(to_unsigned(natural'left,31)), to_unsigned(natural'left,31));
        check_equal(std_logic_vector(to_unsigned(natural'right,31)), to_unsigned(natural'right,31));
        verify_passed_checks(stat, 5);

        get_checker_stat(my_checker, stat);
        check_equal(my_checker, std_logic_vector'(X"A5"), unsigned'(X"A5"));
        check_equal(my_checker, pass, std_logic_vector'(X"A5"), unsigned'(X"A5"));
        counting_assert(pass, "Should return pass = true on passing check");
        verify_passed_checks(my_checker,stat, 2);

      elsif run("Test pass message on std_logic_vector equal unsigned") then
        mock(check_logger);
        check_equal(std_logic_vector'(X"A5"), unsigned'(X"A5"));
        check_only_log(check_logger, "Equality check passed - Got 1010_0101 (165).", pass_level);

        check_equal(std_logic_vector'(X"A5"), unsigned'(X"A5"), "");
        check_only_log(check_logger, "Got 1010_0101 (165).", pass_level);

        check_equal(std_logic_vector'(X"A5"), unsigned'(X"A5"), "Checking my data");
        check_only_log(check_logger, "Checking my data - Got 1010_0101 (165).", pass_level);

        check_equal(std_logic_vector'(X"A5"), unsigned'(X"A5"), result("for my data"));
        check_only_log(check_logger, "Equality check passed for my data - Got 1010_0101 (165).", pass_level);
        unmock(check_logger);

      elsif run("Test should fail on std_logic_vector not equal unsigned") then
        mock(check_logger);
        check_equal(std_logic_vector'(X"A5"), unsigned'(X"5A"));
        check_only_log(check_logger, "Equality check failed - Got 1010_0101 (165). Expected 0101_1010 (90).", default_level);

        check_equal(std_logic_vector'(X"A5"), unsigned'(X"5A"), "");
        check_only_log(check_logger, "Got 1010_0101 (165). Expected 0101_1010 (90).", default_level);

        check_equal(std_logic_vector'(X"A5"), unsigned'(X"5A"), "Checking my data");
        check_only_log(check_logger, "Checking my data - Got 1010_0101 (165). Expected 0101_1010 (90).", default_level);

        check_equal(std_logic_vector'(X"A5"), unsigned'(X"5A"), result("for my data"));
        check_only_log(check_logger, "Equality check failed for my data - Got 1010_0101 (165). Expected 0101_1010 (90).", default_level);

        check_equal(pass, std_logic_vector'(X"A5"), unsigned'(X"5A"));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(check_logger, "Equality check failed - Got 1010_0101 (165). Expected 0101_1010 (90).", default_level);

        pass := check_equal(std_logic_vector'(X"A5"), unsigned'(X"5A"));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(check_logger, "Equality check failed - Got 1010_0101 (165). Expected 0101_1010 (90).", default_level);
        unmock(check_logger);

        mock(my_logger);
        check_equal(my_checker, std_logic_vector'(X"A5"), unsigned'(X"5A"));
        check_only_log(my_logger, "Equality check failed - Got 1010_0101 (165). Expected 0101_1010 (90).", default_level);

        check_equal(my_checker, pass, std_logic_vector'(X"A5"), unsigned'(X"5A"));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(my_logger, "Equality check failed - Got 1010_0101 (165). Expected 0101_1010 (90).", default_level);
        unmock(my_logger);


      elsif run("Test should pass on std_logic_vector equal std_logic_vector") then
        get_checker_stat(stat);
        check_equal(std_logic_vector'(X"A5"), std_logic_vector'(X"A5"));
        check_equal(pass, std_logic_vector'(X"A5"), std_logic_vector'(X"A5"));
        counting_assert(pass, "Should return pass = true on passing check");
        pass := check_equal(std_logic_vector'(X"A5"), std_logic_vector'(X"A5"));
        counting_assert(pass, "Should return pass = true on passing check");
        check_equal(std_logic_vector(to_unsigned(natural'left,31)), std_logic_vector(to_unsigned(natural'left,31)));
        check_equal(std_logic_vector(to_unsigned(natural'right,31)), std_logic_vector(to_unsigned(natural'right,31)));
        verify_passed_checks(stat, 5);

        get_checker_stat(my_checker, stat);
        check_equal(my_checker, std_logic_vector'(X"A5"), std_logic_vector'(X"A5"));
        check_equal(my_checker, pass, std_logic_vector'(X"A5"), std_logic_vector'(X"A5"));
        counting_assert(pass, "Should return pass = true on passing check");
        verify_passed_checks(my_checker,stat, 2);

      elsif run("Test pass message on std_logic_vector equal std_logic_vector") then
        mock(check_logger);
        check_equal(std_logic_vector'(X"A5"), std_logic_vector'(X"A5"));
        check_only_log(check_logger, "Equality check passed - Got 1010_0101 (165).", pass_level);

        check_equal(std_logic_vector'(X"A5"), std_logic_vector'(X"A5"), "");
        check_only_log(check_logger, "Got 1010_0101 (165).", pass_level);

        check_equal(std_logic_vector'(X"A5"), std_logic_vector'(X"A5"), "Checking my data");
        check_only_log(check_logger, "Checking my data - Got 1010_0101 (165).", pass_level);

        check_equal(std_logic_vector'(X"A5"), std_logic_vector'(X"A5"), result("for my data"));
        check_only_log(check_logger, "Equality check passed for my data - Got 1010_0101 (165).", pass_level);
        unmock(check_logger);

      elsif run("Test should fail on std_logic_vector not equal std_logic_vector") then
        mock(check_logger);
        check_equal(std_logic_vector'(X"A5"), std_logic_vector'(X"5A"));
        check_only_log(check_logger, "Equality check failed - Got 1010_0101 (165). Expected 0101_1010 (90).", default_level);

        check_equal(std_logic_vector'(X"A5"), std_logic_vector'(X"5A"), "");
        check_only_log(check_logger, "Got 1010_0101 (165). Expected 0101_1010 (90).", default_level);

        check_equal(std_logic_vector'(X"A5"), std_logic_vector'(X"5A"), "Checking my data");
        check_only_log(check_logger, "Checking my data - Got 1010_0101 (165). Expected 0101_1010 (90).", default_level);

        check_equal(std_logic_vector'(X"A5"), std_logic_vector'(X"5A"), result("for my data"));
        check_only_log(check_logger, "Equality check failed for my data - Got 1010_0101 (165). Expected 0101_1010 (90).", default_level);

        check_equal(pass, std_logic_vector'(X"A5"), std_logic_vector'(X"5A"));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(check_logger, "Equality check failed - Got 1010_0101 (165). Expected 0101_1010 (90).", default_level);

        pass := check_equal(std_logic_vector'(X"A5"), std_logic_vector'(X"5A"));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(check_logger, "Equality check failed - Got 1010_0101 (165). Expected 0101_1010 (90).", default_level);
        unmock(check_logger);

        mock(my_logger);
        check_equal(my_checker, std_logic_vector'(X"A5"), std_logic_vector'(X"5A"));
        check_only_log(my_logger, "Equality check failed - Got 1010_0101 (165). Expected 0101_1010 (90).", default_level);

        check_equal(my_checker, pass, std_logic_vector'(X"A5"), std_logic_vector'(X"5A"));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(my_logger, "Equality check failed - Got 1010_0101 (165). Expected 0101_1010 (90).", default_level);
        unmock(my_logger);

      elsif run("Test should pass on std_logic_vector equal natural") then
        get_checker_stat(stat);
        check_equal(std_logic_vector'(X"A5"), natural'(165));
        check_equal(pass, std_logic_vector'(X"A5"), natural'(165));
        counting_assert(pass, "Should return pass = true on passing check");
        pass := check_equal(std_logic_vector'(X"A5"), natural'(165));
        counting_assert(pass, "Should return pass = true on passing check");
        check_equal(std_logic_vector(to_unsigned(natural'left,31)), natural'left);
        check_equal(std_logic_vector(to_unsigned(natural'right,31)), natural'right);
        verify_passed_checks(stat, 5);

        get_checker_stat(my_checker, stat);
        check_equal(my_checker, std_logic_vector'(X"A5"), natural'(165));
        check_equal(my_checker, pass, std_logic_vector'(X"A5"), natural'(165));
        counting_assert(pass, "Should return pass = true on passing check");
        verify_passed_checks(my_checker,stat, 2);

      elsif run("Test pass message on std_logic_vector equal natural") then
        mock(check_logger);
        check_equal(std_logic_vector'(X"A5"), natural'(165));
        check_only_log(check_logger, "Equality check passed - Got 1010_0101 (165).", pass_level);

        check_equal(std_logic_vector'(X"A5"), natural'(165), "");
        check_only_log(check_logger, "Got 1010_0101 (165).", pass_level);

        check_equal(std_logic_vector'(X"A5"), natural'(165), "Checking my data");
        check_only_log(check_logger, "Checking my data - Got 1010_0101 (165).", pass_level);

        check_equal(std_logic_vector'(X"A5"), natural'(165), result("for my data"));
        check_only_log(check_logger, "Equality check passed for my data - Got 1010_0101 (165).", pass_level);
        unmock(check_logger);

      elsif run("Test should fail on std_logic_vector not equal natural") then
        mock(check_logger);
        check_equal(std_logic_vector'(X"A5"), natural'(90));
        check_only_log(check_logger, "Equality check failed - Got 1010_0101 (165). Expected 90 (0101_1010).", default_level);

        check_equal(std_logic_vector'(X"A5"), natural'(90), "");
        check_only_log(check_logger, "Got 1010_0101 (165). Expected 90 (0101_1010).", default_level);

        check_equal(std_logic_vector'(X"A5"), natural'(90), "Checking my data");
        check_only_log(check_logger, "Checking my data - Got 1010_0101 (165). Expected 90 (0101_1010).", default_level);

        check_equal(std_logic_vector'(X"A5"), natural'(90), result("for my data"));
        check_only_log(check_logger, "Equality check failed for my data - Got 1010_0101 (165). Expected 90 (0101_1010).", default_level);

        check_equal(pass, std_logic_vector'(X"A5"), natural'(90));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(check_logger, "Equality check failed - Got 1010_0101 (165). Expected 90 (0101_1010).", default_level);

        pass := check_equal(std_logic_vector'(X"A5"), natural'(90));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(check_logger, "Equality check failed - Got 1010_0101 (165). Expected 90 (0101_1010).", default_level);
        unmock(check_logger);

        mock(my_logger);
        check_equal(my_checker, std_logic_vector'(X"A5"), natural'(90));
        check_only_log(my_logger, "Equality check failed - Got 1010_0101 (165). Expected 90 (0101_1010).", default_level);

        check_equal(my_checker, pass, std_logic_vector'(X"A5"), natural'(90));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(my_logger, "Equality check failed - Got 1010_0101 (165). Expected 90 (0101_1010).", default_level);
        unmock(my_logger);

      elsif run("Test should pass on natural equal std_logic_vector") then
        get_checker_stat(stat);
        check_equal(natural'(165), std_logic_vector'(X"A5"));
        check_equal(pass, natural'(165), std_logic_vector'(X"A5"));
        counting_assert(pass, "Should return pass = true on passing check");
        pass := check_equal(natural'(165), std_logic_vector'(X"A5"));
        counting_assert(pass, "Should return pass = true on passing check");
        check_equal(natural'left, std_logic_vector(to_unsigned(natural'left,31)));
        check_equal(natural'right, std_logic_vector(to_unsigned(natural'right,31)));
        verify_passed_checks(stat, 5);

        get_checker_stat(my_checker, stat);
        check_equal(my_checker, natural'(165), std_logic_vector'(X"A5"));
        check_equal(my_checker, pass, natural'(165), std_logic_vector'(X"A5"));
        counting_assert(pass, "Should return pass = true on passing check");
        verify_passed_checks(my_checker,stat, 2);

      elsif run("Test pass message on natural equal std_logic_vector") then
        mock(check_logger);
        check_equal(natural'(165), std_logic_vector'(X"A5"));
        check_only_log(check_logger, "Equality check passed - Got 165 (1010_0101).", pass_level);

        check_equal(natural'(165), std_logic_vector'(X"A5"), "");
        check_only_log(check_logger, "Got 165 (1010_0101).", pass_level);

        check_equal(natural'(165), std_logic_vector'(X"A5"), "Checking my data");
        check_only_log(check_logger, "Checking my data - Got 165 (1010_0101).", pass_level);

        check_equal(natural'(165), std_logic_vector'(X"A5"), result("for my data"));
        check_only_log(check_logger, "Equality check passed for my data - Got 165 (1010_0101).", pass_level);
        unmock(check_logger);

      elsif run("Test should fail on natural not equal std_logic_vector") then
        mock(check_logger);
        check_equal(natural'(165), std_logic_vector'(X"5A"));
        check_only_log(check_logger, "Equality check failed - Got 165 (1010_0101). Expected 0101_1010 (90).", default_level);

        check_equal(natural'(165), std_logic_vector'(X"5A"), "");
        check_only_log(check_logger, "Got 165 (1010_0101). Expected 0101_1010 (90).", default_level);

        check_equal(natural'(165), std_logic_vector'(X"5A"), "Checking my data");
        check_only_log(check_logger, "Checking my data - Got 165 (1010_0101). Expected 0101_1010 (90).", default_level);

        check_equal(natural'(165), std_logic_vector'(X"5A"), result("for my data"));
        check_only_log(check_logger, "Equality check failed for my data - Got 165 (1010_0101). Expected 0101_1010 (90).", default_level);

        check_equal(pass, natural'(165), std_logic_vector'(X"5A"));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(check_logger, "Equality check failed - Got 165 (1010_0101). Expected 0101_1010 (90).", default_level);

        pass := check_equal(natural'(165), std_logic_vector'(X"5A"));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(check_logger, "Equality check failed - Got 165 (1010_0101). Expected 0101_1010 (90).", default_level);
        unmock(check_logger);

        mock(my_logger);
        check_equal(my_checker, natural'(165), std_logic_vector'(X"5A"));
        check_only_log(my_logger, "Equality check failed - Got 165 (1010_0101). Expected 0101_1010 (90).", default_level);

        check_equal(my_checker, pass, natural'(165), std_logic_vector'(X"5A"));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(my_logger, "Equality check failed - Got 165 (1010_0101). Expected 0101_1010 (90).", default_level);
        unmock(my_logger);

      elsif run("Test should pass on signed equal signed") then
        get_checker_stat(stat);
        check_equal(signed'(X"A5"), signed'(X"A5"));
        check_equal(pass, signed'(X"A5"), signed'(X"A5"));
        counting_assert(pass, "Should return pass = true on passing check");
        pass := check_equal(signed'(X"A5"), signed'(X"A5"));
        counting_assert(pass, "Should return pass = true on passing check");
        check_equal(to_signed(integer'left,32), to_signed(integer'left,32));
        check_equal(to_signed(integer'right,32), to_signed(integer'right,32));
        verify_passed_checks(stat, 5);

        get_checker_stat(my_checker, stat);
        check_equal(my_checker, signed'(X"A5"), signed'(X"A5"));
        check_equal(my_checker, pass, signed'(X"A5"), signed'(X"A5"));
        counting_assert(pass, "Should return pass = true on passing check");
        verify_passed_checks(my_checker,stat, 2);

      elsif run("Test pass message on signed equal signed") then
        mock(check_logger);
        check_equal(signed'(X"A5"), signed'(X"A5"));
        check_only_log(check_logger, "Equality check passed - Got 1010_0101 (-91).", pass_level);

        check_equal(signed'(X"A5"), signed'(X"A5"), "");
        check_only_log(check_logger, "Got 1010_0101 (-91).", pass_level);

        check_equal(signed'(X"A5"), signed'(X"A5"), "Checking my data");
        check_only_log(check_logger, "Checking my data - Got 1010_0101 (-91).", pass_level);

        check_equal(signed'(X"A5"), signed'(X"A5"), result("for my data"));
        check_only_log(check_logger, "Equality check passed for my data - Got 1010_0101 (-91).", pass_level);
        unmock(check_logger);

      elsif run("Test should fail on signed not equal signed") then
        mock(check_logger);
        check_equal(signed'(X"A5"), signed'(X"5A"));
        check_only_log(check_logger, "Equality check failed - Got 1010_0101 (-91). Expected 0101_1010 (90).", default_level);

        check_equal(signed'(X"A5"), signed'(X"5A"), "");
        check_only_log(check_logger, "Got 1010_0101 (-91). Expected 0101_1010 (90).", default_level);

        check_equal(signed'(X"A5"), signed'(X"5A"), "Checking my data");
        check_only_log(check_logger, "Checking my data - Got 1010_0101 (-91). Expected 0101_1010 (90).", default_level);

        check_equal(signed'(X"A5"), signed'(X"5A"), result("for my data"));
        check_only_log(check_logger, "Equality check failed for my data - Got 1010_0101 (-91). Expected 0101_1010 (90).", default_level);

        check_equal(pass, signed'(X"A5"), signed'(X"5A"));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(check_logger, "Equality check failed - Got 1010_0101 (-91). Expected 0101_1010 (90).", default_level);

        pass := check_equal(signed'(X"A5"), signed'(X"5A"));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(check_logger, "Equality check failed - Got 1010_0101 (-91). Expected 0101_1010 (90).", default_level);
        unmock(check_logger);

        mock(my_logger);
        check_equal(my_checker, signed'(X"A5"), signed'(X"5A"));
        check_only_log(my_logger, "Equality check failed - Got 1010_0101 (-91). Expected 0101_1010 (90).", default_level);

        check_equal(my_checker, pass, signed'(X"A5"), signed'(X"5A"));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(my_logger, "Equality check failed - Got 1010_0101 (-91). Expected 0101_1010 (90).", default_level);
        unmock(my_logger);

      elsif run("Test should pass on signed equal integer") then
        get_checker_stat(stat);
        check_equal(signed'(X"A5"), integer'(-91));
        check_equal(pass, signed'(X"A5"), integer'(-91));
        counting_assert(pass, "Should return pass = true on passing check");
        pass := check_equal(signed'(X"A5"), integer'(-91));
        counting_assert(pass, "Should return pass = true on passing check");
        check_equal(to_signed(integer'left,32), integer'left);
        check_equal(to_signed(integer'right,32), integer'right);
        verify_passed_checks(stat, 5);

        get_checker_stat(my_checker, stat);
        check_equal(my_checker, signed'(X"A5"), integer'(-91));
        check_equal(my_checker, pass, signed'(X"A5"), integer'(-91));
        counting_assert(pass, "Should return pass = true on passing check");
        verify_passed_checks(my_checker,stat, 2);

      elsif run("Test pass message on signed equal integer") then
        mock(check_logger);
        check_equal(signed'(X"A5"), integer'(-91));
        check_only_log(check_logger, "Equality check passed - Got 1010_0101 (-91).", pass_level);

        check_equal(signed'(X"A5"), integer'(-91), "");
        check_only_log(check_logger, "Got 1010_0101 (-91).", pass_level);

        check_equal(signed'(X"A5"), integer'(-91), "Checking my data");
        check_only_log(check_logger, "Checking my data - Got 1010_0101 (-91).", pass_level);

        check_equal(signed'(X"A5"), integer'(-91), result("for my data"));
        check_only_log(check_logger, "Equality check passed for my data - Got 1010_0101 (-91).", pass_level);
        unmock(check_logger);

      elsif run("Test should fail on signed not equal integer") then
        mock(check_logger);
        check_equal(signed'(X"A5"), integer'(90));
        check_only_log(check_logger, "Equality check failed - Got 1010_0101 (-91). Expected 90 (0101_1010).", default_level);

        check_equal(signed'(X"A5"), integer'(90), "");
        check_only_log(check_logger, "Got 1010_0101 (-91). Expected 90 (0101_1010).", default_level);

        check_equal(signed'(X"A5"), integer'(90), "Checking my data");
        check_only_log(check_logger, "Checking my data - Got 1010_0101 (-91). Expected 90 (0101_1010).", default_level);

        check_equal(signed'(X"A5"), integer'(90), result("for my data"));
        check_only_log(check_logger, "Equality check failed for my data - Got 1010_0101 (-91). Expected 90 (0101_1010).", default_level);

        check_equal(pass, signed'(X"A5"), integer'(90));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(check_logger, "Equality check failed - Got 1010_0101 (-91). Expected 90 (0101_1010).", default_level);

        pass := check_equal(signed'(X"A5"), integer'(90));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(check_logger, "Equality check failed - Got 1010_0101 (-91). Expected 90 (0101_1010).", default_level);
        unmock(check_logger);

        mock(my_logger);
        check_equal(my_checker, signed'(X"A5"), integer'(90));
        check_only_log(my_logger, "Equality check failed - Got 1010_0101 (-91). Expected 90 (0101_1010).", default_level);

        check_equal(my_checker, pass, signed'(X"A5"), integer'(90));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(my_logger, "Equality check failed - Got 1010_0101 (-91). Expected 90 (0101_1010).", default_level);
        unmock(my_logger);

      elsif run("Test should pass on integer equal signed") then
        get_checker_stat(stat);
        check_equal(integer'(-91), signed'(X"A5"));
        check_equal(pass, integer'(-91), signed'(X"A5"));
        counting_assert(pass, "Should return pass = true on passing check");
        pass := check_equal(integer'(-91), signed'(X"A5"));
        counting_assert(pass, "Should return pass = true on passing check");
        check_equal(integer'left, to_signed(integer'left,32));
        check_equal(integer'right, to_signed(integer'right,32));
        verify_passed_checks(stat, 5);

        get_checker_stat(my_checker, stat);
        check_equal(my_checker, integer'(-91), signed'(X"A5"));
        check_equal(my_checker, pass, integer'(-91), signed'(X"A5"));
        counting_assert(pass, "Should return pass = true on passing check");
        verify_passed_checks(my_checker,stat, 2);

      elsif run("Test pass message on integer equal signed") then
        mock(check_logger);
        check_equal(integer'(-91), signed'(X"A5"));
        check_only_log(check_logger, "Equality check passed - Got -91 (1010_0101).", pass_level);

        check_equal(integer'(-91), signed'(X"A5"), "");
        check_only_log(check_logger, "Got -91 (1010_0101).", pass_level);

        check_equal(integer'(-91), signed'(X"A5"), "Checking my data");
        check_only_log(check_logger, "Checking my data - Got -91 (1010_0101).", pass_level);

        check_equal(integer'(-91), signed'(X"A5"), result("for my data"));
        check_only_log(check_logger, "Equality check passed for my data - Got -91 (1010_0101).", pass_level);
        unmock(check_logger);

      elsif run("Test should fail on integer not equal signed") then
        mock(check_logger);
        check_equal(integer'(-91), signed'(X"5A"));
        check_only_log(check_logger, "Equality check failed - Got -91 (1010_0101). Expected 0101_1010 (90).", default_level);

        check_equal(integer'(-91), signed'(X"5A"), "");
        check_only_log(check_logger, "Got -91 (1010_0101). Expected 0101_1010 (90).", default_level);

        check_equal(integer'(-91), signed'(X"5A"), "Checking my data");
        check_only_log(check_logger, "Checking my data - Got -91 (1010_0101). Expected 0101_1010 (90).", default_level);

        check_equal(integer'(-91), signed'(X"5A"), result("for my data"));
        check_only_log(check_logger, "Equality check failed for my data - Got -91 (1010_0101). Expected 0101_1010 (90).", default_level);

        check_equal(pass, integer'(-91), signed'(X"5A"));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(check_logger, "Equality check failed - Got -91 (1010_0101). Expected 0101_1010 (90).", default_level);

        pass := check_equal(integer'(-91), signed'(X"5A"));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(check_logger, "Equality check failed - Got -91 (1010_0101). Expected 0101_1010 (90).", default_level);
        unmock(check_logger);

        mock(my_logger);
        check_equal(my_checker, integer'(-91), signed'(X"5A"));
        check_only_log(my_logger, "Equality check failed - Got -91 (1010_0101). Expected 0101_1010 (90).", default_level);

        check_equal(my_checker, pass, integer'(-91), signed'(X"5A"));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(my_logger, "Equality check failed - Got -91 (1010_0101). Expected 0101_1010 (90).", default_level);
        unmock(my_logger);

      elsif run("Test should pass on integer equal integer") then
        get_checker_stat(stat);
        check_equal(integer'(-91), integer'(-91));
        check_equal(pass, integer'(-91), integer'(-91));
        counting_assert(pass, "Should return pass = true on passing check");
        pass := check_equal(integer'(-91), integer'(-91));
        counting_assert(pass, "Should return pass = true on passing check");
        check_equal(integer'left, integer'left);
        check_equal(integer'right, integer'right);
        verify_passed_checks(stat, 5);

        get_checker_stat(my_checker, stat);
        check_equal(my_checker, integer'(-91), integer'(-91));
        check_equal(my_checker, pass, integer'(-91), integer'(-91));
        counting_assert(pass, "Should return pass = true on passing check");
        verify_passed_checks(my_checker,stat, 2);


      elsif run("Test pass message on integer equal integer") then
        mock(check_logger);
        check_equal(integer'(-91), integer'(-91));
        check_only_log(check_logger, "Equality check passed - Got -91.", pass_level);

        check_equal(integer'(-91), integer'(-91), "");
        check_only_log(check_logger, "Got -91.", pass_level);

        check_equal(integer'(-91), integer'(-91), "Checking my data");
        check_only_log(check_logger, "Checking my data - Got -91.", pass_level);

        check_equal(integer'(-91), integer'(-91), result("for my data"));
        check_only_log(check_logger, "Equality check passed for my data - Got -91.", pass_level);
        unmock(check_logger);

      elsif run("Test should fail on integer not equal integer") then
        mock(check_logger);
        check_equal(integer'(-91), integer'(90));
        check_only_log(check_logger, "Equality check failed - Got -91. Expected 90.", default_level);

        check_equal(integer'(-91), integer'(90), "");
        check_only_log(check_logger, "Got -91. Expected 90.", default_level);

        check_equal(integer'(-91), integer'(90), "Checking my data");
        check_only_log(check_logger, "Checking my data - Got -91. Expected 90.", default_level);

        check_equal(integer'(-91), integer'(90), result("for my data"));
        check_only_log(check_logger, "Equality check failed for my data - Got -91. Expected 90.", default_level);

        check_equal(pass, integer'(-91), integer'(90));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(check_logger, "Equality check failed - Got -91. Expected 90.", default_level);

        pass := check_equal(integer'(-91), integer'(90));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(check_logger, "Equality check failed - Got -91. Expected 90.", default_level);
        unmock(check_logger);

        mock(my_logger);
        check_equal(my_checker, integer'(-91), integer'(90));
        check_only_log(my_logger, "Equality check failed - Got -91. Expected 90.", default_level);

        check_equal(my_checker, pass, integer'(-91), integer'(90));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(my_logger, "Equality check failed - Got -91. Expected 90.", default_level);
        unmock(my_logger);

      elsif run("Test should pass on std_logic equal std_logic") then
        get_checker_stat(stat);
        check_equal('1', '1');
        check_equal(pass, '1', '1');
        counting_assert(pass, "Should return pass = true on passing check");
        pass := check_equal('1', '1');
        counting_assert(pass, "Should return pass = true on passing check");
        check_equal('0', '0');
        check_equal('1', '1');
        verify_passed_checks(stat, 5);

        get_checker_stat(my_checker, stat);
        check_equal(my_checker, '1', '1');
        check_equal(my_checker, pass, '1', '1');
        counting_assert(pass, "Should return pass = true on passing check");
        verify_passed_checks(my_checker,stat, 2);

      elsif run("Test pass message on std_logic equal std_logic") then
        mock(check_logger);
        check_equal('1', '1');
        check_only_log(check_logger, "Equality check passed - Got 1.", pass_level);

        check_equal('1', '1', "");
        check_only_log(check_logger, "Got 1.", pass_level);

        check_equal('1', '1', "Checking my data");
        check_only_log(check_logger, "Checking my data - Got 1.", pass_level);

        check_equal('1', '1', result("for my data"));
        check_only_log(check_logger, "Equality check passed for my data - Got 1.", pass_level);
        unmock(check_logger);

      elsif run("Test should fail on std_logic not equal std_logic") then
        mock(check_logger);
        check_equal('1', '0');
        check_only_log(check_logger, "Equality check failed - Got 1. Expected 0.", default_level);

        check_equal('1', '0', "");
        check_only_log(check_logger, "Got 1. Expected 0.", default_level);

        check_equal('1', '0', "Checking my data");
        check_only_log(check_logger, "Checking my data - Got 1. Expected 0.", default_level);

        check_equal('1', '0', result("for my data"));
        check_only_log(check_logger, "Equality check failed for my data - Got 1. Expected 0.", default_level);

        check_equal(pass, '1', '0');
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(check_logger, "Equality check failed - Got 1. Expected 0.", default_level);

        pass := check_equal('1', '0');
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(check_logger, "Equality check failed - Got 1. Expected 0.", default_level);
        unmock(check_logger);

        mock(my_logger);
        check_equal(my_checker, '1', '0');
        check_only_log(my_logger, "Equality check failed - Got 1. Expected 0.", default_level);

        check_equal(my_checker, pass, '1', '0');
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(my_logger, "Equality check failed - Got 1. Expected 0.", default_level);
        unmock(my_logger);

      elsif run("Test should pass on std_logic equal boolean") then
        get_checker_stat(stat);
        check_equal('1', true);
        check_equal(pass, '1', true);
        counting_assert(pass, "Should return pass = true on passing check");
        pass := check_equal('1', true);
        counting_assert(pass, "Should return pass = true on passing check");
        check_equal('0', false);
        check_equal('1', true);
        verify_passed_checks(stat, 5);

        get_checker_stat(my_checker, stat);
        check_equal(my_checker, '1', true);
        check_equal(my_checker, pass, '1', true);
        counting_assert(pass, "Should return pass = true on passing check");
        verify_passed_checks(my_checker,stat, 2);

      elsif run("Test pass message on std_logic equal boolean") then
        mock(check_logger);
        check_equal('1', true);
        check_only_log(check_logger, "Equality check passed - Got 1.", pass_level);

        check_equal('1', true, "");
        check_only_log(check_logger, "Got 1.", pass_level);

        check_equal('1', true, "Checking my data");
        check_only_log(check_logger, "Checking my data - Got 1.", pass_level);

        check_equal('1', true, result("for my data"));
        check_only_log(check_logger, "Equality check passed for my data - Got 1.", pass_level);
        unmock(check_logger);

      elsif run("Test should fail on std_logic not equal boolean") then
        mock(check_logger);
        check_equal('1', false);
        check_only_log(check_logger, "Equality check failed - Got 1. Expected false.", default_level);

        check_equal('1', false, "");
        check_only_log(check_logger, "Got 1. Expected false.", default_level);

        check_equal('1', false, "Checking my data");
        check_only_log(check_logger, "Checking my data - Got 1. Expected false.", default_level);

        check_equal('1', false, result("for my data"));
        check_only_log(check_logger, "Equality check failed for my data - Got 1. Expected false.", default_level);

        check_equal(pass, '1', false);
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(check_logger, "Equality check failed - Got 1. Expected false.", default_level);

        pass := check_equal('1', false);
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(check_logger, "Equality check failed - Got 1. Expected false.", default_level);
        unmock(check_logger);

        mock(my_logger);
        check_equal(my_checker, '1', false);
        check_only_log(my_logger, "Equality check failed - Got 1. Expected false.", default_level);

        check_equal(my_checker, pass, '1', false);
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(my_logger, "Equality check failed - Got 1. Expected false.", default_level);
        unmock(my_logger);

      elsif run("Test should pass on boolean equal std_logic") then
        get_checker_stat(stat);
        check_equal(true, '1');
        check_equal(pass, true, '1');
        counting_assert(pass, "Should return pass = true on passing check");
        pass := check_equal(true, '1');
        counting_assert(pass, "Should return pass = true on passing check");
        check_equal(false, '0');
        check_equal(true, '1');
        verify_passed_checks(stat, 5);

        get_checker_stat(my_checker, stat);
        check_equal(my_checker, true, '1');
        check_equal(my_checker, pass, true, '1');
        counting_assert(pass, "Should return pass = true on passing check");
        verify_passed_checks(my_checker,stat, 2);

      elsif run("Test pass message on boolean equal std_logic") then
        mock(check_logger);
        check_equal(true, '1');
        check_only_log(check_logger, "Equality check passed - Got true.", pass_level);

        check_equal(true, '1', "");
        check_only_log(check_logger, "Got true.", pass_level);

        check_equal(true, '1', "Checking my data");
        check_only_log(check_logger, "Checking my data - Got true.", pass_level);

        check_equal(true, '1', result("for my data"));
        check_only_log(check_logger, "Equality check passed for my data - Got true.", pass_level);
        unmock(check_logger);

      elsif run("Test should fail on boolean not equal std_logic") then
        mock(check_logger);

        check_equal(true, '0');
        check_only_log(check_logger, "Equality check failed - Got true. Expected 0.", default_level);

        check_equal(true, '0', "");
        check_only_log(check_logger, "Got true. Expected 0.", default_level);

        check_equal(true, '0', "Checking my data");
        check_only_log(check_logger, "Checking my data - Got true. Expected 0.", default_level);

        check_equal(true, '0', result("for my data"));
        check_only_log(check_logger, "Equality check failed for my data - Got true. Expected 0.", default_level);

        check_equal(pass, true, '0');
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(check_logger, "Equality check failed - Got true. Expected 0.", default_level);

        pass := check_equal(true, '0');
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(check_logger, "Equality check failed - Got true. Expected 0.", default_level);
        unmock(check_logger);

        mock(my_logger);
        check_equal(my_checker, true, '0');
        check_only_log(my_logger, "Equality check failed - Got true. Expected 0.", default_level);

        check_equal(my_checker, pass, true, '0');
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(my_logger, "Equality check failed - Got true. Expected 0.", default_level);
        unmock(my_logger);

      elsif run("Test should pass on boolean equal boolean") then
        get_checker_stat(stat);
        check_equal(true, true);
        check_equal(pass, true, true);
        counting_assert(pass, "Should return pass = true on passing check");
        pass := check_equal(true, true);
        counting_assert(pass, "Should return pass = true on passing check");
        check_equal(false, false);
        check_equal(true, true);
        verify_passed_checks(stat, 5);

        get_checker_stat(my_checker, stat);
        check_equal(my_checker, true, true);
        check_equal(my_checker, pass, true, true);
        counting_assert(pass, "Should return pass = true on passing check");
        verify_passed_checks(my_checker,stat, 2);

      elsif run("Test pass message on boolean equal boolean") then
        mock(check_logger);
        check_equal(true, true);
        check_only_log(check_logger, "Equality check passed - Got true.", pass_level);

        check_equal(true, true, "");
        check_only_log(check_logger, "Got true.", pass_level);

        check_equal(true, true, "Checking my data");
        check_only_log(check_logger, "Checking my data - Got true.", pass_level);

        check_equal(true, true, result("for my data"));
        check_only_log(check_logger, "Equality check passed for my data - Got true.", pass_level);
        unmock(check_logger);
      elsif run("Test should fail on boolean not equal boolean") then
        mock(check_logger);
        check_equal(true, false);
        check_only_log(check_logger, "Equality check failed - Got true. Expected false.", default_level);

        check_equal(true, false, "");
        check_only_log(check_logger, "Got true. Expected false.", default_level);

        check_equal(true, false, "Checking my data");
        check_only_log(check_logger, "Checking my data - Got true. Expected false.", default_level);

        check_equal(true, false, result("for my data"));
        check_only_log(check_logger, "Equality check failed for my data - Got true. Expected false.", default_level);

        check_equal(pass, true, false);
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(check_logger, "Equality check failed - Got true. Expected false.", default_level);

        pass := check_equal(true, false);
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(check_logger, "Equality check failed - Got true. Expected false.", default_level);
        unmock(check_logger);

        mock(my_logger);
        check_equal(my_checker, true, false);
        check_only_log(my_logger, "Equality check failed - Got true. Expected false.", default_level);

        check_equal(my_checker, pass, true, false);
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(my_logger, "Equality check failed - Got true. Expected false.", default_level);
        unmock(my_logger);

      elsif run("Test should pass on string equal string") then
        get_checker_stat(stat);
        check_equal(string'("test"), string'("test"));
        check_equal(pass, string'("test"), string'("test"));
        counting_assert(pass, "Should return pass = true on passing check");
        pass := check_equal(string'("test"), string'("test"));
        counting_assert(pass, "Should return pass = true on passing check");
        check_equal(string'(""), string'(""));
        check_equal(string'("autogenerated test for type with no max value"), string'("autogenerated test for type with no max value"));
        verify_passed_checks(stat, 5);

        get_checker_stat(my_checker, stat);
        check_equal(my_checker, string'("test"), string'("test"));
        check_equal(my_checker, pass, string'("test"), string'("test"));
        counting_assert(pass, "Should return pass = true on passing check");
        verify_passed_checks(my_checker,stat, 2);

      elsif run("Test pass message on string equal string") then
        mock(check_logger);
        check_equal(string'("test"), string'("test"));
        check_only_log(check_logger, "Equality check passed - Got test.", pass_level);

        check_equal(string'("test"), string'("test"), "");
        check_only_log(check_logger, "Got test.", pass_level);

        check_equal(string'("test"), string'("test"), "Checking my data");
        check_only_log(check_logger, "Checking my data - Got test.", pass_level);

        check_equal(string'("test"), string'("test"), result("for my data"));
        check_only_log(check_logger, "Equality check passed for my data - Got test.", pass_level);
        unmock(check_logger);

      elsif run("Test should fail on string not equal string") then
        mock(check_logger);
        check_equal(string'("test"), string'("tests"));
        check_only_log(check_logger, "Equality check failed - Got test. Expected tests.", default_level);

        check_equal(string'("test"), string'("tests"), "");
        check_only_log(check_logger, "Got test. Expected tests.", default_level);

        check_equal(string'("test"), string'("tests"), "Checking my data");
        check_only_log(check_logger, "Checking my data - Got test. Expected tests.", default_level);

        check_equal(string'("test"), string'("tests"), result("for my data"));
        check_only_log(check_logger, "Equality check failed for my data - Got test. Expected tests.", default_level);

        check_equal(pass, string'("test"), string'("tests"));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(check_logger, "Equality check failed - Got test. Expected tests.", default_level);

        pass := check_equal(string'("test"), string'("tests"));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(check_logger, "Equality check failed - Got test. Expected tests.", default_level);
        unmock(check_logger);

        mock(my_logger);
        check_equal(my_checker, string'("test"), string'("tests"));
        check_only_log(my_logger, "Equality check failed - Got test. Expected tests.", default_level);

        check_equal(my_checker, pass, string'("test"), string'("tests"));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(my_logger, "Equality check failed - Got test. Expected tests.", default_level);
        unmock(my_logger);

      elsif run("Test should pass on time equal time") then
        get_checker_stat(stat);
        check_equal(time'(-91 ns), time'(-91 ns));
        check_equal(pass, time'(-91 ns), time'(-91 ns));
        counting_assert(pass, "Should return pass = true on passing check");
        pass := check_equal(time'(-91 ns), time'(-91 ns));
        counting_assert(pass, "Should return pass = true on passing check");
        check_equal(time'left, time'left);
        check_equal(time'right, time'right);
        verify_passed_checks(stat, 5);

        get_checker_stat(my_checker, stat);
        check_equal(my_checker, time'(-91 ns), time'(-91 ns));
        check_equal(my_checker, pass, time'(-91 ns), time'(-91 ns));
        counting_assert(pass, "Should return pass = true on passing check");
        verify_passed_checks(my_checker,stat, 2);

      elsif run("Test pass message on time equal time") then
        mock(check_logger);
        check_equal(time'(-91 ns), time'(-91 ns));
        check_only_log(check_logger, "Equality check passed - Got " & time'image(-91 ns) & ".", pass_level);

        check_equal(time'(-91 ns), time'(-91 ns), "");
        check_only_log(check_logger, "Got " & time'image(-91 ns) & ".", pass_level);

        check_equal(time'(-91 ns), time'(-91 ns), "Checking my data");
        check_only_log(check_logger, "Checking my data - Got " & time'image(-91 ns) & ".", pass_level);

        check_equal(time'(-91 ns), time'(-91 ns), result("for my data"));
        check_only_log(check_logger, "Equality check passed for my data - Got " & time'image(-91 ns) & ".", pass_level);
        unmock(check_logger);

      elsif run("Test should fail on time not equal time") then
        mock(check_logger);
        check_equal(time'(-91 ns), time'(90 ns));
        check_only_log(check_logger,
                       "Equality check failed - Got " & time'image(-91 ns) & ". Expected " & time'image(90 ns) & ".",
                       default_level);

        check_equal(time'(-91 ns), time'(90 ns), "");
        check_only_log(check_logger,
                       "Got " & time'image(-91 ns) & ". Expected " & time'image(90 ns) & ".",
                       default_level);

        check_equal(time'(-91 ns), time'(90 ns), "Checking my data");
        check_only_log(check_logger,
                       "Checking my data - Got " & time'image(-91 ns) & ". Expected " & time'image(90 ns) & ".",
                       default_level);

        check_equal(time'(-91 ns), time'(90 ns), result("for my data"));
        check_only_log(check_logger,
                       "Equality check failed for my data - Got " & time'image(-91 ns) & ". Expected " & time'image(90 ns) & ".",
                       default_level);

        check_equal(pass, time'(-91 ns), time'(90 ns));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(check_logger,
                       "Equality check failed - Got " & time'image(-91 ns) & ". Expected " & time'image(90 ns) & ".",
                       default_level);

        pass := check_equal(time'(-91 ns), time'(90 ns));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(check_logger,
                       "Equality check failed - Got " & time'image(-91 ns) & ". Expected " & time'image(90 ns) & ".",
                       default_level);
        unmock(check_logger);

        mock(my_logger);
        check_equal(my_checker, time'(-91 ns), time'(90 ns));
        check_only_log(my_logger,
                       "Equality check failed - Got " & time'image(-91 ns) & ". Expected " & time'image(90 ns) & ".",
                       default_level);

        check_equal(my_checker, pass, time'(-91 ns), time'(90 ns));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(my_logger,
                       "Equality check failed - Got " & time'image(-91 ns) & ". Expected " & time'image(90 ns) & ".",
                       default_level);
        unmock(my_logger);

      elsif run("Test should pass on natural equal natural") then
        get_checker_stat(stat);
        check_equal(natural'(165), natural'(165));
        check_equal(pass, natural'(165), natural'(165));
        counting_assert(pass, "Should return pass = true on passing check");
        pass := check_equal(natural'(165), natural'(165));
        counting_assert(pass, "Should return pass = true on passing check");
        check_equal(natural'left, natural'left);
        check_equal(natural'right, natural'right);
        verify_passed_checks(stat, 5);

        get_checker_stat(my_checker, stat);
        check_equal(my_checker, natural'(165), natural'(165));
        check_equal(my_checker, pass, natural'(165), natural'(165));
        counting_assert(pass, "Should return pass = true on passing check");
        verify_passed_checks(my_checker,stat, 2);

      elsif run("Test pass message on natural equal natural") then
        mock(check_logger);
        check_equal(natural'(165), natural'(165));
        check_only_log(check_logger, "Equality check passed - Got 165.", pass_level);

        check_equal(natural'(165), natural'(165), "");
        check_only_log(check_logger, "Got 165.", pass_level);

        check_equal(natural'(165), natural'(165), "Checking my data");
        check_only_log(check_logger, "Checking my data - Got 165.", pass_level);

        check_equal(natural'(165), natural'(165), result("for my data"));
        check_only_log(check_logger, "Equality check passed for my data - Got 165.", pass_level);
        unmock(check_logger);

      elsif run("Test should fail on natural not equal natural") then
        mock(check_logger);
        check_equal(natural'(165), natural'(90));
        check_only_log(check_logger, "Equality check failed - Got 165. Expected 90.", default_level);

        check_equal(natural'(165), natural'(90), "");
        check_only_log(check_logger, "Got 165. Expected 90.", default_level);

        check_equal(natural'(165), natural'(90), "Checking my data");
        check_only_log(check_logger, "Checking my data - Got 165. Expected 90.", default_level);

        check_equal(natural'(165), natural'(90), result("for my data"));
        check_only_log(check_logger, "Equality check failed for my data - Got 165. Expected 90.", default_level);

        check_equal(pass, natural'(165), natural'(90));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(check_logger, "Equality check failed - Got 165. Expected 90.", default_level);

        pass := check_equal(natural'(165), natural'(90));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(check_logger, "Equality check failed - Got 165. Expected 90.", default_level);
        unmock(check_logger);

        mock(my_logger);
        check_equal(my_checker, natural'(165), natural'(90));
        check_only_log(my_logger, "Equality check failed - Got 165. Expected 90.", default_level);

        check_equal(my_checker, pass, natural'(165), natural'(90));
        counting_assert(not pass, "Should return pass = false on failing check");
        check_only_log(my_logger, "Equality check failed - Got 165. Expected 90.", default_level);
        unmock(my_logger);
      end if;
    end loop;

    reset_checker_stat;
    test_runner_cleanup(runner);
    wait;
  end process;

  test_runner_watchdog(runner, 2 us);

end test_fixture;

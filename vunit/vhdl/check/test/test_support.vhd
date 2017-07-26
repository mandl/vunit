-- This package provides various test support for the checker test suites.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this file,
-- You can obtain one at http://mozilla.org/MPL/2.0/.
--
-- Copyright (c) 2014-2016, Lars Asplund lars.anders.asplund@gmail.com

library ieee;
use ieee.std_logic_1164.all;
library vunit_lib;
use vunit_lib.checker_pkg.all;
use vunit_lib.check_pkg.all;
use work.test_count.all;
use std.textio.all;

package test_support is

  procedure counting_assert (
    constant expr : in boolean;
    constant msg  : in string := "";
    constant level : in severity_level := error);

  procedure verify_passed_checks (
    variable stat : inout checker_stat_t;
    constant expected_n_passed : in integer := -1);

  procedure verify_passed_checks (
    checker : checker_t;
    variable stat : inout checker_stat_t;
    constant expected_n_passed : in integer := -1);

  procedure verify_failed_checks (
    variable stat : inout checker_stat_t;
    constant expected_n_failed : in integer := -1);

  procedure verify_failed_checks (
    checker : checker_t;
    variable stat : inout checker_stat_t;
    constant expected_n_failed : in integer := -1);

  procedure apply_sequence (
    constant seq : in string;
    signal clk        : in  std_logic;
    signal data       : out std_logic;
    constant active_rising_clk_edge : in boolean := true);

  procedure apply_sequence (
    constant seq : in string;
    signal clk        : in  std_logic;
    signal data       : out std_logic_vector;
    constant active_rising_clk_edge : in boolean := true);

  procedure banner (
    constant s : in string);

  procedure print_test_result;

  procedure get_and_print_test_result (
    variable stat : out checker_stat_t);

  function clock_edge (
    signal clk                : in std_logic;
    constant wait_rising_edge : in boolean := true)
    return boolean;

end package test_support;

package body test_support is
  constant asserts : natural := 0;
  constant errors : natural := 1;
  constant unexpected_errors : natural := 2;

  procedure counting_assert (
    constant expr : in boolean;
    constant msg  : in string := "";
    constant level : in severity_level := error) is
  begin
    inc_count(asserts);
    if not expr then
      assert false report msg severity level;
      inc_count(unexpected_errors);
    end if;
  end procedure counting_assert;

  procedure verify_passed_checks (
    variable stat : inout checker_stat_t;
    constant expected_n_passed : in integer := -1) is
  begin
    verify_passed_checks(default_checker, stat, expected_n_passed);
  end;

  procedure verify_passed_checks (
    checker : checker_t;
    variable stat : inout checker_stat_t;
    constant expected_n_passed : in integer := -1) is
    variable new_stat : checker_stat_t;
  begin
    get_checker_stat(checker, new_stat);
    if expected_n_passed = -1 then
      counting_assert(new_stat.n_passed > stat.n_passed, "No passed checks registered.");
    else
      counting_assert(new_stat.n_passed = stat.n_passed + expected_n_passed, "Not expected number of passed checks registered. Got " & integer'image(new_stat.n_passed) & " but expected " & integer'image(stat.n_passed + expected_n_passed) & ".");
    end if;
  end;

  procedure verify_failed_checks (
    variable stat : inout checker_stat_t;
    constant expected_n_failed : in integer := -1) is
  begin
    verify_failed_checks(default_checker, stat, expected_n_failed);
  end;

  procedure verify_failed_checks (
    checker : checker_t;
    variable stat : inout checker_stat_t;
    constant expected_n_failed : in integer := -1) is
    variable new_stat : checker_stat_t;
  begin
    get_checker_stat(checker, new_stat);
    if expected_n_failed = -1 then
      counting_assert(new_stat.n_failed > stat.n_failed, "No failed checks registered.");
    else
      counting_assert(new_stat.n_failed = stat.n_failed + expected_n_failed, "Not expected number of failed checks registered. Got " & integer'image(new_stat.n_failed) & " but expected " & integer'image(stat.n_failed + expected_n_failed) & ".");
    end if;
  end;

  function is_std_logic (
    constant c : character)
    return boolean is
  begin
    for i in 0 to 8 loop
      if c = std_logic'image(std_logic'val(i))(2) then
        return true;
      end if;
    end loop;
    return false;
  end;

  procedure apply_sequence (
    constant seq : in string;
    signal clk        : in  std_logic;
    signal data       : out std_logic;
    constant active_rising_clk_edge : in boolean := true) is
  begin
    for i in seq'range loop
      if is_std_logic(seq(i)) then
        data <= std_logic'value("'" & seq(i) & "'");
      end if;
      if i /= seq'right then
        if active_rising_clk_edge then
          wait until rising_edge(clk);
        else
          wait until falling_edge(clk);
        end if;
      end if;
    end loop;
  end procedure apply_sequence;

  procedure apply_sequence (
    constant seq : in string;
    signal clk        : in  std_logic;
    signal data       : out std_logic_vector;
    constant active_rising_clk_edge : in boolean := true) is
    variable i : natural := seq'left;
    variable delimiters : natural := 0;
    variable j : integer := 0;
  begin
    while i <= seq'right loop
      j := data'left;
      delimiters := 0;
      while (j <= data'high) and (j >= data'low) loop
        if data'ascending then
          if is_std_logic(seq(i + delimiters + j - data'left)) then
            data(j) <= std_logic'value("'" & seq(i + delimiters + j - data'left) & "'");
            j := j + 1;
          else
            delimiters := delimiters + 1;
          end if;
        else
          if is_std_logic(seq(i + delimiters - j + data'left)) then
            data(j) <= std_logic'value("'" & seq(i + delimiters - j + data'left) & "'");
            j := j - 1;
          else
            delimiters := delimiters + 1;
          end if;
        end if;
      end loop;
      i := i + data'length + delimiters;
      if i <= seq'right then
        if active_rising_clk_edge then
          wait until rising_edge(clk);
        else
          wait until falling_edge(clk);
        end if;
      end if;
    end loop;
  end procedure apply_sequence;

  procedure banner (
    constant s : in string) is
    constant dashes : string(1 to 256) := (others => '-');
  begin  -- banner
    report LF & dashes(s'range) & LF & s & LF & dashes(s'range);
  end banner;

  procedure print_test_result is
  begin
    banner("Test result");
    report "Number of assertions: " & natural'image(get_count(asserts));
    report "Number of errors: " & natural'image(get_count(unexpected_errors));
  end procedure print_test_result;

  procedure get_and_print_test_result (
    variable stat : out checker_stat_t) is
  begin
    reset_checker_stat; -- Normal checker stat doesn't contain real errors
    print_test_result;
    stat.n_checks := get_count(asserts);
    stat.n_failed := get_count(unexpected_errors);
    stat.n_passed := get_count(asserts) - get_count(unexpected_errors);
  end;

  function clock_edge (
    signal clk                : in std_logic;
    constant wait_rising_edge : in boolean := true)
    return boolean is
  begin
    if wait_rising_edge then
      return rising_edge(clk);
    else
      return falling_edge(clk);
    end if;
  end clock_edge;

end package body test_support;

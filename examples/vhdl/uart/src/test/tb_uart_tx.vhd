-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this file,
-- You can obtain one at http://mozilla.org/MPL/2.0/.
--
-- Copyright (c) 2014-2016, Lars Asplund lars.anders.asplund@gmail.com

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;
context vunit_lib.bfm_context;

library osvvm;
use osvvm.RandomPkg.all;

library uart_lib;

entity tb_uart_tx is
  generic (
    runner_cfg : string);
end entity;

architecture tb of tb_uart_tx is
  constant baud_rate : integer := 115200; -- bits / s
  constant clk_period : integer := 20; -- ns
  constant cycles_per_bit : integer := 50 * 10**6 / baud_rate;

  signal clk : std_logic := '0';
  signal tx : std_logic;
  signal tready : std_logic;
  signal tvalid : std_Logic := '0';
  signal tdata : std_logic_vector(7 downto 0) := (others => '0');

  shared variable rnd_stimuli, rnd_expected : RandomPType;
  constant uart_bfm : uart_slave_t := new_uart_slave(initial_baud_rate => baud_rate);
  constant uart_stream : stream_slave_t := as_stream(uart_bfm);
begin

  main : process
    variable index : integer := 0;

    procedure send is
    begin
      tvalid <= '1';
      tdata <= rnd_stimuli.RandSlv(tdata'length);
      wait until tvalid = '1' and tready = '1' and rising_edge(clk);
      tvalid <= '0';
      tdata <= (others => '0');
    end procedure;

    procedure check_expected(num_bytes : natural) is
    begin
      for i in 0 to num_bytes-1 loop
        check_stream(event, uart_stream, rnd_expected.RandSlv(tdata'length));
      end loop;
    end procedure;

    variable stat : checker_stat_t;
    variable filter : log_filter_t;
  begin
    checker_init(display_format => verbose,
                 file_name => join(output_path(runner_cfg), "error.csv"),
                 file_format => verbose_csv);
    logger_init(display_format => verbose,
                 file_name => join(output_path(runner_cfg), "log.csv"),
                file_format => verbose_csv);
    stop_level((debug, verbose), display_handler, filter);
    test_runner_setup(runner, runner_cfg);

    -- Initialize to same seed to get same sequence
    rnd_stimuli.InitSeed(rnd_stimuli'instance_name);
    rnd_expected.InitSeed(rnd_stimuli'instance_name);

    while test_suite loop
      if run("test_send_one_byte") then
        send;
        check_expected(1);
      elsif run("test_send_two_bytes") then
        send;
        check_expected(1);
        send;
        check_expected(1);
      elsif run("test_send_many_bytes") then
        for i in 0 to 7 loop
          send;
        end loop;
        check_expected(8);
      end if;
    end loop;

    if not active_python_runner(runner_cfg) then
      get_checker_stat(stat);
      info(LF & "Result:" & LF & to_string(stat));
    end if;

    test_runner_cleanup(runner);
    wait;
  end process;
  test_runner_watchdog(runner, 10 ms);

  clk <= not clk after (clk_period/2) * 1 ns;

  dut : entity uart_lib.uart_tx
    generic map (
      cycles_per_bit => cycles_per_bit)
    port map (
      clk => clk,
      tx => tx,
      tready => tready,
      tvalid => tvalid,
      tdata => tdata);

  uart_slave_bfm : entity vunit_lib.uart_slave
    generic map (
      uart => uart_bfm)
    port map (
      rx => tx);

end architecture;

-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this file,
-- You can obtain one at http://mozilla.org/MPL/2.0/.
--
-- Copyright (c) 2017, Lars Asplund lars.anders.asplund@gmail.com

library vunit_lib;
use vunit_lib.string_ptr_pkg.all;
use vunit_lib.integer_vector_ptr_pkg.all;

use work.logger_pkg.all;
use work.log_handler_pkg.all;
use work.log_system_pkg.all;

package log2_pkg is
  constant log_system : log_system_t := new_log_system;

  constant default_logger : logger_t := new_logger(log_system, "default");

  -- Write to stdout
  constant display_handler : log_handler_t := new_log_handler(log_system,
                                                              stdout_file_name,
                                                              format => verbose,
                                                              use_color => false,
                                                              log_level => info);

  -- Write to file
  constant file_handler : log_handler_t := new_log_handler(log_system,
                                                           null_file_name,
                                                           format => verbose,
                                                           use_color => false,
                                                           log_level => verbose);

  procedure init_display_handler(constant format : in log_format_t := verbose;
                                 constant use_color : in boolean := true);
  procedure init_file_handler(constant file_name : string;
                              constant format : in log_format_t := verbose);

  impure function new_logger(name : string;
                             parent : logger_t := null_logger) return logger_t;

  impure function get_logger(name : string;
                             parent : logger_t := null_logger) return logger_t;

  -- Stop simulation for all levels >= level
  procedure set_stop_level(level : log_level_config_t);

  -- Disable stopping simulation
  -- Equivalent with set_stop_level(all_levels)
  procedure disable_stop;

  -- Return true if logging to this logger at this level is enabled in any handler
  -- Can be used to avoid expensive string creation when not logging
  impure function is_enabled(logger : logger_t;
                             level : log_level_t) return boolean;

  -- Disable logging for all levels < level to this handler
  procedure set_log_level(log_handler : log_handler_t;
                          level : log_level_config_t);

  -- Disable all log levels to this handler
  -- equivalent with setting log level to all_levels
  procedure disable_all(log_handler : log_handler_t);

  -- Enable all log levels to this handler
  -- equivalent with setting log level to no_level
  procedure enable_all(log_handler : log_handler_t);

  procedure log(logger : logger_t;
                msg : string;
                log_level : log_level_t;
                line_num : natural := 0;
                file_name : string := "");

  procedure debug(logger : logger_t; msg : string);
  procedure verbose(logger : logger_t; msg : string);
  procedure info(logger : logger_t; msg : string);
  procedure warning(logger : logger_t; msg : string);
  procedure error(logger : logger_t; msg : string);
  procedure failure(logger : logger_t; msg : string);

  procedure debug(msg : string);
  procedure verbose(msg : string);
  procedure info(msg : string);
  procedure warning(msg : string);
  procedure error(msg : string);
  procedure failure(msg : string);

end package;

package body log2_pkg is
  procedure init_display_handler(constant format : in log_format_t := verbose;
                                 constant use_color : in boolean := true) is
  begin
    init_log_handler(display_handler, format, stdout_file_name, use_color);
  end;

  procedure init_file_handler(constant file_name : string;
                              constant format : in log_format_t := verbose) is
  begin
    init_log_handler(file_handler, format, file_name, false);
  end;

  impure function new_logger(name : string;
                             parent : logger_t := null_logger) return logger_t is
  begin
    return new_logger(log_system, name, parent);
  end;

  impure function get_logger(name : string;
                             parent : logger_t := null_logger) return logger_t is
  begin
    return get_logger(log_system, name, parent);
  end;

  impure function is_enabled(logger : logger_t;
                             level : log_level_t) return boolean is
  begin
    return is_enabled(log_system, logger, level);
  end;

  -- Disable logging for all levels < level to this handler
  procedure set_log_level(log_handler : log_handler_t;
                          level : log_level_config_t) is
  begin
    set_log_level(log_system, log_handler, level);
  end;

  -- Disable logging to this handler
  procedure disable_all(log_handler : log_handler_t) is
  begin
    set_log_level(log_system, log_handler, all_levels);
  end;

  -- Enable logging to this handler
  procedure enable_all(log_handler : log_handler_t) is
  begin
    set_log_level(log_system, log_handler, no_level);
  end;

  procedure set_stop_level(level : log_level_config_t) is
  begin
    set_stop_level(log_system, level);
  end;

  procedure disable_stop is
  begin
    set_stop_level(log_system, all_levels);
  end;

  procedure log(logger : logger_t;
                msg : string;
                log_level : log_level_t;
                line_num : natural := 0;
                file_name : string := "") is
  begin
    log(log_system, logger, msg, log_level, line_num, file_name);
  end procedure;

  procedure debug(logger : logger_t; msg : string) is
  begin
    log(logger, msg, debug);
  end procedure;

  procedure verbose(logger : logger_t; msg : string) is
  begin
    log(logger, msg, verbose);
  end procedure;

  procedure info(logger : logger_t; msg : string) is
  begin
    log(logger, msg, info);
  end procedure;

  procedure warning(logger : logger_t; msg : string) is
  begin
    log(logger, msg, warning);
  end procedure;

  procedure error(logger : logger_t; msg : string) is
  begin
    log(logger, msg, error);
  end procedure;

  procedure failure(logger : logger_t; msg : string) is
  begin
    log(logger, msg, failure);
  end procedure;

  procedure debug(msg : string) is
  begin
    debug(default_logger, msg);
  end procedure;

  procedure verbose(msg : string) is
  begin
    verbose(default_logger, msg);
  end procedure;

  procedure info(msg : string) is
  begin
    info(default_logger, msg);
  end procedure;

  procedure warning(msg : string) is
  begin
    warning(default_logger, msg);
  end procedure;

  procedure error(msg : string) is
  begin
    error(default_logger, msg);
  end procedure;

  procedure failure(msg : string) is
  begin
    failure(default_logger, msg);
  end procedure;

end package body;

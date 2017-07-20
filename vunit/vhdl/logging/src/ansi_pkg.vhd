-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this file,
-- You can obtain one at http://mozilla.org/MPL/2.0/.
--
-- Copyright (c) 2017, Lars Asplund lars.anders.asplund@gmail.com

use std.textio.all;

package ansi_pkg is
  type ansi_colors_t is (
    no_color,

    black,
    red,
    green,
    yellow,
    blue,
    magenta,
    cyan,
    white,

    -- Non standard foregrounds
    lightblack,
    lightred,
    lightgreen,
    lightyellow,
    lightblue,
    lightmagenta,
    lightcyan,
    lightwhite
    );

  type ansi_styles_t is (
    dim,
    normal,
    bright
    );

  function colorize(msg : string;
                    fg : ansi_colors_t := no_color;
                    bg : ansi_colors_t := no_color;
                    style : ansi_styles_t := normal) return string;

  procedure ansi_color_demo;
end package;

package body ansi_pkg is
  type color_to_code_t is array (ansi_colors_t range <>) of integer;
  type style_to_code_t is array (ansi_styles_t range <>) of integer;

  constant color_to_code : color_to_code_t := (
    no_color => 39,
    black => 30,
    red => 31,
    green => 32,
    yellow => 33,
    blue => 34,
    magenta => 35,
    cyan => 36,
    white => 37,

    -- Non standard foregrounds
    lightblack => 90,
    lightred => 91,
    lightgreen => 92,
    lightyellow => 93,
    lightblue => 94,
    lightmagenta => 95,
    lightcyan => 96,
    lightwhite => 97);

  constant style_to_code : style_to_code_t := (
    bright => 1,
    dim => 2,
    normal => 22);

  function colorize(msg : string;
                    fg : ansi_colors_t := no_color;
                    bg : ansi_colors_t := no_color;
                    style : ansi_styles_t := normal) return string is
  begin
    if fg = no_color and bg = no_color and style = normal then
      return msg;
    else
      return (character'val(27) & '[' &
              integer'image(style_to_code(style)) & ';' &
              integer'image(color_to_code(fg)) & ';' &
              integer'image(color_to_code(bg)+10) & 'm' &
              msg &
              -- Reset all
              character'val(27) & '[' & integer'image(0) & 'm');
    end if;
  end;

  procedure ansi_color_demo is
    variable l : line;
  begin
    for fg in ansi_colors_t'low to ansi_colors_t'high loop
      for bg in ansi_colors_t'low to ansi_colors_t'high loop
        for style in ansi_styles_t'low to ansi_styles_t'high loop
          write(l, colorize(
            "<" &
            "fg=" & ansi_colors_t'image(fg) & ", " &
            "bg=" & ansi_colors_t'image(bg) & ", " &
            "style=" & ansi_styles_t'image(style) &
            ">",
            fg, bg, style));
        end loop;
        writeline(output, l);
      end loop;
    end loop;
  end procedure;

end package body;

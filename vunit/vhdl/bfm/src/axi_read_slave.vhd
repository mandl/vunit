-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this file,
-- You can obtain one at http://mozilla.org/MPL/2.0/.
--
-- Copyright (c) 2017, Lars Asplund lars.anders.asplund@gmail.com

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.axi_pkg.all;
use work.axi_private_pkg.all;
use work.queue_pkg.all;
use work.memory_pkg.all;
use work.message_pkg.all;

entity axi_read_slave is
  generic (
    axi_slave : axi_slave_t;
    memory : memory_t);
  port (
    aclk : in std_logic;

    arvalid : in std_logic;
    arready : out std_logic;
    arid : in std_logic_vector;
    araddr : in std_logic_vector;
    arlen : in std_logic_vector;
    arsize : in std_logic_vector;
    arburst : in axi_burst_type_t;

    rvalid : out std_logic;
    rready : in std_logic;
    rid : out std_logic_vector;
    rdata : out std_logic_vector;
    rresp : out axi_resp_t;
    rlast : out std_logic
    );
end entity;

architecture a of axi_read_slave is
  shared variable self : axi_slave_private_t;
  signal local_event : event_t := no_event;
begin

  main : process
  begin
    -- Static Error checking
    assert arid'length = rid'length report "arid vs rid data width mismatch";
    self.init(axi_slave, rdata);
    main_loop(self, event);
    wait;
  end process;

  address_channel(self,
                  local_event,
                  aclk,
                  arvalid,
                  arready,
                  arid,
                  araddr,
                  arlen,
                  arsize,
                  arburst);

  read_data : process
    variable burst : axi_burst_t;
    variable address : integer;
    variable idx : integer;
    variable msg : msg_t;
  begin
    -- Initialization
    rvalid <= '0';
    rid <= (rid'range => '0');
    rdata <= (rdata'range => '0');
    rresp <= (rresp'range => '0');
    rlast <= '0';

    wait until self.is_initialized and rising_edge(aclk);

    loop
      recv(local_event, self.get_addr_inbox, msg);
      burst := pop_axi_burst(msg.data);
      recycle(msg);

      rid <= std_logic_vector(to_unsigned(burst.id, rid'length));
      rdata <= (rdata'range => '0');
      rresp <= axi_resp_ok;

      address := burst.address;

      for i in 0 to burst.length-1 loop
        for j in 0 to burst.size-1 loop
          idx := (address + j) mod self.data_size;
          rdata(8*idx+7 downto 8*idx) <= std_logic_vector(to_unsigned(read_byte(memory, address+j), 8));
        end loop;

        if burst.burst_type = axi_burst_type_incr then
          address := address + burst.size;
        end if;

        if i = burst.length - 1 then
          rlast <= '1';
        else
          rlast <= '0';
        end if;

        rvalid <= '1';
        wait until (rvalid and rready) = '1' and rising_edge(aclk);
        rvalid <= '0';
      end loop;

    end loop;
  end process;
end architecture;

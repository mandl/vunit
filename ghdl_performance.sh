set -ex

# Compile
rm -rf vunit_lib
rm -rf osvvm
mkdir vunit_lib
mkdir osvvm
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib --workdir=vunit_lib vunit/vhdl/vhdl/src/lang/lang.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib vunit/vhdl/string_ops/src/string_ops.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib vunit/vhdl/path/src/path.vhd
ghdl -a --std=08 --work=osvvm --workdir=osvvm vunit/vhdl/osvvm/VendorCovApiPkg.vhd
ghdl -a --std=08 --work=osvvm --workdir=osvvm vunit/vhdl/osvvm/TranscriptPkg.vhd
ghdl -a --std=08 --work=osvvm --workdir=osvvm vunit/vhdl/osvvm/TextUtilPkg.vhd
ghdl -a --std=08 --work=osvvm --workdir=osvvm vunit/vhdl/osvvm/NamePkg.vhd
ghdl -a --std=08 --work=osvvm --workdir=osvvm vunit/vhdl/osvvm/OsvvmGlobalPkg.vhd
ghdl -a --std=08 --work=osvvm --workdir=osvvm vunit/vhdl/osvvm/AlertLogPkg.vhd
ghdl -a --std=08 --work=osvvm --workdir=osvvm vunit/vhdl/osvvm/TbUtilPkg.vhd
ghdl -a --std=08 --work=osvvm --workdir=osvvm vunit/vhdl/osvvm/SortListPkg_int.vhd
ghdl -a --std=08 --work=osvvm --workdir=osvvm vunit/vhdl/osvvm/ResolutionPkg.vhd
ghdl -a --std=08 --work=osvvm --workdir=osvvm vunit/vhdl/osvvm/RandomBasePkg.vhd
ghdl -a --std=08 --work=osvvm --workdir=osvvm vunit/vhdl/osvvm/RandomPkg.vhd
ghdl -a --std=08 --work=osvvm --workdir=osvvm vunit/vhdl/osvvm/MessagePkg.vhd
ghdl -a --std=08 --work=osvvm --workdir=osvvm vunit/vhdl/osvvm/MemoryPkg.vhd
ghdl -a --std=08 --work=osvvm --workdir=osvvm vunit/vhdl/osvvm/CoveragePkg.vhd
ghdl -a --std=08 --work=osvvm --workdir=osvvm vunit/vhdl/osvvm/OsvvmContext.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/logging/src/log_types.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/logging/src/log_formatting.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/logging/src/log_special_types200x.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/logging/src/log_base_api.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/logging/src/log_base.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/logging/src/log_api.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/logging/src/log.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/data_types/src/string_ptr_pkg.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/data_types/src/integer_vector_ptr_pkg.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/data_types/src/queue_pkg.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/data_types/src/integer_array_pkg.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/data_types/src/array_pkg.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/core/src/stop_api.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/core/src/stop_body_2008.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/core/src/core_pkg.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/com/src/com_types.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/com/src/com_api.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/check/src/check_types.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/check/src/check_special_types200x.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/check/src/check_base_api.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/check/src/check_base.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/check/src/check_api.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/dictionary/src/dictionary.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/run/src/run_types.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/run/src/run_special_types200x.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/run/src/run_base_api.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/run/src/run_base.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/run/src/run_api.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/vunit_run_context.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/vunit_context.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/random/src/random_pkg.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/data_types/src/string_ptr_pool_pkg.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/data_types/src/integer_vector_ptr_pool_pkg.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/data_types/src/queue_pool_pkg.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/data_types/src/data_types_context.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/com/src/com_support.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/com/src/com_std_codec_builder.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/com/src/com_debug_codec_builder.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/com/src/com_string.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/com/src/com_codec_api.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/com/src/com_string_payload.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/com/src/com_messenger.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/com/src/com_common.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/com/src/com_deprecated.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/com/src/com_context.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/com/src/com_codec.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/com/src/com.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/run/src/run.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/check/src/check.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/bfm/src/fail_pkg.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/bfm/src/message_types_pkg.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/bfm/src/sync_pkg.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/bfm/test/tb_sync_pkg.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/bfm/src/stream_pkg.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/bfm/src/uart_pkg.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/bfm/src/uart_slave.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/bfm/src/uart_master.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/bfm/test/tb_uart.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/bfm/src/memory_pkg.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/bfm/test/tb_memory.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/bfm/src/bus_pkg.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/bfm/src/ram_master.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/bfm/test/tb_ram_master.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/bfm/src/bus2memory.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/bfm/test/tb_bus_pkg.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/bfm/src/axi_stream_pkg.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/bfm/src/axi_stream_slave.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/bfm/src/axi_stream_master.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/bfm/test/tb_axi_stream.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/bfm/src/axi_pkg.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/bfm/src/bfm_context.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/bfm/src/axi_private_pkg.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/bfm/src/axi_write_slave.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/bfm/test/tb_axi_write_slave.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/bfm/src/axi_read_slave.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/bfm/test/tb_axi_read_slave.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/bfm/src/axi_lite_master.vhd
ghdl -a --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm vunit/vhdl/bfm/test/tb_axi_lite_master.vhd

# Run
rm -rf tb_output
mkdir tb_output
ghdl --elab-run --std=08 --work=vunit_lib --workdir=vunit_lib -Posvvm tb_axi_stream a \
     -grunner_cfg="active python runner : true,enabled_test_cases : test read before write,output path : tb_output"\
     --assert-level=error

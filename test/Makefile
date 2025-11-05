SIM ?= icarus
TOPLEVEL_LANG ?= verilog

# Nguồn RTL
VERILOG_SOURCES := $(abspath ../src/tt_um_sensor_hub_top.v ../src/uart_tx.v ../src/adc8_fake.v)

TOPLEVEL := tt_um_sensor_hub_top
MODULE   := test
COCOTB_RESOLVE_X := ZEROS

# Kết quả junit (CI cần file này)
export COCOTB_RESULTS_FILE := $(PWD)/results.xml

include $(shell cocotb-config --makefiles)/Makefile.sim

.PHONY: sim
sim: clean
	$(MAKE) SIM=$(SIM) TOPLEVEL=$(TOPLEVEL) MODULE=$(MODULE)

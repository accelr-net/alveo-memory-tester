TOPLEVEL_LANG ?= verilog

PWD=$(shell pwd)

export PYTHONPATH := $(PWD)/../model:$(PYTHONPATH)

# VERILOG_SOURCES  = $(PWD)/../hdl/mem_read.sv
VERILOG_SOURCES  = $(PWD)/../../../../fpga/alveo_mem_test_experiments/mem_read_write.sv
VERILOG_SOURCES += $(PWD)/../../../../fpga/alveo_mem_test_experiments/mem_read.sv
VERILOG_SOURCES += $(PWD)/../../../../fpga/alveo_mem_test_experiments/mem_write.sv


TOPLEVEL := mem_read_write
MODULE   := mem_read_write_testbench

ifeq ($(HWDEBUG), 1)
	COMPILE_ARGS := -D DEBUG
endif

include $(shell cocotb-config --makefiles)/Makefile.sim
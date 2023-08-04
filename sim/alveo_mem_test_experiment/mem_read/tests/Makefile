TOPLEVEL_LANG ?= verilog

PWD=$(shell pwd)

export PYTHONPATH := $(PWD)/../model:$(PYTHONPATH)

# VERILOG_SOURCES  = $(PWD)/../hdl/mem_read.sv
VERILOG_SOURCES += $(PWD)/../../../../fpga/alveo_mem_test_experiments/mem_read.sv

TOPLEVEL := mem_read
MODULE   := mem_read_testbench

ifeq ($(HWDEBUG), 1)
	COMPILE_ARGS := -D DEBUG
endif

include $(shell cocotb-config --makefiles)/Makefile.sim
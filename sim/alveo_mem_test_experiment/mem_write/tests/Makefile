TOPLEVEL_LANG ?= verilog

PWD=$(shell pwd)
VERILOG_PATH=$(PWD)/../../../../fpga/alveo_mem_test_experiments

export PYTHONPATH := $(PWD)/../model:$(PYTHONPATH)

# VERILOG_SOURCES  = $(PWD)/../hdl/mem_write.sv
VERILOG_SOURCES += $(VERILOG_PATH)/mem_write.sv

TOPLEVEL := mem_write
MODULE   := mem_write_testbench

ifeq ($(HWDEBUG), 1)
	COMPILE_ARGS := -D DEBUG
endif

include $(shell cocotb-config --makefiles)/Makefile.sim
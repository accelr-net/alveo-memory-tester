export CPP_MODEL_HOME ?= $(PWD)/../../../../cpp/alveo_mem_test_experiments
export COMMON_HOME = $(PWD)/../../../../cpp/common/

export DEBUG ?= false
all:
	python setup.py build_ext --inplace

test:
	python mem_write_test.py

clean:
	rm -rf __pycache__
	rm -rf common
	rm -rf *.so
	rm -rf *.o
	rm -rf build
	rm -rf *.cpp
	rm -rf ../../common/*.cpp
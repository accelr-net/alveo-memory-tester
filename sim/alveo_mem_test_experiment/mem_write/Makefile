export CPP_MODEL_HOME = $(PWD)/../../../cpp/alveo_mem_test_experiments
export COMMON_HOME = $(PWD)/../../../cpp/common/
#export SOLR_HOME ?= $(PWD)/../../../solrprivate/
#export INDEX_PATH ?= solr/packaging/build/solr-10.0.0-SNAPSHOT/server/solr/configsets/sample_techproducts_configs/data/index/
export DEBUG ?= false
export HWDEBUG ?= 0

.PHONY: clean	#says clean is not a target with a dependency "just run it, it's a command"
.PHONY: all model tests
all: model tests

model: 
	$(MAKE) -C model CPP_MODEL_HOME=$(CPP_MODEL_HOME) \
						COMMON_HOME=$(COMMON_HOME) \
						DEBUG=$(DEBUG)

tests: model
	$(MAKE) -C tests SIM=icarus

clean:
	rm -rf model/*.so
	rm -rf model/__pycache__
	rm -rf model/build
	rm -rf model/*.cpp 
	rm -rf model/common/
	rm -rf tests/__pycache__
	rm -rf tests/*.vcd
	rm -rf tests/results.xml
	rm -rf tests/sim_build
	rm -rf ../common/*.cpp

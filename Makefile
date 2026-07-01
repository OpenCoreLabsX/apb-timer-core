VERILATOR_BIN ?= C:/msys64/usr/bin/perl C:/msys64/ucrt64/bin/verilator
VERILATOR_FLAGS ?= --language 1800-2017

FILELIST ?= filelist.f
RTL_FILELIST ?= .rtl_filelist.f
TOP_MODULE ?= apb_timer_wrapper

UVM_TOP ?= apb_timer_tb_top
UVM_TEST ?= apb_timer_smoke_test

MODELSIM_HOME ?= /c/intelFPGA/18.1/modelsim_ase
MODELSIM_BIN ?= $(MODELSIM_HOME)/win32aloem
UVM_SRC ?= C:/intelFPGA/18.1/modelsim_ase/verilog_src/uvm-1.2/src
UVM_DEFINES ?= +define+UVM_NO_DPI+UVM_NO_RELNOTES

VLIB ?= $(MODELSIM_BIN)/vlib.exe
VLOG ?= $(MODELSIM_BIN)/vlog.exe
VSIM ?= $(MODELSIM_BIN)/vsim.exe
VSIM_FLAGS ?= -suppress 19 -suppress 8315

SIM_DIR ?= sim
RUN_LOG ?= $(SIM_DIR)/run_check.log

.PHONY: all lint compile run coverage clean check-modelsim

all: lint compile

$(RTL_FILELIST): $(FILELIST)
	@grep -v '^uvm/' $(FILELIST) | grep -v '^+incdir+uvm/' > $@

check-modelsim:
	@test -x $(VLIB) || { echo "ERROR: missing $(VLIB). Set MODELSIM_HOME or VLIB."; exit 127; }
	@test -x $(VLOG) || { echo "ERROR: missing $(VLOG). Set MODELSIM_HOME or VLOG."; exit 127; }
	@test -x $(VSIM) || { echo "ERROR: missing $(VSIM). Set MODELSIM_HOME or VSIM."; exit 127; }
	@test -f $(UVM_SRC)/uvm_pkg.sv || { echo "ERROR: missing $(UVM_SRC)/uvm_pkg.sv. Set UVM_SRC."; exit 127; }

lint: $(RTL_FILELIST)
	$(VERILATOR_BIN) $(VERILATOR_FLAGS) --lint-only -f $(RTL_FILELIST) --top-module $(TOP_MODULE)

compile: check-modelsim
	@test -d work || $(VLIB) work
	$(VLOG) -sv $(UVM_DEFINES) +incdir+$(UVM_SRC) -work work $(UVM_SRC)/uvm_pkg.sv
	$(VLOG) -sv $(UVM_DEFINES) +acc +incdir+$(UVM_SRC) -work work -f $(FILELIST)

run: compile
	@mkdir -p $(SIM_DIR)
	$(VSIM) -c $(VSIM_FLAGS) $(UVM_TOP) +UVM_TESTNAME=$(UVM_TEST) +UVM_NO_RELNOTES -l $(RUN_LOG) -do "run -all; quit -f"
	@grep -q 'UVM_ERROR :    0' $(RUN_LOG) || { echo "UVM run failed: see $(RUN_LOG)"; exit 1; }
	@grep -q 'UVM_FATAL :    0' $(RUN_LOG) || { echo "UVM run failed: see $(RUN_LOG)"; exit 1; }
	@echo "Test passed."

coverage: check-modelsim
	@mkdir -p $(SIM_DIR)
	@test -d work || $(VLIB) work
	$(VLOG) -sv $(UVM_DEFINES) +incdir+$(UVM_SRC) -work work $(UVM_SRC)/uvm_pkg.sv
	$(VLOG) -sv $(UVM_DEFINES) +acc +cover +incdir+$(UVM_SRC) -work work -f $(FILELIST)
	$(VSIM) -c $(VSIM_FLAGS) -coverage $(UVM_TOP) +UVM_TESTNAME=$(UVM_TEST) +UVM_NO_RELNOTES -l $(RUN_LOG) -do "coverage save -onexit $(SIM_DIR)/coverage.ucdb; run -all; quit -f"
	@grep -q 'UVM_ERROR :    0' $(RUN_LOG) || { echo "UVM run failed: see $(RUN_LOG)"; exit 1; }
	@grep -q 'UVM_FATAL :    0' $(RUN_LOG) || { echo "UVM run failed: see $(RUN_LOG)"; exit 1; }
	@echo "Generating HTML coverage report..."
	$(MODELSIM_BIN)/vcover.exe report -html -htmldir $(SIM_DIR)/covhtmlreport $(SIM_DIR)/coverage.ucdb
	@echo "Coverage report generated at $(SIM_DIR)/covhtmlreport/index.html"

clean:
	rm -rf obj_dir work $(SIM_DIR) reports
	rm -f $(RTL_FILELIST)
	rm -f transcript tr_db.log vsim.wlf modelsim.ini
	rm -f *.wlf *.vstf *.ucdb *.log
	rm -rf wlft* covhtmlreport

RTL_DIR   := rtl
TB_DIR    := tb
SYNTH_DIR := synth
STA_DIR   := sta

TOP := pico_top

RTL_FILES := \
	$(RTL_DIR)/pico_alu.v \
	$(RTL_DIR)/pico_regfile.v \
	$(RTL_DIR)/pico_pc.v \
	$(RTL_DIR)/pico_ir.v \
	$(RTL_DIR)/pico_decoder.v \
	$(RTL_DIR)/pico_control_fsm.v \
	$(RTL_DIR)/pico_datapath.v \
	$(RTL_DIR)/pico_core.v \
	$(RTL_DIR)/pico_top.v

.PHONY: lint synth sta clean

lint:
	verilator --lint-only -Wall -I$(RTL_DIR) $(RTL_FILES)

synth:
	yosys -s $(SYNTH_DIR)/scripts/synth.ys

sta:
	sta $(STA_DIR)/scripts/run_sta.tcl

clean:
	rm -rf obj_dir
	rm -rf sim/build/*
	rm -rf synth/results/*
	rm -rf sta/results/*
	rm -rf waveforms/*

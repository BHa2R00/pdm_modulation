pdm_lint: ../rtl/pdm.v 
	verilator --lint-only --top-module pdm_modulator ../rtl/pdm.v 
	verilator --lint-only --top-module audio_pdm_modulator ../rtl/pdm.v 
	verilator --lint-only --top-module pdm_demodulator ../rtl/pdm.v 
	verilator --lint-only --top-module audio_pdm_demodulator ../rtl/pdm.v 

pdm_tb: ../rtl/pdm.v ../tb/pdm_tb.sv 
	rm -rfv pdm_tb.vcd
	iverilog ../rtl/pdm.v ../tb/pdm_tb.sv 
	./a.out
	gtkwave ./pdm_tb.vcd

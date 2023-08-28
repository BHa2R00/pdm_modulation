pdm_lint: ../rtl/pdm.v 
	verilator --lint-only --top-module pdm ../rtl/pdm.v 
	verilator --lint-only --top-module pddm ../rtl/pdm.v 

pdm_tb: ../rtl/pdm.v ../tb/pdm_tb.sv 
	rm -rfv pdm_tb.vcd
	iverilog ../rtl/pdm.v ../tb/pdm_tb.sv 
	./a.out
	gtkwave ./pdm_tb.vcd

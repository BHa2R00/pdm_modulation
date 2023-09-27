pdm_lint: ../rtl/pdm.v 
	verilator --lint-only --top-module pdm ../rtl/pdm.v 
	verilator --lint-only --top-module pddm ../rtl/pdm.v 

pdm_tb: ../rtl/pdm.v ../tb/pdm_tb.sv 
	rm -rfv pdm_tb.vcd
	iverilog ../rtl/pdm.v ../tb/pdm_tb.sv 
	./a.out
	gtkwave ./pdm_tb.vcd

dsm_lint: ../rtl/dsm.v 
	verilator --lint-only --top-module dsm ../rtl/dsm.v 
	verilator --lint-only --top-module dsdm ../rtl/dsm.v 
	verilator --lint-only --top-module audio_dsm ../rtl/dsm.v 
	verilator --lint-only --top-module audio_dsdm ../rtl/dsm.v 
	verilator --lint-only --top-module ir_dsm ../rtl/dsm.v 
	verilator --lint-only --top-module ir_dsdm ../rtl/dsm.v 
	verilator --lint-only --top-module dsck ../rtl/dsm.v 
	verilator --lint-only --top-module dsmdm ../rtl/dsm.v 

dsm_tb: ../rtl/dsm.v ../tb/dsm_tb.sv 
	cc ../src/wave2memb.c -o ../bin/wave2memb
	rm -rfv dsm_tb.fst
	${hdl_simulator} ../rtl/dsm.v ../tb/dsm_tb.sv 
	vvp ./a.out -fst
	gtkwave ./dsm_tb.fst

ir_tb: ../rtl/dsm.v ../tb/ir_tb.sv 
	rm -rfv ir_tb.fst
	${hdl_simulator} ../rtl/dsm.v ../tb/ir_tb.sv 
	vvp ./a.out -fst
	gtkwave ./ir_tb.fst

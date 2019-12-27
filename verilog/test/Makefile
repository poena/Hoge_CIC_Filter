
all: comp run

comp:
	vcs -full64 -debug_pp +vcs+dumpvars+cic_test.vcd -sverilog test_top.sv ../cic_filter.sv ../comb.sv ../integrator.sv
	#vcs -full64 -debug_pp +vpdfile+cic_test.vpd -sverilog test_top.sv ../cic_filter.sv ../comb.sv ../integrator.sv

run:
	./simv
	#vcd2vpd cic_test.vcd cic_test.vpd

clean:
	rm *.vpd *.vcd

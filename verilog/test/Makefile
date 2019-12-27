
all: comp run

comp:
	vcs -full64 -debug_pp +vcs+vcdpluson +memcbk -sverilog test_top.sv ../cic_filter.sv ../comb.sv ../integrator.sv |tee comp.log

run:
	./simv -vpd_file cic_test.vpd |tee run.log

clean:
	rm *.vpd *.vcd

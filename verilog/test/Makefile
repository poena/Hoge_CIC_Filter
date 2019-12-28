OS := 4

all: comp run

comp:
	vcs -full64 -debug_pp +vcs+vcdpluson +memcbk +define+OS=${OS} -sverilog ./test_top.sv ../src/cic_filter.sv ../src/comb.sv ../src/integrator.sv |tee comp.log

run:
	./simv -vpd_file cic_test.vpd |tee run.log

analysis:
	python ../script/dbfft.py

gui:
	dve -full64

clean:
	rm *.vpd *.vcd

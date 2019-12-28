OS := 4


test: comp run

comp:
	vcs -full64 -debug_pp +vcs+vcdpluson +memcbk +define+OS=${OS} -sverilog ./test_top.sv ../src/cic_filter.sv ../src/comb.sv ../src/integrator.sv |tee comp.log

run:
	./simv -vpd_file cic_test.vpd |tee run.log

analysis:
	python ../script/reg_ana.py

gui:
	dve -full64

LAST := 6
NUMBERS := $(shell seq 0 ${LAST})
JOBS := $(addprefix job,${NUMBERS})
.PHONY: all ${JOBS}
regression: ${JOBS} ; echo "$@ success"
${JOBS}: job% : ; vcs -full64 -debug_pp +vcs+vcdpluson +memcbk +define+OS=$* -sverilog ./test_top.sv ../src/cic_filter.sv ../src/comb.sv ../src/integrator.sv |tee comp.log ; ./simv -vpd_file cic_test.vpd |tee run.log

clean:
	rm *.vpd *.vcd *.csv


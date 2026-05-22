vlog list.svh
#vopt top +cover=fcbest +acc -o test
vsim -novopt -suppress 12110 top -sv_seed 48596
#vsim -suppress 12110 test
#coverage save -onexit test.ucdb
#add wave -position insertpoint -radix hex sim:/top/dut/*
do wave.do
run -all

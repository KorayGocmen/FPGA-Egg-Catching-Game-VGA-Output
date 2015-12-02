# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog EggCatcherTop.v

#load simulation using mux as the top level simulation module
vsim -L altera_mf_ver -t 1ns EggCatcherTop

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}
add wave -position 56  sim:/EggCatcherTop/egg1/w_in_y
add wave -position 55  sim:/EggCatcherTop/egg1/in_y
add wave -position 56  sim:/EggCatcherTop/black/count_x
add wave -position 50  sim:/EggCatcherTop/black/count_y
#add wave -position 43  sim:/EggCatcherTop/plyr/plyr/addr_y
#add wave -position 43  sim:/EggCatcherTop/plyr/plyr/addr_x
add wave -position 50  sim:/EggCatcherTop/egg2/w_out_y

#force -freeze sim:/EggCatcherTop/CLOCK_50 1 0, 0 {50 ps} -r 100
#force -freeze sim:/EggCatcherTop/CLOCK_50 1 0, 0 {25 ns} -r {50 }
force -freeze sim:/EggCatcherTop/CLOCK_50 1 0, 0 {2 ns} -r 5

force {KEY[0]} 0
run 1000ns

force {KEY[0]} 1
run 4500000ns

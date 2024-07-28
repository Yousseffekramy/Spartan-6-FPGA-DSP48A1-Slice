vlib work

vlog DSP48A1Module.v DSP48A1Module_tb.v

vsim -voptargs=+acc work.DSP48A1Module_tb

# add Internal signals
add wave DUT/*

run -all


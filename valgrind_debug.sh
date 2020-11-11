#!/bin/bash

../iverilog_src/my_iverilog/ivlpp/ivlpp $1 > temp.v #~/project/hardware/iverilog-test-case/case1011/case2/has_multi_driver/case2/multiply_large.v > temp.v #4way_4word.v > temp.v 
valgrind --tool=callgrind ../my_iverilog_src/iverilog/ivl temp.v
ls -lt |awk 'NR==2{print}' |  awk '{printf $9}'  | xargs kcachegrind {} &


# ../iverilog_src/iverilog-dev/ivlpp/ivlpp $1 > temp.v #~/project/hardware/iverilog-test-case/case1011/case2/has_multi_driver/case2/multiply_large.v > temp.v #4way_4word.v > temp.v 
# valgrind --tool=callgrind ../iverilog_src/iverilog-dev/ivl temp.v
# ls -lt |awk 'NR==2{print}' |  awk '{printf $9}'  | xargs kcachegrind {} &

#kcachegrind callgrind.out.3427
#!/bin/sh

work_dir=${1:-'.'}
count=0;

echo "" > temp.txt

case_list=`find $work_dir -name "*.v"`
for case in $case_list
    do
        echo $case >>temp.txt
        echo $case

        time iverilog $case >>temp.txt
        # iverilog $case -d driverConflict 2&>>temp.txt # danger: mem overflow
        count=$(($count+1))
    done

echo "total "$count "cases"
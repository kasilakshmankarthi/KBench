#!/bin/bash
echo "========================"
echo "Running Hackbench"
ulimit -n 65536

echo "set socket affinity firstly!"
echo "running process mode"
rm -rf log.hackbench*

for i in $(seq 4 4 64); do echo "running process $i"; ./hackbench $i process 50000 >>log.hackbench.process; done

echo "running thread mode"


for i in $(seq 4 4 64); do echo "running thread $i"; ./hackbench $i thread 50000 >>log.hackbench.thread; done

echo "process scalability performance"

grep "Time" ./log.hackbench.proces

echo "thread shceduling scalability performance"

grep "Time" ./log.hackbench.thread



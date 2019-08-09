#!/bin/bash
echo "Running Hackbench to collect process and thread 8, 64 and 128"
ulimit -n 65536

echo "---------------------------------------" | tee -a log.hackbench.summary
echo "start of test: `date`" | tee -a log.hackbench.summary
echo "process " | tee -a log.hackbench.summary

./hackbench 8 process 1000 | tee -a log.hackbench.summary
./hackbench 64 process 1000 | tee -a log.hackbench.summary 
./hackbench 128 process 1000 | tee -a log.hackbench.summary 

echo "thread " | tee -a log.hackbench.summary

./hackbench 8 thread 1000 | tee -a log.hackbench.summary 
./hackbench 64 thread 1000 | tee -a log.hackbench.summary 
./hackbench 128 thread 1000 | tee -a log.hackbench.summary 




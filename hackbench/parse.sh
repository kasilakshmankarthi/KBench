#!/bin/bash

grep Running log.hackbench.thread | cut -d'(' -f2 | cut -d' ' -f2| cut -d')' -f
grep Time log.hackbench.thread | cut -d':' -f2

echo "Process"
grep Running log.hackbench.process | cut -d'(' -f2 | cut -d' ' -f2| cut -d')' -f1
grep Time log.hackbench.process | cut -d':' -f2 

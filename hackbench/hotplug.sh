#!/bin/bash -u

if [[ "$EUID" -ne 0 ]]; then 
	echo "Please run as root"
    exit
fi

if [[ $# -ne 3 ]]; then
	echo "Usage $0 <cpu-begin> <cpu-end> <on|off>"
	exit
fi

cpubegin=$1
cpuend=$2
switch="${3}"
cpumax=$(nproc)

if [[ $cpubegin -gt $cpuend ]]; then
	echo "Invalid cpu numbers"
	exit
fi

if [[ "${switch}" != "on" ]] && [[ "${switch}" != "off" ]]; then
	echo "Invalid mode <on|off>"
	exit
fi

for i in $(seq $cpubegin $cpuend); do 
	if [[ "${switch}" == "on" ]]; then
		echo "Bringing cpu ${i} online."
		echo "1" > /sys/devices/system/cpu/cpu${i}/online;
	else
		echo "Powering down cpu ${i}."
		echo "0" > /sys/devices/system/cpu/cpu${i}/online;
	fi
done
echo "---------------------"
echo "Total online cpus: $(nproc)"
echo "---------------------"

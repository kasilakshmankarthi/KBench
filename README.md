# Linux System Construct Benchmarking

Add benchmarks for Performance model simulation/FPGA Emulation studies </br>
======================================================================= </br>

(1) tmphammer [To study lock performance] </br>
(2) syncTest [To study different atomic lock implementation performance in arm64] </br>
(3) ctx_latr [To study content switch performance] </br>
(4) ipc-bench [Upstream clone from https://github.com/rigtorp/ipc-bench] </br>
(5) hackbench [To study kernel scheduler] </br>
(6) kproc [Pulled proc tests from lmbench and run with fixed iterations] </br>

Scripts </br>
====== </br>
(1) run_emulation.sh [Script to program and boot FPGA with various configurations] </br>
(2) run_parent.sh [Script to run the individual benchmark in FPGA] </br>


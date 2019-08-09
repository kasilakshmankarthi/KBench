ARCH=$1
DEV=$2

echo "ARCH" $ARCH
echo  "DEVICE" $DEV

adb push binaries/syncTest.${ARCH}.elf /data/local/tmp/
adb shell chmod +x /data/local/tmp/syncTest.${ARCH}.elf
adb push binaries/syncTest.${ARCH}-lse.elf /data/local/tmp/
adb shell chmod +x /data/local/tmp/syncTest.${ARCH}-lse.elf

adb push envSetup.sh /data/local/tmp/
adb shell chmod +x /data/local/tmp/envSetup.sh
#adb shell "/data/local/tmp/envSetup.sh $DEV"

if [[ ${DEV} == "universal" || ${DEV} == "smdk" ]]; then
    rm -rf cpiter_${DEV}_big.score
    rm -rf cpiter_${DEV}_mid.score
    rm -rf cpiter_${DEV}_low.score

    ##Cheetah
    adb shell "echo Running at 2.47GHz"
    adb shell /data/local/tmp/syncTest.${ARCH}.elf --cpu_to_lock 6 --locked_freq 2470000 > cpiter_${DEV}_big.score
    adb shell /data/local/tmp/syncTest.${ARCH}-lse.elf --cpu_to_lock 6 --locked_freq 2470000 >> cpiter_${DEV}_big.score

    ###Parse and show the results
    grep "us" c*${DEV}_big.score | grep -Eo '.*:'
    grep  "average cycles per iteration" c*${DEV}_big.score | grep -Eo '[0-9]*\.[0-9]*'

    ###A75
    adb shell "echo Running at 2.314GHz"
    adb shell /data/local/tmp/syncTest.${ARCH}.elf --cpu_to_lock 5 --locked_freq 2314000 > cpiter_${DEV}_mid.score
    adb shell /data/local/tmp/syncTest.${ARCH}-lse.elf --cpu_to_lock 5 --locked_freq 2314000 >> cpiter_${DEV}_mid.score

    ###Parse and show the results
    grep "us" c*${DEV}_mid.score | grep -Eo '.*:'
    grep  "average cycles per iteration" c*${DEV}_mid.score | grep -Eo '[0-9]*\.[0-9]*'

    ###A55
    adb shell "echo Running at 1.95GHz"
    adb shell /data/local/tmp/syncTest.${ARCH}.elf --cpu_to_lock 0 --locked_freq 1950000 > cpiter_${DEV}_low.score
    adb shell /data/local/tmp/syncTest.${ARCH}-lse.elf --cpu_to_lock 0 --locked_freq 1950000 >> cpiter_${DEV}_low.score

    ###Parse and show the results
    grep "us" c*${DEV}_low.score | grep -Eo '.*:'
    grep  "average cycles per iteration" c*${DEV}_low.score | grep -Eo '[0-9]*\.[0-9]*'
fi

if [[ ${DEV} == "sd845" ]]; then
    rm -rf cpiter_${DEV}_big.score
    rm -rf cpiter_${DEV}_low.score

    ##A75 derivative
    adb shell "echo Running at 2.47GHz"
    adb shell /data/local/tmp/syncTest.${ARCH}.elf --cpu_to_lock 6 --locked_freq 2476800 > cpiter_${DEV}_big.score
    adb shell /data/local/tmp/syncTest.${ARCH}-lse.elf --cpu_to_lock 6 --locked_freq 2476800 >> cpiter_${DEV}_big.score

    ###Parse and show the results
    grep "us" c*${DEV}_big.score | grep -Eo '.*:'
    grep  "average cycles per iteration" c*${DEV}_big.score | grep -Eo '[0-9]*\.[0-9]*'

    ###A55
    adb shell "echo Running at 1.76GHz"
    adb shell /data/local/tmp/syncTest.${ARCH}.elf --cpu_to_lock 0 --locked_freq 1766400 > cpiter_${DEV}_low.score
    adb shell /data/local/tmp/syncTest.${ARCH}-lse.elf --cpu_to_lock 0 --locked_freq 1766400 >> cpiter_${DEV}_low.score

    ###Parse and show the results
    grep "us" c*${DEV}_low.score | grep -Eo '.*:'
    grep  "average cycles per iteration" c*${DEV}_low.score | grep -Eo '[0-9]*\.[0-9]*'
fi

if [[ ${DEV} == "mate20" ]]; then
    ###To push the A76 (plus) to 2.6GHz
    ###Push these to the device:
    adb push /sarc-c/spa_secondary/workloads/Geekbenchv5/5.0.0-Drop12/universal/v1/aarch64/geekbench.plar /data/local/tmp
    adb push /sarc-c/spa_secondary/workloads/Geekbenchv5/5.0.0-Drop12/universal/v1/aarch64/geekbench_aarch64 /data/local/tmp
    adb push /sarc-c/spa_secondary/workloads/Geekbenchv5/5.0.0-Drop12/universal/v1/aarch64/libstingray.so /data/local/tmp

    adb shell chmod +x /data/local/tmp/geekbench_aarch64
    ####adb shell export LD_LIBRARY_PATH=/data/local/tmp/

    #####Run a subtest (101.AES) on CPU6 for a long time (10k iterations):
    adb shell LD_LIBRARY_PATH=/data/local/tmp/ taskset -a 80 /data/local/tmp/geekbench_aarch64 --section 1 --workload 101 --iterations 10000&
    sleep 10

    ###Run the benchmark
    ##A76 (plus)
    rm -rf cpiter_${DEV}.score
    adb shell "echo Running at 2.6GHz"
    adb shell /data/local/tmp/syncTest.${ARCH}.elf --cpu_to_lock 6 --locked_freq 2600000 > cpiter_${DEV}.score

    ##A76 (plus)
    adb shell "echo Running at 2.6GHz"
    adb shell /data/local/tmp/syncTest.${ARCH}-lse.elf --cpu_to_lock 6 --locked_freq 2600000 >> cpiter_${DEV}.score

    ###Parse and show the results
    grep "us" c*${DEV}.score | grep -Eo '.*:'
    grep  "average cycles per iteration" c*${DEV}.score | grep -Eo '[0-9]*\.[0-9]*'
fi


DEV=$1
echo  "DEVICE" $DEV

#if [[ ${DEV} == "mate20" ]]; then
    #echo performance > /sys/devices/system/cpu/cpufreq/policy0/scaling_governor
    #echo performance > /sys/devices/system/cpu/cpufreq/policy4/scaling_governor
    #echo performance > /sys/devices/system/cpu/cpufreq/policy4/scaling_governor

    #f_set=2400000
    #echo $f_set > /sys/devices/system/cpu/cpufreq/policy4/scaling_max_freq
    #echo $f_set > /sys/devices/system/cpu/cpufreq/policy4/scaling_min_freq
    #echo $f_set > /sys/devices/system/cpu/cpufreq/policy4/scaling_max_freq
    #echo $f_set > /sys/devices/system/cpu/cpufreq/policy4/scaling_min_freq
    #echo -n "Big core max freq set to "
    #cat  /sys/devices/system/cpu/cpufreq/policy4/scaling_max_freq
    #echo -n "Big core min freq set to "
    #cat /sys/devices/system/cpu/cpufreq/policy4/scaling_min_freq
    #echo -n "Big core cur freq "
#fi

if [[ ${DEV} == "universal" || ${DEV} == "smdk" ]]; then
    ###echo performance > /sys/devices/system/cpu/cpufreq/policy0/scaling_governor
    ###echo performance > /sys/devices/system/cpu/cpufreq/policy4/scaling_governor
    ###echo performance > /sys/devices/system/cpu/cpufreq/policy4/scaling_governor

    f_set=2470000
    echo $f_set > /sys/devices/system/cpu/cpufreq/policy4/scaling_max_freq
    echo $f_set > /sys/devices/system/cpu/cpufreq/policy4/scaling_min_freq
    echo $f_set > /sys/devices/system/cpu/cpufreq/policy4/scaling_max_freq
    echo $f_set > /sys/devices/system/cpu/cpufreq/policy4/scaling_min_freq
    echo -n "Big core max freq set to "
    cat  /sys/devices/system/cpu/cpufreq/policy4/scaling_max_freq
    echo -n "Big core min freq set to "
    cat /sys/devices/system/cpu/cpufreq/policy4/scaling_min_freq
    echo -n "Big core cur freq "
    cat /sys/devices/system/cpu/cpufreq/policy4/scaling_cur_freq

    f_set=2314000
    echo $f_set > /sys/devices/system/cpu/cpufreq/policy4/scaling_max_freq
    echo $f_set > /sys/devices/system/cpu/cpufreq/policy4/scaling_min_freq
    echo $f_set > /sys/devices/system/cpu/cpufreq/policy4/scaling_max_freq
    echo $f_set > /sys/devices/system/cpu/cpufreq/policy4/scaling_min_freq
    echo -n "Mid core max freq set to "
    cat  /sys/devices/system/cpu/cpufreq/policy4/scaling_max_freq
    echo -n "Mid core min freq set to "
    cat /sys/devices/system/cpu/cpufreq/policy4/scaling_min_freq
    echo -n "Mid core cur freq "
    cat /sys/devices/system/cpu/cpufreq/policy4/scaling_cur_freq

    f_set=1950000
    echo $f_set > /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq
    echo $f_set > /sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq
    echo $f_set > /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq
    echo $f_set > /sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq
    echo -n "Little core max freq set to "
    cat  /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq
    echo -n "Little core min freq set to "
    cat /sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq
    echo -n "Little core cur freq "
    cat /sys/devices/system/cpu/cpufreq/policy0/scaling_cur_freq
fi

if [[ ${DEV} == "sd845" ]]; then
    ###echo performance > /sys/devices/system/cpu/cpufreq/policy0/scaling_governor
    ###echo performance > /sys/devices/system/cpu/cpufreq/policy4/scaling_governor
    ###echo performance > /sys/devices/system/cpu/cpufreq/policy4/scaling_governor

    f_set=2474800
    echo $f_set > /sys/devices/system/cpu/cpufreq/policy4/scaling_max_freq
    echo $f_set > /sys/devices/system/cpu/cpufreq/policy4/scaling_min_freq
    echo $f_set > /sys/devices/system/cpu/cpufreq/policy4/scaling_max_freq
    echo $f_set > /sys/devices/system/cpu/cpufreq/policy4/scaling_min_freq
    echo -n "Big core max freq set to "
    cat  /sys/devices/system/cpu/cpufreq/policy4/scaling_max_freq
    echo -n "Big core min freq set to "
    cat /sys/devices/system/cpu/cpufreq/policy4/scaling_min_freq
    echo -n "Big core cur freq "
    cat /sys/devices/system/cpu/cpufreq/policy4/scaling_cur_freq

    f_set=1766400
    echo $f_set > /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq
    echo $f_set > /sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq
    echo $f_set > /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq
    echo $f_set > /sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq
    echo -n "Little core max freq set to "
    cat  /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq
    echo -n "Little core min freq set to "
    cat /sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq
    echo -n "Little core cur freq "
    cat /sys/devices/system/cpu/cpufreq/policy0/scaling_cur_freq
  fi

############################# Readme############################################
# First argument specifies the FPGA type you would like to run

# Second argument is used to set mem_size to quicken the ELK boot process in FPGA

# Third argument is used to reproram FPGA/clocks (or) only clocks. This helps
# in saving time when FPGA has the right visr tag but not the right CPU/SYS clock ratio.
##################################################################################

TYPE=$1
echo "FPGA chosen: [42]/[48] (aw-rumi[]/ft-rumi[]/ft-rumi[]-light/ft-rumi[]-heavy " ${TYPE}

TEST=$2
echo "Test run: " ${TEST}

CMD=$3
echo "Program visr (visr + risr)/Program only clocks (risr): " ${CMD}

####Copy the latest tags released by the Enablement Team
tag_aw42="visr_program_fpgas -verbose -tag amberwing_v2.0_rumi42_p3r36_r1.0_p1.0_b1.0_20161228_MST -config_filename visr.config_May_17_2017_12_52_p3r43_Falkor_4.18.5_hf1_DDR4_sys3.8MHz_cpu13.0MHz"
tag_aw48="visr_program_fpgas -verbose -tag amberwing_v2.0_rumi48_p3r36_r1.0_p1.0_b1.0_20161218_MST -config_filename visr.config_Mar_07_2017_12_08_r43__4.18.0_su_hf_DDR4_sys3.7MHz_cpu4.2MHz"
tag_ft42="visr_program_fpgas -verbose  -tag firetail_rumi42_r34.0_r1.0_p1.0_b1.0_201800302_MST -config_filename visr.config_Mar_27_2018_08_43_42r34_Saphira_20.16.0_L3coh13_SINGLE_MC_sys3.6MHz_cpu13.2MHz"
tag_ft48="visr_program_fpgas -verbose -tag firetail_rumi48_r34.0_r1.1_p1.0_b1.0_20180301_MST -config_filename visr.config_Mar_19_2018_09_41_48r34_Saphira_20.14.0_L3r36prerelease_SINGLE_MC_sys3.9MHz_cpu5.5MHz"

#To find UART console to connect with minicom
#do ~/n_drive/CPUE_repo/firetail/firetail/tests/UART/ttyusb_search.cmm

if [[ ${TEST} == "database" ]]; then
  #Not specifying the memory uses all of 128GB DDR connected to RUMIs
  boot_args="console=ttyAMA0"
else
  boot_args="console=ttyAMA0 mem_size=0x100000000"
fi

#Paths to access files in RUMI vnc
os_drivew="\\magdalena\dcg_modeling_rtp_workloads_share\usr\kasilka\fsimages"
os_drivel="/prj/dcg/modeling/rtp/workloads/share/usr/kasilka/fsimages"
n_drive="/prj/qct/chips/raptor2/rtp/rumi/integration/software/CPUE_repo"

cmm_path="/usr2/rtplabsvc/t32tmp"

###Cleanup T32 sessions
killall t32marm64-qt
killall t32marm64-qt

visr_pdu -jtag_cycle

#####POR CPU/BUS Silicon frequencies
if [[ ${TYPE} == "aw-rumi42" || ${TYPE} == "aw-rumi48" || ${TYPE} == "ft-rumi42" || ${TYPE} == "ft-rumi48" ]]; then
  cpus=2600
  buss=2100
elif [[ ${TYPE} == "ft-rumi42-light" || ${TYPE} == "ft-rumi48-light" ]]; then
  cpus=3100
  buss=2300
elif [[ ${TYPE} == "ft-rumi42-heavy" || ${TYPE} == "ft-rumi48-heavy" ]]; then
   cpus=2800
   buss=2200
fi

#Silicon ratio
cpus_buss_ratio=$(echo "scale=3; ${cpus}/${buss}" | bc)
cpus_buss_ratio=$(echo ${cpus_buss_ratio} | xargs printf "%.*f\n" 2)

#AW Rumi42
configure_aw_rumi42()
{
    local cpur_scale=$1
    local busr_scale=$2
    local cntfrq=$3

    if [[ ${CMD} != "risr" ]]; then
      eval "$tag_aw42"
    fi

    ###CPU/BUS ratio of FPGA match that of Si###
    /usr2/mzimmerm/bin/risr_program_pll3.pl -e -p "s1,s4" -f "${busr_scale},${cpur_scale}"

    echo "cd ${os_drivel}/rtp_linux_environment/Dragonfly/t32/4860
do linux-restart.cmm ${boot_args} pcie=0 console=ttyAMA0 fs_name=${os_drivel}/rtp_linux_environment/fs/kasi.cpio.gz cntfrq_scale=${cntfrq}" > ${cmm_path}/boot.${TYPE}.cmm

    ~/n_drive/CPUE_repo/amberwing/T32_QDF2400/shortcuts/QDF2400_T32_Linux.sh -j `~/bin/query_host_t32`
}

#AW Rumi48
configure_aw_rumi48()
{
    local cpur_scale=$1
    local busr_scale=$2
    local cntfrq=$3

    if [[ ${CMD} != "risr" ]]; then
      eval "$tag_aw48"
    fi

    ###CPU/BUS ratio of FPGA match that of Si###
    /usr2/mzimmerm/bin/risr_program_pll3.pl -e -p "s1,s4" -f "${busr_scale},${cpur_scale}"

      echo "cd ${os_drivel}/rtp_linux_environment/Dragonfly/t32/4860
do linux-restart.cmm ${boot_args} pcie=0 console=ttyAMA0 fs_name=${os_drivel}/rtp_linux_environment/fs/kasi.cpio.gz cntfrq_scale=${cntfrq}" > ${cmm_path}/boot.${TYPE}.cmm

    ~/n_drive/CPUE_repo/amberwing/T32_QDF2400/shortcuts/QDF2400_T32_Linux.sh -j `~/bin/query_host_t32`
}

#FT Rumi42
configure_ft_rumi42()
{
    local cpur_scale=$1
    local busr_scale=$2
    local cntfrq=$3

    if [[ ${CMD} != "risr" ]]; then
      eval "$tag_ft42"
    fi

    ###CPU/BUS ratio of FPGA match that of Si###
    /usr2/mzimmerm/bin/risr_program_pll3.pl -e -p "s1,s4" -f "${busr_scale},${cpur_scale}"

    ###Reduce the qtimer frequency to 32KHz###
    tcsh -c "source /usr2/rtplabsvc/bin/saphira_qtimer_32K"

    echo "cd ${os_drivel}/rtp_linux_environment/Dragonfly/t32/3000
do linux-restart.cmm ${boot_args} pcie=0 fs_name=${os_drivel}/rtp_linux_environment/fs/kasi.cpio.gz cntfrq_scale=${cntfrq}" > ${cmm_path}/boot.${TYPE}.cmm


    ~/n_drive/CPUE_repo/firetail/T32_QDF3000/shortcuts/QDF3000_T32_Linux.sh -j `~/bin/query_host_t32`
}

#FT Rumi48
configure_ft_rumi48()
{
    local cpur_scale=$1
    local busr_scale=$2
    local cntfrq=$3

    if [[ ${CMD} != "risr" ]]; then
      eval "$tag_ft48"
    fi

    ###CPU/BUS ratio of FPGA match that of Si###
    /usr2/mzimmerm/bin/risr_program_pll3.pl -e -p "s1,s4" -f "${busr_scale},${cpur_scale}"

    ###Reduce the qtimer frequency to 32KHz###
    tcsh -c "source /usr2/rtplabsvc/bin/saphira_qtimer_32K"

    echo "cd ${os_drivel}/rtp_linux_environment/Dragonfly/t32/3000
do linux-restart.cmm ${boot_args} pcie=0 fs_name=${os_drivel}/rtp_linux_environment/fs/kasi.cpio.gz cntfrq_scale=${cntfrq}" > ${cmm_path}/boot.${TYPE}.cmm

    ~/n_drive/CPUE_repo/firetail/T32_QDF3000/shortcuts/QDF3000_T32_Linux.sh -j `~/bin/query_host_t32`
}


###Scaling cpu frequency in RUMIs
##CAUTION: Be sure NOT to exceed the system clock speed (s1) of the VISR tag you loaded.
##(the CPU clock can generally be run well above the speed in the tag)

if [[ ${TYPE} == *"aw-rumi42"* ]]; then
    tag=$(echo ${tag_aw42} | cut -d" " -f 6)
    eval `echo "${tag}" | sed 's/.*sys\([0-9].[0-9]\)MHz.*/sysr=\1/p'`
    eval `echo "${tag}" | sed 's/.*cpu\([0-9]*.[0-9]\)MHz.*/cpur=\1/p'`

    #Scaling cpu frequency in RUMIs
    cpur_s=$(echo "scale=3; ${cpus_buss_ratio}*${sysr}" | bc)
    cpur_s=$(echo ${cpur_s} | xargs printf "%.*f\n" 1)

    #Slowing down time in RUMIs
    cntfrq_s=$(echo "scale=3; ${cpus}/${cpur_s}" | bc)
    cntfrq_s=$(echo ${cntfrq_s} | xargs printf "%.*f\n" 0)

    configure_aw_rumi42 ${cpur_s} ${sysr} ${cntfrq_s}
elif [[ ${TYPE} == *"aw-rumi48"* ]]; then
    tag=$(echo ${tag_aw48} | cut -d" " -f 6)
    eval `echo "${tag}" | sed 's/.*sys\([0-9].[0-9]\)MHz.*/sysr=\1/p'`
    eval `echo "${tag}" | sed 's/.*cpu\([0-9]*.[0-9]\)MHz.*/cpur=\1/p'`

    #Scaling cpu frequency in RUMIs
    cpur_s=$(echo "scale=3; ${cpus_buss_ratio}*${sysr}" | bc)
    cpur_s=$(echo ${cpur_s} | xargs printf "%.*f\n" 1)

    #Slowing down time in RUMIs
    cntfrq_s=$(echo "scale=3; ${cpus}/${cpur_s}" | bc)
    cntfrq_s=$(echo ${cntfrq_s} | xargs printf "%.*f\n" 0)

    configure_aw_rumi48 ${cpur_s} ${sysr} ${cntfrq_s}
elif  [[ ${TYPE} == *"ft-rumi42"* ]]; then
    tag=$(echo ${tag_ft42} | cut -d" " -f 6)
    eval `echo "${tag}" | sed 's/.*sys\([0-9].[0-9]\)MHz.*/sysr=\1/p'`
    eval `echo "${tag}" | sed 's/.*cpu\([0-9]*.[0-9]\)MHz.*/cpur=\1/p'`

    #Scaling cpu frequency in RUMIs
    cpur_s=$(echo "scale=3; ${cpus_buss_ratio}*${sysr}" | bc)
    cpur_s=$(echo ${cpur_s} | xargs printf "%.*f\n" 1)

    #Slowing down time in RUMIs
    cntfrq_s=$(echo "scale=3; ${cpus}/${cpur_s}" | bc)
    cntfrq_s=$(echo ${cntfrq_s} | xargs printf "%.*f\n" 0)

    configure_ft_rumi42 ${cpur_s} ${sysr} ${cntfrq_s}
elif  [[ ${TYPE} == *"ft-rumi48"* ]]; then
    tag=$(echo ${tag_ft48} | cut -d" " -f 6)
    eval `echo "${tag}" | sed 's/.*sys\([0-9].[0-9]\)MHz.*/sysr=\1/p'`
    eval `echo "${tag}" | sed 's/.*cpu\([0-9]*.[0-9]\)MHz.*/cpur=\1/p'`

    #Scaling cpu frequency in RUMIs
    cpur_s=$(echo "scale=3; ${cpus_buss_ratio}*${sysr}" | bc)
    cpur_s=$(echo ${cpur_s} | xargs printf "%.*f\n" 1)

    #Slowing down time in RUMIs
    cntfrq_s=$(echo "scale=3; ${cpus}/${cpur_s}" | bc)
    cntfrq_s=$(echo ${cntfrq_s} | xargs printf "%.*f\n" 0)

    configure_ft_rumi48 ${cpur_s} ${sysr} ${cntfrq_s}
fi


#Command to boot the RUMIs
echo "Type the following command in T32 aARM window"
echo "do ${cmm_path}/boot.${TYPE}.cmm"

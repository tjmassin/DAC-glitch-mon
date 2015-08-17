#!/bin/bash

start_time=$1
duration=$2
outdir=$3
trigger_dir=$4
ifo=$5

basedir="${outdir}/${start_time}_${duration}"

echo "Building directory structure at ${basedir}"

# Build directory structure and copy over executables from top level directory
mkdir -p ${basedir}
mkdir -p ${basedir}/condor_dag
mkdir -p ${basedir}/condor_dag/log_${start_time}_MCT

cp find_crossings_condor.py ${basedir}/condor_dag/find_crossings_condor.py
cp MCT_condor_exe ${basedir}/condor_dag/MCT_condor_exe

source /home/detchar/opt/gwpysoft/etc/gwpy-user-env.sh

# Find raw frames and generate list of MASTER_OUT channels
frame=`gw_data_find -n -o ${ifo} -t ${ifo}1_R -s ${start_time} -e ${start_time} -u file`
chan_list="all_SUS_MASTER_OUT_chans_${start_time}"

FrChannels ${frame} | grep 'SUS' | grep 'MASTER_OUT' | grep 'DQ' | cut -d ' ' -f 1 > ${basedir}/${chan_list}

echo "Wrote list of all SUS MASTER_OUT channels to file: ${chan_list}"

numchans=`wc -l ${basedir}/${chan_list} | cut -d ' ' -f 1`

# generate condor DAG and sub files
python make_sub_MCT.py ${basedir} ${start_time} ${duration} ${basedir}/${chan_list} ${ifo}1 ${trigger_dir}
python make_dag_MCT.py ${numchans} ${start_time} ${duration} ${basedir}



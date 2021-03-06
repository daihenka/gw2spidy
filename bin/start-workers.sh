#!/bin/bash

CNT=$1
LOGDIR="/var/log/gw2spidy"

if [ -z "$ROOT" ]; then
    ROOT=`php -r "echo dirname(dirname(realpath('$(pwd)/$0')));"`
    export ROOT
fi

if [[ -z "${CNT}" ]]; then
    CNT=1
fi

if [ ! -d "${LOGDIR}" ]; then 
    mkdir -p ${LOGDIR}
fi

if [ -d "${LOGDIR}/archive" ]; then
      rm -rf ${LOGDIR}/archive
fi

mkdir ${LOGDIR}/archive
mv ${LOGDIR}/*.log ${LOGDIR}/archive
rm -f ${LOGDIR}/*.log

for ((i = 0; i < CNT; i++)); do 
    if [[ -e /var/run/gw2spidy/worker-${i}.pid ]]; then
        PID=$(cat /var/run/gw2spidy/worker-${i}.pid)
                        
        if [ -e /proc/$PID -a /proc/$PID/exe ]; then
            echo "already running daemon number ${i}; [[ ${PID} ]]"
            continue
        fi
    fi
    
    echo "startin daemon number ${i}"
    
    ((${ROOT}/bin/worker.sh $i &>> ${LOGDIR}/start-workers.log) & echo $! > /var/run/gw2spidy/worker-${i}.pid &)
done
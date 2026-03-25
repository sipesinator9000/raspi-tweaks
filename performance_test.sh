#!/bin/bash

set -eo nounset

## Prompt the user to name the test
echo "Enter test name"
read TEST_NAME

## Create the log and logging directory
mkdir -p "${LOG_DIR:=$HOME/code/raspi-tweaks/logs}"
DATE=`date +"%Y-%m-%d"`
touch "${LOG:=$LOG_DIR/$DATE-$TEST_NAME.log}"

## Define some things
TIME=$(date +%T)
CPU_TEMP=$(vcgencmd measure_temp)
CPU_VOLTS=$(vcgencmd measure_volts)
THROTTLED=$(vcgencmd get_throttled)

## Create a header for the report
echo "===== Performance Report $TEST_NAME ======

$DATE
Test Name: $TEST_NAME
" >> $LOG

echo "Current max params
======================================="
for param in arm_freq gpu_freq core_freq sdram_freq over_voltage sdram_over_voltage; do
  echo "$param: $(vcgencmd get_config $param)"
done

=======================================
" >> $LOG

## Start temperature logging in the background
log_temperature() {
    while true; do
        echo "Time $(date +"%T"), CPU $(vcgencmd measure_temp), $(vcgencmd measure_volts), $(vcgencmd get_throttled), MEM $(free | awk '/^Mem/ {printf "%d%s",$3/$2*100,"%"}')" >> $LOG_FILE
        sleep 1
    done
}

echo "Starting temperature logging to $LOG..."
log_temperature &
LOGGER_PID=$!

## Log system information for 5 seconds before starting stress test
sleep 5

## Run sysbench test and append the output to the log file
echo "Running stress test..."
echo "
=== Stress test started at $(date) ===" >> $LOG
sysbench --test=cpu --cpu-max-prime=20000 --num-threads=4 run 2>&1 >> $LOG
STRESS_EXIT_CODE=$?
echo "=== Stress test finished at $(date) ===" >> $LOG

# Stop temperature logging
echo "Stopping temperature logging..."
kill $LOGGER_PID 2>/dev/null

echo "Performance test finished. Output saved to $LOG"

exit

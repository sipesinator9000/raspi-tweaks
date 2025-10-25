#!/bin/bash

set -eo nounset

## Ask the user to name the test
echo "Enter test name"
read TEST_NAME
mkdir -p logs
LOG_FILE=logs/$TEST_NAME.log

## Define some system params
CPU_CLOCK=`cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq`
CPU_CLOCK_MHZ=$(expr $CPU_CLOCK / 1000)
CPU_V=`vcgencmd measure_volts core`
SYSTEM_STATS=`vcgencmd get_config int | egrep "(arm|core|gpu|sdram)_freq|over_voltage|sdram_schmoo"`
DATE=`date +"%Y-%m-%d"`

LOG_FILE=logs/$DATE-$TEST_NAME.log

## Create a log file
touch $LOG_FILE
## Create a header for the report
echo "==== Performance Report $TEST_NAME ====

$DATE
Test Name: $TEST_NAME
" >> $LOG_FILE

## Add some test params to the top of the log
#echo "CPU Clock Speed: $CPU_CLOCK_MHZ Mhz" >> $LOG_FILE
#echo "CPU Voltage: $CPU_V volts" >> $LOG_FILE
echo "$SYSTEM_STATS

==================
" >> $LOG_FILE

## Start temperature logging in the background
log_temperature() {
    while true; do
        echo "Date $(date +"%d.%m.%y"), Time $(date +"%T"), CPU $(vcgencmd measure_temp), $(vcgencmd measure_volts), $(vcgencmd get_throttled), MEM $(free | awk '/^Mem/ {printf "%d%s",$3/$2*100,"%"}')" >> $LOG_FILE
        sleep 1
    done
}

echo "Starting temperature logging to $LOG_FILE..."
log_temperature &
LOGGER_PID=$!

## Run sysbench test and append the output to the log file
echo "Running stress test..."
echo "=== Stress test started at $(date) ===" >> $LOG_FILE
sysbench --test=cpu --cpu-max-prime=20000 --num-threads=4 run 2>&1 >> $LOG_FILE
STRESS_EXIT_CODE=$?
echo "=== Stress test finished at $(date) ===" >> $LOG_FILE

# Continue to log temperature for 5 more seconds
sleep 5s

# Stop temperature logging
echo "Stopping temperature logging..."
kill $LOGGER_PID 2>/dev/null

echo "Performance test finished. Output saved to $PWD/$LOG_FILE"

exit

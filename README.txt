This is a toolkit for setting up a Retropie system with my preferences.

Besides maybe things having to do with overclocking settings, these tweaks should be goo for all versions of RetroPie on all Raspberry Pi versions.

h2. Tool Installer
The install_tools script simply installs tools that I find useful. Some of these tools are necessary for running the performance_test script as well. The script also installs the GPiCase SafeShutdown script necessary for those using a RetroFlag Nespi case.


h2.Stress Testing
---

The performance_test runs a stress test with sysbench whilst logging basic temperature and voltage information during the test, as well as 5 seconds before and after the test. The user is asked to provide a log name when the command is run. The script outputs a report inside a logs folder that it creates, and displays the important bits of your test.

The stress test itself is simply asking all four CPU cores to factor prime numbers up to 15000.

```alex@retropie:~/raspi-tweaks $ cat /home/alex/raspi-tweaks/logs/performance_report_1400_mhz.log
==== 1400_mhz ====

CPU Clock Speed: 1400 Mhz

==================

Date 11.10.25, Time 17:36:47, CPU temp=25.7'C, volt=1.2250V, throttled=0x0, MEM 18%
...
Date 11.10.25, Time 17:36:51, CPU temp=25.7'C, volt=1.2250V, throttled=0x0, MEM 18%
=== Stress test started at Sat 11 Oct 17:36:52 BST 2025 ===
sysbench 0.4.12:  multi-threaded system evaluation benchmark

Running the test with following options:
Number of threads: 4

Doing CPU performance benchmark

Threads started!
Date 11.10.25, Time 17:36:52, CPU temp=25.7'C, volt=1.3250V, throttled=0x0, MEM 18%
Date 11.10.25, Time 17:36:53, CPU temp=26.8'C, volt=1.3250V, throttled=0x0, MEM 18%
...
Date 11.10.25, Time 17:37:45, CPU temp=29.5'C, volt=1.3250V, throttled=0x0, MEM 18%
Date 11.10.25, Time 17:37:46, CPU temp=28.9'C, volt=1.3250V, throttled=0x0, MEM 18%
Done.

Maximum prime number checked in CPU test: 15000


Test execution summary:
    total time:                          55.3473s
    total number of events:              10000
    total time taken by event execution: 221.3615
    per-request statistics:
         min:                                 21.67ms
         avg:                                 22.14ms
         max:                                 52.34ms
         approx.  95 percentile:              23.83ms

Threads fairness:
    events (avg/stddev):           2500.0000/3.08
    execution time (avg/stddev):   55.3404/0.00

=== Stress test finished at Sat 11 Oct 17:37:47 BST 2025 ===
Date 11.10.25, Time 17:37:47, CPU temp=29.5'C, volt=1.3250V, throttled=0x0, MEM 18%
...
Date 11.10.25, Time 17:37:52, CPU temp=27.9'C, volt=1.2250V, throttled=0x0, MEM 18%```


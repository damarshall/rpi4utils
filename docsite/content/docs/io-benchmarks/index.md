---
title: 'I/O Benchmarks'
date: 2019-02-11T19:27:37+10:00
weight: 6
summary: Parts sources and benchmark performance results for various USB3 drive configurations.
---

Credit for this benchmark goes to James Chambers and this [excellent Pi-oriented benchmark script](https://jamesachambers.com/raspberry-pi-storage-benchmarks-2019-benchmarking-script/).

We benchmarked the combinations detailed below. Overall the recommendation is a Kingston A400 SSD with an inexpensive SATA-to-USB-A cable which offers the best overall price-performance. A solid I/O rig is available for around $40 per node.

## Sandisk Ultra microSD 32GB
Available [here on Amazon](https://www.amazon.com/gp/product/B00CNYV942/ref=ppx_yo_dt_b_asin_title_o02_s01?ie=UTF8&psc=1) for about $14 for a 2-pack.

Scores a baseline 1,078 on the I/O benchmark:

![Sandisk Ultra SD benchmark](images/sandisk-ultra-sd-io-benchmark.png  "Sandisk Ultra SD benchmark")

We see read performance is adequate but the device performs poorly on random writes.
This is an excellent low-cost bootable microSD for experimental purposes.

## Sandisk Ultra Fit USB Flash Drive 128GB
Available [here on Amazon](https://www.amazon.com/SanDisk-128GB-Ultra-Flash-Drive/dp/B07855LJ99/ref=sr_1_1?crid=1QGB25GB7188T&keywords=sandisk+ultra+fit+128gb&qid=1565120868&s=gateway&sprefix=sandisk+ultra+fit%2Caps%2C175&sr=8-1) for about $18,

scores a better 1,393 on the I/O benchmark:

![Sandisk Ultra Fit](images/sandisk-ultra-usb-io-benchmark.png  "Sandisk Ultra Fit").

This is an interesting result. Read performance is a notch better than the microSD card, however random write performance is much worse.

## Kingston A400 2.5" SSD 120GB
This is device gives remarkably good I/O performance for a small price.
The 120GB drive is [available on Amazon](https://www.amazon.com/dp/B01N6JQS8C/ref=twister_B07Q8TL285?_encoding=UTF8&psc=1) . There's a 240GB version available for $10 more. You'll need a compatible USB 3 <-> SATA cable, and [this one from Startech](https://www.amazon.com/StarTech-com-SATA-USB-Cable-USB3S2SAT3CB/dp/B00HJZJI84/ref=sr_1_3?crid=9VR8VCHUUL00&keywords=startech+usb+sata+adapter&qid=1565121503&s=gateway&sprefix=startech+usb+sata+%2Celectronics%2C151&sr=8-3) works well for $10.

So this overall setup is $32 for 120GB or $42 for 240GB (adapter cable + SSD) and gives a credible 7,533 on the I/O benchmark:

![A400 benchmark](images/A400-io-benchmark.png  "A400 benchmark").

This drive delivers more than 9K IOPS on random writes and 15K IOPS on random reads with 4K blocks.

## WD Blue SN500 and SSK NVMe Enclosure
This was the highest performing and most expensive I/O combination tested.
The [250GB NVMe m.2 drive](https://www.amazon.com/Blue-SN500-500GB-NVMe-Internal/dp/B07PC59ZDV/ref=sr_1_2?crid=1AJVP7LC8WPYR&keywords=sn500%2Bwd%2Bblue&qid=1566135942&s=gateway&sprefix=sn500%2Caps%2C164&sr=8-2&th=1) is available at Amazon for $55. This is coupled with a [SSK NVMe m.2 drive enclosure](https://www.amazon.com/SSK-Aluminum-Enclosure-Adapter-External/dp/B07MNFH1PX/ref=sr_1_3?crid=1NBANNFW0S0VA&keywords=ssk+nvme+enclosure&qid=1566136043&s=gateway&sprefix=ssk+nvm%2Caps%2C161&sr=8-3) available on Amazon for $29.

You will need a good quality [USB-c to USB 3.1 cable](https://www.amazon.com/AmazonBasics-Type-C-Adapter-Charger-Cable/dp/B01GGKYS6E/ref=sr_1_3?keywords=usb-c+male+to+usb-a+male+cable&qid=1566136634&s=electronics&sr=1-3) ($10 on Amazon). I tested with a cheaper USB-C male to USB-A male adapter, supposedly 3.0 capable but got 1/10th the I/O throughput of the cable above when testing.



N.B. the drive supports USB3.1 and only comes with a short USB-C cable, so you will additionally need the USB-C male to USB-A male cable to connect. So all in this I/O rig is @ $94/node for 250GB.

![](images/wd500blue.jpg)

With a weighted performance rating of 7,912 on our I/O benchmark, it is the best tested, but it is not much better than a Kingston A400 available in a 250GB configuration for less than half the price.

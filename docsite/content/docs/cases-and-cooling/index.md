---
title: 'Cases and Cooling'
date: 2019-02-11T19:27:37+10:00
weight: 7
summary: Learn about heatsinks, fans and cases.
---

# Heatsinks
Installing heatsinks is not well documented. [This youtube video](https://www.youtube.com/watch?v=E-4GaAz7XNM) shows how to install the heatsinks provided from [Canakit](https://www.canakit.com/), a North-American Pi supplier.

# The Zebra Virtue Case
This case from [c4labs](https://www.c4labs.com/product/zebra-virtue-fan-case-raspberry-pi-3-b-color-options/) is an excellent layered case with a built-in interior fan which is acceptably loud (price $25).

![ZebraVirtueCase](images/ZebraVirtueCase.jpg)

With heatsinks installed and the case fan operating, a Pi 4 reports an operating temperature of around 38'C.

# The Cloudlet Case
This is another case from [c4labs](https://www.c4labs.com/product/8-slot-stackable-cluster-case-raspberry-pi-3b-and-other-single-board-computers-color-options/), this time it allows up to 8 Pi 4 boards to be installed in a cluster case.

In the picture below you can see 4 Pi4 boards, each with a Texas PoE HAT installed. To the right of the board you can see the two additional case fans.

![CloudletCase](images/c4labscloudletcase.jpg)

Operating temperatures, with the Texas PoE HATs installed are in the range of 44-49C.

# Measuring Board Temperature
You may measure the on-board temperature for your Pi 4 by issuing the following command:
```
vcgencmd measure_temp
```

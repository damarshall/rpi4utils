---
title: 'Bill of Materials'
date: 2019-09-20T19:27:37+10:00
weight: 5
summary: Here is a hardware parts list to build a Raspberry Pi 4 Cluster.
---
Here is a complete bill of materials for an 8-node cluster:


| Quantity | Part                                                                                            | Unit | Extended |
| -------- | ----------------------------------------------------------------------------------------------- | ---- | -------- |
|     1    | [Cloudlet case](https://www.amazon.com/CLOUDLET-CASE-Raspberry-Single-Computers/dp/B07D5NM9ZG/) |  $60 |      $60 |
|     8    | [4GB Raspberry Pi 4 Board](https://www.canakit.com/raspberry-pi-4-4gb.html)                     |  $55 |     $440 |
|     8    | [Heatsink set](https://www.canakit.com/raspberry-pi-4-heat-sinks.html)                          |   $5 |     $ 40 |
|     8    | [Sandisk 2x32GB MicroSD cards](https://www.amazon.com/gp/product/B00CNYV942/)                   |  $13 |      $96 |
|     8    | [Startech SATA USB3 cable](https://www.amazon.com/gp/product/B00HJZJI84/)                       |  $10 |      $80 |
|     8    | [Kingston 120GB A400 SATA SSD](https://www.amazon.com/gp/product/B01N6JQS8C/)                   |  $22 |     $176 |
|     8    | [PoE Texas GAF-PiHAT](https://www.amazon.com/gp/product/B07TVFFHVP/)                            |  $26 |     $208 |
|     2    | [Cat 6 Ethernet Cable 5 Pack](https://www.amazon.com/gp/product/B01JO3FM7Y/ref)                 |   $8 |      $16 |
|     1    | [YuanLey 8 Port Gigabit PoE Switch](https://www.amazon.com/gp/product/B0795MFCHZ/)              |  $88 |      $88 |
|     1    | [MicroSD card organizer](https://www.amazon.com/gp/product/B006J73IZM/)                         |   $7 |       $7 |
|     1    | [Sandisk 16GB Cruzer Fit USB Flash Drive](https://www.amazon.com/dp/B07MDXBT87)                 |   $6 |       $6 |


The total cost (before shipping) is $1,217.

The USB flash drive is for cloud-init, so you can configure your cluster easily.

The MicroSD card organizer is a nice touch, allows you to organize and keep spares handy. I've recommended doubling up on
the MicroSD cards (the Sandisk 2x32GB cards are 2-packs) as a spare for each node will be useful during upgrades.

## PoE Switch

The YuanLey gigabit PoE switch is a cheap and cheerful unmanaged switch providing 120W total PoE across 8 ports. 
It also has 2 gigabit uplink ports and a backplane that will support 22gbps throughput. 

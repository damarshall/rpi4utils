# Bootstrapping with cloud-init
Cloud vendors and popular distributions use `cloud-init` scripts to perform actions on first boot such as:

- supply a hostname
- supply a network config (beyond DHCP)
- configure the default user
- install additional repos and packages

We will leverage this strategy for a standard repeatable configuration of our Pi 4 leaving it in a well-known state amenable to further automation.

As a Raspberry Pi is a bare-metal device with no lights out management we will supply our `cloud-init` data using the ''nocloud' strategy. This is done by creating a small vfat parition on a USB flashdrive with a volume name of 'cidata'. On first boot, `cloud-init` searches for a mountable partition with a volume name of 'cidata' and if found, it will read well-known filenames found and use them as datasources for customization.

# Preparing the USB Flashdrive cidata volume
All we need is a VFAT formatted volume named 'cidata' that can be found and mounted at first boot.
We do this by using a USB flashdrive. You can use any thumbdrive to do this, it doesn't need to be expensive or have good performance. Here's an inexpensive [Sandisk 32GB Cruzer Fit USB flash drive](https://www.amazon.com/SanDisk-32GB-Cruzer-Flash-Drive/dp/B07MPCJDXS/ref=sr_1_20?keywords=sandisk+usb+thumb+drive+8gb&qid=1565535563&s=gateway&sr=8-20) only $5 on Amazon.

Reformat it, create a single 32MB (minimal size) VFAT volume named 'cidata'. You can use a tool such as `gparted` to do this simply and quickly. N.B. there should only be a single partition on the flash drive (this is important later when bootstrapping a new Pi 4 with USB3 root drive).

Copy the contents of the cloud directory into the root directory on the 'cidata' partition you created. The sections below describe the content in detail. When you boot for the first time, ensure the thumbdrive is in a USB3 slot and the microSD card has the modified Ubuntu image.


# Example Script content
### meta-data

The `meta-data` file contains [instance metadata](https://cloudinit.readthedocs.io/en/latest/topics/instancedata.html) generally of interest to cloud operators. In our minimal pi 4 installation we will use it to create an instance-id and to set the hostname.

```
instance_id: marshall2019080901
local-hostname: dm1.pi
```

### network-config

We configure networking via `network-config`. Here we use v2 syntax which used the [netplan](https://netplan.io/) method of network configuration (preferred method in Ubuntu Bionic and later).

In the example below we set a static IP address, gateway and configure DNS. The `cloud-init` scripts take care of turning this into the appropriate `netplan` configuration files.

```
version: 2
ethernets:
  # opaque ID for physical interfaces, only referred to by other stanzas
  eth0:
    match:
      macaddress: dc:a6:32:09:21:b1
    set-name: eth0
    dhcp4: false
    addresses:
      - 192.168.25.71/24
    gateway4: 192.168.25.1
    nameservers:
      search: [dm.local]
      addresses: [1.1.1.1,2.2.2.2]

```

### user-data
The instructions in `user-data` run late in the boot cycle, equivalent to `rc.local`. We use this file to set a password on the default 'ubuntu' account. We also tell `apt` to hold updates on kernel-related packages as the official Ubuntu repos will overwrite the pi 4 firmware we prepared for our image. Once pi 4 is officially supported we will be able to unhold these packages, but until then we are frozen with this kernel.

We also add an `apt` repository for Raspberry-Pi utilities such as the important `vcgencmd` (e.g. you can measure temperature via the command `vcgencmd measure_temp`).

Finally, we clone a simple git repository and use the script to set `dircolors` making our directory listings readable on a console.

```
#cloud-config
password: Welcome2ACI!
chpasswd: { expire: False }
ssh_pwauth: True

# run commands
# default: none
# runcmd contains a list of either lists or a string
# each item will be executed in order at rc.local like level with
# output to the console
# - runcmd only runs during the first boot
# - if the item is a list, the items will be properly executed as if
#   passed to execve(3) (with the first arg as the command).
# - if the item is a string, it will be simply written to the file and
#   will be interpreted by 'sh'
#
# Note, that the list has to be proper yaml, so you have to quote
# any characters yaml would eat (':' can be problematic)
runcmd:
# hold kernel updates and rpi firmware distributed by Ubuntu, it's not pi 4 compatible yet
 - [ apt-mark, hold, linux-firmware-raspi2, linux-headers-4.15.0-1041-raspi2, linux-headers-raspi2, linux-image-4.15.0-1041-raspi2, linux-image-raspi2, linux-modules-4.15.0-1041-raspi2, linux-raspi2, linux-raspi2-headers-4.15.0-1041 ]
# install essential pi tools so you can run commands like 'vcgencmd measure_temp'
 - [ add-apt-repository, -y, "ppa:ubuntu-raspi2/ppa" ]
 - [ apt-get, install, -y, libraspberrypi-bin ]
 # Note: Don't write files to /tmp from cloud-init use /run/somedir instead.
 # Early boot environments can race systemd-tmpfiles-clean LP: #1707222.
 #
 # make directory listings legible and readable
 - [ git, clone, "https://github.com/huyz/dircolors-solarized", /home/ubuntu/dircolors-solarized ]
 - [ ln, -s, /home/ubuntu/dircolors-solarized/dircolors.ansi-universal, /home/ubuntu/.dircolors ]

```

## Bugs / Limitations
We must find the MAC address for the Pi 4's onboard GiG ethernet port by booting with another image supporting DHCP. Once known, an appropriate `user-data` datasource can be generated.

## ToDo
- write templates for `network-config`, `user-data` and `meta-data`
- write a generator that can generate instances from templates using a simple datasource such as a `.csv` for variables
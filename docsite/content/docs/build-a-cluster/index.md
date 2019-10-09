---
title: 'Building a Cluster'
date: 2019-09-23T19:27:37+10:00
weight: 3
summary: Image, build and verify a cluster in 8 steps
---

# Building our Cluster - Step by Step Guide

Here we'll walk through the pre-requisites and then build to go from zero to 
[PLONK](https://www.openfaas.com/blog/plonk-stack/) over Ubuntu 18.04.3 (arm64) on RPi 4, 
in 8 steps.

## Pre-requisites

Let's take care of a few setup steps before we take on the actual cluster build.
First we assume operation from a `bash` command-line. Much of this can be done
from any full `bash` environment such as [git bash for Windows](https://gitforwindows.org/).
A full Ubuntu environment is needed for the last step and some operations 
but you can perform many of the steps from any `bash` environment, 
including day-to-day operation of your cluster.

### pre-1: Generate SSH Key

Several of the utilities require we have a public SSH key installed on all nodes
so we can operate like cattle. To generate an SSH key, perform the following steps:

```
ssh-keygen
```

When prompted for a passphrase just hit [Enter] for an empty passphrase.
We'll use this later in the build and for day-to-day cluster operations.

### pre-2: Network planning

Assign a block of hostnames for our cluster. For illustration purposes we'll
assume we are going to have an 8 node cluster with nodes having hostnames in the
range `pi1...pi8`. It's helpful to have an additional non-clustered console
node, so let's reserve `pi9` for that.

We're going to need a small static IPv4 block reachable from our local network.
We'll assign one address to each cluster node as well as a block of addresses
we reserve for the `metallb` load-balancer to automatically assign to external services.

This block should be reserved for cluster purposes and should not intersect with
DHCP-assigned address ranges. For illustration, let's assume our local network
operates on `192.168.1.0/24` and the 32 address block `192.168.1.128/27` is reserved
for the cluster we are building.

For convention, it's helpful to match node hostnames with IP addresses, so we'll use
addresses as follows:

| hostname | node IP       |
| -------- | ------------- |
| pi1      | 192.168.1.131 |
| pi2      | 192.168.1.132 |
| pi3      | 192.168.1.133 |
| pi4      | 192.168.1.134 |
| pi5      | 192.168.1.135 |
| pi6      | 192.168.1.136 |
| pi7      | 192.168.1.137 |
| pi8      | 192.168.1.138 |
| pi9      | 192.168.1.139 |

We'll reserve the range 192.168.1.140-192.168.1.155 for `metallb`.

### pre-3: Get `rpi4utils` and prep local config files

If not haven't done so already, install `git` in the terminal environment.
If this is a new installation be sure to set up initial configuration:

```
git config --global user.name "John Doe"
git config --global user.email johndoe@example.com
git config --global core.editor vim
# Set git to use the credential memory cache
git config --global credential.helper cache
# Set the cache to timeout after 1 hour (setting is in seconds)
git config --global credential.helper 'cache --timeout=3600'
```

Clone the `rpi4utils` project. We recommend having this in one level down
from the home directory.

```
cd ~
git clone https://github.com/damarshall/rpi4utils.git
cd rpi4utils
```

For the majority of our work we'll be in `rpi4utils` or one of its subdirectories.

Now let's set up our __rpicluster.csv__ data source (used by some utilities).
This CSV file holds data about our cluster, one row per node and is used to generate templates 
for `cloud-init` and hostfile entries on nodes.

To determine the MAC address for each node we will have to boot the node (perhaps with Raspbian), 
ping it and look at the ARP table. For now just leave the MAC column blank. (Once the cluster
is operational we can retrieve all MAC addresses at once via `rpic mac`).

Edit the __rpicluster.csv__ file and fill out _hostname_ and _publicip_. We can leave _mac_ and _clusterip_
columns blank for now:

```
cp conf/rpicluster.csv.sample rpicluster.csv
vim rpicluster.csv
```

The columns in the cluster data CSV are as follows:

| Column    | Purpose |
| --------- | -------------------------------------------------------- |
| mac       | The MAC address for the nodes 1gbps NIC                  |
| hostname  | The hostname for the node                                |
| publicip  | The IP address on our local (v)LAN for the node          |
| clusterip | The IP address on a private /24 accessible intra-cluster |

### pre-4: Prepare a `cidata` flashdrive for cloud-init

We are going to use [`cloud-init`](https://cloudinit.readthedocs.io/en/latest/) in 'no-cloud' mode
to bootstrap nodes in our cluster. Ubuntu will automatically search for an attached volume with the name 'cidata'
and if found, will use the seed data it contains to boostrap a node. (In a cloud environment the same thing is
achieved with an http(s) data source).

We need a VFAT formatted volume named __cidata__ that can be found and mounted at first boot. 
We do this by using a USB flashdrive. We can use any thumbdrive to do this, it doesn't need to be expensive 
or have good performance. See the bill-of-materials for an inexpensive option.

Reformat it, create a single 32MB (minimal size) VFAT volume named __cidata__. 
We can use a tool such as `gparted` to do this simply and quickly. 
N.B. there should only be a single partition on the flash drive 
(this is important later when bootstrapping a new Pi 4 with USB3 root drive).

Copy the contents of the cloud directory into the root directory on the __cidata__ partition you created. 
The sections below describe the content in detail. 
When booting for the first time, ensure the thumbdrive is in a USB3 slot and a microSD card has our Ubuntu image.

```
# Let's assume our flashdrive is on the device /dev/sda
gparted /dev/sda
# mount the flashdrive once the single VFAT partition is created
# copy the sample seed data files from cloud/seed into the root directory of your CIDATA flash drive
```
Edit the seed data files on the CIDATA volume in preparation for the first node:

- change _local-hostname:_ in __meta-data__ to reflect the name for our first node
- change *instance_id:* in __meta-data__ to reflect a unique value
- change _addresses:_ in __network-config__ to reflect the values selected above
- ensure _gateway4:_ in __network-config__ is valid for our network
- change _password:_ in __user-data__ to reflect the password you want to use for the ubuntu user
- add the key generated via `ssh-keygen` in step [pre-1](#pre-1-generate-ssh-key) to __user-data__

Do this by replacing the corresponding section in __user-data__ (shown below, leave the '-' in place, 
replace the remainder of the line from 'ssh-rsa' onward)
with the content of your public key (contents of __~/.ssh/id_rsa.pub__):

```
# add each entry to ~/.ssh/authorized_keys for the configured user or the
# first user defined in the user definition directive.
ssh_authorized_keys:
  - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDyHu7LDlT6NH6Zo+jvrJszDlsMECwTljRvqRKoW6RKQJkVYQYsSnhlq8XQloTico4DkqFoHj1F41vnFcSnwARe/3yzrJ8aLIlTTNOLRcEbzrYA2KTiJK4NypDUMEBEZLaW1utb5r7vPy1NGnd7zHtf7o9xwVjbfUrCXd3fi8yBTm33C6qtm1XWADFg4q9qhVIFOvQ3QcdqpyI3ssrsvWuuyRm3jx9j7f1iq0q0XRCpLgQkWrLcGiAwGGrTTbBShGtcUoQ4i1rIpANtcQD7Y0DHsjpdt2qejvqOBJNWH+Czp/k4148NPXH17RmkhWeQKomjQ9GrGHCe4h58zKfE8aOV marshalld@NAPSL-R90GF6LY

```

### pre-5: Install Balena Etcher and download Ubuntu image

Download and install [Balena Etcher](https://www.balena.io/etcher/) - this is the tool
we will use to image microSD cards and SSD drives.

Download the current recommended arm64 Ubuntu image and save locally. 
We will find a link to the recommended image(s) at the bottom of the
'preparing-an-image' page.

N.B. the image above is built for USB3 root. At present RPi 4 firmware does not boot
USB3 directly (a feature that will be added in future). We will have to copy the image
onto both a microSD card and a USB3 drive and ensure both are present at boot time.
The RPi 4 board will perform the initial portion of the boot from the microSD card, 
however it will mount the USB3 drive as root, operating much faster. The same image
is designed to be imaged onto both the microSD card and the USB3 drive.

## Build Steps

Now that all the pre-requisites are in place we go through the following steps
to build the cluster. For steps 1 and 2, we recommend performing them one node at a time,
coming back and adding each additional node when the previous one is verified.

We recommend using a label-maker (this [Dymo LM160](https://www.amazon.com/DYMO-LabelManager-Handheld-Label-1790415/dp/B005X9VZ70) is an inexpensive choice that works well) to add hostname labels to:

- the ethernet port on each RPi 4 board (visible from the top of the cloudlet case)
- the microSD card to be inserted into the slot for a given node
- the SSD associated with a given node

This allows us to disassemble/reassemble your cluster without having to reimage.

### Step 1: Image and Boot a Node

If this is our 2nd or subsequent node, repeat the edits in step [pre-4](#pre-4-prepare-a-cidata-flashdrive-for-cloud-init) to
reflect the hostname and IP address for the node we are working on.

- add physical node labels to the microSD card and SSD card
- use Balena Etcher to image the microSD with the image from step [pre-5](#pre-5-install-balena-etcher-and-download-ubuntu-image)
- use Balena Etcher to image the USB3 SSD drive with the image from step [pre-5](#pre-5-install-balena-etcher-and-download-ubuntu-image)
- add the physical node label to the top edge of the RPi ethernet port
- put the microSD card in the microSD slot
- put the CIDATA cloud init flashdrive in one USB3 slot
- put the SSD drive cable in the other USB3 slot (order does not matter)
- power up the node 

First boot will take a little longer as `cloud-init` needs to run.
Allow 3 or 4 minutes for the 1st boot - subsequent boots take seconds.

If we have an extra RPi 4 with an attached monitor it is useful to perform the 
1st boot on that hardware. This allows us to inspect the boot output and 
`cloud-init` output.

### Step 2: Verify a Node

- ping the node with the IP address from the `cloud-init network-config` file
- ssh into the node to ensure passphrase free operation `ssh ubuntu@hostname`. As this is the first time we log into the node you will be prompted to add the host to your `known_hosts' file
- append the node name to the `RPNODES` list in our `~/.rpicrc` file (make sure there is a single space between subsequent entries)
- verify the node responds with the rest of the cluster with a simple command such as `rpic temp`

If this is the first node, create the `~/.rpicrc` file by copying from the
sample provided and then editing:

```
cp conf/.rpicrc.sample ~/.rpicrc
vim ~/.rpicrc
```

Generally we will not need to change the value of `RPUSER`.
For the `RPNODES` list, ensure it only contains a space separated list
of nodes you have verified.

At this stage we can operate on our herd of nodes ([cattle, not pets](http://cloudscaling.com/blog/cloud-computing/the-history-of-pets-vs-cattle/))
with the `rpic` command. 

```
rpic temp
```

Try `rpic help` for a list of sub-commands.
One very important sub-command is `rpic shutdown` for a clean cluster shutdown.

### Step 3: PLONK

`rpi4utils` contains scripts to install and configure PLONK on our cluster.
With all the steps so far, we've been able to operate from a general `bash`
command line. This step has only been verified on Ubuntu.

Begin by using the wrapper around `k3sup` to install a no-frills cluster.

```
./k3sinstall
```

The script will download and install `k3sup` and `kubectl` if they are
not already installed on our controller environment. 

The 1st node in the `$RPNODES` list will be configured as the Kubernetes master,
other nodes in the list will be configured as agent workers.

A `kubeconfig` file is created in the `rpi4utils` directory. If you operate
`kubectl` from here it will pick up that configuration by default.

Verify your cluster is up and running with:

```
kubectl get node
```

or if you have a wide terminal, try:

```
kubectl get node -o wide
```
Now we are ready to install additional software in our cluster:

- `metrics-server`
- the Kubernetes dashboard
- the `metallb` load balancer
- the `ingress-nginx` ingress controller
- `helm` and `tiller` to allow us to deploy components via Charts

First you'll have to edit `conf/metallb/config.yaml` and update
addresses to reference the range reserved in step [pre-2](#pre-2-network-planning).

```
vim conf/metallb/config.yaml
```

Now we are ready to perform the installation via the script:

```
./ktoolsinstall
```

Ensure `tiller` has deployed successfully and is available before continuing.

Now we are ready to deploy OpenFaaS:

```
ofinstall
```

Admin creds are copied into the file `ofcreds.txt` in the local directory.
Alternatively, you can set up values in advance in your `~/.rpicrc` file -
simply create and populate the variables _$OFUSER_ and _$OFPASSWD_ exist
before running `ofinstall`.

OpenFaaS `gateway-external` is exposed on port 8080 on an external IP
address assigned by `metallb`. You can find the details with the command:

```
kubectl describe svc gateway-external -n openfaas
```

For a quick verification, you can log into the OpenFaaS UI and deploy
a function from the function store and invoke it.

Go to `https://{externalip}:8080/ui` in your browser. You will be prompted
for a basic-auth login. Use the credentials from `ofcreds.txt` or pre-created
in `~/.rpicrc`.

You can check on OpenFaaS readiness via the script `ofcheck`.

Finally, we need to mesh the _openfaas_ namespace  with linkerd. Simply run:

```
meshup
```

Have patience, it can take several minutes. Once the deployments are all 
complete, access the linkerd webui via:

```
linkerd dashboard &
```

Refer to OpenFaaS tutorials and documentation to proceed from here.

And there you have it, zero to PLONK in 8 steps.

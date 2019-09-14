# Configuration Files
## .rpicrc
This file holds default values used by `rpic` and other utilities.
Copy the sample `.rpicrc`into your home directory and edit with local values as appropriate:
```
cp ./.rpicrc.sample ~/.rpicrc
vim .rpicrc
```


## rpicluster.csv
This CSV file holds data about your cluster, one row per node and is used to generate templates for `cloud-init` and hostfile entries on nodes.


# Creating Cluster host entries
Here's how to update the cluster `/etc/hosts`file on each node with entries for all nodes in the cluster. The awk script `genhostentries.awk` will parse your `rpicluster.csv` and generate a script that will update an `/etc/hosts` file.

To generate the script and then apply the entries across the cluster, use these two commands:

```
cat rpicluster.csv | ./genhostentries.awk > updatehosts.sh
rpic suexec updatehosts.sh
```
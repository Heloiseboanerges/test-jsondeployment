# SLES activation
SUSEConnect -r EA18E064F5CBC3A3 -e heloiseboanerges@hotmail.com
SUSEConnect --status

# patching
zypper --quiet patch -y --updatestack-only
zypper --non-interactive --quiet patch -y --category security

#installation of the necessary components
zypper install -y socat
zypper install -y resource-agents

# Change the DefaultTasksMax
tasks=$(cat /etc/systemd/system.conf | grep DefaultTasksMax=)
sudo sed -i "s/$tasks/DefaultTasksMax=4096/g" /etc/systemd/system.conf
systemctl daemon-reload
# test if the change was successful
systemctl --no-pager show | grep DefaultTasksMax

# Reduce the size of the dirty cache
dirty=$(cat /proc/sys/vm/dirty_bytes)
$dirty
sudo echo 629145600 > /proc/sys/vm/dirty_bytes
dirty=$(cat /proc/sys/vm/dirty_bytes)
$dirty

# Reduce the size of the dirty background
dirty_background=$(cat /proc/sys/vm/dirty_background_bytes)
$dirty_background
sudo echo 314572800 > /proc/sys/vm/dirty_background_bytes
dirty_background=$(cat /proc/sys/vm/dirty_background_bytes)
$dirty_background

# Change the configuration file for the network interface to prevent the cloud network plugin from removing the virtual IP address
NIC=$(cat /etc/sysconfig/network/ifcfg-eth0 | grep CLOUD_NETCONFIG_MANAGE=)
sudo sed -i "s/$NIC/CLOUD_NETCONFIG_MANAGE="no"/g" /etc/sysconfig/network/ifcfg-eth0

# generating a new key pair for the VMs
sudo ssh-keygen -t rsa -N '' -f /root/.ssh/id_rsa <<< y
# hay que encontrar una forma de copiar la clave en las "authorized keys"

# Setup host name resolution using /etc/hosts file
# IP address and hostname of the first cluster node
echo "192.168.0.10 pacemaker1" >> /etc/hosts
# IP address and hostname of the second cluster node
echo "192.168.0.11 pacemaker2" >> /etc/hosts

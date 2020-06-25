SUSEConnect -r EA18E064F5CBC3A3 -e heloiseboanerges@hotmail.com
SUSEConnect --status
zypper --quiet patch -y --updatestack-only
zypper --non-interactive --quiet patch -y --category security

zypper install -y socat
zypper install -y resource-agents
tasks=$(cat /etc/systemd/system.conf | grep DefaultTasksMax=)
sudo sed -i "s/$tasks/DefaultTasksMax=4096/g" /etc/systemd/system.conf
systemctl daemon-reload
systemctl --no-pager show | grep DefaultTasksMax

dirty=$(cat /etc/sysconfig/network/ifcfg-eth0 | grep CLOUD_NETCONFIG_MANAGE=)
sudo sed -i "s/$dirty/CLOUD_NETCONFIG_MANAGE="no"/g" /etc/sysconfig/network/ifcfg-eth0